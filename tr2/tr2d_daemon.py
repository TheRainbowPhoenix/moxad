"""
tr2d_daemon.py  :  TurboRing2 daemon  (main entry point)

This is the Python equivalent of main() @ 0xCD7C in the tr2d binary.

Startup sequence (mirrors binary exactly):
  1. pthread_attr init (priority 50, SCHED_RR)          -> Python threads
  2. atoi(argv[1]) -> SetDebugLevel
  3. Get_Mac("eth0")  -> read own MAC
  4. memset config buffers
  5. sub_13004() -> default config init
  6. tr2_initTx() -> open AF_PACKET raw socket on eth0
  7. tr2_loadConfig() -> parse /etc/tr2_config.txt
  8. tr2_activeConfig() -> apply config, start ring tasks
  9. signal handlers
  10. tr2_msgHandler() -> UNIX socket loop (blocking)

Usage:
    python3 tr2d_daemon.py [debug_level]  # debug_level 3..7 (default 5)

Environment:
    TR2_SOCKET  override socket path (default /tmp/tr2socket)
    TR2_IFACE   network interface    (default eth0)
    TR2_SIM     set to 1 to use SimSwitchBackend (no hardware needed)
"""

import os
import sys
import signal
import socket
import struct
import logging
import threading
import time
import argparse
from typing import List, Optional

from tr2d_structs import (
    TR2Config, RingConfig, CouplingConfig,
    RingInfo, CouplingInfo, LHCPortInfo,
    Cmd, StatusSubtype, MSG_SIZE, READ_BUF,
    TR2_SOCKET_PATH, TR2_ETH_IFACE,
    CouplingMode, MAX_RINGS,
    pack_activate_payload, unpack_activate_payload,
    parse_msg, build_msg,
    LOG_ERROR, LOG_NOTICE, LOG_INFO, LOG_DEBUG5, LOG_DEBUG7,
)
from tr2d_core import (
    RingState, CouplingState, LhcPortState,
    RingMainThread, RingAuxThread, SlhcThread,
    MgmtTR2Wakeup, MgmtTR2Start, MgmtTR2Stop,
    tr2_activeConfig, Ssys_current_msecs,
    Llhc_sendLhcInfo,
)
from ssc import Ssc, SimSwitchBackend, LinuxSwitchBackend
from compat import (
    IS_WINDOWS, ipc_make_server, ipc_connect, ipc_cleanup,
    make_wakeup_pair, safe_signal, wait_readable,
    open_raw_socket, get_iface_mac,
    SIGHUP, SIGINT, SIGTERM,
)


# 
# log_printf shim
# 

_debug_level = 5

def log_printf(level: int, fmt: str, *args):
    """log_printf() @ 0x1C744 : only emit if level <= debug_level"""
    if level <= _debug_level:
        msg = fmt % args if args else fmt
        logging.getLogger("tr2d").log(
            {1: 50, 2: 40, 3: 30, 4: 20, 5: 10, 6: 10, 7: 10}.get(level, 10),
            msg.rstrip())

def SetDebugLevel(level: int):
    global _debug_level
    _debug_level = level


# 
# tr2_sendRingInfo / tr2_sendCouplingInfo  (reply helpers)
# 

def tr2_sendRingInfo(client_fd: int, rings: List[RingState]):
    """tr2_sendRingInfo @ 0xC644"""
    payload = b"".join(r.to_ring_info().pack() for r in rings)
    try:
        if isinstance(client_fd, socket.socket):
            client_fd.sendall(payload)
        elif client_fd >= 0:
            os.write(client_fd, payload)
        log_printf(LOG_DEBUG5, " tr2_sendRingInfo() reply Ring info success\n")
    except OSError as e:
        log_printf(LOG_ERROR, "tr2_sendRingInfo() write error\n")

def tr2_sendCouplingInfo(client_fd: int,
                          coupling: Optional[CouplingState]):
    """tr2_sendCouplingInfo @ 0xC6C8"""
    ci = coupling.to_coupling_info() if coupling else CouplingInfo()
    try:
        data = ci.pack()
        if isinstance(client_fd, socket.socket):
            client_fd.sendall(data)
        elif client_fd >= 0:
            os.write(client_fd, data)
        log_printf(LOG_DEBUG5, " tr2_sendCouplingInfo() reply Coupling info success\n")
    except OSError as e:
        log_printf(LOG_ERROR, "tr2_sendCouplingInfo() write error\n")

def tr2_setWaitTime(ms: int):
    """tr2_setWaitTime @ 0xC74C"""
    log_printf(LOG_DEBUG5, "tr2_setWaitTime() Set wait timeout = %d ms\n", ms)
    # propagated to ring threads via shared state in the real binary;
    # here we'd update a global
    global _wait_timeout_ms
    _wait_timeout_ms = ms

_wait_timeout_ms = 4


# 
# tr2_doMsgCmd  (@ 0xC798)
# 

def tr2_doMsgCmd(client_fd: int, command: bytes,
                  rings: List[RingState],
                  coupling: Optional[CouplingState],
                  lhc_thread: SlhcThread,
                  ssc: Ssc,
                  cfg_shm: TR2Config):
    """
    tr2_doMsgCmd @ 0xC798
    Dispatch an IPC command received on /tmp/tr2socket.
    """
    cmd, subtype, payload = parse_msg(command)
    log_printf(LOG_DEBUG7, "command = %d\n", cmd)

    if cmd == Cmd.ACTIVATE:
        # 'a' : apply new configuration
        new_cfg = unpack_activate_payload(payload)
        cfg_shm.enabled  = new_cfg.enabled
        cfg_shm.rings    = new_cfg.rings
        cfg_shm.coupling = new_cfg.coupling
        log_printf(LOG_DEBUG7, "tr2_doMsgCmd() %d Active configuration change\n", 1290)
        tr2_activeConfig(cfg_shm, rings, coupling, ssc)

    elif cmd == Cmd.SET_TIMEOUT:
        # 'i' : set wait timeout
        ms = struct.unpack_from("<I", payload, 0)[0] if len(payload) >= 4 else 0
        log_printf(LOG_DEBUG7, "tr2_doMsgCmd() waitTime = %d %d\n", ms, subtype)
        tr2_setWaitTime(ms)

    elif cmd in (Cmd.STATUS, Cmd.STATUS_W):
        # 's'/'w' : status query
        if subtype == StatusSubtype.RING:
            tr2_sendRingInfo(client_fd, rings)
        elif subtype == StatusSubtype.COUPLING:
            tr2_sendCouplingInfo(client_fd, coupling)
        elif subtype == StatusSubtype.LHC:
            Llhc_sendLhcInfo(client_fd, lhc_thread)
        else:
            log_printf(LOG_ERROR, "tr2_doMsgCmd() MUST not be here!\n")

    elif cmd == Cmd.TEST_TX:
        # 't' : test transmit trigger
        pkt_type = payload[0] if payload else 0
        log_printf(LOG_DEBUG7,
                   "tr2_doMsgCmd() trigger pktType = %d TTTTTTTTTTTT\n", pkt_type)
        # wake ring 0 for test
        if rings:
            MgmtTR2Wakeup(rings[0])

    else:
        log_printf(LOG_DEBUG7, "tr2_doMsgCmd: unknown cmd %d\n", cmd)


# 
# tr2_msgHandler  (@ 0xCBA8) : UNIX socket accept loop
# 

def tr2_msgHandler(rings: List[RingState],
                    coupling: Optional[CouplingState],
                    lhc_thread: SlhcThread,
                    ssc: Ssc,
                    cfg_shm: TR2Config,
                    socket_path: str = TR2_SOCKET_PATH):
    """
    tr2_msgHandler @ 0xCBA8  : blocking UNIX socket server loop.
    Handles tr2ctrl connections.
    """
    # create cross-platform IPC server
    ipc_cleanup(socket_path)
    srv = ipc_make_server(socket_path, backlog=5)
    srv.settimeout(1.0)
    log_printf(LOG_INFO, "Socket has name %s\n", socket_path)

    def _handle(conn: socket.socket):
        try:
            while True:
                buf = b""
                while len(buf) < MSG_SIZE:
                    chunk = conn.recv(MSG_SIZE - len(buf))
                    if not chunk:
                        break
                    buf += chunk
                if not buf:
                    log_printf(LOG_DEBUG5, "Ending connection\n")
                    break
                log_printf(LOG_DEBUG7,
                           "tr2_msgHandler() Get Msg >>>>>>>>>>>>>>> \n")
                tr2_doMsgCmd(conn, buf,
                              rings, coupling, lhc_thread, ssc, cfg_shm)
        except OSError as e:
            log_printf(LOG_ERROR, "reading stream message: %s\n", str(e))
        finally:
            conn.close()

    while True:
        try:
            conn, _ = srv.accept()
        except socket.timeout:
            continue
        except OSError:
            break
        t = threading.Thread(target=_handle, args=(conn,), daemon=True)
        t.start()


# 
# Get_Mac  : read interface MAC  (called as Get_Mac(&byte_27314))
# 

def Get_Mac(iface: str = TR2_ETH_IFACE) -> bytes:
    """Read MAC address for iface : cross-platform via compat."""
    return get_iface_mac(iface)


# 
# tr2_initTx  (@ 0x12EA4) : open raw TX socket on eth0
# 

def tr2_initTx(iface: str = TR2_ETH_IFACE):
    """
    tr2_initTx @ 0x12EA4
    Opens AF_PACKET SOCK_RAW socket bound to iface for TX/RX of TR2 frames.
    Returns socket object or None (on Windows / permission error).
    """
    log_printf(LOG_DEBUG5, "[TR2]> tr2_initTx() ==========\n")
    sock = open_raw_socket(iface)
    if sock is None and not IS_WINDOWS:
        print(f"tr2_initTx(): socket failed", file=sys.stderr)
    return sock


# 
# default config init  (sub_13004 @ 0x13004)
# 

def _default_config_init(cfg: TR2Config):
    """
    sub_13004 @ 0x13004 : hardcoded default port assignments.
    ring0: ports 9, 10  (port0=9 port1=10)
    ring1: ports 7,  8
    coupling: mode=0 primary=7 backup=8
    """
    cfg.rings[0] = RingConfig(enabled=0, priority=0xFF, port0=9,  port1=10)
    cfg.rings[1] = RingConfig(enabled=0, priority=0xFF, port0=7,  port1=8)
    cfg.coupling = CouplingConfig(mode=CouplingMode.NONE,
                                   primary_port=7, backup_port=8)


# 
# TR2Daemon  :  top-level orchestrator
# 

class TR2Daemon:
    """
    Top-level daemon.  Mirrors the full startup sequence of main() @ 0xCD7C.

    Parameters
    ----------
    debug_level : int
        Verbosity (1=errors only … 7=all).  Matches tr2d <debugLevel> arg.
    iface : str
        Network interface for raw packet I/O.
    socket_path : str
        UNIX socket path for tr2ctrl communication.
    use_sim : bool
        If True, use SimSwitchBackend (no real hardware needed).
    """

    def __init__(self,
                 debug_level: int = 5,
                 iface:       str  = TR2_ETH_IFACE,
                 socket_path: str  = TR2_SOCKET_PATH,
                 use_sim:     bool = True):

        SetDebugLevel(debug_level)
        self.iface       = iface
        self.socket_path = socket_path
        self.use_sim     = use_sim

        #  shared config state (dword_2AA30 / dword_2AA58) 
        self.cfg_default = TR2Config()     # dword_2AA30 : "hardware defaults"
        self.cfg_active  = TR2Config()     # dword_2AA58 : "active config"
        _default_config_init(self.cfg_default)
        _default_config_init(self.cfg_active)

        #  MAC / raw socket 
        self.mac   = bytes(6)
        self.tx_fd = -1
        self.raw_fd = -1

        #  switch backend 
        if use_sim:
            self.backend = SimSwitchBackend(port_count=10)
        else:
            self.backend = LinuxSwitchBackend(iface=iface)
        self.ssc = Ssc(self.backend)

        #  ring state  (up to MAX_RINGS rings + 1 coupling) 
        self.rings: List[RingState] = []
        self.coupling: Optional[CouplingState] = None

        #  threads 
        self._ring_mains: List[RingMainThread] = []
        self._ring_auxes: List[RingAuxThread]  = []
        self._lhc_thread: Optional[SlhcThread] = None
        self._msg_thread: Optional[threading.Thread] = None
        self._stop = threading.Event()

    #  public API 

    def start(self):
        """Full startup sequence mirroring main() @ 0xCD7C."""
        log_printf(LOG_NOTICE, "tr2d starting (sim=%s)\n", self.use_sim)

        # 1. Get MAC
        self.mac = Get_Mac(self.iface)
        self.ssc.mac = self.mac
        log_printf(LOG_DEBUG5, "MAC: %s\n",
                   ":".join(f"{b:02x}" for b in self.mac))

        # 2. tr2_initTx : raw socket
        if not self.use_sim:
            self.tx_fd = tr2_initTx(self.iface)
            if self.tx_fd < 0:
                log_printf(LOG_ERROR, "tx init failed\n")
                return -1
            self.raw_fd = self.tx_fd
            self.ssc.tx_fd = self.tx_fd
        else:
            self.tx_fd  = -1
            self.raw_fd = -1

        # 3. Build ring state objects
        for i in range(MAX_RINGS):
            rs = RingState(id=i)
            self.rings.append(rs)

        # 4. Start LHC thread (pthread_create for Slhc_main)
        self._lhc_thread = SlhcThread(
            self.ssc, lhc_port_count=4,
            tx_fd=self.tx_fd, raw_fd=self.raw_fd)
        self._lhc_thread.start()

        # 5. Load config
        loaded = TR2Config.from_file()
        rc = self._apply_config(loaded)
        if rc < 0:
            log_printf(LOG_ERROR, "Configuration loading error\n")
            # still continue : default config stays

        # 6. Signal handlers (main thread only; SIGHUP skipped on Windows)
        safe_signal(SIGHUP,  self._sig_handler)
        safe_signal(SIGINT,  self._sig_handler)
        safe_signal(SIGTERM, self._sig_handler)

        # 7. Message handler loop (blocking in main thread)
        self._msg_thread = threading.Thread(
            target=tr2_msgHandler,
            args=(self.rings, self.coupling, self._lhc_thread,
                  self.ssc, self.cfg_active, self.socket_path),
            daemon=True, name="tr2_msgHandler")
        self._msg_thread.start()

        log_printf(LOG_NOTICE, "tr2d ready on %s\n", self.socket_path)
        return 0

    def run(self):
        """Block until stopped."""
        self.start()
        try:
            while not self._stop.is_set():
                time.sleep(1)
        except KeyboardInterrupt:
            pass
        self.stop()

    def stop(self):
        """Graceful shutdown."""
        log_printf(LOG_NOTICE, "tr2d stopping\n")
        self._stop.set()
        for rm in self._ring_mains:
            rm.stop()
        for ra in self._ring_auxes:
            ra.stop()
        if self._lhc_thread:
            self._lhc_thread.stop()
        ipc_cleanup(self.socket_path)

    #  internal 

    def _apply_config(self, cfg: TR2Config) -> int:
        """tr2_loadConfig + tr2_activeConfig combined."""
        self.cfg_active.enabled  = cfg.enabled
        self.cfg_active.rings    = cfg.rings
        self.cfg_active.coupling = cfg.coupling

        if cfg.coupling.mode != CouplingMode.NONE:
            self.coupling = CouplingState(
                mode         = cfg.coupling.mode,
                primary_port = cfg.coupling.primary_port,
                backup_port  = cfg.coupling.backup_port,
            )

        tr2_activeConfig(self.cfg_active, self.rings, self.coupling, self.ssc)

        # Start ring threads for enabled rings
        for i, ring in enumerate(self.rings):
            rcfg = cfg.rings[i]
            if rcfg.enabled:
                rm = RingMainThread(
                    ring, self.cfg_active, self.ssc,
                    self.tx_fd, self.raw_fd,
                    self.mac, self.mac)   # bridge IDs initialised to own MAC
                rm.start()
                self._ring_mains.append(rm)

                if cfg.coupling.mode != CouplingMode.NONE:
                    ra = RingAuxThread(ring, self.ssc, self.tx_fd, self.raw_fd)
                    ra.start()
                    self._ring_auxes.append(ra)

        return 0

    def _sig_handler(self, signum, frame):
        """tr2_sighandler @ 0x9778"""
        log_printf(LOG_NOTICE, "tr2_sighandler() received signal %d\n", signum)
        self._stop.set()


# 
# Multi-instance manager  (for debugging multiple virtual switches)
# 

class TR2DaemonManager:
    """Spawn N independent tr2d instances (different sockets)."""

    def __init__(self):
        self._daemons: List[TR2Daemon] = []
        self._threads: List[threading.Thread] = []

    def add(self, debug_level: int = 5,
            socket_path: str = TR2_SOCKET_PATH,
            instance_id: int = 0) -> TR2Daemon:
        d = TR2Daemon(debug_level=debug_level,
                      socket_path=socket_path,
                      use_sim=True)
        self._daemons.append(d)
        t = threading.Thread(target=d.run, daemon=True,
                             name=f"tr2d-{instance_id}")
        self._threads.append(t)
        t.start()
        time.sleep(0.1)
        return d

    def stop_all(self):
        for d in self._daemons:
            d.stop()

    def status(self) -> List[dict]:
        out = []
        for i, d in enumerate(self._daemons):
            out.append({
                "instance": i,
                "socket":   d.socket_path,
                "rings": [
                    {"id": r.id, "status": r.status,
                     "is_master": r.is_master, "active": r.active}
                    for r in d.rings
                ],
                "coupling": d.coupling.__dict__ if d.coupling else None,
            })
        return out


# 
# tr2ctrl Python client  (same as tr2d.py, kept here for convenience)
# 

class TR2Client:
    """Python equivalent of the tr2ctrl binary."""

    def __init__(self, socket_path: str = TR2_SOCKET_PATH):
        self.path = socket_path

    def _send(self, cmd: int, subtype: int = 0,
              payload: bytes = b"") -> bytes:
        sock = ipc_connect(self.path)
        sock.sendall(build_msg(cmd, subtype, payload))
        reply = b""
        sock.settimeout(2.0)
        try:
            while True:
                chunk = sock.recv(READ_BUF)
                if not chunk:
                    break
                reply += chunk
        except socket.timeout:
            pass
        sock.close()
        return reply

    def activate(self, cfg: TR2Config):
        """tr2ctrl -a"""
        self._send(Cmd.ACTIVATE, payload=pack_activate_payload(cfg))

    def get_rings(self) -> List[RingInfo]:
        raw = self._send(Cmd.STATUS, StatusSubtype.RING)
        return [RingInfo.unpack(raw[i*RingInfo.WIRE_SIZE:(i+1)*RingInfo.WIRE_SIZE])
                for i in range(len(raw) // RingInfo.WIRE_SIZE)]

    def get_coupling(self) -> CouplingInfo:
        raw = self._send(Cmd.STATUS, StatusSubtype.COUPLING)
        return CouplingInfo.unpack(raw) if raw else CouplingInfo()

    def get_lhc(self) -> List[LHCPortInfo]:
        raw = self._send(Cmd.STATUS, StatusSubtype.LHC)
        return [LHCPortInfo.unpack(raw[i*LHCPortInfo.WIRE_SIZE:(i+1)*LHCPortInfo.WIRE_SIZE])
                for i in range(len(raw) // LHCPortInfo.WIRE_SIZE)]

    def set_timeout(self, ms: int):
        self._send(Cmd.SET_TIMEOUT, payload=struct.pack("<I", ms))

    def test_tx(self, pkt_type: int = 0):
        self._send(Cmd.TEST_TX, payload=bytes([pkt_type]))


# 
# Entry point
# 

def main():
    ap = argparse.ArgumentParser(description="TurboRing2 daemon (Python)")
    ap.add_argument("debug_level", nargs="?", type=int, default=5,
                    help="Debug verbosity 1..7 (matches tr2d <debugLevel>)")
    ap.add_argument("--socket", default=os.environ.get("TR2_SOCKET", TR2_SOCKET_PATH))
    ap.add_argument("--iface",  default=os.environ.get("TR2_IFACE",  TR2_ETH_IFACE))
    ap.add_argument("--sim",    action="store_true",
                    default=bool(os.environ.get("TR2_SIM", "1")),
                    help="Use software simulator (no hardware)")
    ap.add_argument("--multi",  type=int, default=0,
                    help="Spawn N sim-daemons on /tmp/tr2socket_0..N")
    args = ap.parse_args()

    # configure Python logging
    log_levels = {1: 50, 2: 40, 3: 30, 4: 20, 5: 10, 6: 10, 7: 10}
    logging.basicConfig(
        level=log_levels.get(args.debug_level, 10),
        format="[tr2d] %(levelname)s %(message)s",
        handlers=[logging.StreamHandler(sys.stdout)])

    if args.multi > 0:
        mgr = TR2DaemonManager()
        for i in range(args.multi):
            import tempfile, pathlib
            _tmp = pathlib.Path(tempfile.gettempdir())
            mgr.add(debug_level=args.debug_level,
                    socket_path=str(_tmp / f"tr2socket_{i}"),
                    instance_id=i)
        print(f"Started {args.multi} tr2d instances. Ctrl-C to stop.")
        try:
            while True:
                time.sleep(5)
                import json
                print(json.dumps(mgr.status(), indent=2))
        except KeyboardInterrupt:
            mgr.stop_all()
        return

    d = TR2Daemon(debug_level=args.debug_level,
                  iface=args.iface,
                  socket_path=args.socket,
                  use_sim=args.sim)
    d.run()


if __name__ == "__main__":
    main()
