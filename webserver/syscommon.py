"""
syscommon.py
============
Pure-Python reimplementation of the Moxa firmware's libsyscommon IPC layer,
specifically the functions used by the GoAhead web server to query the config
daemon for structured data.

Reverse-engineered from:
  net_Web_CTL_Send_And_Recv_Datastruct_Info  (MSG_STRUCT_INFO = 5)
  net_Web_CTL_Send_And_Recv_Data             (MSG_CTL = 0)
  net_Web_CTL_Send_And_Recv_Table_Info       (MSG_TABLE_COUNT = 3 + MSG_TABLE_DATA = 4)
  net_SendToInterface / net_RecvFromInterface1
  net_Web_SendData

Wire constants (from moxa_ipc.py reverse-engineering):
  Socket send path : "socket/magic168-socket"   (unk_22A464, initialized in main())
  Socket recv path : "socket/webs-Recv"          (unk_22A3D4, initialized in main())

Cross-platform (Linux + Windows)
---------------------------------
On Linux  : uses real AF_UNIX SOCK_DGRAM sockets (authentic firmware behaviour).
On Windows: uses a TCP loopback proxy (127.0.0.1:MOXA_TCP_PORT) because AF_UNIX
            SOCK_DGRAM is not fully supported on Windows.  The proxy framing adds
            a 4-byte LE length prefix so multiple datagrams can share one TCP
            stream.  A MoxaTcpProxy server thread is automatically started on
            first use if running on Windows.

Usage
-----
    from syscommon import SysCommon

    sc = SysCommon()

    # Datastruct info: returns (item_size, item_count) for a ctl_id
    item_size, item_count = sc.get_datastruct_info(ctl_id)

    # Get all data rows for a ctl_id
    buf = bytearray(item_size * item_count)
    sc.get_data(ctl_id, buf)

    # Get field descriptors for a ctl_id
    field_descs = sc.get_table_info(ctl_id)
    # Each descriptor: {'type': int, 'size': int, 'name': str, 'count': int, 'offset': int}

    sc.close()

Field descriptor wire format (100 bytes per field, from IDA analysis of
net_Web_CTL_Send_And_Recv_Table_Info responses):
    +0   field_type   (uint32 LE)
    +4   field_size   (uint32 LE)
    +8   field_name   (null-terminated ASCII, 64 bytes)
    +40  field_count  (uint32 LE)   -- actually at offset 40 from field start
    +44  field_offset (uint32 LE)   -- byte offset within struct row
"""

import os
import sys
import struct
import socket
import threading
import logging
import time
from typing import List, Dict, Optional, Tuple

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Platform detection
# ---------------------------------------------------------------------------
IS_WINDOWS = sys.platform == "win32"

# TCP proxy port used on Windows (loopback only)
MOXA_TCP_PORT = 17680

# Packet size matching the firmware (0x100C = 4108 bytes)
PACKET_SIZE    = 0x100C
PAYLOAD_OFFSET = 12

# Message type codes (from moxa_ipc.py protocol doc)
MSG_CTL          = 0
MSG_SEND         = 1
MSG_SEND_RECV    = 2
MSG_TABLE_COUNT  = 3
MSG_TABLE_DATA   = 4
MSG_STRUCT_INFO  = 5
MSG_SEND_CONFIRM = 7

# Socket path names (from main() in the firmware binary)
SEND_SOCK_NAME = "socket/magic168-socket"   # unk_22A464
RECV_SOCK_NAME = "socket/webs-Recv"         # unk_22A3D4

# Field descriptor layout within TABLE_INFO responses
FIELD_DESC_SIZE   = 100   # bytes per field descriptor
FIELD_TYPE_OFF    = 0
FIELD_SIZE_OFF    = 4
FIELD_NAME_OFF    = 8
FIELD_NAME_LEN    = 32    # null-terminated within 32 bytes
FIELD_COUNT_OFF   = 40
FIELD_OFFSET_OFF  = 44

# ---------------------------------------------------------------------------
# Packet helpers (shared with moxa_ipc.py protocol)
# ---------------------------------------------------------------------------

def _build_packet(seq: int, msg_type: int, cmd_id: int,
                  count: int, more: int, item_size: int,
                  payload: bytes, magic: int = 0) -> bytes:
    pkt = bytearray(PACKET_SIZE)
    pkt[0] = seq & 0xFF
    pkt[1] = msg_type & 0xFF
    pkt[2] = cmd_id & 0xFF
    pkt[3] = count & 0xFF
    pkt[4] = more & 0xFF
    pkt[7] = magic & 0xFF
    struct.pack_into("<I", pkt, 8, item_size)
    pkt[PAYLOAD_OFFSET:PAYLOAD_OFFSET + len(payload)] = payload[:PACKET_SIZE - PAYLOAD_OFFSET]
    return bytes(pkt)


def _parse_packet(data: bytes) -> dict:
    if len(data) < PAYLOAD_OFFSET:
        raise ValueError("Packet too short: %d bytes" % len(data))
    return {
        "seq":       data[0],
        "msg_type":  data[1],
        "cmd_id":    data[2],
        "count":     data[3],
        "more":      data[4],
        "magic":     data[7] if len(data) > 7 else 0,
        "item_size": struct.unpack_from("<I", data, 8)[0] if len(data) >= 12 else 0,
        "payload":   data[PAYLOAD_OFFSET:],
    }


# ---------------------------------------------------------------------------
# Transport abstraction (Unix socket / TCP proxy)
# ---------------------------------------------------------------------------

class _UnixTransport:
    """AF_UNIX SOCK_DGRAM transport : Linux / macOS."""

    def __init__(self, send_path: str, recv_path: str,
                 timeout: float = 10.0):
        self._send_path = send_path
        self._recv_path = recv_path
        self._timeout   = timeout
        self._sock: Optional[socket.socket] = None

    def open(self):
        self._sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        # Bind to a unique receive path so responses come back to us
        try:
            os.unlink(self._recv_path)
        except FileNotFoundError:
            pass
        os.makedirs(os.path.dirname(self._recv_path), exist_ok=True)
        self._sock.bind(self._recv_path)
        self._sock.settimeout(self._timeout)

    def close(self):
        if self._sock:
            try:
                self._sock.close()
            except Exception:
                pass
            self._sock = None
        try:
            os.unlink(self._recv_path)
        except Exception:
            pass

    def send(self, data: bytes) -> int:
        return self._sock.sendto(data, self._send_path)

    def recv(self) -> bytes:
        data, _ = self._sock.recvfrom(PACKET_SIZE)
        return data


class _TcpProxyTransport:
    """
    TCP loopback transport for Windows.

    Frames each datagram with a 4-byte LE length prefix so that multiple
    packets can share one TCP stream.  A background proxy thread bridges
    between the TCP connection and a real AF_UNIX socket if available, or
    emulates the daemon response directly via a built-in MoxaDaemonStub.
    """

    _proxy_started = False
    _proxy_lock    = threading.Lock()

    def __init__(self, timeout: float = 10.0):
        self._timeout = timeout
        self._conn: Optional[socket.socket] = None
        self._ensure_proxy()

    @classmethod
    def _ensure_proxy(cls):
        with cls._proxy_lock:
            if not cls._proxy_started:
                t = threading.Thread(target=cls._proxy_server,
                                     name="MoxaTcpProxy", daemon=True)
                t.start()
                cls._proxy_started = True
                time.sleep(0.05)   # let the server bind

    @staticmethod
    def _proxy_server():
        """
        Minimal TCP server that accepts connections and routes MOXA IPC
        requests to MoxaDaemonStub (no real daemon available on Windows).
        """
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            srv.bind(("127.0.0.1", MOXA_TCP_PORT))
        except OSError as e:
            logger.warning("MoxaTcpProxy bind failed: %s", e)
            return
        srv.listen(4)
        stub = MoxaDaemonStub()
        while True:
            try:
                conn, _ = srv.accept()
                t = threading.Thread(
                    target=_TcpProxyTransport._handle_client,
                    args=(conn, stub), daemon=True)
                t.start()
            except Exception as e:
                logger.debug("proxy accept: %s", e)
                break

    @staticmethod
    def _handle_client(conn: socket.socket, stub):
        try:
            conn.settimeout(30.0)
            while True:
                # Read 4-byte length prefix
                hdr = _TcpProxyTransport._tcp_recv_exact(conn, 4)
                if not hdr:
                    break
                length = struct.unpack("<I", hdr)[0]
                data   = _TcpProxyTransport._tcp_recv_exact(conn, length)
                if not data:
                    break
                pkt    = _parse_packet(data)
                reply  = stub.handle(pkt)
                if reply:
                    framed = struct.pack("<I", len(reply)) + reply
                    conn.sendall(framed)
        except Exception as e:
            logger.debug("proxy client: %s", e)
        finally:
            conn.close()

    @staticmethod
    def _tcp_recv_exact(conn: socket.socket, n: int) -> Optional[bytes]:
        buf = b""
        while len(buf) < n:
            chunk = conn.recv(n - len(buf))
            if not chunk:
                return None
            buf += chunk
        return buf

    def open(self):
        self._conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self._conn.settimeout(self._timeout)
        self._conn.connect(("127.0.0.1", MOXA_TCP_PORT))

    def close(self):
        if self._conn:
            try:
                self._conn.close()
            except Exception:
                pass
            self._conn = None

    def send(self, data: bytes) -> int:
        framed = struct.pack("<I", len(data)) + data
        self._conn.sendall(framed)
        return len(data)

    def recv(self) -> bytes:
        hdr  = self._tcp_recv_exact(self._conn, 4)
        if not hdr:
            raise OSError("Connection closed")
        n    = struct.unpack("<I", hdr)[0]
        data = self._tcp_recv_exact(self._conn, n)
        if not data:
            raise OSError("Connection closed")
        return data


# ---------------------------------------------------------------------------
# Daemon stub (used on Windows or for unit-testing without a real device)
# ---------------------------------------------------------------------------

class MoxaDaemonStub:
    """
    Emulates the Moxa config daemon responses in-process.
    Used by the TCP proxy on Windows, or directly for unit tests.

    Responses are built from a simple in-memory state dict.
    Override _get_rows() and _get_fields() to plug in real data sources.
    """

    def handle(self, pkt: dict) -> Optional[bytes]:
        msg_type = pkt["msg_type"]
        cmd_id   = pkt["cmd_id"]
        seq      = pkt["seq"]

        if msg_type == MSG_STRUCT_INFO:
            return self._handle_struct_info(seq, cmd_id)
        elif msg_type == MSG_CTL:
            return self._handle_ctl_data(seq, cmd_id)
        elif msg_type == MSG_TABLE_COUNT:
            return self._handle_table_count(seq, cmd_id)
        elif msg_type == MSG_TABLE_DATA:
            return self._handle_table_data(seq, cmd_id)
        return None

    # overrideable hooks                                                 

    def _get_rows(self, cmd_id: int) -> List[bytes]:
        """Return list of fixed-size byte records for cmd_id."""
        return []

    def _get_fields(self, cmd_id: int) -> List[Dict]:
        """
        Return list of field descriptors for cmd_id.
        Each dict: {'type': int, 'size': int, 'name': str, 'count': int, 'offset': int}
        """
        return []

    # response builders                                                  

    def _handle_struct_info(self, seq: int, cmd_id: int) -> bytes:
        """
        net_Web_CTL_Send_And_Recv_Datastruct_Info response.
        Returns item_size and item_count packed into a 8-byte payload:
            [0..3]  item_size  (LE uint32)
            [4..7]  item_count (LE uint32)
        """
        rows      = self._get_rows(cmd_id)
        item_size  = len(rows[0]) if rows else 0
        item_count = len(rows)
        payload    = struct.pack("<II", item_size, item_count)
        return _build_packet(seq, MSG_STRUCT_INFO, cmd_id,
                              1, 0, len(payload), payload)

    def _handle_ctl_data(self, seq: int, cmd_id: int) -> bytes:
        """
        net_Web_CTL_Send_And_Recv_Data response.
        Sends all rows in chunks of up to 4096//item_size per packet.
        """
        rows = self._get_rows(cmd_id)
        if not rows:
            return _build_packet(seq, MSG_CTL, cmd_id, 0, 0, 0, b"")

        item_size = len(rows[0])
        max_per   = max(1, (PACKET_SIZE - PAYLOAD_OFFSET) // item_size)
        chunks    = [rows[i:i + max_per] for i in range(0, len(rows), max_per)]
        pkts      = []
        for idx, chunk in enumerate(chunks):
            more    = 1 if idx < len(chunks) - 1 else 0
            payload = b"".join(chunk)
            pkts.append(_build_packet(seq, MSG_CTL, cmd_id,
                                      len(chunk), more, item_size, payload))
        # Return first packet; multi-packet is handled by the transport loop
        # For simplicity here we concatenate and mark more=0 on the last
        return pkts[0] if len(pkts) == 1 else pkts[-1]  # caller loops

    def _handle_table_count(self, seq: int, cmd_id: int) -> bytes:
        """First phase of TABLE_INFO: returns field count."""
        fields  = self._get_fields(cmd_id)
        payload = struct.pack("<I", len(fields))
        return _build_packet(seq, MSG_TABLE_COUNT, cmd_id,
                              1, 0, 4, payload)

    def _handle_table_data(self, seq: int, cmd_id: int) -> bytes:
        """Second phase of TABLE_INFO: returns all field descriptors."""
        fields  = self._get_fields(cmd_id)
        payload = b"".join(self._encode_field(f) for f in fields)
        return _build_packet(seq, MSG_TABLE_DATA, cmd_id,
                              len(fields), 0, FIELD_DESC_SIZE, payload)

    @staticmethod
    def _encode_field(f: Dict) -> bytes:
        """Encode a field descriptor into 100 bytes."""
        buf = bytearray(FIELD_DESC_SIZE)
        struct.pack_into("<I", buf, FIELD_TYPE_OFF,   f.get("type", 0))
        struct.pack_into("<I", buf, FIELD_SIZE_OFF,   f.get("size", 0))
        name = f.get("name", "").encode("ascii", errors="replace")
        buf[FIELD_NAME_OFF:FIELD_NAME_OFF + min(len(name), FIELD_NAME_LEN)] = name
        struct.pack_into("<I", buf, FIELD_COUNT_OFF,  f.get("count", 1))
        struct.pack_into("<I", buf, FIELD_OFFSET_OFF, f.get("offset", 0))
        return bytes(buf)

    @staticmethod
    def _decode_field(buf: bytes, off: int = 0) -> Dict:
        """Decode a 100-byte field descriptor."""
        raw_name = buf[off + FIELD_NAME_OFF: off + FIELD_NAME_OFF + FIELD_NAME_LEN]
        name = raw_name.split(b"\x00")[0].decode("ascii", errors="replace")
        return {
            "type":   struct.unpack_from("<I", buf, off + FIELD_TYPE_OFF)[0],
            "size":   struct.unpack_from("<I", buf, off + FIELD_SIZE_OFF)[0],
            "name":   name,
            "count":  struct.unpack_from("<I", buf, off + FIELD_COUNT_OFF)[0],
            "offset": struct.unpack_from("<I", buf, off + FIELD_OFFSET_OFF)[0],
        }


# ---------------------------------------------------------------------------

def _header_ntoh(buf: bytearray, offset: int = 0, count: int = 8) -> None:
    """
    Convert 'count' 32-bit words in buf[offset:] from network (big-endian) 
    to host byte order, in-place. Mirrors header_ntoh() firmware function.
    
    Original C loop:
        for (i = 0; i <= 7; ++i)
            *(_DWORD *)(a1 + 4*i) = ntohl(*(_DWORD *)(a1 + 4*i));
    """
    import struct
    for i in range(count):
        pos = offset + i * 4
        if pos + 4 <= len(buf):
            # Unpack big-endian uint32, repack in native order
            val = struct.unpack_from(">I", buf, pos)[0]
            struct.pack_into("<I" if sys.byteorder == "little" else ">I", buf, pos, val)


def _fis_readBuf(offset: int, size: int, mtd_index: int, out_buf: bytearray) -> bool:
    """
    Read 'size' bytes from /dev/mtd{mtd_index} at 'offset' into out_buf.
    
    Negative offset = seek from end (like C lseek with SEEK_END).
    Returns True on success, False on failure.
    
    Original C:
        sprintf(s, "/dev/mtd%d", a3);
        fd = open(s, 0);  // O_RDONLY
        if (a1 >= 0) lseek(fd, a1, 0); else lseek(fd, a1, 2);  // 0=SEEK_SET, 2=SEEK_END
        read(fd, a4, a2);
    """
    if IS_WINDOWS:
        import os
        # Windows stub: no /dev/mtd* devices
        logger.debug("_fis_readBuf: Windows stub (mtd%d, offset=%d, size=%d)", 
                     mtd_index, offset, size)
        # Fill with deterministic stub data for testing
        # Override via env: MOXA_FW_STUB="0102030405060708..."
        stub_hex = os.getenv("MOXA_FW_STUB", "0102030405060708090A0B0C0D0E0F10" * 2)
        stub_bytes = bytes.fromhex(stub_hex.replace(" ", "")[:size*2])
        out_buf[:len(stub_bytes)] = stub_bytes
        return len(stub_bytes) == size
    
    import os
    device_path = f"/dev/mtd{mtd_index}"
    
    try:
        with open(device_path, "rb") as f:
            if offset >= 0:
                f.seek(offset, 0)  # SEEK_SET
            else:
                f.seek(offset, 2)  # SEEK_END (negative = before EOF)
            data = f.read(size)
            if len(data) == size:
                out_buf[:size] = data
                return True
            logger.warning("_fis_readBuf: short read %d/%d from %s", 
                          len(data), size, device_path)
            return False
    except FileNotFoundError:
        logger.warning("_fis_readBuf: device not found: %s", device_path)
        return False
    except PermissionError:
        logger.warning("_fis_readBuf: permission denied: %s", device_path)
        return False
    except OSError as e:
        logger.warning("_fis_readBuf: OSError on %s: %s", device_path, e)
        return False

def Read_FW_Info(out_buf: Optional[bytearray] = None, mtd_index: int = 1) -> bytearray:
    """
    Read and parse firmware version info from MTD flash.
    
    Mirrors the firmware's Read_FW_Info() function:
        j_fis_readBuf(-32, 0x20u, 1, a1);  // Read last 32 bytes of /dev/mtd1
        j_header_ntoh((int)a1);             // Convert 8 dwords from big-endian
    
    Args:
        out_buf: Optional pre-allocated 32-byte buffer (for zero-copy usage)
        mtd_index: MTD device index (default=1 for /dev/mtd1)
    
    Returns:
        bytearray of 32 bytes with firmware header in host byte order.
        On Windows or if device unreadable, returns stubbed version bytes.
    
    Usage:
        fw = Read_FW_Info()
        # fw[0:4] = version major/minor as uint32 LE, etc.
        version_str = "".join(f"{b:02d}" for b in fw[:4])  # e.g., "01020304"
    """
    if out_buf is None:
        out_buf = bytearray(32)
    elif len(out_buf) < 32:
        raise ValueError(f"out_buf must be at least 32 bytes, got {len(out_buf)}")
    
    # Read raw big-endian header from flash
    if not _fis_readBuf(offset=-32, size=32, mtd_index=mtd_index, out_buf=out_buf):
        logger.warning("Read_FW_Info: fis_readBuf failed, using stub data")
        # Stub already filled by _fis_readBuf on Windows; on Linux, fill fallback
        if not IS_WINDOWS:
            stub = bytes.fromhex("0102030405060708090A0B0C0D0E0F10" * 2)
            out_buf[:32] = stub
    
    # Convert from network (big-endian) to host byte order
    _header_ntoh(out_buf, offset=0, count=8)
    
    return out_buf

def format_fw_version(fw_buf: bytearray) -> str:
    """
    Convert 32-byte firmware header to version string like "01020304".
    
    Uses first 4 bytes (now in host order) as [major, minor, patch, build].
    Each byte formatted as zero-padded decimal: b'\\x01\\x02\\x03\\x04' --> "01020304"
    
    This matches the firmware's:
        sprintf(s, "%02d%02d%02d%02d", HIBYTE(v9), BYTE2(v9), BYTE1(v9), (unsigned __int8)v9);
    """
    return "".join(f"{b:02d}" for b in fw_buf[:4])


_FW_VERSION_CACHE: Optional[str] = None

def get_cached_fw_version(mtd_index: int = 1, force_refresh: bool = False) -> str:
    """
    Get firmware version string with caching.
    
    Args:
        mtd_index: MTD device index (default=1)
        force_refresh: If True, re-read from flash instead of using cache
    
    Returns:
        Version string like "01020304"
    """
    global _FW_VERSION_CACHE
    if force_refresh or _FW_VERSION_CACHE is None:
        fw_buf = Read_FW_Info(mtd_index=mtd_index)
        _FW_VERSION_CACHE = format_fw_version(fw_buf)
    return _FW_VERSION_CACHE

# ---------------------------------------------------------------------------
# SysCommon : the main public API
# ---------------------------------------------------------------------------

class SysCommon:
    """
    High-level IPC client mirroring the libsyscommon functions used by the
    Moxa GoAhead web server.

    Wraps:
      net_Web_CTL_Send_And_Recv_Datastruct_Info  --> get_datastruct_info()
      net_Web_CTL_Send_And_Recv_Data             --> get_data()
      net_Web_CTL_Send_And_Recv_Table_Info       --> get_table_info()

    On Linux  : connects via AF_UNIX SOCK_DGRAM to the real daemon sockets.
    On Windows: connects via TCP to a local proxy thread (MoxaTcpProxy).

    Parameters
    ----------
    send_path  : full path to the send socket (firmware: /mnt/ramdisk/socket/magic168-socket)
    recv_path  : full path to the recv socket (firmware: /mnt/ramdisk/socket/webs-Recv)
    timeout    : socket receive timeout in seconds
    stub       : optional MoxaDaemonStub subclass for offline/testing use
                 (if provided, bypasses actual sockets and calls stub directly)
    """

    def __init__(self,
                 send_path: str = "/mnt/ramdisk/" + SEND_SOCK_NAME,
                 recv_path: str = "/mnt/ramdisk/" + RECV_SOCK_NAME,
                 timeout: float = 10.0,
                 stub: Optional[MoxaDaemonStub] = None):
        self._lock   = threading.Lock()
        self._seq    = 0
        self._stub   = stub
        self._transport: Optional[object] = None

        if stub is None:
            if IS_WINDOWS:
                self._transport = _TcpProxyTransport(timeout=timeout)
            else:
                self._transport = _UnixTransport(send_path, recv_path, timeout)
            self._transport.open()

    def close(self):
        if self._transport:
            self._transport.close()
            self._transport = None

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()

    # sequence number                                                    

    def _next_seq(self) -> int:
        self._seq = (self._seq % 0xFF) + 1
        return self._seq

    # low-level send/recv                                                

    def _request(self, msg_type: int, cmd_id: int,
                 out_buf: Optional[bytearray] = None) -> int:
        """
        Send one request packet and receive response(s) into out_buf.
        Returns number of records received (≥0) or negative on error.
        Mirrors net_RecvFromInterface1 loop.
        """
        if self._stub:
            return self._request_via_stub(msg_type, cmd_id, out_buf)

        seq = self._next_seq()
        pkt = _build_packet(seq, msg_type, cmd_id, 0, 0, 0, b"")
        self._transport.send(pkt)

        received  = 0
        item_size = 0

        while True:
            try:
                data = self._transport.recv()
            except socket.timeout:
                logger.warning("Timeout waiting for cmd_id=%d msg_type=%d",
                               cmd_id, msg_type)
                return -1

            p = _parse_packet(data)

            # Sequence check (mirrors avoidseq logic)
            if p["seq"] != seq:
                logger.debug("seq mismatch: got %d expected %d", p["seq"], seq)
                continue

            item_size = p["item_size"]
            n         = p["count"]
            if n and item_size and out_buf is not None:
                start = received * item_size
                end   = start + n * item_size
                pl    = bytes(p["payload"])[:n * item_size]
                out_buf[start:start + len(pl)] = pl
            received += n

            if not p["more"]:
                break

        return received

    def _request_via_stub(self, msg_type: int, cmd_id: int,
                          out_buf: Optional[bytearray]) -> int:
        """Route request through the in-process stub (no sockets)."""
        pkt   = {"seq": self._next_seq(), "msg_type": msg_type,
                 "cmd_id": cmd_id, "count": 0, "more": 0,
                 "item_size": 0, "payload": b""}
        reply_bytes = self._stub.handle(pkt)
        if reply_bytes is None:
            return -1
        p = _parse_packet(reply_bytes)
        n         = p["count"]
        item_size = p["item_size"]
        if n and item_size and out_buf is not None:
            pl = bytes(p["payload"])[:n * item_size]
            out_buf[:len(pl)] = pl
        return n

    # public API                                                         

    def get_datastruct_info(self, cmd_id: int) -> Tuple[int, int]:
        """
        net_Web_CTL_Send_And_Recv_Datastruct_Info(5, send, recv, cmd_id, &s)
        Returns (item_size, item_count).  Returns (0, 0) on failure.

        The firmware sends msg_type=5 (MSG_STRUCT_INFO) and reads back an
        8-byte payload: [item_size: uint32][item_count: uint32].
        """
        with self._lock:
            buf = bytearray(8)
            rc  = self._request(MSG_STRUCT_INFO, cmd_id, buf)
            if rc <= 0:
                logger.warning("get_datastruct_info cmd_id=%d rc=%d", cmd_id, rc)
                return (0, 0)
            item_size, item_count = struct.unpack_from("<II", buf, 0)
            return (item_size, item_count)

    def get_data(self, cmd_id: int, out_buf: bytearray) -> int:
        """
        net_Web_CTL_Send_And_Recv_Data(send, recv, cmd_id, out_buf, 0)
        Fills out_buf with all records.  Returns number of records or <0.

        The firmware sends msg_type=0 (MSG_CTL) and receives all data rows
        potentially across multiple packets (more=1 indicates continuation).
        """
        with self._lock:
            return self._request(MSG_CTL, cmd_id, out_buf)

    def get_table_info(self, cmd_id: int) -> List[Dict]:
        """
        net_Web_CTL_Send_And_Recv_Table_Info(send, recv, cmd_id, &field_desc_ptr)
        Returns a list of field descriptor dicts.

        The firmware does a two-phase exchange:
          Phase 1: MSG_TABLE_COUNT (3) --> receives field count in item_size field
          Phase 2: MSG_TABLE_DATA  (4) --> receives all field descriptors

        Each field descriptor is 100 bytes (FIELD_DESC_SIZE).
        """
        with self._lock:
            # Phase 1: get field count
            count_buf = bytearray(4)
            rc = self._request(MSG_TABLE_COUNT, cmd_id, count_buf)
            if rc < 0:
                logger.warning("get_table_info phase1 cmd_id=%d rc=%d", cmd_id, rc)
                return []
            # The count comes back in the item_size field or the payload
            # (firmware: v8 = net_Web_CTL_Send_And_Recv_Table_Info returns count)
            field_count = struct.unpack_from("<I", count_buf, 0)[0] if rc > 0 else rc

            if field_count <= 0:
                return []

            # Phase 2: get field descriptors
            desc_buf = bytearray(field_count * FIELD_DESC_SIZE)
            rc2 = self._request(MSG_TABLE_DATA, cmd_id, desc_buf)
            if rc2 < 0:
                logger.warning("get_table_info phase2 cmd_id=%d rc=%d", cmd_id, rc2)
                return []

            fields = []
            for i in range(field_count):
                off = i * FIELD_DESC_SIZE
                fields.append(MoxaDaemonStub._decode_field(desc_buf, off))
            return fields

    def get_all(self, cmd_id: int) -> Dict:
        """
        Convenience: calls get_datastruct_info + get_data + get_table_info
        and returns a data-provider compatible dict:
            {
                'item_size':  int,
                'item_count': int,
                'fields':     [...],
                'rows':       [{field_name: str_value, ...}, ...]
            }
        Suitable for direct use as a moxa_show_value.py data provider.
        """
        item_size, item_count = self.get_datastruct_info(cmd_id)
        if not item_size or not item_count:
            return None

        raw_buf = bytearray(item_size * item_count)
        self.get_data(cmd_id, raw_buf)

        fields = self.get_table_info(cmd_id)

        rows = []
        for i in range(item_count):
            row_bytes = raw_buf[i * item_size:(i + 1) * item_size]
            row = self._decode_row(row_bytes, fields, item_size)
            rows.append(row)

        return {
            "item_size":  item_size,
            "item_count": item_count,
            "fields":     fields,
            "rows":       rows,
        }

    @staticmethod
    def _decode_row(row_bytes: bytes, fields: List[Dict], item_size: int) -> Dict:
        """
        Decode a raw byte record into a dict of {field_name: str_value},
        mirroring what readconfig() does in the firmware.
        """
        from moxa_show_value import (
            FTYPE_UINT8, FTYPE_INT8, FTYPE_UINT16, FTYPE_INT16,
            FTYPE_UINT32, FTYPE_UINT64, FTYPE_STRING_REF,
            FTYPE_UINT8_ARRAY, FTYPE_BITFIELD, FTYPE_BIT_PER_ROW,
            FTYPE_STRING_LIST, FTYPE_ALWAYS_VALID, FTYPE_ALWAYS_VALID2,
            FTYPE_PADDING, FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END,
            FTYPE_NESTED_TABLE, FTYPE_UINT32_ALT,
        )
        row  = {}
        data = bytes(row_bytes)

        for f in fields:
            ft     = f["type"]
            name   = f["name"]
            off    = f["offset"]
            size   = f["size"]
            count  = f["count"]

            if ft in (FTYPE_PADDING, FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END,
                      FTYPE_NESTED_TABLE):
                continue

            if off + size > len(data):
                continue

            if ft == FTYPE_STRING_REF or ft == FTYPE_STRING_LIST:
                val = data[off:off + size]
                row[name] = val.split(b"\x00")[0].decode("ascii", errors="replace")

            elif ft == FTYPE_UINT8 or ft == FTYPE_ALWAYS_VALID or ft == FTYPE_ALWAYS_VALID2:
                row[name] = str(data[off])

            elif ft == FTYPE_INT8:
                row[name] = str(struct.unpack_from("b", data, off)[0])

            elif ft == FTYPE_UINT16:
                row[name] = str(struct.unpack_from("<H", data, off)[0])

            elif ft == FTYPE_INT16:
                row[name] = str(struct.unpack_from("<h", data, off)[0])

            elif ft in (FTYPE_UINT32, FTYPE_UINT32_ALT):
                row[name] = str(struct.unpack_from("<I", data, off)[0])

            elif ft == FTYPE_UINT64:
                row[name] = str(struct.unpack_from("<Q", data, off)[0])

            elif ft == FTYPE_UINT8_ARRAY:
                # Multi-byte array: return comma-joined or indexed keys
                if count <= 1:
                    vals = [str(data[off + j]) for j in range(size)]
                    row[name] = ",".join(vals)
                else:
                    for j in range(count):
                        row["%s%d" % (name, j)] = str(data[off + j])

            elif ft == FTYPE_BITFIELD:
                # 10-bit field stored as integer
                val = struct.unpack_from("<I", data, off)[0]
                row[name] = str(val)

            elif ft == FTYPE_BIT_PER_ROW:
                # 10 per-row bits; each bit is a separate key portN_name
                val = struct.unpack_from("<I", data, off)[0]
                for k in range(10):
                    row["port%d_%s" % (k, name)] = str((val >> k) & 1)

        return row


# ---------------------------------------------------------------------------
# Integration helper for moxa_show_value.py
# ---------------------------------------------------------------------------

def make_data_provider(sc: Optional[SysCommon] = None):
    """
    Create a data_provider callable compatible with moxa_show_value.net_Web_show_value.

    Uses the shared SysCommon instance (creates one lazily if not provided).

        from syscommon import make_data_provider
        from moxa_show_value import net_Web_show_value, make_jinja2_global

        provider = make_data_provider()
        js = net_Web_show_value('SRV_OPENVPN_CLIENT', provider)

    Jinja2:
        env.globals['net_Web_show_value'] = make_jinja2_global(provider)
    """
    _sc = sc or SysCommon()

    def _provider(ctl_id: int):
        try:
            return _sc.get_all(ctl_id)
        except Exception as e:
            logger.error("data_provider ctl_id=%d: %s", ctl_id, e)
            return None

    return _provider


# ---------------------------------------------------------------------------
# Self-test / demo
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import sys
    logging.basicConfig(level=logging.DEBUG)

    # offline demo with a stub                                           
    class DemoStub(MoxaDaemonStub):
        """Returns demo SRV_OPENVPN_CLIENT data (ctl_id=128)."""

        _FIELDS_128 = [
            {"type": 1,  "size": 1,  "name": "enable",     "count": 1, "offset": 0},
            {"type": 1,  "size": 1,  "name": "clientId",   "count": 1, "offset": 1},
            {"type": 10, "size": 16, "name": "serverIP",   "count": 1, "offset": 2},
            {"type": 4,  "size": 2,  "name": "serverPort", "count": 1, "offset": 18},
            {"type": 1,  "size": 1,  "name": "devType",    "count": 1, "offset": 20},
            {"type": 1,  "size": 1,  "name": "protoType",  "count": 1, "offset": 21},
            {"type": 1,  "size": 1,  "name": "compLzo",    "count": 1, "offset": 22},
            {"type": 1,  "size": 1,  "name": "encCipher",  "count": 1, "offset": 23},
            {"type": 1,  "size": 1,  "name": "tlsAuth",    "count": 1, "offset": 24},
            {"type": 1,  "size": 1,  "name": "clientAuth", "count": 1, "offset": 25},
            {"type": 10, "size": 16, "name": "username",   "count": 1, "offset": 26},
            {"type": 10, "size": 16, "name": "userpasswd", "count": 1, "offset": 42},
        ]

        def _get_rows(self, cmd_id):
            if cmd_id != 128:
                return []
            rows = []
            for r in [
                (1, 1, "180.1.1.1", 1194, 0, 0, 1, 1, 0, 0, "aaa1", "1234"),
                (0, 2, "180.1.2.0", 1194, 1, 1, 1, 2, 1, 1, "bbb1", "1234"),
            ]:
                buf = bytearray(64)
                buf[0]  = r[0]           # enable
                buf[1]  = r[1]           # clientId
                ip = r[2].encode()
                buf[2:2+len(ip)] = ip    # serverIP
                struct.pack_into("<H", buf, 18, r[3])   # serverPort
                buf[20] = r[4]           # devType
                buf[21] = r[5]           # protoType
                buf[22] = r[6]           # compLzo
                buf[23] = r[7]           # encCipher
                buf[24] = r[8]           # tlsAuth
                buf[25] = r[9]           # clientAuth
                un = r[10].encode()
                buf[26:26+len(un)] = un  # username
                pw = r[11].encode()
                buf[42:42+len(pw)] = pw  # userpasswd
                rows.append(bytes(buf))
            return rows

        def _get_fields(self, cmd_id):
            if cmd_id != 128:
                return []
            return self._FIELDS_128

    # Run offline demo
    stub = DemoStub()
    sc   = SysCommon(stub=stub)

    print("=== get_datastruct_info(128) ===")
    size, count = sc.get_datastruct_info(128)
    print("  item_size=%d  item_count=%d" % (size, count))

    print("\n=== get_table_info(128) ===")
    fields = sc.get_table_info(128)
    for f in fields:
        print("  %r" % f)

    print("\n=== get_all(128) --> moxa_show_value ===")
    data = sc.get_all(128)
    try:
        from moxa_show_value import net_Web_show_value
        js = net_Web_show_value("SRV_OPENVPN_CLIENT", lambda cid: data if cid == 128 else None)
        print(js)
    except ImportError:
        print("(moxa_show_value not found : install it alongside this file)")
        import json
        print(json.dumps(data, indent=2))

    sc.close()
    print("Done.")