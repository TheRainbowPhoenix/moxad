"""
tr2_shell.py — Interactive TurboRing2 console simulator
═══════════════════════════════════════════════════════

A live terminal shell for an 8-node TurboRing sim.
Uses the same RingSim / NetworkedSimSwitchBackend from test_ring8.

Commands
─────────
  status            Redraw the ring map
  ping  <src> <dst> [count]
                    Send COUNT (default 5) tracert frames from node src to dst
                    and show each hop live
  pathping <s> <d>  Like ping but also shows RTT and hop-by-hop loss summary
  break <a> <b>     Break the physical link between node a and node b
  heal  <a> <b>     Heal a previously broken link
  isolate <n>       Cut all links of node n (simulate power-off)
  restore <n>       Restore a previously isolated node
  elect <n>         Promote node n to master
  watch             Toggle auto-refresh of ring map every 0.5 s (Ctrl-C to stop)
  reset             Rebuild the ring from scratch
  help              This message
  quit / exit       Exit

Ring map legend
───────────────
  ★  master node       ·  slave node
  ─  healthy link      ✗  broken link
  ↑  port up           ↓  port down
  colors: GREEN=healthy  RED=faulted  YELLOW=isolated  CYAN=master
"""

import os, sys, time, struct, threading, tempfile, pathlib, shutil
import logging
from typing import List, Dict, Optional, Tuple

HERE = pathlib.Path(__file__).parent
sys.path.insert(0, str(HERE))
logging.basicConfig(level=logging.WARNING, stream=sys.stdout,
                    format="%(levelname)s [%(name)s] %(message)s")

from tr2d_structs import (
    TR2Config, RingConfig, CouplingConfig, CouplingMode,
    dsa_build, dsa_parse, build_tr2_payload, TR2_PKT_MAGIC,
    Cmd, StatusSubtype,
)
from compat import ipc_cleanup, IS_WINDOWS
from ssc import SimSwitchBackend, Ssc
from tr2d_core import RingState, MgmtTR2Wakeup
from tr2d_daemon import TR2Daemon, TR2Client

# ── Import shared infrastructure from test_ring8 ─────────────────────────────
from test_ring8 import (
    NetworkedSimSwitchBackend, RingSim,
    _event_log, _event_lock, _event_id, _record,
    PKT_TYPE_NAMES,
)
import test_ring8 as _t8

# ─────────────────────────────────────────────────────────────────────────────
# ANSI colour helpers
# ─────────────────────────────────────────────────────────────────────────────

_use_color = sys.stdout.isatty() and not IS_WINDOWS

def _c(code: str, text: str) -> str:
    if not _use_color:
        return text
    codes = {
        "reset": "\033[0m",   "bold":  "\033[1m",
        "red":   "\033[31m",  "green": "\033[32m",
        "yellow":"\033[33m",  "blue":  "\033[34m",
        "cyan":  "\033[36m",  "white": "\033[37m",
        "bred":  "\033[91m",  "bgreen":"\033[92m",
        "byellow":"\033[93m", "bcyan": "\033[96m",
    }
    return f"{codes.get(code,'')}{text}{codes['reset']}"


# ─────────────────────────────────────────────────────────────────────────────
# Ring map renderer
# ─────────────────────────────────────────────────────────────────────────────

def render_ring(sim: RingSim) -> str:
    """
    Draw a circular ring map like:

            ★(0)
         ·(7)  ·(1)
       ·(6)      ·(2)
         ·(5)  ·(3)
            ·(4)

    Links drawn with ─ or ✗, nodes coloured by role.
    """
    import math
    n = sim.n
    statuses = sim.get_status()
    stat_map = {s["node"]: s for s in statuses}

    lines: List[str] = []
    W = 60

    def node_str(nid: int) -> str:
        s = stat_map.get(nid, {})
        if s.get("error"):
            return _c("yellow", f"?({nid})")
        if s.get("is_master"):
            return _c("bcyan", f"★({nid})")
        return _c("bgreen", f"·({nid})")

    def link_char(na: int, pa: int) -> str:
        lnk = sim.links.get((na, pa))
        if not lnk:
            return " "
        _, _, broken = lnk
        return _c("bred", "✗") if broken else _c("bgreen", "─")

    # Position nodes in a circle
    radius = 12
    cx, cy_line = W // 2, 1
    positions: Dict[int, Tuple[int,int]] = {}
    for i in range(n):
        angle = math.pi / 2 - 2 * math.pi * i / n
        x = int(cx + radius * math.cos(angle) * 1.8)
        y = int(cy_line + (radius - radius * math.sin(angle)))
        positions[i] = (x, y)

    # Build character grid
    h = max(y for x, y in positions.values()) + 2
    grid: List[List[str]] = [[" "] * (W + 10) for _ in range(h + 1)]

    def gset(x, y, s):
        if 0 <= y < len(grid) and 0 <= x < len(grid[y]) - 4:
            # s may contain ANSI codes; store as-is
            for k, ch in enumerate(s):
                if x + k < len(grid[y]):
                    grid[y][x + k] = ch

    # Draw link segments
    for i in range(n):
        nxt = (i + 1) % n
        x1, y1 = positions[i]
        x2, y2 = positions[nxt]
        broken = sim.links.get((i, 2), (None, None, False))[2]
        ch = _c("bred", "✗") if broken else _c("bgreen", "─")
        # draw a few dots along the segment
        for t_num in range(1, 4):
            t = t_num / 4
            mx = int(x1 + (x2 - x1) * t)
            my = int(y1 + (y2 - y1) * t)
            gset(mx, my, ch)

    # Draw nodes on top
    for i in range(n):
        x, y = positions[i]
        ns = node_str(i)
        gset(x - 2, y, ns)

    # Render grid to string lines
    result_lines = [""]
    for row in grid:
        result_lines.append("  " + "".join(row).rstrip())

    return "\n".join(result_lines)


def render_status_table(sim: RingSim) -> str:
    """Compact table showing all node states."""
    statuses = sim.get_status()
    lines = [
        "",
        "  " + _c("bold", f"{'Node':>5}  {'Role':<10}  {'Status':<10}  {'p1':>5}  {'p2':>5}  {'Links'}"),
        "  " + "─" * 60,
    ]
    for s in statuses:
        nid = s["node"]
        if s.get("error"):
            lines.append(f"  {nid:>5}  " + _c("yellow", f"{'ISOLATED':<10}") + "  " + "─" * 30)
            continue
        role   = _c("bcyan",  "★ MASTER") if s.get("is_master") else _c("white", "  slave ")
        status = _c("bgreen", s.get("status","?")) if s.get("status") == "Healthy" else _c("bred", s.get("status","?"))
        ports  = s.get("ports", [])
        backend = sim.nodes[nid]["backend"]
        def _lk(pid):
            up = backend._port_link[pid] if 0 <= pid < backend.port_count else True
            return _c("bgreen","↑") if up else _c("bred","↓")
        p1 = f"{_lk(1)}"
        p2 = f"{_lk(2)}"
        link_parts = []
        for port in [1, 2]:
            lnk = sim.links.get((nid, port))
            if lnk:
                dst, dp, broken = lnk
                sym = _c("bred","✗") if broken else _c("bgreen","─")
                link_parts.append(f"p{port}{sym}N{dst}")
        link_str = "  ".join(link_parts)
        lines.append(f"  {nid:>5}  {role:<10}  {status:<10}  {p1:>5}  {p2:>5}  {link_str}")
    return "\n".join(lines) + "\n"


# ─────────────────────────────────────────────────────────────────────────────
# Traceroute / pathping
# ─────────────────────────────────────────────────────────────────────────────

# Expected single-traversal time: 8 nodes × ~10ms per hop = ~80ms
# We wait 100ms then snapshot — long enough for one full traversal,
# short enough that frame hasn't looped more than once.
_TRAVERSE_WAIT = 0.10   # seconds

def _path_from_events(evs: list, src: int, first_port: int) -> str:
    """
    Build a readable hop string from a list of events.
    Follows the chain: first event starts at src:first_port, then each
    subsequent event's src matches the previous dst.  Stops at first DROP
    or when we've seen 'n' unique hops (ring size).
    Deduplicates consecutive identical src to handle async duplicates.
    """
    # Sort by event id (arrival order)
    evs = sorted(evs, key=lambda e: e["id"])

    # Filter to the single chain starting from src:first_port
    chain = []
    expected_src = src
    for ev in evs:
        if ev["src"] == expected_src:
            # skip exact duplicates (same src→dst already in chain)
            if chain and chain[-1]["src"] == ev["src"] and chain[-1]["dst"] == ev["dst"]:
                continue
            chain.append(ev)
            if ev["drop"]:
                break
            expected_src = ev["dst"]
            if len(chain) >= 12:   # safety: max ring size + some slack
                break

    if not chain:
        return _c("yellow", "(no events)")

    parts = [f"N{chain[0]['src']}"]
    for ev in chain:
        if ev["drop"]:
            parts.append(_c("bred", f" ✗ N{ev['dst']}"))
        else:
            parts.append(_c("bgreen", f"→N{ev['dst']}"))
    return "".join(parts)


def do_ping(sim: RingSim, src: int, dst: int, count: int = 5, show_all: bool = False):
    """
    Send `count` USER_DATA frames from src→dst.
    For each frame:
      - CW path: src:port2 → (next CW node) → … → dst
      - CCW path: src:port1 → (next CCW node) → … → dst
    Each frame is sent alone, events collected after one traversal time.
    """
    dst_mac = bytes([0x02, 0x00, 0x00, 0x00, 0x00, dst])
    n       = sim.n

    # Expected CW hops: (dst - src) % n   CCW: (src - dst) % n
    cw_hops  = (dst - src) % n
    ccw_hops = (src - dst) % n

    print()
    print(_c("bold", f"  TRACERT  Node {src} → Node {dst}   ({count} probes)"))
    print(f"  CW path ({cw_hops} hops): {' → '.join(f'N{(src+i)%n}' for i in range(cw_hops+1))}")
    print(f"  CCW path ({ccw_hops} hops): {' → '.join(f'N{(src-i)%n}' for i in range(ccw_hops+1))}")
    print("  " + "─" * 60)
    print(f"  {'Seq':>4}  {'CW path':<35}  {'CCW path'}")
    print("  " + "─" * 60)

    ok_cw = ok_ccw = 0

    for seq in range(count):
        # ── send CW ──────────────────────────────────────────────────────────
        before_cw = _t8._event_id
        sim.send_user_frame(src_node=src, src_port=2, dst_mac=dst_mac,
                            payload=f"CW{seq:04d}".encode())
        time.sleep(_TRAVERSE_WAIT)
        with _event_lock:
            cw_evs = [e for e in _event_log
                      if e["id"] > before_cw and e["type"] == "USER_DATA"]

        # ── send CCW ─────────────────────────────────────────────────────────
        before_ccw = _t8._event_id
        sim.send_user_frame(src_node=src, src_port=1, dst_mac=dst_mac,
                            payload=f"CCW{seq:04d}".encode())
        time.sleep(_TRAVERSE_WAIT)
        with _event_lock:
            ccw_evs = [e for e in _event_log
                       if e["id"] > before_ccw and e["type"] == "USER_DATA"]

        # Extract just the first clean traversal for each direction
        # CW chain starts at src:port2, CCW at src:port1
        cw_chain  = _first_traversal(cw_evs,  src, port=2, ring_n=n)
        ccw_chain = _first_traversal(ccw_evs, src, port=1, ring_n=n)

        cw_ok  = any(e["dst"] == dst and not e["drop"] for e in cw_chain)
        ccw_ok = any(e["dst"] == dst and not e["drop"] for e in ccw_chain)
        if cw_ok:  ok_cw  += 1
        if ccw_ok: ok_ccw += 1

        cw_str  = _chain_str(cw_chain)
        ccw_str = _chain_str(ccw_chain)

        # Truncate display width
        max_w = 34
        if len(_strip_ansi(cw_str)) > max_w:
            cw_str = cw_str[:max_w*2] + "…"

        print(f"  {seq+1:>4}  {cw_str:<35}  {ccw_str}")

    print("  " + "─" * 60)
    cw_col  = "bgreen" if ok_cw  == count else ("yellow" if ok_cw  else "bred")
    ccw_col = "bgreen" if ok_ccw == count else ("yellow" if ok_ccw else "bred")
    print(f"  CW  reached dst: {_c(cw_col,  f'{ok_cw}/{count}')}")
    print(f"  CCW reached dst: {_c(ccw_col, f'{ok_ccw}/{count}')}")
    print()


def _first_traversal(evs: list, src: int, port: int, ring_n: int) -> list:
    """
    Extract the first clean hop chain from src:port.
    Stops at DROP or when dst == src (completed ring) or after ring_n hops.
    Deduplicates consecutive same-edge events.
    """
    evs = sorted(evs, key=lambda e: e["id"])
    chain = []
    expected = src
    seen_edges = set()
    for ev in evs:
        if ev["src"] != expected:
            continue
        edge = (ev["src"], ev["sport"], ev["dst"], ev["dport"])
        if edge in seen_edges:
            continue
        seen_edges.add(edge)
        chain.append(ev)
        if ev["drop"] or ev["dst"] == src or len(chain) >= ring_n:
            break
        expected = ev["dst"]
    return chain


def _chain_str(chain: list) -> str:
    """Render a hop chain as N0→N1→N2 with colour."""
    if not chain:
        return _c("yellow", "(no hops)")
    parts = [f"N{chain[0]['src']}"]
    for ev in chain:
        arrow = _c("bred", "✗") if ev["drop"] else _c("bgreen", "→")
        parts.append(f"{arrow}N{ev['dst']}")
    return "".join(parts)


def _strip_ansi(s: str) -> str:
    """Remove ANSI escape codes for length calculation."""
    import re
    return re.sub(r'\033\[[^m]*m', '', s)


def do_pathping(sim: RingSim, src: int, dst: int, count: int = 10):
    """
    Like pathping: send frames and collect per-hop loss statistics.
    """
    dst_mac = bytes([0x02, 0x00, 0x00, 0x00, 0x00, dst])
    hop_counts: Dict[int, int]  = {}   # node → forwarded
    hop_drops:  Dict[int, int]  = {}   # node → drops
    total_ok = total_fail = 0

    print()
    print(_c("bold", f"  PATHPING  Node {src} → Node {dst}   ({count} probes)"))
    sys.stdout.write("  Probing")
    sys.stdout.flush()

    for seq in range(count):
        before = _t8._event_id
        sim.send_user_frame(src_node=src, src_port=2, dst_mac=dst_mac,
                            payload=f"PP{seq:04d}".encode())
        time.sleep(0.08)
        sys.stdout.write(".")
        sys.stdout.flush()

        with _event_lock:
            evs = [e for e in _event_log if e["id"] > before and e["type"] == "USER_DATA"]

        reached = any(e["dst"] == dst and not e["drop"] for e in evs)
        if reached:
            total_ok += 1
        else:
            total_fail += 1

        for ev in evs:
            n = ev["src"]
            if ev["drop"]:
                hop_drops[n] = hop_drops.get(n, 0) + 1
            else:
                hop_counts[n] = hop_counts.get(n, 0) + 1

    print(f"\n\n  {'Node':>5}  {'Sent':>6}  {'Loss':>6}  {'Bar'}")
    print("  " + "─" * 50)
    # show nodes in clockwise order from src
    for step in range(sim.n):
        nid = (src + step) % sim.n
        sent  = hop_counts.get(nid, 0) + hop_drops.get(nid, 0)
        drops = hop_drops.get(nid, 0)
        if sent == 0:
            continue
        loss_pct = 100 * drops / sent if sent else 0
        bar_ok  = int((sent - drops) / max(sent, 1) * 20)
        bar_bad = 20 - bar_ok
        bar = _c("bgreen", "█" * bar_ok) + _c("bred", "░" * bar_bad)
        marker = "←src" if nid == src else ("←dst" if nid == dst else "     ")
        print(f"  {nid:>5}  {sent:>6}  {loss_pct:>5.0f}%  {bar} {marker}")

    print()
    pct = 100 * total_ok / count if count else 0
    col = "bgreen" if pct >= 90 else ("yellow" if pct >= 50 else "bred")
    print(f"  End-to-end: {_c(col, f'{total_ok}/{count} ({pct:.0f}%)')} reached destination")
    print()


# ─────────────────────────────────────────────────────────────────────────────
# Shell main loop
# ─────────────────────────────────────────────────────────────────────────────

BANNER = """
╔══════════════════════════════════════════════════════════╗
║         TurboRing2 Interactive Simulator Shell           ║
║   Type  help  for commands.   Ctrl-C or quit to exit.   ║
╚══════════════════════════════════════════════════════════╝
"""

HELP = """
  Commands:
    status                  — redraw ring map + node table
    ring                    — show ASCII ring diagram only

    ping  <src> <dst>       — tracert 5 frames src→dst (both directions)
    ping  <src> <dst> <n>   — send n frames
    pathping <src> <dst>    — per-hop loss statistics (10 probes)
    pathping <s> <d> <n>    — n probes

    break <a> <b>           — break link between node a and node b
    heal  <a> <b>           — heal link between node a and node b
    isolate <n>             — cut all links of node n (simulate crash)
    restore <n>             — restore isolated node n
    elect <n>               — promote node n to ring master

    watch                   — live auto-refresh every 0.5 s (Ctrl-C to stop)
    reset                   — rebuild 8-node ring from scratch
    help                    — this message
    quit / exit             — exit shell
"""


def _find_link(sim: RingSim, na: int, nb: int) -> Optional[int]:
    """Return the port on na that connects to nb, or None."""
    for port in range(1, 8):
        lnk = sim.links.get((na, port))
        if lnk and lnk[0] == nb:
            return port
    return None


def run_shell():
    print(BANNER)

    sim: Optional[RingSim] = None

    def ensure_sim() -> bool:
        nonlocal sim
        if sim is None:
            print(_c("yellow", "  No ring active. Building 8-node ring..."))
            sim = RingSim(n_nodes=8, master_node=0)
            sim.build()
            return True
        return True

    def cmd_status():
        ensure_sim()
        print(render_status_table(sim))

    def cmd_ring():
        ensure_sim()
        print(render_ring(sim))

    def cmd_ping(args):
        ensure_sim()
        try:
            src = int(args[0]); dst = int(args[1])
            count = int(args[2]) if len(args) > 2 else 5
        except (IndexError, ValueError):
            print("  Usage: ping <src> <dst> [count]"); return
        if not (0 <= src < sim.n and 0 <= dst < sim.n):
            print(f"  Node must be 0-{sim.n-1}"); return
        do_ping(sim, src, dst, count, show_all=True)

    def cmd_pathping(args):
        ensure_sim()
        try:
            src = int(args[0]); dst = int(args[1])
            count = int(args[2]) if len(args) > 2 else 10
        except (IndexError, ValueError):
            print("  Usage: pathping <src> <dst> [count]"); return
        do_pathping(sim, src, dst, count)

    def cmd_break(args):
        ensure_sim()
        try:
            na = int(args[0]); nb = int(args[1])
        except (IndexError, ValueError):
            print("  Usage: break <node_a> <node_b>"); return
        port = _find_link(sim, na, nb)
        if port is None:
            print(f"  No link found between node {na} and node {nb}"); return
        sim.break_link(na, port)
        print(render_status_table(sim))

    def cmd_heal(args):
        ensure_sim()
        try:
            na = int(args[0]); nb = int(args[1])
        except (IndexError, ValueError):
            print("  Usage: heal <node_a> <node_b>"); return
        port = _find_link(sim, na, nb)
        if port is None:
            print(f"  No link found between node {na} and node {nb}"); return
        sim.heal_link(na, port)
        print(render_status_table(sim))

    def cmd_isolate(args):
        ensure_sim()
        try:
            n = int(args[0])
        except (IndexError, ValueError):
            print("  Usage: isolate <node>"); return
        sim.isolate_node(n)
        time.sleep(0.4)
        print(render_status_table(sim))

    def cmd_restore(args):
        ensure_sim()
        try:
            n = int(args[0])
        except (IndexError, ValueError):
            print("  Usage: restore <node>"); return
        sim.restore_node(n)
        time.sleep(0.6)
        print(render_status_table(sim))

    def cmd_elect(args):
        ensure_sim()
        try:
            n = int(args[0])
        except (IndexError, ValueError):
            print("  Usage: elect <node>"); return
        sim.elect_new_master(n)
        time.sleep(0.4)
        print(render_status_table(sim))

    def cmd_watch():
        ensure_sim()
        print("  Auto-refresh active (Ctrl-C to stop)")
        try:
            while True:
                # Move cursor up and redraw
                tbl = render_status_table(sim)
                n_lines = tbl.count("\n") + 2
                if _use_color:
                    sys.stdout.write(f"\033[{n_lines}A")
                print(tbl, end="", flush=True)
                time.sleep(0.5)
        except KeyboardInterrupt:
            print("\n  Watch stopped.")

    def cmd_reset():
        nonlocal sim
        if sim:
            sim.stop()
        sim = RingSim(n_nodes=8, master_node=0)
        sim.build()
        print(render_status_table(sim))

    # ── initial build ─────────────────────────────────────────────────────────
    cmd_reset()

    # ── REPL ─────────────────────────────────────────────────────────────────
    while True:
        try:
            line = input(_c("bcyan", "\ntr2> ")).strip()
        except (EOFError, KeyboardInterrupt):
            print("\n  Bye.")
            break

        if not line:
            continue

        parts = line.split()
        cmd   = parts[0].lower()
        args  = parts[1:]

        if cmd in ("quit", "exit", "q"):
            print("  Bye.")
            break
        elif cmd in ("status", "s"):
            cmd_status()
        elif cmd == "ring":
            cmd_ring()
        elif cmd == "ping":
            cmd_ping(args)
        elif cmd == "pathping":
            cmd_pathping(args)
        elif cmd == "break":
            cmd_break(args)
        elif cmd == "heal":
            cmd_heal(args)
        elif cmd == "isolate":
            cmd_isolate(args)
        elif cmd == "restore":
            cmd_restore(args)
        elif cmd == "elect":
            cmd_elect(args)
        elif cmd == "watch":
            cmd_watch()
        elif cmd == "reset":
            cmd_reset()
        elif cmd in ("help", "?", "h"):
            print(HELP)
        else:
            print(f"  Unknown command: {cmd!r}. Type help.")

    if sim:
        sim.stop()


if __name__ == "__main__":
    run_shell()