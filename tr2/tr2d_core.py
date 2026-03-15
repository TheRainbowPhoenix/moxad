"""
tr2d_core.py  —  TurboRing2 daemon core state machines

Covers:
  tr2_*     — ring-level state machine (tr2_ringMain, tr2_ringAux, timers, pkts)
  Mgmt*     — management/IPC helpers (MgmtTR2Wait, MgmtRecvTR2Packet, …)
  lhc_*     — Link Health Check state machine
  Slhc_*    — LHC main thread
  Str2_*    — polling-timer helpers
  Ssys_*    — system time helpers
"""

import os
import time
import socket
import struct
import select
import threading
import logging
from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict

from tr2d_structs import (
    TR2Config, RingConfig, CouplingConfig, CouplingInfo, RingInfo,
    LHCPortInfo, PortInfo, PortState, CouplingMode, LhcFlags, PktType,
    TR2_SOCKET_PATH, MSG_SIZE, READ_BUF, DEFAULT_WAIT_MS,
    TR2_PKT_MAGIC, LOG_ERROR, LOG_WARN, LOG_NOTICE, LOG_INFO,
    LOG_DEBUG5, LOG_DEBUG6, LOG_DEBUG7,
    build_tr2_payload, build_tr2_frame, dsa_parse,
    MAX_RINGS,
)
from ssc import Ssc, SimSwitchBackend
from compat import (
    IS_WINDOWS, make_wakeup_pair, wait_readable, fd_write, fd_read,
)

log = logging.getLogger("tr2d.core")


# ─────────────────────────────────────────────────────────────────────────────
# Ssys_ helpers  (wall-clock time, mirrors Ssys_current_msecs / _secs)
# ─────────────────────────────────────────────────────────────────────────────

def Ssys_current_msecs() -> int:
    """Ssys_current_msecs @ 0x1C290 — monotonic ms"""
    return int(time.monotonic() * 1000)

def Ssys_current_secs() -> int:
    """Ssys_current_secs @ 0x1C220"""
    return int(time.monotonic())


# ─────────────────────────────────────────────────────────────────────────────
# Polling-timer state  (Str2_pollingTimer*)
#
# Binary: dword_27ED0[4] — array of {flag_ptr, type} per ring
#         tr2_polling_flag_init initialises these
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class PollingTimer:
    """Mirrors the timer-flag / trigger mechanism in the binary."""
    index:     int
    flag:      threading.Event = field(default_factory=threading.Event)
    type_:     int = 0           # POLLING_TYPE_*
    interval:  int = 500         # ms
    active:    bool = False
    _thread:   Optional[threading.Thread] = field(default=None, repr=False)
    _stop:     threading.Event  = field(default_factory=threading.Event)

    def start(self, interval_ms: int, one_shot: bool = False):
        """Str2_pollingTimerReset"""
        self._stop.clear()
        self.interval = interval_ms
        self.active   = True
        self._thread = threading.Thread(
            target=self._run, args=(one_shot,), daemon=True,
            name=f"polltimer-{self.index}")
        self._thread.start()

    def stop(self):
        self._stop.set()
        self.active = False

    def set_flag(self):
        """Str2_pollingTimerFlagSet — notify the ring thread"""
        self.flag.set()

    def _run(self, one_shot: bool):
        while not self._stop.is_set():
            self._stop.wait(self.interval / 1000.0)
            if not self._stop.is_set():
                self.flag.set()
                if one_shot:
                    break


# ─────────────────────────────────────────────────────────────────────────────
# Ring member list  (Srml_* helpers, sub_127F4 / sub_1264C / sub_126E0)
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class RingMemberEntry:
    """One entry in the ring-member list queue."""
    mac:        bytes = field(default_factory=lambda: bytes(6))
    flag:       int   = 0
    seq:        int   = 0

class RingMemberList:
    """Srml_checkRingMemberListQueue etc."""

    def __init__(self):
        self._entries: List[RingMemberEntry] = []
        self._lock = threading.Lock()

    def enqueue(self, mac: bytes, flag: int) -> int:
        """sub_127F4"""
        with self._lock:
            e = RingMemberEntry(mac=mac, flag=flag)
            self._entries.append(e)
            return len(self._entries)

    def dequeue(self) -> Optional[RingMemberEntry]:
        with self._lock:
            return self._entries.pop(0) if self._entries else None

    def clear(self):
        with self._lock:
            self._entries.clear()


# ─────────────────────────────────────────────────────────────────────────────
# CouplingState  (per-ring coupling object, pointed to by ring.coupling_ptr)
#
# Binary offsets (from tr2_initCoupling / sub_9D40):
#   [0]   active        u8
#   [1]   mode          u8   CouplingMode
#   [2]   local_active  u8
#   [3]   is_blocked    u8
#   [4]   _pad
#   ...
#   [8]   primary_port  u8
#   [9]   partner_port1 u8
#   [10]  p1_link       u8
#   [16]  backup_port   u8
#   [17]  partner_port2 u8
#   [18]  p2_link       u8
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class CouplingState:
    active:        int = 0
    mode:          int = CouplingMode.NONE
    local_active:  int = 0
    is_blocked:    int = 0
    primary_port:  int = 0
    partner_port1: int = 0
    p1_link:       int = 0
    backup_port:   int = 0
    partner_port2: int = 0
    p2_link:       int = 0

    def to_coupling_info(self) -> CouplingInfo:
        return CouplingInfo(
            active   = self.active,
            mode     = self.mode,
            port1_id = self.primary_port,
            port1    = PortState.FORWARDING if self.p1_link else PortState.BLOCKED,
            port2_id = self.backup_port,
            port2    = PortState.FORWARDING if self.p2_link else PortState.BLOCKED,
        )


# ─────────────────────────────────────────────────────────────────────────────
# RingState  (the big struct_ring in the binary)
#
# Critical offsets from tr2_ringMain / tr2_initRing / tr2_showBuffer:
#   id              int   (ring index 0/1)
#   status          u8    1=Healthy  0=Break   (offset 28)
#   active          u8    (offset 30)
#   is_master       u8    (offset 31)
#   main_port       u8    (offset 32)
#   backup_port     u8    (offset 33)
#   topo_change_cnt u8    (offset 40)
#   master_id[8]          (offset 18)
#   bridge_id[8]          (offset 10)
#   ports[2]  PortInfo    (offsets 336, 344)
#   coupling_ptr          (offset 352)
#   mutex                 (pthread_mutex)
#   + various timer/flag fields
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class RingState:
    id:             int   = 0
    status:         int   = 1        # 1=Healthy, 0=Break
    active:         int   = 1
    is_master:      int   = 0
    main_port:      int   = 0
    backup_port:    int   = 0
    topo_change_cnt:int   = 0
    master_age:     int   = 0
    master_id:      bytes = field(default_factory=lambda: bytes(8))
    bridge_id:      bytes = field(default_factory=lambda: bytes(8))
    bpdu_dest:      bytes = field(default_factory=lambda: bytes(6))
    faulted:        int   = 0
    need_init:      int   = 1        # True when ring is newly configured
    need_start:     Optional['CouplingState'] = None
    priority:       int   = 0xFF     # 0=master-prio  0xFF=slave
    ports:          List[PortInfo] = field(
                        default_factory=lambda: [PortInfo(), PortInfo()])
    coupling:       Optional[CouplingState] = None
    member_list:    RingMemberList = field(default_factory=RingMemberList)
    polling_timer:  Optional[PollingTimer]  = None

    # runtime
    some_ms_time:   int   = 0
    some_ms_hi:     int   = 0
    _lock:          threading.Lock = field(default_factory=threading.Lock,
                                           repr=False)
    # MgmtTR2 notification socket pair
    _wakeup_w:      Optional[socket.socket] = field(default=None, repr=False)
    _wakeup_r:      Optional[socket.socket] = field(default=None, repr=False)

    def __post_init__(self):
        r, w = make_wakeup_pair()
        self._wakeup_r = r
        self._wakeup_w = w
        if self.polling_timer is None:
            self.polling_timer = PollingTimer(self.id)

    def to_ring_info(self) -> RingInfo:
        return RingInfo(
            ring_id           = self.id + 1,
            bpdu_dest         = self.bpdu_dest,
            bridge_id         = self.bridge_id,
            master_id         = self.master_id,
            status            = self.status,
            active            = self.active,
            is_master         = self.is_master,
            main_port         = self.main_port,
            backup_port       = self.backup_port,
            topo_change_count = self.topo_change_cnt,
            master_age        = self.master_age,
            ports             = list(self.ports),
        )


# ─────────────────────────────────────────────────────────────────────────────
# LHC port state  (byte_2AA98[64*i + ...])
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class LhcPortState:
    """One entry of the 64-byte per-port block in byte_2AA98."""
    link_partner:   bytes = field(default_factory=lambda: bytes(6))
    partner_port:   int   = 0
    lhc_checking:   int   = 0
    state:          int   = 0       # LHC FSM state (0,1,2)
    partner_state:  int   = 0
    lhc_recv:       int   = 0
    lhc_status:     int   = 0
    lhc_polling:    int   = 0
    flags:          int   = 0       # LhcFlags bitmask  (byte_2AA98[64*i+7])
    status_flags:   int   = 0       # byte_2AA98[64*i+11]
    lhc_established:int   = 0       # byte_2AA98[64*i+10]
    check_timer:    Optional[PollingTimer] = None
    delay_timer:    Optional[PollingTimer] = None

    def to_wire(self) -> LHCPortInfo:
        return LHCPortInfo(
            link_partner  = self.link_partner,
            partner_port  = self.partner_port,
            lhc_checking  = self.lhc_checking,
            state         = self.state,
            partner_state = self.partner_state,
            lhc_recv      = self.lhc_recv,
            lhc_status    = self.lhc_status,
            lhc_polling   = self.lhc_polling,
        )


# ─────────────────────────────────────────────────────────────────────────────
# Mgmt* — ring notification / packet receive
# ─────────────────────────────────────────────────────────────────────────────

def MgmtTR2Wakeup(ring: RingState):
    """MgmtTR2Wakeup @ 0x1322C — send 1-byte wakeup to ring thread"""
    log.debug(f"[TR2]> MgmtTR2Wakeup() ring {ring.id}")
    try:
        ring._wakeup_w.send(b'\x01')
    except OSError:
        pass

def MgmtTR2Start(ring: RingState):
    """MgmtTR2Start @ 0x13268"""
    log.debug(f"[TR2]> MgmtTR2Start() ring {ring.id}")
    MgmtTR2Wakeup(ring)

def MgmtTR2Stop(ring: RingState):
    """MgmtTR2Stop @ 0x132AC"""
    log.debug(f"[TR2]> MgmtTR2Stop() ring {ring.id}")

def MgmtTR2Wait(ring: RingState, timeout_ms: int = DEFAULT_WAIT_MS) -> int:
    """
    MgmtTR2Wait @ 0x132E8 — poll ring wakeup socket.
    Returns >0 if data available, -1 on timeout.
    """
    log.debug(f"[TR2]> MgmtTR2Wait() ring {ring.id}")
    try:
        if wait_readable([ring._wakeup_r], timeout_ms / 1000.0):
            ring._wakeup_r.recv(64)   # drain
            return 1
    except OSError:
        pass
    now = Ssys_current_msecs()
    log.debug(f"[TR2]> MgmtTR2Wait() {ring.id} ret=-1 Tcurr={now} WAIT TIMEOUT")
    return -1

def MgmtRecvTR2Packet(ring: RingState, raw_fd,
                      ring0_bridge_id: bytes, ring1_bridge_id: bytes,
                      ssc: "Ssc" = None
                      ) -> Tuple[int, Optional[bytes], int]:
    """
    MgmtRecvTR2Packet @ 0x1342C
    Reads one frame from the raw socket (real HW) or the backend queue (sim).
    Validates it belongs to this ring and strips the DSA tag.
    Returns (pkt_len, pkt_buf, src_port)  or  (0/−1, None, 0).
    """
    data = None
    src_port = 0

    # ── sim path: drain from backend's per-port frame queue ──────────────────
    if (raw_fd is None or raw_fd == -1) and ssc is not None:
        frame, src_port = ssc.sw.recv_frame()
        if frame:
            data = frame
        else:
            return 0, None, 0

    # ── hardware path: read from raw AF_PACKET socket ────────────────────────
    else:
        if raw_fd is None or raw_fd == -1:
            return 0, None, 0
        try:
            rd = raw_fd if isinstance(raw_fd, socket.socket) else None
            if rd is None or not wait_readable([rd], 0):
                return 0, None, 0
            data = rd.recv(1518)
        except OSError as e:
            log.error(f"MgmtRecvTR2Packet recvfrom error: {e}")
            return -1, None, 0
        if len(data) < 20:
            return 0, None, 0
        src_port, _vid = dsa_parse(data[12:16])

    if not data or len(data) < 20:
        return 0, None, 0

    # DSA tag at offset 12; strip it → re-assemble without DSA
    pkt = data[0:12] + data[16:]
    return len(pkt), pkt, src_port


# ─────────────────────────────────────────────────────────────────────────────
# tr2_ packet builders
# ─────────────────────────────────────────────────────────────────────────────

def tr2_sendPollingPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                       ring: RingState, port_idx: int):
    """tr2_sendPollingPkt @ 0x103A0"""
    port = ring.ports[port_idx].port_id
    payload = build_tr2_payload(PktType.POLLING, ring.id, bytes(8))
    log.debug(f"tr2_sendPollingPkt ring={ring.id} port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, port, payload)

def tr2_forwardPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                   ring: RingState, port_idx: int, pkt: bytes) -> int:
    """tr2_forwardPkt @ 0x10554 — forward a received packet out the other port"""
    out_port = ring.ports[1 - port_idx].port_id
    log.debug(f"tr2_forwardPkt ring={ring.id} → port={out_port} len={len(pkt)}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, out_port, pkt)

def tr2_sendRingPortDownNegoPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                                 ring: RingState, port_idx: int):
    """tr2_sendRingPortDownNegoPkt @ 0x105FC"""
    port = ring.ports[port_idx].port_id
    payload = build_tr2_payload(PktType.RING_PORT_DOWN, ring.id,
                                 ring.master_id[:6])
    log.debug(f"tr2_sendRingPortDownNegoPkt ring={ring.id} port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, port, payload)

def tr2_sendCouplerNegoPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                            ring: RingState, port_idx: int,
                            flag: int, mode: int):
    """tr2_sendCouplerNegoPkt @ 0x106FC"""
    port = ring.ports[port_idx].port_id
    payload = build_tr2_payload(PktType.COUPLER_NEGO, ring.id,
                                 bytes([flag, mode]) + bytes(4))
    log.debug(f"tr2_sendCouplerNegoPkt ring={ring.id} port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, port, payload)

def tr2_sendCouplerTopologyChangedPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                                       ring: RingState, port_idx: int, flag: int):
    """tr2_sendCouplerTopologyChangedPkt @ 0x1088C"""
    port = ring.ports[port_idx].port_id
    payload = build_tr2_payload(PktType.COUPLER_TC, ring.id, bytes([flag]) + bytes(3))
    log.debug(f"tr2_sendCouplerTopologyChangedPkt ring={ring.id} port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, port, payload)

def tr2_sendForwardingRequestNegoPkt(ssc: Ssc, tx_fd: int, raw_fd: int,
                                      ring: RingState, port_idx: int, flag: int):
    """tr2_sendForwardingRequestNegoPkt @ 0x1097C"""
    port = ring.ports[port_idx].port_id
    payload = build_tr2_payload(PktType.FWD_REQUEST, ring.id, bytes([flag]) + bytes(3))
    log.debug(f"tr2_sendForwardingRequestNegoPkt ring={ring.id} port={port}")
    return ssc.Ssc_sendTR2Packet(tx_fd, raw_fd, ring.id, port, payload)


# ─────────────────────────────────────────────────────────────────────────────
# Timer-expiry callbacks  (tr2_*TimerExpiry* @ various addresses)
# ─────────────────────────────────────────────────────────────────────────────

def tr2_masterAliveTimerExpiry(ring: RingState, ssc: Ssc, tx_fd: int, raw_fd: int):
    """tr2_masterAliveTimerExpiry @ 0x10BB8"""
    now = Ssys_current_msecs()
    log.debug(f"tr2_masterAliveTimerExpiry ring={ring.id} t={now}")
    # if we are master and haven't heard from partner → mark break
    ring.master_age += 1

def tr2_ringPortForwardDelayTimerExpiry(ring: RingState, port_idx: int,
                                         ssc: Ssc, tx_fd: int, raw_fd: int):
    """tr2_ringPortForwardDelayTimerExpiry @ 0x10F80"""
    now = Ssys_current_msecs()
    log.debug(f"tr2_ringPortForwardDelayTimerExpiry ring={ring.id} port={port_idx} t={now}")
    ring.ports[port_idx].state = PortState.FORWARDING
    ssc.Ssc_setPortState(ring.ports[port_idx].port_id, PortState.FORWARDING)

def tr2_ringPortForwardRequestTimerExpiry(ring: RingState, port_idx: int,
                                           ssc: Ssc, tx_fd: int, raw_fd: int):
    """tr2_ringPortForwardRequestTimerExpiry @ 0x112D8"""
    now = Ssys_current_msecs()
    log.debug(f"tr2_ringPortForwardRequestTimerExpiry ring={ring.id} port={port_idx} t={now}")
    tr2_sendForwardingRequestNegoPkt(ssc, tx_fd, raw_fd, ring, port_idx, 1)

def tr2_startRingPortForwardRequestTimer(ring: RingState, port_idx: int):
    """tr2_startRingPortForwardRequestTimer @ 0x11150"""
    log.debug(f"tr2_startRingPortForwardRequestTimer ring={ring.id} port={port_idx}")
    ring.polling_timer.start(500)

def tr2_startCouplingPortLinkChangedTimer(ring: RingState):
    """tr2_startCouplingPortLinkChangedTimer @ 0x11630"""
    log.debug(f"tr2_startCouplingPortLinkChangedTimer ring={ring.id}")
    ring.polling_timer.start(200)

def tr2_couplingPortLinkChangedTimerExpiry(ring: RingState,
                                            ssc: Ssc, tx_fd: int, raw_fd: int):
    """tr2_couplingPortLinkChangedTimerExpiry @ 0x117C0"""
    now = Ssys_current_msecs()
    log.debug(f"tr2_couplingPortLinkChangedTimerExpiry ring={ring.id} t={now}")
    if ring.coupling:
        ring.coupling.p1_link = ssc.Ssc_getPortLinkState(ring.coupling.primary_port)
        ring.coupling.p2_link = ssc.Ssc_getPortLinkState(ring.coupling.backup_port)


# ─────────────────────────────────────────────────────────────────────────────
# tr2_checkMasterStatus  (@ 0xA66C)
# ─────────────────────────────────────────────────────────────────────────────

def tr2_checkMasterStatus(ring: RingState, ssc: Ssc):
    """
    tr2_checkMasterStatus @ 0xA66C
    Periodically called from tr2_ringMain (~1 s).
    Updates is_master based on bridge-id priority comparison.
    """
    log.debug(f"tr2_checkMasterStatus ring={ring.id}")
    # Simple: if priority byte is 0 we are master-capable
    ring.is_master = 1 if ring.priority == 0 else 0


# ─────────────────────────────────────────────────────────────────────────────
# tr2_activeConfig  (@ 0xC1D8) — apply a new TR2Config to all rings
# ─────────────────────────────────────────────────────────────────────────────

def tr2_activeConfig(cfg: TR2Config, rings: List[RingState],
                     coupling_state: Optional[CouplingState],
                     ssc: Ssc):
    """
    tr2_activeConfig @ 0xC1D8
    Apply configuration change: update ring/coupling state, set port modes.
    """
    log.info(f"[TR2]> tr2_activeConfig diff Ring0:{cfg.rings[0].enabled} Ring1:{cfg.rings[1].enabled}")
    for i, ring in enumerate(rings):
        rcfg = cfg.rings[i]
        ring.active   = rcfg.enabled
        ring.priority = rcfg.priority
        ring.main_port   = rcfg.port0
        ring.backup_port = rcfg.port1
        if ring.ports:
            ring.ports[0].port_id = rcfg.port0
            ring.ports[1].port_id = rcfg.port1
        if not rcfg.enabled:
            # disable ring ports
            for p in ring.ports:
                if p.port_id:
                    ssc.Ssc_setPortState(p.port_id - 1, PortState.FORWARDING)
    # coupling
    if coupling_state and cfg.coupling:
        coupling_state.mode         = cfg.coupling.mode
        coupling_state.primary_port = cfg.coupling.primary_port
        coupling_state.backup_port  = cfg.coupling.backup_port


# ─────────────────────────────────────────────────────────────────────────────
# LHC  —  Link Health Check state machine
# ─────────────────────────────────────────────────────────────────────────────

def lhc_sendLhcPkt(port: LhcPortState, ssc: Ssc,
                    tx_fd: int, raw_fd: int, port_idx: int):
    """lhc_sendLhcPkt @ 0x13D3C — send LHC probe packet"""
    from tr2d_structs import build_tr2_payload
    payload = build_tr2_payload(PktType.LHC, 0, ssc.mac + bytes([port.state]))
    log.debug(f"lhc_sendLhcPkt port={port_idx} state={port.state}")
    return ssc.Ssc_sendPacket(tx_fd, raw_fd, port_idx, ssc.mac, payload)

def lhc_linkHealthCheckTimerExpired(port: LhcPortState,
                                     now_ts: Tuple[int, int]) -> bool:
    """lhc_linkHealthCheckTimerExpired @ 0x152D8"""
    if port.check_timer and port.check_timer.flag.is_set():
        port.check_timer.flag.clear()
        return True
    return False

def lhc_linkHealthCheckTimerExpiry(port_idx: int, port: LhcPortState,
                                    ssc: Ssc, tx_fd: int, raw_fd: int):
    """lhc_linkHealthCheckTimerExpiry @ 0x154C4"""
    now = Ssys_current_msecs()
    log.debug(f"lhc_linkHealthCheckTimerExpiry port={port_idx} t={now}")
    port.lhc_recv = 0
    lhc_sendLhcPkt(port, ssc, tx_fd, raw_fd, port_idx)

def lhc_linkHealthDelayTimerExpired(port: LhcPortState,
                                     now_ts: Tuple[int, int]) -> bool:
    """lhc_linkHealthDelayTimerExpired @ 0x156A0"""
    if port.delay_timer and port.delay_timer.flag.is_set():
        port.delay_timer.flag.clear()
        return True
    return False

def lhc_linkHealthDelayTimerExpiry(port_idx: int, port: LhcPortState,
                                    ssc: Ssc, tx_fd: int, raw_fd: int):
    """lhc_linkHealthDelayTimerExpiry @ 0x157E0"""
    now = Ssys_current_msecs()
    log.debug(f"lhc_linkHealthDelayTimerExpiry port={port_idx} t={now}")
    # advance LHC state machine
    if port.state < 2:
        port.state += 1
    lhc_sendLhcPkt(port, ssc, tx_fd, raw_fd, port_idx)


# ─────────────────────────────────────────────────────────────────────────────
# Slhc_main  —  LHC thread main loop
# ─────────────────────────────────────────────────────────────────────────────

class SlhcThread:
    """
    Slhc_main @ 0x144B0 — LHC thread.
    Spawned by main() via pthread_create.
    """

    def __init__(self, ssc: Ssc, lhc_port_count: int = 4,
                 tx_fd: int = -1, raw_fd: int = -1):
        self.ssc      = ssc
        self.tx_fd    = tx_fd
        self.raw_fd   = raw_fd
        self.ports:   List[LhcPortState] = [LhcPortState() for _ in range(lhc_port_count)]
        self._stop    = threading.Event()
        self._ready   = threading.Event()
        self._thread: Optional[threading.Thread] = None
        # wakeup socket pair (MgmtLhcWait)
        self._wakeup_r, self._wakeup_w = make_wakeup_pair()
        # sem (mirrors sem in binary)
        self._sem     = threading.Semaphore(1)

    def start(self):
        self._thread = threading.Thread(target=self._main_loop,
                                        daemon=True, name="Slhc_main")
        self._thread.start()
        log.info("Slhc_main starting")

    def stop(self):
        self._stop.set()
        self._wakeup_w.send(b'\x01')

    def wakeup(self, port_idx: int):
        """MgmtLhcWait notification"""
        self._wakeup_w.send(struct.pack("B", port_idx))

    def _main_loop(self):
        log.info("[LHC]> Slhc_main thread running")
        now_buf = [0, 0, 0]   # Ssys_current_msecs result buffer

        while not self._stop.is_set():
            # MgmtLhcWait
            readable = wait_readable([self._wakeup_r], 0.5)
            v7 = 1 if readable else -1
            if readable:
                data = self._wakeup_r.recv(64)
                port_idx = data[0] if data else 0
            else:
                port_idx = 0
            log.debug(f"[LHC]> Slhc_main() ret={v7}")

            # timer processing for all ports
            now_buf[0] = Ssys_current_msecs()
            for i, port in enumerate(self.ports):
                if not port.flags:
                    continue
                if (port.flags & LhcFlags.PARTNER) and \
                        lhc_linkHealthCheckTimerExpired(port, now_buf):
                    lhc_linkHealthCheckTimerExpiry(i, port,
                                                   self.ssc, self.tx_fd, self.raw_fd)
                if lhc_linkHealthDelayTimerExpired(port, now_buf):
                    lhc_linkHealthDelayTimerExpiry(i, port,
                                                   self.ssc, self.tx_fd, self.raw_fd)

            # drain received LHC packets if wakeup had data
            if v7 > 0:
                self._process_lhc_pkt(port_idx)

        log.info("[LHC]> Slhc_main thread stopped")

    def _process_lhc_pkt(self, port_idx: int):
        """Process an incoming LHC packet for port_idx."""
        port = self.ports[port_idx]
        port.lhc_recv += 1
        log.debug(f"[LHC]> Slhc_main recv port={port_idx} lhc_recv={port.lhc_recv}")


# ─────────────────────────────────────────────────────────────────────────────
# Llhc helpers
# ─────────────────────────────────────────────────────────────────────────────

def Llhc_sendLhcInfo(client_fd: int, lhc_thread: SlhcThread):
    """
    Llhc_sendLhcInfo @ 0x13CB8 — reply to STATUS/LHC request.
    Serialises all LHC port states and writes to client socket.
    """
    payload = b"".join(p.to_wire().pack() for p in lhc_thread.ports)
    try:
        if isinstance(client_fd, socket.socket):
            client_fd.sendall(payload)
        elif client_fd >= 0:
            os.write(client_fd, payload)
        log.debug(f"Llhc_sendLhcInfo: replied {len(payload)} bytes")
    except OSError as e:
        log.error(f"Llhc_sendLhcInfo write error: {e}")


# ─────────────────────────────────────────────────────────────────────────────
# tr2_ringMain  —  per-ring main thread
# ─────────────────────────────────────────────────────────────────────────────

class RingMainThread:
    """
    tr2_ringMain @ 0xACA0 — main ring state-machine thread.
    One instance per ring.
    """

    def __init__(self, ring: RingState, cfg: TR2Config,
                 ssc: Ssc, tx_fd: int, raw_fd: int,
                 ring0_bridge_id: bytes = bytes(6),
                 ring1_bridge_id: bytes = bytes(6)):
        self.ring    = ring
        self.cfg     = cfg
        self.ssc     = ssc
        self.tx_fd   = tx_fd
        self.raw_fd  = raw_fd
        self.bids    = [ring0_bridge_id, ring1_bridge_id]
        self._stop   = threading.Event()
        self._thread: Optional[threading.Thread] = None

    def start(self):
        self._thread = threading.Thread(
            target=self._main_loop, daemon=True,
            name=f"tr2_ringMain-{self.ring.id}")
        self._thread.start()

    def stop(self):
        self._stop.set()
        MgmtTR2Wakeup(self.ring)

    def _main_loop(self):
        ring = self.ring
        log.info(f"tr2_ringMain ring={ring.id} started")

        ring._lock = threading.Lock()
        old_status = ring.status

        if ring.need_init:
            ring.polling_timer.start(500)
            log.debug(f"tr2_ringMain ring={ring.id} init path, polling timer started")

        ring.faulted       = 0
        ring.some_ms_time  = Ssys_current_msecs()
        t_last_master_chk  = Ssys_current_msecs()
        v16_startup_done   = 0
        t_startup          = Ssys_current_msecs()
        wait_timeout       = DEFAULT_WAIT_MS

        while not self._stop.is_set():
            now = Ssys_current_msecs()

            # ── fault recovery (1 s window) ──────────────────────────────────
            if ring.faulted and (now - ring.some_ms_time) > 1000:
                self.ssc.Ssc_clearFaultLed(4)
                ring.faulted      = 0
                ring.some_ms_time = now

            # ── startup delay (3 s) ──────────────────────────────────────────
            if not v16_startup_done and (now - t_startup) > 3000:
                v16_startup_done = 1

            # ── coupling init after startup ──────────────────────────────────
            if ring.need_start and v16_startup_done and ring.coupling is None:
                ring.coupling = CouplingState(
                    mode         = self.cfg.coupling.mode,
                    primary_port = self.cfg.coupling.primary_port,
                    backup_port  = self.cfg.coupling.backup_port,
                )

            # ── main state-machine sub-tasks (when not faulted) ──────────────
            if not ring.faulted:
                self._process_ring_state()

            # ── status-change logging ────────────────────────────────────────
            if old_status != ring.status:
                log.warning(f"tr2_ringMain ring={ring.id} "
                             f"status {old_status} → {ring.status}")
                old_status = ring.status

            # ── wait for packet or timeout ───────────────────────────────────
            # In sim mode: also check if backend has a queued frame directly
            has_queued = (hasattr(self.ssc.sw, 'has_frame') and
                          self.ssc.sw.has_frame())
            ret = 1 if has_queued else MgmtTR2Wait(ring, wait_timeout)

            if ret > 0:
                pkt_len, pkt, src_port = MgmtRecvTR2Packet(
                    ring, self.raw_fd, self.bids[0], self.bids[1],
                    ssc=self.ssc)
                if pkt_len > 0 and pkt:
                    self._handle_pkt(pkt, pkt_len, src_port)

            # ── periodic master check (~1 s) ─────────────────────────────────
            if (now - t_last_master_chk) > 1000:
                t_last_master_chk = now
                tr2_checkMasterStatus(ring, self.ssc)

        log.info(f"tr2_ringMain ring={ring.id} stopped")

    def _process_ring_state(self):
        """Periodic ring state-machine work (polling, timer checks)."""
        ring = self.ring
        # send polling packets if timer fired
        if ring.polling_timer and ring.polling_timer.flag.is_set():
            ring.polling_timer.flag.clear()
            for pi in range(2):
                tr2_sendPollingPkt(self.ssc, self.tx_fd, self.raw_fd, ring, pi)

    def _port_idx_for(self, port_id: int) -> int:
        """Return 0 or 1 for the ring port index that matches port_id, or -1."""
        for i, p in enumerate(self.ring.ports):
            if p.port_id == port_id:
                return i
        return -1

    def _handle_pkt(self, pkt: bytes, pkt_len: int, src_port: int):
        """
        Dispatch a received TR2 packet.
        Mirrors the switch inside tr2_ringMain @ 0xB3xx region.

        Guards (checked first, in order):
          1. DA == own MAC  → frame delivered to this node, absorb silently.
          2. SA == own MAC  → frame completed a full loop, drop.
          3. BPDU           → absorbed, state updated, NOT forwarded.
          4. All others     → forwarded out the opposite ring port.
        """
        ring = self.ring

        if pkt_len <= 22:
            log.warning(f"tr2_ringMain ring={ring.id} Invalid pkt len={pkt_len}")
            return

        own_mac  = self.ssc.mac
        frame_da = pkt[0:6]
        frame_sa = pkt[6:12]

        # Guard 1 — destination absorption: DA == our MAC → delivered, done.
        if frame_da == own_mac and frame_da != bytes(6):
            log.debug(f"tr2_ringMain ring={ring.id} frame DELIVERED to this node, absorb")
            return

        # payload starts at byte 17 after DSA-strip:
        # DA(6)+SA(6)+etype(2)+LLC(3) = 17 bytes before payload
        payload = pkt[17:]

        # validate TR2 magic and constant byte
        if payload[:4] != TR2_PKT_MAGIC or payload[5] != 1:
            log.warning(f"tr2_ringMain ring={ring.id} bad magic, drop")
            return

        pkt_type = payload[6]
        src_idx  = self._port_idx_for(src_port)
        out_idx  = 1 - src_idx if src_idx >= 0 else 0   # opposite port

        log.debug(f"tr2_ringMain ring={ring.id} "
                  f"port={src_port}(idx={src_idx}) pktType={pkt_type}")

        if pkt_type == PktType.BPDU:
            # Guard 3 — BPDU: absorbed, updates ring state, NOT forwarded.
            self._handle_bpdu(payload, src_port, pkt_len)

        elif pkt_type == PktType.POLLING:
            self._handle_polling(payload, src_port)
            # Guard 2 — SA loop guard for POLLING
            if frame_sa != own_mac:
                self._forward(pkt, out_idx)
            else:
                log.debug(f"tr2_ringMain ring={ring.id} POLLING completed ring, drop")

        else:
            # Guard 2 — SA loop guard for all other types
            if frame_sa == own_mac:
                log.debug(f"tr2_ringMain ring={ring.id} pktType={pkt_type} "
                          f"completed ring, drop")
            else:
                log.debug(f"tr2_ringMain ring={ring.id} relay pktType={pkt_type} "
                          f"→ port_idx={out_idx}")
                self._forward(pkt, out_idx)

    def _forward(self, pkt: bytes, out_idx: int):
        """
        Forward pkt out ring port out_idx.

        Critical: preserve the original DA and SA from the received frame.
        Only the DSA tag (bytes 12-15) changes — it carries the egress port.
        We must NOT call Ssc_sendTR2Packet here because that rebuilds the
        ethernet header from scratch (DA = ring_bridge_id, SA = our MAC),
        which destroys the original destination address and causes the
        destination node to never recognise itself as the target.

        Wire layout (after DSA-strip, i.e. what we have in `pkt`):
          [0:6]   DA  — original destination (MUST be preserved)
          [6:12]  SA  — original source      (MUST be preserved)
          [12:14] etype / length
          [14:17] LLC  (DSAP, SSAP, ctrl)
          [17:]   TR2 payload

        We re-insert the DSA tag at position 12 before sending:
          DA(6) + SA(6) + DSA(4) + original[12:]
        """
        ring     = self.ring
        out_port = ring.ports[out_idx].port_id
        if not ring.active or ring.faulted:
            return

        # Re-insert DSA tag: pkt has had DSA stripped, so add it back with the
        # new egress port — this is exactly what a real switch does.
        from tr2d_structs import dsa_build
        dsa      = dsa_build(out_port)
        new_frame = pkt[0:12] + dsa + pkt[12:]   # DA+SA preserved, DSA rewritten

        log.debug(f"tr2_ringMain ring={ring.id} forward DA={pkt[0:6].hex()} "
                  f"→ port {out_port}")
        self.ssc.sw.send_frame(self.tx_fd, self.raw_fd, out_port, new_frame)

    def _handle_bpdu(self, payload: bytes, src_port: int, pkt_len: int):
        """Handle BPDU-type ring management packet (absorbed, not forwarded)."""
        ring = self.ring
        if ring.faulted:
            return
        log.debug(f"tr2_ringMain ring={ring.id} BPDU from port={src_port}")
        # topology-change: set master_id from packet, update status
        if len(payload) >= 14:
            ring.master_id = bytes(payload[7:13])
        ring.status = 1  # Healthy if we received BPDU

    def _handle_polling(self, payload: bytes, src_port: int):
        """Handle polling packet — update ring health (also forwarded by _handle_pkt)."""
        ring = self.ring
        log.debug(f"tr2_ringMain ring={ring.id} POLLING from port={src_port}")
        ring.status = 1


# ─────────────────────────────────────────────────────────────────────────────
# tr2_ringAux  —  per-ring auxiliary thread  (tr2_ringAux @ 0xB6C4)
# ─────────────────────────────────────────────────────────────────────────────

class RingAuxThread:
    """
    tr2_ringAux @ 0xB6C4 — secondary ring thread handling coupling/aux tasks.
    """

    def __init__(self, ring: RingState, ssc: Ssc,
                 tx_fd: int, raw_fd: int):
        self.ring   = ring
        self.ssc    = ssc
        self.tx_fd  = tx_fd
        self.raw_fd = raw_fd
        self._stop  = threading.Event()
        self._thread: Optional[threading.Thread] = None

    def start(self):
        self._thread = threading.Thread(
            target=self._aux_loop, daemon=True,
            name=f"tr2_ringAux-{self.ring.id}")
        self._thread.start()

    def stop(self):
        self._stop.set()

    def _aux_loop(self):
        ring = self.ring
        log.debug(f"[TR2]> tr2_ringAux ring={ring.id} RINGAUX started")
        while not self._stop.is_set():
            # Coupling topology change notification
            if ring.coupling and ring.coupling.active:
                tr2_sendCouplerTopologyChangedPkt(
                    self.ssc, self.tx_fd, self.raw_fd,
                    ring, 0, ring.is_master)
                log.debug(f"[TR2]> tr2_ringAux ring={ring.id} sent TC")
            self._stop.wait(1.0)
        log.debug(f"[TR2]> tr2_ringAux ring={ring.id} stopped")