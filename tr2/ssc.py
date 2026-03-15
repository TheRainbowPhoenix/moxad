"""
ssc.py  :  Switch System Control layer  (Ssc_* functions)

Maps to the Ssc_* functions in tr2d binary.  All hardware I/O goes through
here.  Replace the ioctl calls with your driver / simulation backend.

Real binary calls ioctl() on a device opened by sub_16534() (the switch fd).
Here we use a SwitchBackend ABC so the same code runs against:
  - a real Marvell/Moxa switch  (LinuxSwitchBackend)
  - a software simulator        (SimSwitchBackend)
  - unit tests                  (MockSwitchBackend)
"""

import os
import sys
import socket

# Added for simulator GUI
GLOBAL_LINKS = []
GLOBAL_DAEMONS = []
import struct
import logging
from abc import ABC, abstractmethod
from typing import Optional, Tuple, List
from tr2d_structs import (
    PortState, CouplingInfo, LHCPortInfo, dsa_parse, dsa_build,
    TR2_ETH_IFACE, TR2_ETH_PROTO, TR2_MIN_FRAME, build_tr2_frame,
    LOG_DEBUG7, LOG_DEBUG5, LOG_ERROR, LOG_NOTICE,
)
from compat import (
    IS_WINDOWS, fd_write, fd_read, wait_readable,
    open_raw_socket, get_iface_mac, make_wakeup_pair,
)
# fcntl is Linux-only
if not IS_WINDOWS:
    import fcntl
else:
    fcntl = None

log = logging.getLogger("tr2d.ssc")

# 
# ioctl codes seen in the binary
# 
ETHSW_GET        = 0x82044702
ETHSW_SET        = 0x42044703
ETHSW_FDB_GET    = 0x82044704
ETHSW_FDB_SET    = 0x42044705
ETHSW_VLAN_GET   = 0x82044706
ETHSW_VLAN_SET   = 0x82044707
ETHSW_TRUNK_GET  = 0x8204470E
ETHSW_TRUNK_SET  = 0x4204470F
ETHSW_MIRROR     = 0x4204470D
ETHSW_QOS        = 0x42044711
ETHSW_STATS      = 0x82044708

# sub-command bytes (s[0]) used in ioctl payloads
class SwCmd:
    # GET ops (0x82044702)
    GET_PORT_SPEED   = 8
    GET_PORT_STATE   = 1
    GET_CPU_RATE     = 6
    # SET ops (0x42044703)
    SET_PORT_ENABLE  = 0
    SET_PORT_DUPLEX  = 2
    SET_PORT_MDI     = 3
    SET_PORT_PAUSE   = 4
    SET_IGMP_PORT    = 5
    SET_CPU_RATE     = 6
    # FDB ops
    FDB_GET_FIRST    = 0
    FDB_GET_NEXT     = 1
    FDB_ADD_STATIC   = 3
    FDB_DEL_ENTRY    = 5
    FDB_ADD_MCAST    = 2
    FDB_GET_BY_MAC   = 7
    FDB_FLUSH        = 1
    # VLAN ops
    VLAN_GET         = 0
    VLAN_SET         = 1
    VLAN_GET_TABLE   = 2
    # TRUNK ops
    TRUNK_GET_INFO   = 0
    TRUNK_SET_HASH   = 1
    TRUNK_SET_MEMBER = 2
    TRUNK_CLR_MEMBER = 3
    # QOS ops
    QOS_SCHEDULING   = 0
    QOS_TOS_PORT     = 1
    QOS_COS_PORT     = 2
    QOS_PRIORITY     = 3
    QOS_WEIGHTS      = 4
    QOS_DSCP_MAP     = 5


# 
# Abstract backend
# 

class SwitchBackend(ABC):
    """Every Ssc_ function delegates hardware work to one of these."""

    #  port state 
    @abstractmethod
    def set_port_state(self, port: int, state: int) -> int:
        """Ssc_setPortState  (0x17AC8) : DISABLE/BLOCKED/LEARNING/FORWARDING"""
    @abstractmethod
    def get_port_state(self, port: int) -> int:
        """Ssc_getPortState  (sub_179CC)"""
    @abstractmethod
    def get_port_link(self, port: int) -> bool:
        """Ssc_getPortLinkState  (0x17DF4)"""
    @abstractmethod
    def set_port_enable(self, port: int, enable: bool) -> int:
        """Ssc_port_enable_set  (sub_17C5C)"""

    #  packet I/O 
    @abstractmethod
    def send_frame(self, tx_fd=None, raw_fd=None, port: int = 0,
                   frame: bytes = b"", vid: int = 0) -> int:
        """frame_send  (sub_1B970) : write frame to raw socket"""
    @abstractmethod
    def recv_frame(self, fd=None) -> Tuple[Optional[bytes], int]:
        """recvfrom on raw ring socket -> (frame, src_port)"""

    #  MAC / FDB 
    @abstractmethod
    def fdb_flush(self, pbmp: int) -> int:
        """Ssc_flushMacAddr  (sub_1816C)"""
    @abstractmethod
    def fdb_add_ucast(self, mac: bytes, is_tagged: int, pbmp: int) -> int:
        """Ssc_fdbAddUcastEntry  (sub_191B8)"""
    @abstractmethod
    def fdb_find(self, mac: bytes) -> Optional[dict]:
        """Ssc_fdbFindMacEntry  (0x1852C)"""

    #  LED / fault 
    @abstractmethod
    def set_fault_led(self, val: int): ...
    @abstractmethod
    def clear_fault_led(self, val: int): ...

    #  learning 
    @abstractmethod
    def port_learning_disable(self, port: int) -> int: ...
    @abstractmethod
    def port_learning_enable(self, port: int) -> int: ...


# 
# Linux raw-socket backend  (what the real tr2d uses)
# 

class LinuxSwitchBackend(SwitchBackend):
    """
    Uses AF_PACKET raw sockets for packet I/O and ioctl for switch control.
    sub_16534() in the binary opens /dev/ethsw or similar; we use ioctl on
    a socket as the real driver does.
    """

    def __init__(self, iface: str = TR2_ETH_IFACE):
        self.iface = iface
        self._sw_fd: Optional[int] = None
        self._raw_sock: Optional[socket.socket] = None

    #  internal helpers 

    def _open_sw(self) -> int:
        """sub_16534  : open switch control fd (Linux only)"""
        if IS_WINDOWS:
            return -1
        if self._sw_fd is None or self._sw_fd < 0:
            import socket as _s
            self._sw_fd = _s.socket(_s.AF_INET, _s.SOCK_DGRAM, 0).fileno()
        return self._sw_fd

    def _ioctl(self, cmd: int, data: bytearray) -> bytearray:
        if IS_WINDOWS or fcntl is None:
            log.debug(f"_ioctl: skipped (Windows) cmd=0x{cmd:08X}")
            return data
        fd = self._open_sw()
        try:
            result = fcntl.ioctl(fd, cmd, data)
            return bytearray(result)
        except OSError as e:
            log.error(f"ioctl 0x{cmd:08X} error: {e}")
            return data

    def _open_raw(self) -> Optional[socket.socket]:
        """tr2_initTx  : AF_PACKET SOCK_RAW (Linux only)"""
        if self._raw_sock is None and not IS_WINDOWS:
            self._raw_sock = open_raw_socket(self.iface)
        return self._raw_sock

    #  port state 

    def set_port_state(self, port: int, state: int) -> int:
        log.debug(f"Ssc_setPortState port={port} state={state}")
        buf = bytearray(516)
        buf[0] = SwCmd.SET_PORT_ENABLE
        buf[2] = 8
        struct.pack_into("<I", buf, 4, port)
        struct.pack_into("<I", buf, 8, state)
        self._ioctl(ETHSW_SET, buf)
        return 0

    def get_port_state(self, port: int) -> int:
        buf = bytearray(516)
        buf[0] = SwCmd.GET_PORT_STATE
        buf[2] = 8
        struct.pack_into("<I", buf, 4, port)
        result = self._ioctl(ETHSW_GET, buf)
        state = struct.unpack_from("<I", result, 8)[0]
        log.debug(f"Ssc_getPortState port={port} -> {state}")
        return state

    def get_port_link(self, port: int) -> bool:
        buf = bytearray(516)
        buf[0] = 1; buf[2] = 8
        struct.pack_into("<I", buf, 4, port)
        result = self._ioctl(ETHSW_STATS, buf)
        link = bool(struct.unpack_from("<I", result, 8)[0])
        log.debug(f"Ssc_getPortLinkState port={port} -> {link}")
        return link

    def set_port_enable(self, port: int, enable: bool) -> int:
        log.debug(f"Ssc_port_enable_set port={port} enable={enable}")
        buf = bytearray(516)
        buf[0] = SwCmd.SET_PORT_ENABLE; buf[2] = 8
        struct.pack_into("<I", buf, 4, port)
        struct.pack_into("<I", buf, 8, int(enable))
        self._ioctl(ETHSW_SET, buf)
        return 0

    #  packet I/O 

    def send_frame(self, tx_fd=None, raw_fd=None, port: int = 0,
                   frame: bytes = b"", vid: int = 0) -> int:
        sock = self._open_raw()
        if sock is None:
            log.debug("send_frame: no raw socket (Windows/sim)")
            return len(frame)
        try:
            sock.send(frame)
            return len(frame)
        except OSError as e:
            log.error(f"frame_send write error: {e}")
            return -1

    def recv_frame(self, fd=None) -> Tuple[Optional[bytes], int]:
        sock = self._open_raw()
        if sock is None:
            return None, 0
        try:
            data, _ = sock.recvfrom(1518)
            src_port, _vid = dsa_parse(data[12:16]) if len(data) >= 16 else (0, 0)
            return data, src_port
        except OSError as e:
            log.error(f"recv_frame error: {e}")
            return None, 0

    #  MAC / FDB 

    def fdb_flush(self, pbmp: int) -> int:
        log.debug(f"Ssc_flushMacAddr pbmp=0x{pbmp:x}")
        return 0

    def fdb_add_ucast(self, mac: bytes, is_tagged: int, pbmp: int) -> int:
        log.debug(f"Ssc_fdbAddUcastEntry mac={mac.hex()} pbmp=0x{pbmp:x}")
        return 0

    def fdb_find(self, mac: bytes) -> Optional[dict]:
        return None

    #  LED 

    def set_fault_led(self, val: int):
        log.debug(f"Ssc_setFaultLed {val}")

    def clear_fault_led(self, val: int):
        log.debug(f"Ssc_clearFaultLed {val}")

    #  learning 

    def port_learning_disable(self, port: int) -> int:
        log.debug(f"Ssc_port_learing_disable port={port}")
        return 0

    def port_learning_enable(self, port: int) -> int:
        log.debug(f"Ssc_port_learing_enable port={port}")
        return 0


# 
# Software simulation backend  (no hardware needed)
# 

class SimSwitchBackend(SwitchBackend):
    """
    Pure-Python switch simulator.  Tracks port states, link states, FDB.
    Packet I/O uses socketpair() pairs so multiple sim-daemons can talk.
    """

    def __init__(self, port_count: int = 10):
        self.instance_id = -1
        self.port_count  = port_count
        self._port_state = [PortState.FORWARDING] * port_count
        self._port_link  = [True]  * port_count
        self._port_learn = [True]  * port_count
        self._fdb: dict  = {}          # mac_hex -> {"port": int, "vid": int}
        self._fault_led  = 0
        # socket pairs per port: (tx_end, rx_end) : cross-platform
        self._port_socks: List[Tuple[socket.socket, socket.socket]] = []
        for _ in range(port_count):
            a, b = make_wakeup_pair()
            self._port_socks.append((a, b))
        # inbound queue per ring (port -> list[bytes])
        self._rx_queue: List[List[bytes]] = [[] for _ in range(port_count)]

    def inject_frame(self, port: int, frame: bytes):
        """Test helper : inject a frame as if it arrived on port."""
        self._rx_queue[port].append(frame)
        try:
            _, w = self._port_socks[port]
            w.send(b'\x01')
        except Exception:
            pass

    #  port state 

    def set_port_state(self, port: int, state: int) -> int:
        log.info(f"[SIM] Ssc_setPortState port={port} "
                 f"{PORT_STATE_STR.get(state, state)!r}")
        if 0 <= port < self.port_count:
            self._port_state[port] = state
        return 0

    def get_port_state(self, port: int) -> int:
        return self._port_state[port] if 0 <= port < self.port_count else 0

    def get_port_link(self, port: int) -> bool:
        return self._port_link[port] if 0 <= port < self.port_count else False

    def set_port_enable(self, port: int, enable: bool) -> int:
        log.info(f"[SIM] Ssc_port_enable_set port={port} enable={enable}")
        if 0 <= port < self.port_count:
            self._port_state[port] = (PortState.FORWARDING if enable
                                      else PortState.DISABLE)
        return 0

    #  packet I/O 

    def send_frame(self, tx_fd=None, raw_fd=None, port: int = 0,
                   frame: bytes = b"", vid: int = 0) -> int:
        log.debug(f"[SIM] send_frame node={getattr(self, 'instance_id', -1)} port={port} len={len(frame)}")

        # GUI Link Forwarding
        if getattr(self, "instance_id", -1) != -1 and GLOBAL_LINKS and GLOBAL_DAEMONS:
            for l in GLOBAL_LINKS:
                if not l.get("active", True):
                    continue
                # Forward N1 -> N2
                if l["n1"] == self.instance_id and l["p1"] == port:
                    dst_node = l["n2"]
                    dst_port = l["p2"]
                    if 0 <= dst_node < len(GLOBAL_DAEMONS):
                        GLOBAL_DAEMONS[dst_node].ssc.sw.inject_frame(dst_port, frame)
                # Forward N2 -> N1
                elif l["n2"] == self.instance_id and l["p2"] == port:
                    dst_node = l["n1"]
                    dst_port = l["p1"]
                    if 0 <= dst_node < len(GLOBAL_DAEMONS):
                        GLOBAL_DAEMONS[dst_node].ssc.sw.inject_frame(dst_port, frame)

        return len(frame)

    def recv_frame(self, fd=None) -> Tuple[Optional[bytes], int]:
        # fd maps to port index via position in _port_socks
        for port, (tx, rx) in enumerate(self._port_socks):
            if tx.fileno() == fd or rx.fileno() == fd:
                if self._rx_queue[port]:
                    frame = self._rx_queue[port].pop(0)
                    return frame, port
        return None, 0

    #  MAC / FDB 

    def fdb_flush(self, pbmp: int) -> int:
        removed = [m for m, e in self._fdb.items()
                   if (1 << e["port"]) & pbmp]
        for m in removed:
            del self._fdb[m]
        return 0

    def fdb_add_ucast(self, mac: bytes, is_tagged: int, pbmp: int) -> int:
        port = (pbmp & -pbmp).bit_length() - 1  # lowest set bit
        self._fdb[mac.hex()] = {"port": port, "vid": 0, "tagged": is_tagged}
        return 0

    def fdb_find(self, mac: bytes) -> Optional[dict]:
        return self._fdb.get(mac.hex())

    #  LED 

    def set_fault_led(self, val: int):
        log.warning(f"[SIM] *** FAULT LED ON ({val}) ***")
        self._fault_led = 1

    def clear_fault_led(self, val: int):
        log.info(f"[SIM] fault LED cleared ({val})")
        self._fault_led = 0

    #  learning 

    def port_learning_disable(self, port: int) -> int:
        self._port_learn[port] = False
        return 0

    def port_learning_enable(self, port: int) -> int:
        self._port_learn[port] = True
        return 0


# 
# Ssc facade  (thin wrappers matching binary function names exactly)
# 

from tr2d_structs import PORT_STATE_STR   # re-import for use below

class Ssc:
    """
    Drop-in Python equivalent of all Ssc_* functions.
    Constructed once and shared across ring/coupling/LHC layers.
    """

    def __init__(self, backend: SwitchBackend,
                 mac_addr:        bytes = bytes(6),
                 tx_fd:           int   = -1,
                 ring_bridge_ids: list  = None):
        self.sw  = backend
        self.mac = mac_addr          # byte_27314 : our own MAC
        self.tx_fd = tx_fd           # dword_2AA8C (AF_PACKET raw socket)
        # dword_2AD30 / dword_2AD34 : per-ring destination bridge MACs
        # set by tr2_initRing; default to own MAC until configured
        self.ring_bridge_ids: list = ring_bridge_ids or [bytes(6), bytes(6)]

    #  port state 

    def Ssc_setPortState(self, port: int, state: int, instance: int = 0) -> int:
        log.debug(f"Ssc_setPortState port={port} state={PORT_STATE_STR.get(state, state)!r}")
        return self.sw.set_port_state(port, state)

    def Ssc_getPortState(self, port: int) -> int:
        s = self.sw.get_port_state(port)
        log.debug(f"Ssc_getPortState port={port} -> {PORT_STATE_STR.get(s, s)!r}")
        return s

    def Ssc_getPortLinkState(self, port: int) -> bool:
        return self.sw.get_port_link(port)

    def Ssc_port_enable_set(self, port: int, enable: bool) -> int:
        return self.sw.set_port_enable(port, enable)

    def Ssc_port_learing_disable(self, port: int) -> int:   # typo preserved
        return self.sw.port_learning_disable(port)

    def Ssc_port_learing_enable(self, port: int) -> int:
        return self.sw.port_learning_enable(port)

    def Ssc_isGigaCopperLink(self, port: int) -> bool:
        """sub_16A0C : checks giga-copper bitmap"""
        return False  # simulator default

    #  LED 

    def Ssc_setFaultLed(self, val: int):
        self.sw.set_fault_led(val)

    def Ssc_clearFaultLed(self, val: int):
        self.sw.clear_fault_led(val)

    #  FDB 

    def Ssc_flushMacAddr(self, pbmp: int) -> int:
        log.debug(f"Ssc_flushMacAddr pbmp=0x{pbmp:x}")
        return self.sw.fdb_flush(pbmp)

    def Ssc_fdbAddUcastEntry(self, mac: bytes, is_tagged: int, pbmp: int) -> int:
        log.debug(f"Ssc_fdbAddUcastEntry mac={mac.hex()} pbmp=0x{pbmp:x}")
        return self.sw.fdb_add_ucast(mac, is_tagged, pbmp)

    def Ssc_fdbFindMacEntry(self, mac: bytes) -> Optional[dict]:
        return self.sw.fdb_find(mac)

    #  packet send 

    def Ssc_sendTR2Packet(self, tx_fd: int, raw_fd: int, ring_id: int,
                          port: int, payload: bytes, vid: int = 0,
                          use_mcast_sa: bool = False) -> int:
        """
        Ssc_sendTR2Packet @ 0x1BE4C
        Builds ethernet frame with DSA tag and sends on raw socket.
        dword_2AD30 / dword_2AD34 = per-ring bridge IDs stored on Ssc instance.
        """
        # DA = ring bridge ID (dword_2AD30 for ring 0, dword_2AD34 for ring 1)
        da = self.ring_bridge_ids[ring_id] if ring_id < len(self.ring_bridge_ids) else self.mac
        sa = self.mac
        frame = build_tr2_frame(da, sa, port, ring_id, payload, vid)
        log.debug(f"Ssc_sendTR2Packet ring={ring_id} port={port} len={len(frame)}")
        n = self.sw.send_frame(tx_fd, raw_fd, port, frame, vid)
        return n

    def Ssc_sendBpduPacket(self, tx_fd: int, raw_fd: int, port: int,
                           payload: bytes, vid: int = 0,
                           use_mcast_sa: bool = False) -> int:
        """Ssc_sendBpduPacket @ 0x1BCB0"""
        from tr2d_structs import MCAST_BPDU_DA
        sa = self.mac
        frame = build_tr2_frame(MCAST_BPDU_DA, sa, port, 0, payload, vid)
        log.debug(f"Ssc_sendBpduPacket port={port} len={len(frame)}")
        return self.sw.send_frame(tx_fd, raw_fd, port, frame, vid)

    def Ssc_sendPacket(self, tx_fd: int, raw_fd: int, port: int,
                       da: bytes, payload: bytes, vid: int = 0) -> int:
        """Ssc_sendPacket @ 0x1BB50 : generic frame send"""
        frame = build_tr2_frame(da, self.mac, port, 0, payload, vid)
        return self.sw.send_frame(tx_fd, raw_fd, port, frame, vid)


# 
# Sstap helpers  (Sstap_transmitCouplerTCNego / Sstap_transmitLinkupConfirm)
# These build specific packet types and call Ssc_sendTR2Packet
# 

def Sstap_transmitCouplerTCNego(ssc: 'Ssc', tx_fd: int, raw_fd: int,
                                 port: int, ring_id: int):
    """
    Sstap_transmitCouplerTCNego @ 0x139FC
    Sends a Topology Change Negotiation packet on the coupling port.
    """
    from tr2d_structs import build_tr2_payload, PktType
    payload = build_tr2_payload(PktType.COUPLER_TC, ring_id, bytes(4))
    log.debug(f"Sstap_transmitCouplerTCNego port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring_id, port, payload)

def Sstap_transmitLinkupConfirm(ssc: 'Ssc', tx_fd: int, raw_fd: int,
                                 port: int, ring_id: int):
    """
    Sstap_transmitLinkupConfirm @ 0x13AB8
    Sends a link-up confirmation packet.
    """
    from tr2d_structs import build_tr2_payload, PktType
    payload = build_tr2_payload(PktType.FWD_REQUEST, ring_id, bytes(4))
    log.debug(f"Sstap_transmitLinkupConfirm port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring_id, port, payload)
