"""
moxa_shm.py  -  Shared-memory layer for Moxa EDR-810 mock

Faithfully reverse-engineered from:
  libsysshm_so_1.c  - Semaphore_init/V/P, ShmAttachRW, CS_Start/CS_End,
                      shm_enterCS/shm_leaveCS
  libsyscommon_so_1.c - CS_Start(1492, 7890, &ptr) call pattern

Architecture on the real device
--------------------------------
  • POSIX shared memory: shmget(key, 6984, 0x3B6) + shmat
  • POSIX semaphore:     semget(key, 1, 0x3B6) protecting each region
  • CS_Start(sem_key=1492, shm_key=7890, &ptr)  - lock + attach
  • CS_End  (sem_key=1492, shm_key=7890,  ptr)  - detach + unlock
  • Multiple named regions (keys 1492/7890, plus per-daemon keys)

Our Python implementation
--------------------------
  • mmap-backed files under MOXA_RAMDISK/shm/<key>.shm  (32 kB each)
  • threading.Lock per key  (mimics the semaphore)
  • ShmRegion  - context-manager wrapping lock + mmap (= CS_Start/CS_End)
  • JSON overlay written to <key>.json for human-readable inspection
  • MoxaSHM   - the singleton registry / "shared memory bus"
"""

import os, json, mmap, struct, threading, contextlib, socket
from pathlib import Path
from typing import Any, Dict

# --- paths --------------------------------------------------------------------
RAMDISK = Path(os.environ.get("MOXA_RAMDISK", "/tmp/moxa_ramdisk"))
SHM_DIR = RAMDISK / "shm"

# --- SHM region sizes (from ShmAttachRW: shmget(key, 6984, ...) ) ------------
DEFAULT_SHM_SIZE = 6984     # bytes - real firmware default
LARGE_SHM_SIZE   = 32768    # our backing file is larger for safety

# --- well-known SHM / semaphore key pairs -------------------------------------
#   CS_Start(sem_key=1492, shm_key=7890, &ptr)  - main system config block
KEY_SEM_SYSCFG = 1492
KEY_SHM_SYSCFG = 7890
KEY_SEM_MCAST = 1509
KEY_SHM_MCAST = 7895

# --- IPC message type codes (used in net_Web_CTL_Send_And_Recv_Data) ----------
MSG_TYPE_CTL          = 0   # get scalar / small struct
MSG_TYPE_SEND         = 1   # push data to daemon
MSG_TYPE_SEND_RECV    = 2   # push + receive response
MSG_TYPE_TABLE_COUNT  = 3   # query table row count
MSG_TYPE_TABLE_DATA   = 4   # fetch table
MSG_TYPE_STRUCT_INFO  = 5   # get struct size/count info
MSG_TYPE_SEND_CONFIRM = 7   # push + confirm receipt


class ShmRegion:
    """
    One named shared-memory region backed by an mmap file.
    Mirrors ShmAttachRW + Semaphore_P/V lifecycle.

    Usage (mirrors CS_Start / CS_End):
        with ShmRegion(key=7890) as mem:
            data = mem.read(0, 100)
            mem.write(0, new_bytes)
    """
    _registry: dict = {}           # class-level: key → (lock, path)
    _reg_lock  = threading.Lock()  # protects _registry itself

    def __init__(self, key: int, size: int = LARGE_SHM_SIZE):
        SHM_DIR.mkdir(parents=True, exist_ok=True)
        self.key  = key
        self.size = size
        self.path = SHM_DIR / f"{key}.shm"
        with ShmRegion._reg_lock:
            if key not in ShmRegion._registry:
                ShmRegion._registry[key] = threading.Lock()
        self._lock = ShmRegion._registry[key]
        self._mm: mmap.mmap | None = None
        self._fh = None

    # -- context manager (= CS_Start / CS_End) ---------------------------------
    def __enter__(self) -> "ShmRegion":
        self._lock.acquire()          # Semaphore_P
        self._open()
        return self

    def __exit__(self, *_):
        self._close()                 # ShmDetach
        self._lock.release()          # Semaphore_V

    # -- low-level I/O ---------------------------------------------------------
    def _open(self):
        # Create file if it doesn't exist
        exists = self.path.exists()
        self._fh = open(self.path, "r+b" if exists else "w+b")
        if not exists:
            self._fh.write(b"\x00" * self.size)
            self._fh.flush()
        self._mm = mmap.mmap(self._fh.fileno(), self.size)

    def _close(self):
        if self._mm:
            self._mm.flush()
            self._mm.close()
            self._mm = None
        if self._fh:
            self._fh.close()
            self._fh = None

    def read(self, offset: int, length: int) -> bytes:
        assert self._mm, "Not attached"
        self._mm.seek(offset)
        return self._mm.read(length)

    def write(self, offset: int, data: bytes):
        assert self._mm, "Not attached"
        self._mm.seek(offset)
        self._mm.write(data)

    def read_u8(self, offset: int) -> int:
        return struct.unpack_from("<B", self.read(offset, 1))[0]

    def write_u8(self, offset: int, value: int):
        self.write(offset, struct.pack("<B", int(value) & 0xFF))

    def read_u16(self, offset: int) -> int:
        return struct.unpack_from("<H", self.read(offset, 2))[0]

    def write_u16(self, offset: int, value: int):
        self.write(offset, struct.pack("<H", int(value) & 0xFFFF))

    def read_u32(self, offset: int) -> int:
        return struct.unpack_from("<I", self.read(offset, 4))[0]

    def write_u32(self, offset: int, value: int):
        self.write(offset, struct.pack("<I", int(value) & 0xFFFFFFFF))

    def read_str(self, offset: int, maxlen: int) -> str:
        raw = self.read(offset, maxlen)
        return raw.split(b"\x00")[0].decode("latin-1")

    def write_str(self, offset: int, value: str, maxlen: int):
        b = value.encode("latin-1")[:maxlen-1]
        self.write(offset, b + b"\x00" * (maxlen - len(b)))

    def read_ip(self, offset: int) -> str:
        return socket.inet_ntoa(self.read(offset, 4))

    def write_ip(self, offset: int, ip: str):
        try:
            ip_bytes = socket.inet_aton(ip)
        except socket.error:
            ip_bytes = b'\x00\x00\x00\x00'
        self.write(offset, ip_bytes)

    # -- without lock (for bulk batch operations) -------------------------------
    @contextlib.contextmanager
    def open_nolock(self):
        self._open()
        try:
            yield self
        finally:
            self._close()


class MoxaSHM:
    """
    High-level shared-memory bus.

    Mirrors the behaviour of the real firmware's SHM daemon:
      - stores the complete device state as a JSON overlay
      - provides typed accessors for every field queried by
        net_Web_CTL_Send_And_Recv_Data(send_domain, recv_domain, cmd_id, buf, size)
      - can serialise / deserialise the full device state to/from JSON
        (human-readable companion to the raw mmap files)

    The on-disk layout:
        $MOXA_RAMDISK/shm/state.json   ← canonical JSON state
        $MOXA_RAMDISK/shm/7890.shm     ← raw mmap backing (syscfg region)
        $MOXA_RAMDISK/shm/<key>.shm    ← other regions as needed
    """

    STATE_FILE = SHM_DIR / "state.json"

    # -- default factory state --------------------------------------------------
    FACTORY = {
        "system": {
            "hostname":    "MOXA-EDR810",
            "location":    "",
            "description": "",
            "contact":     "",
            "fw_version":  "3.13",
            "hw_version":  "1.0",
            "serial":      "MOCKSN000001",
            "mac":         "00:90:e8:00:00:01",
            "uptime_sec":  0,
            "device_mode": 0,       # 0=router
            "login_mode":  "local",
            "banner":      "",
            "fail_banner": "",
            "mac_aging":   300,
            "lldp_enable": 1,
            "lldp_timer":  30,
            "fast_bootup": 0,
            "auto_backup": 0,
            "mtu":         1500,
            "redundancy_mode": 0,
            "watchdog_flag": 1,
        },
        # 10 account slots, 72 bytes each in real SHM:
        #   [0..31] username, [32..63] password, [64] is_admin, [68] role
        "accounts": [
            {"username": "admin", "password": "moxa", "role": 0, "is_admin": 1},
        ],
        "network": {
            "lan_ip":   "192.168.127.254",
            "lan_mask": "255.255.255.0",
            "wan_ip":   "0.0.0.0",
            "wan_mask": "0.0.0.0",
            "wan_gw":   "0.0.0.0",
            "dns1":     "8.8.8.8",
            "dns2":     "",
            "wan_conn_type": 0,
            "default_gw_active": 0,
        },
        "interfaces": {},
        "static_routes": [],
        "config": {
            "ping_status": 0,
            "wan_backup": 0,
            "link_check": 0,
            "ping_check": 0,
            "ping_dst_ip": "0.0.0.0",
            "ping_retry": 3,
            "ping_timeout": 3,
            "ping_interval": 10,
        },
        "logging": {"buffered": 128000, "servers": []},
        "ntp":     {"servers": [], "refresh": 3600},
        "clock":   {"timezone_index": 23, "dst_start": "", "dst_end": "", "dst_offset": 0},
        "snmp": {
            "version": "v1-v2c",
            "community1": "public",  "access1": 1,
            "community2": "private", "access2": 0,
        },
        "ssh":    {"enabled": 1, "port": 22, "idle_timeout": 0},
        "web":    {"enabled": 1, "port": 80, "https_enabled": 1, "https_port": 443,
                   "auto_logout": 0, "max_users": 5},
        "telnet": {"enabled": 1, "port": 23, "max_users": 1},
        "login_lockout":   {"enabled": 0, "max_fail": 5, "lockout_time": 300},
        "password_policy": {"min_len": 4, "enabled": 0,
                            "require_digit": 0, "require_upper_lower": 0, "require_special": 0},
        "redundancy":    {"mode": "none"},
        "spanning_tree": {"enabled": 0, "priority": 32768},
        "vlan":          {"mode": "1qvlan", "vlans": []},
        "upgrade_status": 0,
        "timezone_index": 23,
        "mcast": [],
    }

    def __init__(self):
        SHM_DIR.mkdir(parents=True, exist_ok=True)
        self._lock = threading.Lock()
        self._state: dict = {}
        self._load()

    # -- persistence -----------------------------------------------------------
    def _load(self):
        import copy
        try:
            self._state = json.loads(self.STATE_FILE.read_text())
        except Exception:
            self._state = copy.deepcopy(self.FACTORY)

    def save(self):
        """Flush JSON state to disk (and sync to mmap backing)."""
        with self._lock:
            self.STATE_FILE.write_text(json.dumps(self._state, indent=2))
            self._sync_mmap()

    def _sync_mmap(self):
        """Write key fields to the raw mmap backing for compatibility."""
        s = self._state
        
        # --- MAIN SHM REGION (SYSCFG) -----------------------------------------
        with ShmRegion(KEY_SHM_SYSCFG).open_nolock() as mem:
            # Offset 0: device_mode (4 bytes LE)
            mem.write_u32(0, s["system"].get("device_mode", 0))
            # Offset 4: hostname (41 bytes)
            mem.write_str(4, s["system"].get("hostname", ""), 41)
            # Offset 45: location (81 bytes)
            mem.write_str(45, s["system"].get("location", ""), 81)
            # Offset 126: contact (37 bytes) - approx layout
            mem.write_str(126, s["system"].get("contact", ""), 37)

            # TODO: use libsyscommon and look at CS_Start(1492, 7890 for offsets...
            
            # =========================================================
            # DYNAMIC OFFSETS DECODED FROM sub_8DC8 (KEY: 7890)
            # =========================================================

            # --- ShmData Globals ---
            mem.write_u32(424, s["system"].get("redundancy_mode", 0))
            mem.write_u32(428, s["config"].get("ping_status", 0))
            mem.write_u32(432, s["network"].get("default_gw_active", 0))
            mem.write_u32(444, s["system"].get("timezone_index", 23))
            mem.write_u32(6976, s["system"].get("watchdog_flag", 1))

            # --- ShmData.Data (WAN Interfaces Array) (i=0..1) ---
            wan_keys = ["wan0", "wan1"]
            for i, wkey in enumerate(wan_keys):
                w_data = s["interfaces"].get(wkey, {})
                b = 60 * i
                mem.write_u32(452 + b, w_data.get("link_status", 0))
                mem.write_ip(456 + b, w_data.get("ip", "0.0.0.0"))
                mem.write_ip(460 + b, w_data.get("mask", "0.0.0.0"))
                mem.write_ip(464 + b, w_data.get("gw", "0.0.0.0"))
                mem.write_u32(468 + b, w_data.get("vid", 1))
                mem.write_str(472 + b, w_data.get("name", wkey), 16)

            # --- ShmConfig ---
            mem.write_u32(6868, s["config"].get("wan_backup", 0))
            mem.write_u32(6872, s["config"].get("link_check", 0))
            mem.write_u32(6876, s["config"].get("ping_check", 0))
            mem.write_ip(6880, s["config"].get("ping_dst_ip", "0.0.0.0"))
            mem.write_u32(6884, s["config"].get("ping_retry", 3))
            mem.write_u32(6888, s["config"].get("ping_timeout", 3))
            mem.write_u32(6892, s["config"].get("ping_interval", 10))

            # --- shm_vconf (VLAN Interfaces Config Array) (i=0..15) ---
            vlans = s["vlan"].get("vlans", [])
            for i in range(min(16, len(vlans))):
                v = vlans[i]
                b = 88 * i
                mem.write_str(1408 + b, v.get("name", f"vlan{i}"), 16)
                mem.write_str(1440 + b, v.get("usr_name", ""), 16)
                mem.write_u32(1472 + b, v.get("id", 1))
                mem.write_u32(1484 + b, v.get("routing", 0))
                mem.write_u32(1488 + b, v.get("port_member", 0))
                mem.write_u32(1492 + b, v.get("if_link", 0))

            # --- shm_vlan (VLAN Hardware IDs) (i=0..15) ---
            for i in range(min(16, len(vlans))):
                v = vlans[i]
                b = 18 * i
                mem.write_u16(5808 + b, v.get("id", 1))
                mem.write_u8(5810 + b, v.get("port_type_0", 0))
                
            # --- shm_vplan (Bridge Groups) (i=0..13) ---
            for i in range(14):
                b = 8 * i
                mem.write_u16(6096 + b, 1) # default pvid = 1
                mem.write_u16(6098 + b, 0) # default bg_id = 0

            # --- shm_brg (Bridge Interfaces) (i=0..3) ---
            for i in range(4):
                b = 88 * i
                mem.write_str(2816 + b, f"brg{i}", 16)
                mem.write_u32(2880 + b, i)             # brg_gid
                mem.write_u32(2884 + b, 0)             # brg_Ip
                mem.write_u32(2888 + b, 0)             # brg_Mask
                mem.write_u32(2892 + b, 0)             # brg_enable

        # --- MCAST SHM REGION (MCAST) -----------------------------------------
        # MCAST SHM (KEY: 7895) DECODED FROM shm_enterCS(1509)
        with ShmRegion(KEY_SHM_MCAST).open_nolock() as mcast_mem:
            mcast_entries = s.get("mcast", [])
            mcast_mem.write_u32(6144, len(mcast_entries))
            
            for i, entry in enumerate(mcast_entries):
                b = 24 * i
                mcast_mem.write_u16(0 + b, entry.get("valid", 1))
                mac = entry.get("mac", "00:00:00:00:00:00")
                mac_bytes = bytes.fromhex(mac.replace(':', ''))
                for j in range(6):
                    mcast_mem.write_u8(2 + b + j, mac_bytes[j] if j < len(mac_bytes) else 0)


    def reset(self):
        """Reset to factory defaults."""
        import copy
        with self._lock:
            self._state = copy.deepcopy(self.FACTORY)
        self.save()

    # -- getters (cmd_id-indexed, mirrors net_Web_CTL_Send_And_Recv_Data) ------
    def get(self, cmd_id: int) -> object:
        """
        Return the data block for a given cmd_id.
        Mirrors what the SHM daemon returns to net_Web_CTL_Send_And_Recv_Data.
        """
        s = self._state
        _map = {
            1:   s["system"].get("device_mode", 0),
            4:   s.get("snmp", {}),
            5:   s.get("network", {}),
            20:  s["system"].get("hostname", ""),
            51:  s["system"].get("hostname", ""),   # used in export_file_init
            95:  s.get("accounts", []),
            105: s.get("login_lockout", {}),
            108: s.get("web", {}).get("auto_logout", 0),
            110: s.get("network", {}),
            111: s.get("ntp", {}),
            113: s.get("clock", {}),
            124: s["system"].get("hostname", ""),
            208: s.get("accounts", []),
        }
        return _map.get(cmd_id, None)

    def set(self, cmd_id: int, data: object):
        """Update the state for a given cmd_id."""
        s = self._state
        if cmd_id == 20:
            s["system"]["hostname"] = str(data)
        elif cmd_id == 208:
            s["accounts"] = data
        # … extend as needed
        self.save()

    # -- direct field accessors -------------------------------------------------
    @property
    def state(self) -> dict:
        return self._state

    def get_accounts(self) -> list:
        with self._lock:
            return list(self._state.get("accounts", []))

    def set_account(self, username: str, password: str, role: int):
        with self._lock:
            accs = self._state.setdefault("accounts", [])
            for a in accs:
                if a["username"] == username:
                    a["password"] = password
                    a["role"]     = role
                    return
            accs.append({"username": username, "password": password,
                         "role": role, "is_admin": 1 if role == 0 else 0})
        self.save()

    def get_account(self, username: str) -> dict | None:
        with self._lock:
            return next((a for a in self._state.get("accounts", [])
                         if a["username"] == username), None)

    def get_account_index(self, username: str) -> int:
        """Port of account_get_account_list_index."""
        with self._lock:
            for i, a in enumerate(self._state.get("accounts", [])):
                if a["username"] == username:
                    return i
        return -1

    def update(self, section: str, key: str, value):
        with self._lock:
            self._state.setdefault(section, {})[key] = value
        self.save()

    def section(self, name: str) -> dict:
        with self._lock:
            import copy
            return copy.deepcopy(self._state.get(name, {}))


# -- module-level singleton -----------------------------------------------------
_shm_singleton: MoxaSHM | None = None
_shm_lock = threading.Lock()

def get_shm() -> MoxaSHM:
    """Return the process-global MoxaSHM singleton."""
    global _shm_singleton
    with _shm_lock:
        if _shm_singleton is None:
            _shm_singleton = MoxaSHM()
    return _shm_singleton


# -- CS_Start / CS_End Python equivalents --------------------------------------
def cs_start(sem_key: int, shm_key: int) -> ShmRegion:
    """Mirrors CS_Start(sem_key, shm_key, &ptr): lock + attach."""
    region = ShmRegion(shm_key)
    region.__enter__()
    return region

def cs_end(region: ShmRegion):
    """Mirrors CS_End(sem_key, shm_key, ptr): detach + unlock."""
    region.__exit__(None, None, None)


# -- IMPORTANT ARCHITECTURE NOTE: MAC ADDRESS FDB ------------------------------
# As seen in `sub_BD98` (`do_getCPU_FdbEntry`), the MAC Forwarding Database
# is NOT stored in Shared Memory. It queries the switch ASIC directly via:
#   ioctl(open("/dev/eth_switch"), 0x82044704, payload)
# To mock MAC table retrieval, you should intercept or mock `/dev/eth_switch` 
# rather than adding it to `MoxaSHM`.

if __name__ == "__main__":
    import sys
    cmd = sys.argv[1] if len(sys.argv) > 1 else "dump"
    shm = get_shm()
    if cmd == "dump":
        print(json.dumps(shm.state, indent=2))
    elif cmd == "reset":
        shm.reset()
        print("SHM reset to factory defaults.")
    elif cmd == "region":
        key = int(sys.argv[2]) if len(sys.argv) > 2 else KEY_SHM_SYSCFG
        with ShmRegion(key) as r:
            print(f"Region {key}: first 64 bytes = {r.read(0, 64).hex()}")
