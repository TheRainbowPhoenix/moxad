"""
compat.py  :  Cross-platform shim for tr2d

All platform-specific divergence lives here.  The rest of the codebase
imports from this module; nothing else does sys.platform checks.

Supported platforms
-------------------
  Linux   : AF_UNIX sockets, AF_PACKET raw sockets, fcntl/ioctl, /tmp paths
  Windows : TCP loopback IPC, no raw sockets (sim-only), tempfile paths

IPC transport choice
--------------------
  Linux   : AF_UNIX stream socket  (same as real tr2d binary)
  Windows : TCP loopback on 127.0.0.1:<port>

  The port is derived deterministically from the socket "name" so that
  tr2ctrl / TR2Client can still connect by name without any coordination.
  name -> port = 40000 + (hash(name) % 20000)

Wakeup channel (replaces socketpair)
--------------------------------------
  Both platforms: a pair of connected TCP loopback sockets created once.
  On Linux socketpair(AF_UNIX) would work too, but TCP keeps one code path.
"""

import os
import sys
import socket
import hashlib
import tempfile
import pathlib
import threading
import select as _select
from typing import Tuple, Optional

IS_WINDOWS = sys.platform == "win32"
IS_LINUX   = sys.platform.startswith("linux")

# 
# Path helpers
# 

def _tmpdir() -> pathlib.Path:
    return pathlib.Path(tempfile.gettempdir())

def default_socket_path() -> str:
    """Platform-appropriate default IPC address for the main daemon socket."""
    if IS_WINDOWS:
        return "tr2socket"          # used as a name -> converted to port
    return str(_tmpdir() / "tr2socket")

def default_lhc_socket_path() -> str:
    if IS_WINDOWS:
        return "lhcsocket"
    return str(_tmpdir() / "lhcsocket")

def default_config_path() -> str:
    if IS_WINDOWS:
        return str(_tmpdir() / "tr2_config.txt")
    return "/etc/tr2_config.txt"

def default_status_path() -> str:
    if IS_WINDOWS:
        return str(_tmpdir() / "tr2status")
    return "/var/db/tr2status"

# 
# IPC transport : unified AF_UNIX / TCP-loopback interface
# 

IPC_TCP_BASE_PORT = 40000
IPC_TCP_PORT_RANGE = 20000

def _name_to_port(name: str) -> int:
    """Derive a stable TCP port from a socket name string."""
    h = int(hashlib.md5(name.encode()).hexdigest(), 16)
    return IPC_TCP_BASE_PORT + (h % IPC_TCP_PORT_RANGE)

def ipc_address(name: str) -> object:
    """
    Return the address object to pass to bind()/connect().
      Linux  -> str (path)
      Windows -> (host, port) tuple
    """
    if IS_WINDOWS:
        return ("127.0.0.1", _name_to_port(name))
    return name         # already a filesystem path on Linux

def ipc_socket_family() -> int:
    """AF_UNIX on Linux, AF_INET on Windows."""
    return socket.AF_UNIX if not IS_WINDOWS else socket.AF_INET

def ipc_socket_type() -> int:
    return socket.SOCK_STREAM

def ipc_make_server(name: str, backlog: int = 5) -> socket.socket:
    """
    Create, bind, listen a server socket for the given name.
    On Linux: unlinks stale socket file first.
    """
    if not IS_WINDOWS and os.path.exists(name):
        try:
            os.unlink(name)
        except OSError:
            pass
    srv = socket.socket(ipc_socket_family(), ipc_socket_type())
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(ipc_address(name))
    srv.listen(backlog)
    return srv

def ipc_connect(name: str) -> socket.socket:
    """Create a connected client socket to the given server name."""
    sock = socket.socket(ipc_socket_family(), ipc_socket_type())
    sock.connect(ipc_address(name))
    return sock

def ipc_cleanup(name: str):
    """Remove the socket file (Linux only; no-op on Windows)."""
    if not IS_WINDOWS:
        try:
            os.unlink(name)
        except FileNotFoundError:
            pass

# 
# Wakeup channel  (replaces AF_UNIX socketpair)
#
# Returns (reader_sock, writer_sock) : both are socket.socket objects.
# Data written to writer_sock is readable from reader_sock.
# Works on Windows and Linux without fcntl.
# 

def make_wakeup_pair() -> Tuple[socket.socket, socket.socket]:
    """
    Return (reader, writer) connected socket pair.
    Uses AF_UNIX socketpair on Linux (O(1), no port needed).
    Falls back to a TCP loopback pair on Windows.
    """
    if not IS_WINDOWS:
        try:
            r, w = socket.socketpair(socket.AF_UNIX, socket.SOCK_DGRAM)
            return r, w
        except (AttributeError, OSError):
            pass
    # Windows / fallback: loopback TCP pair
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind(("127.0.0.1", 0))
    srv.listen(1)
    port = srv.getsockname()[1]
    w = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    w.connect(("127.0.0.1", port))
    r, _ = srv.accept()
    srv.close()
    r.setblocking(False)
    return r, w

# 
# Socket send/recv helpers
# (replaces os.write(fd, ...) / os.read(fd, ...) on raw fds)
# 

def sock_send(sock: socket.socket, data: bytes) -> int:
    """Send all bytes; return bytes sent or -1 on error."""
    try:
        sock.sendall(data)
        return len(data)
    except OSError:
        return -1

def sock_recv(sock: socket.socket, n: int) -> bytes:
    """Recv up to n bytes; return b'' on closed/error."""
    try:
        return sock.recv(n)
    except OSError:
        return b""

def sock_recv_exact(sock: socket.socket, n: int) -> Optional[bytes]:
    """Recv exactly n bytes or return None on EOF/error."""
    buf = b""
    while len(buf) < n:
        try:
            chunk = sock.recv(n - len(buf))
        except OSError:
            return None
        if not chunk:
            return None
        buf += chunk
    return buf

def fd_write(fd_or_sock, data: bytes) -> int:
    """
    Write to either an int fd (Linux raw socket) or a socket object.
    Returns bytes written or -1.
    """
    if isinstance(fd_or_sock, socket.socket):
        return sock_send(fd_or_sock, data)
    if IS_WINDOWS or fd_or_sock < 0:
        return -1
    try:
        return os.write(fd_or_sock, data)
    except OSError:
        return -1

def fd_read(fd_or_sock, n: int) -> bytes:
    """Read from either an int fd or a socket object."""
    if isinstance(fd_or_sock, socket.socket):
        return sock_recv(fd_or_sock, n)
    if IS_WINDOWS or fd_or_sock < 0:
        return b""
    try:
        return os.read(fd_or_sock, n)
    except OSError:
        return b""

# 
# select / wait helpers
# 

def wait_readable(socks, timeout_s: float) -> bool:
    """
    Return True if any of socks is readable within timeout_s seconds.
    Accepts socket.socket objects or integer fds.
    On Windows integer fds are skipped (only socket objects work).
    """
    if IS_WINDOWS:
        readable = [s for s in socks if isinstance(s, socket.socket)]
    else:
        readable = socks
    if not readable:
        return False
    try:
        r, _, _ = _select.select(readable, [], [], timeout_s)
        return bool(r)
    except (OSError, ValueError):
        return False

# 
# signal helpers
# 

import signal as _signal

def safe_signal(signum, handler):
    """
    Register a signal handler only when running in the main thread.
    Also skips SIGHUP on Windows (doesn't exist).
    """
    if threading.current_thread() is not threading.main_thread():
        return
    if IS_WINDOWS and signum == getattr(_signal, "SIGHUP", None):
        return
    try:
        _signal.signal(signum, handler)
    except (OSError, ValueError):
        pass

SIGHUP  = getattr(_signal, "SIGHUP",  None)
SIGINT  = _signal.SIGINT
SIGTERM = _signal.SIGTERM

# 
# Raw packet socket (Linux only : returns None on Windows)
# 

def open_raw_socket(iface: str) -> Optional[socket.socket]:
    """
    tr2_initTx equivalent.
    Returns an AF_PACKET SOCK_RAW socket bound to iface, or None on Windows.
    """
    if IS_WINDOWS:
        return None
    try:
        ETH_P_ALL = 0x0003
        sock = socket.socket(socket.AF_PACKET, socket.SOCK_RAW,
                              socket.htons(ETH_P_ALL))
        sock.bind((iface, ETH_P_ALL))
        return sock
    except OSError as e:
        import logging
        logging.getLogger("tr2d.compat").error(f"open_raw_socket({iface}): {e}")
        return None

def get_iface_mac(iface: str) -> bytes:
    """Read MAC address for iface; returns bytes(6) on failure/Windows."""
    try:
        if IS_WINDOWS:
            # Use uuid on Windows as a fallback
            import uuid
            mac_int = uuid.getnode()
            return mac_int.to_bytes(6, "big")
        path = f"/sys/class/net/{iface}/address"
        mac_str = open(path).read().strip()
        return bytes(int(x, 16) for x in mac_str.split(':'))
    except Exception:
        return bytes(6)
