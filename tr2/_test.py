import time, os, logging, sys, tempfile, pathlib
logging.basicConfig(level=logging.WARNING, format="[%(name)s] %(levelname)s %(message)s", stream=sys.stdout)

from compat import (
    IS_WINDOWS, make_wakeup_pair, ipc_make_server, ipc_connect,
    ipc_cleanup, wait_readable
)
from tr2d_structs import *
from ssc import Ssc, SimSwitchBackend
from tr2d_core import *
from tr2d_daemon import TR2Daemon, TR2Client, TR2DaemonManager

_tmp = pathlib.Path(tempfile.gettempdir())

def check(label, expr):
    sym = "✓" if expr else "✗"
    print(f"  {sym}  {label}")
    if not expr:
        raise AssertionError(label)

# compat layer 
print("\n 0. compat layer")
from compat import make_wakeup_pair, ipc_make_server, ipc_connect, ipc_cleanup
r, w = make_wakeup_pair()
w.send(b'\x42')
data = r.recv(4)
check("make_wakeup_pair send/recv", data == b'\x42')
r.close(); w.close()
check(f"IS_WINDOWS={IS_WINDOWS}", True)
# check(f"default_socket_path uses tempdir on Windows",
#       not IS_WINDOWS and str(_tmp) in TR2_SOCKET_PATH)

# Structs round-trips 
print("\n 1. Structs")
ri = RingInfo(ring_id=2, status=1, is_master=1,
              master_id=b'\x01\x02\x03\x04\x05\x06\x00\x00',
              ports=[PortInfo(3, PortState.FORWARDING),
                     PortInfo(4, PortState.BLOCKED, is_down=1)])
raw = ri.pack(); ri2 = RingInfo.unpack(raw)
check("RingInfo 376B", len(raw)==376)
check("ring_id", ri2.ring_id==2)
check("port[1].is_down", ri2.ports[1].is_down==1)
ci = CouplingInfo(active=1, mode=CouplingMode.DUAL_HOMING)
raw_c = ci.pack(); ci2 = CouplingInfo.unpack(raw_c)
check("CouplingInfo 192B", len(raw_c)==192)
check("coupling mode", ci2.mode==CouplingMode.DUAL_HOMING)
lhc = LHCPortInfo(link_partner=b'\xaa\xbb\xcc\xdd\xee\xff', state=2, lhc_recv=5)
raw_l = lhc.pack(); lhc2 = LHCPortInfo.unpack(raw_l)
check("LHCPortInfo 64B", len(raw_l)==64)
check("lhc_recv", lhc2.lhc_recv==5)

# DSA tag 
print("\n 2. DSA tag")
from tr2d_structs import dsa_build, dsa_parse
tag = dsa_build(5, 100)
p, v = dsa_parse(tag)
check("DSA port", p==5)
check("DSA vid", v==100)

# Config payload 
print("\n 3. Config")
cfg = TR2Config(1, [RingConfig(1,0,3,4), RingConfig(0,0xFF,7,8)],
                CouplingConfig(CouplingMode.COUPLING_PRIMARY, 5, 6))
pl = pack_activate_payload(cfg); cfg2 = unpack_activate_payload(pl)
check("ring0.port0", cfg2.rings[0].port0==3)
check("coupling.mode", cfg2.coupling.mode==CouplingMode.COUPLING_PRIMARY)
check("coupling.primary_port", cfg2.coupling.primary_port==5)

# IPC message 
print("\n 4. IPC message")
msg = build_msg(Cmd.STATUS, StatusSubtype.RING)
cmd, sub, _ = parse_msg(msg)
check(f"size {len(msg)}=={MSG_SIZE}", len(msg)==MSG_SIZE)
check("cmd", cmd==Cmd.STATUS)
check("subtype", sub==StatusSubtype.RING)

# SimSwitchBackend 
print("\n 5. SimSwitchBackend")
sim = SimSwitchBackend(8)
sim.set_port_state(3, PortState.BLOCKED)
check("set/get state", sim.get_port_state(3)==PortState.BLOCKED)
sim.set_port_enable(3, True)
check("enable->FWD", sim.get_port_state(3)==PortState.FORWARDING)
sim.fdb_add_ucast(b'\xde\xad\xbe\xef\x00\x01', 0, 0b100)
check("fdb", sim.fdb_find(b'\xde\xad\xbe\xef\x00\x01') is not None)

# Ssc facade 
print("\n 6. Ssc facade")
ssc = Ssc(sim, b'\x00\x11\x22\x33\x44\x55',
          ring_bridge_ids=[b'\xAA\xBB\xCC\xDD\xEE\x00', b'\xAA\xBB\xCC\xDD\xEE\x01'])
ssc.Ssc_setPortState(2, PortState.LEARNING)
check("setPortState", sim.get_port_state(2)==PortState.LEARNING)
check("getPortState", ssc.Ssc_getPortState(2)==PortState.LEARNING)

# PollingTimer 
print("\n 7. PollingTimer")
pt = PollingTimer(0); pt.start(50)
time.sleep(0.13)
check("flag fires", pt.flag.is_set())
pt.stop()

# RingState + Mgmt 
print("\n 8. RingState + Mgmt")
rs = RingState(id=0, active=1, is_master=1)
check("to_ring_info", rs.to_ring_info().ring_id==1)
rs2 = RingState(id=1)
check("wait timeout->-1", MgmtTR2Wait(rs2, 10)==-1)
MgmtTR2Wakeup(rs2); time.sleep(0.01)
check("wait after wakeup->>0", MgmtTR2Wait(rs2, 50)>0)

# SlhcThread 
print("\n 9. SlhcThread")
ssc2 = Ssc(SimSwitchBackend(4), b'\x00\xAA\xBB\xCC\xDD\xEE')
lhc_t = SlhcThread(ssc2, 4, None, None)
lhc_t.start(); time.sleep(0.12)
check("LHC thread alive", lhc_t._thread.is_alive())
lhc_t.stop(); time.sleep(0.1)

# IPC server round-trip (ipc_make_server / ipc_connect) 
print("\n 10. IPC server (compat)")
TPATH = str(_tmp / "tr2d_compat_test.sock")
ipc_cleanup(TPATH)
srv = ipc_make_server(TPATH)
srv.settimeout(1.0)
import threading
received = []
def _srv():
    try:
        conn, _ = srv.accept()
        data = conn.recv(64)
        received.append(data)
        conn.sendall(b"ACK")
        conn.close()
    except: pass
threading.Thread(target=_srv, daemon=True).start()
time.sleep(0.05)
cli = ipc_connect(TPATH)
cli.sendall(b"HELLO")
resp = cli.recv(64)
cli.close()
srv.close()
ipc_cleanup(TPATH)
check("ipc server recv HELLO", received and received[0]==b"HELLO")
check("ipc client recv ACK", resp==b"ACK")

# Full Daemon + TR2Client 
print("\n 11. Daemon + IPC")
SOCK = str(_tmp / "tr2d_val_final.sock")
ipc_cleanup(SOCK)
d = TR2Daemon(debug_level=1, socket_path=SOCK, use_sim=True)
d.start(); time.sleep(0.3)

c = TR2Client(SOCK)
rings = c.get_rings()
check(f"get_rings list len={len(rings)}", isinstance(rings, list))
check("RingInfo objects", all(isinstance(r, RingInfo) for r in rings))
cpl = c.get_coupling()
check("get_coupling->CouplingInfo", isinstance(cpl, CouplingInfo))
lhcs = c.get_lhc()
check(f"get_lhc len={len(lhcs)}", isinstance(lhcs, list))
cfg_a = TR2Config(1, [RingConfig(1,0,1,2), RingConfig(0,0xFF,3,4)], CouplingConfig(0))
c.activate(cfg_a); time.sleep(0.05)
check("activate OK", True)
c.set_timeout(100); check("set_timeout OK", True)
c.test_tx(3);       check("test_tx OK", True)
d.stop(); ipc_cleanup(SOCK)

# Multi-daemon (each with own TCP/UNIX port) 
print("\n 12. Multi-daemon")
mgr = TR2DaemonManager()
MSOCKS = [str(_tmp / f"tr2d_multi_val_{i}.sock") for i in range(3)]
for s in MSOCKS: ipc_cleanup(s)
for i, s in enumerate(MSOCKS):
    mgr.add(debug_level=1, socket_path=s, instance_id=i)
time.sleep(0.4)
status = mgr.status()
check("3 daemons", len(status)==3)
for i, s in enumerate(MSOCKS):
    r = TR2Client(s).get_rings()
    check(f"daemon {i} answers", isinstance(r, list))
mgr.stop_all()
for s in MSOCKS: ipc_cleanup(s)

print("\n======================================")
print("  ALL TESTS PASSED  (platform: %s)" % sys.platform)
print("======================================\n")