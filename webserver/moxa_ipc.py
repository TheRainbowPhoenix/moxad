"""
moxa_ipc.py  -  Unix-domain socket IPC layer for Moxa EDR-810 mock

Faithfully reverse-engineered from libsyscommon_so_1.c:
  net_OpenSocketToInterface_Send  (line 12835)
  net_OpenSocketToInterface_Recv  (line 12860)
  net_SendToInterface             (line 12387)
  net_RecvFromInterface1          (line 12422)
  net_Web_CTL_Send_And_Recv_Data  (line 12669)
  net_Web_SendData                (line 12520)
  sock_path                       (line 12999)

Wire protocol (4096-byte datagrams, magic field at byte 7)
                                                           
  Offset  Size  Field
                                                             
     0      1   seq          - rolling 1..255 sequence number
     1      1   msg_type     - 0=CTL 1=SEND 2=SEND+RECV 3=TABLE_COUNT
                               4=TABLE_DATA 5=STRUCT_INFO 7=SEND+CONFIRM
     2      1   cmd_id       - service/data type ID
     3      1   count        - number of records in this packet
     4      1   more         - 1 if more packets follow (multi-packet)
     5      2   (padding)
     7      1   magic        - copied from socket struct offset 128
     8      4   item_size    - size of each record (LE uint32 at offset 8)
    12   4084   payload      - count × item_size bytes of data

Special socket name: "socket/magic168-socket"
  When the send socket path contains "magic168-socket" and msg_type is 1 or 7,
  net_SendToInterface redirects the datagram to "socket/magic168-wexe-socket"
  and sleeps 1 second.  (See: if(!strcmp(path, magic168-socket) && type in {1,7}))

State globals (from libsyscommon):
  s_seq     - uint8 rolling send sequence (increments mod 255, 1-based)
  r_seq     - last received sequence (set by set_seq_num)
  avoidseq  - when 1, skip sequence check on receive
  lockspin  - mutex flag for CTL calls
"""

import os, socket, struct, threading, time, logging
from pathlib import Path
from typing import Callable, Optional
from moxa_shm import get_shm, RAMDISK, SHM_DIR

logger = logging.getLogger(__name__)

# constants                                                                 
RAMDISK_SOCK = RAMDISK / "socket"
MAGIC168_SOCK       = "socket/magic168-socket"
MAGIC168_WEXE_SOCK  = "socket/magic168-wexe-socket"
PACKET_SIZE         = 0x100C   # 4108 bytes  (the real malloc(0x100C))
PAYLOAD_OFFSET      = 12       # data starts at byte 12

# Message type codes
MSG_CTL          = 0
MSG_SEND         = 1
MSG_SEND_RECV    = 2
MSG_TABLE_COUNT  = 3
MSG_TABLE_DATA   = 4
MSG_STRUCT_INFO  = 5
MSG_SEND_CONFIRM = 7

# global state (mirrors C globals)                                          
_s_seq:    int  = 0    # send sequence
_r_seq:    int  = 0    # last received sequence
_avoidseq: bool = True # skip seq check by default (avoidseq=1 initially)
_lockspin: bool = False
_spin_lock = threading.Lock()


def _next_seq() -> int:
    global _s_seq
    _s_seq = (_s_seq % 0xFF) + 1
    return _s_seq


# socket path helper (sock_path)                                            
def sock_path(name: str) -> str:
    """
    Port of sock_path(): sprintf(msg, "%s/%s", "socket", name)
    Returns the full filesystem path under RAMDISK.
    """
    return str(RAMDISK / "socket" / name)


def _ensure_sock_dir():
    (RAMDISK / "socket").mkdir(parents=True, exist_ok=True)


# packet builder                                                             
def _build_packet(seq: int, msg_type: int, cmd_id: int,
                  count: int, more: int, item_size: int,
                  payload: bytes, magic: int = 0) -> bytes:
    """
    Build a 4108-byte datagram matching the real firmware wire format:
      [0] seq [1] msg_type [2] cmd_id [3] count [4] more [5-6] pad
      [7] magic [8-11] item_size (LE) [12..] payload
    """
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
    """Parse a raw datagram into named fields."""
    if len(data) < PAYLOAD_OFFSET:
        raise ValueError("Packet too short")
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


# socket context objects                                                      
class SendSocket:
    """
    Mirrors the 144-byte C struct used by net_OpenSocketToInterface_Send.
    Layout (relevant fields):
      [0]    valid byte
      [2..N] sun_path (AF_UNIX abstract path)
      [112]  fd (socket file descriptor)
      [116]  addrlen
      [120]  type_offset (added to msg_type in net_SendToInterface)
      [128]  magic byte
      [133]  last_seq
      [136]  timeout_sec
    """
    def __init__(self, dest_name: str, type_offset: int = 0):
        _ensure_sock_dir()
        self.dest_name   = dest_name
        self.dest_path   = sock_path(dest_name) if not dest_name.startswith("/") else dest_name
        self.type_offset = type_offset
        self.magic       = 0
        self.last_seq    = 0
        self.sock: socket.socket | None = None

    def open(self) -> int:
        """Port of net_OpenSocketToInterface_Send."""
        try:
            self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
            return 0
        except OSError as e:
            logger.error(f"SendSocket.open: {e}")
            return -1

    def close(self):
        """Port of net_CloseSocketToInterface_Send."""
        if self.sock:
            try:
                self.sock.close()
            except Exception:
                pass
            self.sock = None

    def send(self, pkt: bytearray | bytes) -> int:
        """
        Port of net_SendToInterface.
        Special-case: if dest is magic168-socket and msg_type ∈ {1,7},
        redirect to magic168-wexe-socket and sleep 1s.
        """
        if not self.sock:
            return -1
        pkt = bytearray(pkt)
        msg_type = pkt[1]

        if MAGIC168_SOCK in self.dest_path and msg_type in (MSG_SEND, MSG_SEND_CONFIRM):
            dest = sock_path("magic168-wexe-socket")
            time.sleep(1.0)       # usleep(0xF4240) = 1 second
        else:
            dest = self.dest_path

        # Apply type_offset (a1+120 in C)
        pkt[1] = (msg_type + self.type_offset) & 0xFF
        # Apply magic (a1+128 in C --> pkt[7])
        pkt[7] = self.magic

        try:
            n = self.sock.sendto(bytes(pkt), dest)
            pkt[1] = msg_type  # restore
            return n
        except OSError as e:
            logger.error(f"net_SendToInterface to {dest}: {e}")
            pkt[1] = msg_type
            return -1


class RecvSocket:
    """
    Mirrors the 144-byte C struct used by net_OpenSocketToInterface_Recv.
    Bound to a named AF_UNIX SOCK_DGRAM socket under RAMDISK/socket/.

    offset 133: expected_seq
    offset 134: avoidseq_flag (1 = accept any sequence)
    offset 136: timeout_sec
    offset 140: timeout_usec
    """
    def __init__(self, bind_name: str,
                 timeout_sec: int = 10, timeout_usec: int = 0):
        _ensure_sock_dir()
        self.bind_name    = bind_name
        self.bind_path    = sock_path(bind_name) if not bind_name.startswith("/") else bind_name
        self.expected_seq = 0
        self.avoidseq     = True      # 1=ignore sequence check
        self.timeout_sec  = timeout_sec
        self.timeout_usec = timeout_usec
        self.last_cmd_id  = 0
        self.last_type    = 0
        self.last_seq     = 0
        self.last_size    = 0
        self.sock: socket.socket | None = None

    def open(self) -> int:
        """Port of net_OpenSocketToInterface_Recv."""
        _ensure_sock_dir()
        for attempt in range(5):
            try:
                self.sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
                break
            except OSError:
                time.sleep(0.1)
                continue
        if not self.sock:
            logger.error(f"RecvSocket.open: cannot create socket")
            return -1
        try:
            Path(self.bind_path).unlink(missing_ok=True)
            self.sock.bind(self.bind_path)
            return 0
        except OSError as e:
            logger.error(f"RecvSocket bind {self.bind_path}: {e}")
            return -1

    def close(self):
        """Port of net_CloseSocketToInterface_Recv."""
        if self.sock:
            try:
                self.sock.close()
            except Exception:
                pass
            self.sock = None
        Path(self.bind_path).unlink(missing_ok=True)

    def recv(self, out_buf: bytearray, total_items: int) -> int:
        """
        Port of net_RecvFromInterface1.
        Reads datagrams until more==0 (last packet).
        Accumulates payload into out_buf.
        Returns number of items received, or negative on error/timeout.
        """
        if not self.sock:
            return -5

        received = 0
        if self.timeout_sec or self.timeout_usec:
            self.sock.settimeout(self.timeout_sec + self.timeout_usec / 1e6)
        else:
            self.sock.settimeout(None)   # block forever

        while True:
            try:
                data, _ = self.sock.recvfrom(PACKET_SIZE)
            except socket.timeout:
                return -1     # LABEL_30 timeout path in C
            except OSError as e:
                logger.error(f"recvfrom: {e}")
                return -2

            pkt = _parse_packet(data)

            # Sequence check (avoidseq || avoidseq_flag || seq matches expected)
            if not (_avoidseq or self.avoidseq or pkt["seq"] == self.expected_seq):
                logger.warning(f"seq error on {self.bind_path}: "
                               f"got {pkt['seq']} expected {self.expected_seq}")
                continue

            # Update recv-side metadata (mirrors C struct fields at +132..+134)
            self.last_cmd_id  = pkt["cmd_id"]
            self.last_type    = pkt["msg_type"]
            self.last_seq     = pkt["seq"]
            self.last_size    = pkt["item_size"]
            self.expected_seq = pkt["seq"]
            global _r_seq
            _r_seq = pkt["seq"]

            # Copy payload into out_buf  (memcpy at offset a2 + v13*item_size)
            n    = pkt["count"]
            size = pkt["item_size"]
            if n and size and out_buf is not None:
                start = received * size
                end   = start + n * size
                pl    = bytes(pkt["payload"])[:n * size]
                out_buf[start:start + len(pl)] = pl
            received += n

            if not pkt["more"]:
                break

        return received


# high-level CTL helpers                                                      
class CtlChannel:
    """
    Convenience wrapper combining a SendSocket + RecvSocket for request/reply.
    Mirrors net_Web_CTL_Send_And_Recv_Data:
      lockspin loop --> malloc pkt --> fill header --> sendto --> recvfrom --> free
    """
    def __init__(self, send_name: str, recv_name: str):
        self._send = SendSocket(send_name)
        self._recv = RecvSocket(recv_name, timeout_sec=10)
        self._lock = threading.Lock()   # lockspin equivalent
        self._open()

    def _open(self):
        self._send.open()
        self._recv.open()

    def close(self):
        self._send.close()
        self._recv.close()

    def ctl(self, cmd_id: int, out_buf: bytearray, item_size: int = 0) -> int:
        """
        net_Web_CTL_Send_And_Recv_Data equivalent.
        Sends a MSG_CTL request, receives response into out_buf.
        Returns bytes received (≥0) or negative on error.
        """
        with self._lock:
            seq = _next_seq()
            self._recv.expected_seq = seq
            self._recv.avoidseq     = False
            pkt = _build_packet(seq, MSG_CTL, cmd_id, 0, 0, 0, b"")
            self._send.send(pkt)
            return self._recv.recv(out_buf, 1)

    def send_data(self, cmd_id: int, data: bytes,
                  item_size: int, count: int) -> int:
        """
        net_Web_SendData equivalent.
        Sends data in chunks of up to 4096/item_size records per packet.
        """
        max_per_pkt = 4096 // item_size if item_size else 1
        i = 0
        rc = 0
        seq = _next_seq()
        self._recv.expected_seq = seq
        while True:
            remaining = count - max_per_pkt * i
            chunk_n   = min(remaining, max_per_pkt)
            more      = 1 if remaining > chunk_n else 0
            offset    = item_size * max_per_pkt * i
            payload   = data[offset:offset + item_size * chunk_n]
            pkt = _build_packet(seq, MSG_SEND, cmd_id,
                                chunk_n, more, item_size, payload)
            rc = self._send.send(pkt)
            if not rc or not more:
                break
            i += 1
        return rc


# SHM daemon (the "agent" side)                                              
class MoxaDaemon:
    """
    Emulates the real Moxa SHM daemon that listens on AF_UNIX sockets and
    responds to net_Web_CTL_Send_And_Recv_Data requests.

    The real daemon (sub_F898 and friends) listens on:
      /mnt/ramdisk/socket/<service>   - for incoming CTL requests
    and responds on:
      /mnt/ramdisk/socket/<service>2  - reply channel

    We run a background thread per service name.
    """
    def __init__(self, service_name: str):
        _ensure_sock_dir()
        self.service    = service_name
        self.listen_path = sock_path(service_name)
        self._sock: socket.socket | None = None
        self._thread: threading.Thread | None = None
        self._running   = False
        self._shm       = get_shm()

    def start(self):
        """Bind and start the daemon listener thread."""
        self._sock = socket.socket(socket.AF_UNIX, socket.SOCK_DGRAM)
        Path(self.listen_path).unlink(missing_ok=True)
        self._sock.bind(self.listen_path)
        self._running = True
        self._thread  = threading.Thread(target=self._loop,
                                         name=f"MoxaDaemon:{self.service}",
                                         daemon=True)
        self._thread.start()
        logger.info(f"MoxaDaemon:{self.service} listening on {self.listen_path}")

    def stop(self):
        self._running = False
        if self._sock:
            try:
                self._sock.close()
            except Exception:
                pass

    def _loop(self):
        while self._running:
            try:
                self._sock.settimeout(1.0)
                try:
                    data, sender = self._sock.recvfrom(PACKET_SIZE)
                except socket.timeout:
                    continue
                pkt = _parse_packet(data)
                reply = self._handle(pkt)
                if reply and sender:
                    self._sock.sendto(reply, sender)
            except OSError:
                break

    def _handle(self, pkt: dict) -> Optional[bytes]:
        """
        Build a reply datagram for a CTL request.
        Queries MoxaSHM for the requested cmd_id and serialises it.
        """
        cmd_id   = pkt["cmd_id"]
        msg_type = pkt["msg_type"]
        seq      = pkt["seq"]

        state = self._shm.state
        payload = self._serialize(cmd_id, state)
        if payload is None:
            return None

        item_size = len(payload)
        reply = _build_packet(seq, msg_type, cmd_id,
                              1, 0, item_size, payload)
        return reply

    def _serialize(self, cmd_id: int, state: dict) -> Optional[bytes]:
        """Convert state fields to bytes for a given cmd_id."""
        import json as _json
        s = state
        handlers = {
            1:   lambda: struct.pack("<I", s["system"].get("device_mode", 0)),
            20:  lambda: s["system"].get("hostname","").encode()[:40].ljust(41, b"\x00"),
            51:  lambda: s["system"].get("hostname","").encode()[:40].ljust(41, b"\x00"),
            108: lambda: struct.pack("<I", s.get("web",{}).get("auto_logout", 0)),
            124: lambda: s["system"].get("hostname","").encode()[:40].ljust(41, b"\x00"),
        }
        fn = handlers.get(cmd_id)
        if fn:
            try:
                return fn()
            except Exception as e:
                logger.warning(f"_serialize cmd_id={cmd_id}: {e}")
        # Default: return JSON for inspection
        return _json.dumps({"cmd_id": cmd_id}).encode()[:PACKET_SIZE - PAYLOAD_OFFSET]


# module self-test                                                           
if __name__ == "__main__":
    import sys
    logging.basicConfig(level=logging.DEBUG)
    cmd = sys.argv[1] if len(sys.argv) > 1 else "test"
    if cmd == "test":
        # Start a mini daemon on service "test_svc"
        daemon = MoxaDaemon("test_svc")
        daemon.start()
        time.sleep(0.1)

        # Client side
        send = SendSocket("test_svc")
        recv = RecvSocket("test_svc_reply")
        send.open()
        recv.open()

        seq = _next_seq()
        pkt = _build_packet(seq, MSG_CTL, 20, 0, 0, 0, b"")
        n = send.send(pkt)
        print(f"Sent {n} bytes")

        daemon.stop()
        send.close()
        recv.close()
        print("IPC test done")
