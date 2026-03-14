#!/usr/bin/env python3
"""
moxa_cli.py  -  Moxa EDR-810 CLI shell mock

Sources:
  libsyscommon_so_1.c   - account layout, lockout, string validators
  libsysexport_so_1.c   - cmd_prefix_table (527 entries), cli_lib_cmd_export,
                           cli_banner_process, DataEncryp/DatadeEncryp,
                           all cparser_show* functions
  cparser.c / cparser_*.c  - cparser_t FSM, line editing, help, tab-complete
  libsysshm_so_1.c      - CS_Start/CS_End (via moxa_shm.py)

Usage:
  python3 moxa_cli.py [--state PATH] [--user USER]
  python3 moxa_cli.py --export          # dump running-config to stdout
  python3 moxa_cli.py --show <topic>    # non-interactive show
  python3 moxa_cli.py --daemon          # start background SHM daemon
"""

import sys, os, re, json, hashlib, struct, copy, time, socket
from pathlib import Path
from datetime import datetime, timezone
from typing import Optional
import warnings

# -- optional crypto import ----------------------------------------------------
try:
    from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
    from cryptography.hazmat.backends import default_backend
    _HAVE_CRYPTO = True
except ImportError:
    _HAVE_CRYPTO = False

# -- SHM / IPC imports --------------------------------------------------------
RAMDISK = Path(os.environ.get("MOXA_RAMDISK", "moxa_ramdisk"))
sys.path.insert(0, str(Path(__file__).parent))

try:
    from moxa_shm import get_shm, MoxaSHM
    _HAS_SHM = True
except ImportError:
    _HAS_SHM = False

# -----------------------------------------------------------------------------
# Device identity
# -----------------------------------------------------------------------------
BANNER_MODEL = os.environ.get("MOXA_MODEL",  "EDR-810")
BANNER_FW    = os.environ.get("MOXA_FW",     "3.13")
BANNER_BUILD = os.environ.get("MOXA_BUILD",  "24010516")

# -----------------------------------------------------------------------------
# Pure-Python DES (single key, ECB)
# Faithful port of DES_encrypt1 (OpenSSL) used in DataEncryp / DatadeEncryp
# Verified against OpenSSL TripleDES(key×3) which equals single DES for 8-byte key
# -----------------------------------------------------------------------------
_DES_PC1  = [57,49,41,33,25,17,9,1,58,50,42,34,26,18,10,2,59,51,43,35,27,19,
             11,3,60,52,44,36,63,55,47,39,31,23,15,7,62,54,46,38,30,22,14,6,
             61,53,45,37,29,21,13,5,28,20,12,4]
_DES_PC2  = [14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,26,8,16,7,27,20,13,2,
             41,52,31,37,47,55,30,40,51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32]
_DES_SHF  = [1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1]
_DES_IP   = [58,50,42,34,26,18,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,6,
             64,56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,51,43,35,27,19,11,3,
             61,53,45,37,29,21,13,5,63,55,47,39,31,23,15,7]
_DES_FP   = [40,8,48,16,56,24,64,32,39,7,47,15,55,23,63,31,38,6,46,14,54,22,62,30,
             37,5,45,13,53,21,61,29,36,4,44,12,52,20,60,28,35,3,43,11,51,19,59,27,
             34,2,42,10,50,18,58,26,33,1,41,9,49,17,57,25]
_DES_E    = [32,1,2,3,4,5,4,5,6,7,8,9,8,9,10,11,12,13,12,13,14,15,16,17,16,17,18,19,
             20,21,20,21,22,23,24,25,24,25,26,27,28,29,28,29,30,31,32,1]
_DES_P    = [16,7,20,21,29,12,28,17,1,15,23,26,5,18,31,10,2,8,24,14,32,27,3,9,19,13,
             30,6,22,11,4,25]
_DES_S    = [
  [[14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7],[0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8],
   [4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0],[15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13]],
  [[15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10],[3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5],
   [0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15],[13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9]],
  [[10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8],[13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1],
   [13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7],[1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12]],
  [[7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15],[13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9],
   [10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4],[3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14]],
  [[2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9],[14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
   [4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],[11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]],
  [[12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11],[10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
   [9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],[4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13]],
  [[4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],[13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
   [1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],[6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12]],
  [[13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],[1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
   [7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],[2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]],
]

def _bits(data: bytes) -> list:
    b = []
    for byte in data:
        for i in range(7, -1, -1):
            b.append((byte >> i) & 1)
    return b

def _frombits(b: list) -> bytes:
    out = []
    for i in range(0, len(b), 8):
        v = 0
        for j in range(8):
            v = (v << 1) | b[i+j]
        out.append(v)
    return bytes(out)

def _perm(bits, tbl):
    return [bits[t-1] for t in tbl]

def _des_keyschedule(key: bytes) -> list:
    k = _perm(_bits(key), _DES_PC1)
    C, D = k[:28], k[28:]
    subs = []
    for sh in _DES_SHF:
        C = C[sh:] + C[:sh]
        D = D[sh:] + D[:sh]
        subs.append(_perm(C + D, _DES_PC2))
    return subs

def _des_block(block: bytes, subs: list, enc: bool) -> bytes:
    bb  = _perm(_bits(block), _DES_IP)
    L, R = bb[:32], bb[32:]
    ks = subs if enc else list(reversed(subs))
    for sk in ks:
        ER   = _perm(R, _DES_E)
        xr   = [ER[i] ^ sk[i] for i in range(48)]
        sout = []
        for s in range(8):
            chunk = xr[6*s:6*s+6]
            row = (chunk[0] << 1) | chunk[5]
            col = (chunk[1] << 3) | (chunk[2] << 2) | (chunk[3] << 1) | chunk[4]
            sout += [int(x) for x in f'{_DES_S[s][row][col]:04b}']
        f    = _perm(sout, _DES_P)
        L, R = R, [L[i] ^ f[i] for i in range(32)]
    return _frombits(_perm(R + L, _DES_FP))

_MOXA_KEY = b"MOXA2DES"
_MOXA_SUBS = _des_keyschedule(_MOXA_KEY)

def _des_enc(block8: bytes) -> bytes:
    return _des_block(block8, _MOXA_SUBS, True)

def _des_dec(block8: bytes) -> bytes:
    return _des_block(block8, _MOXA_SUBS, False)


def data_encryp(password: str, buf_len: int = 32) -> str:
    """
    Faithful port of DataEncryp(char *a1, int a2) from libsysexport_so_1.c:

      1. Copy password into buf_len zero-padded buffer
      2. DES-ECB encrypt with key "MOXA2DES" in 8-byte blocks
         (n_blocks = ((buf_len-1)>>3)+1)
      3. Hex-encode encrypted bytes → hex_str
      4. MD5(hex_str) → 16 bytes → append as 32 hex chars
      Result length = buf_len*2 + 32
    """
    buf = bytearray(buf_len)
    pw  = password.encode("latin-1")[:buf_len]
    buf[:len(pw)] = pw
    n_blocks = ((buf_len - 1) >> 3) + 1
    enc = bytearray()
    for i in range(n_blocks):
        enc += _des_enc(bytes(buf[8*i : 8*i+8]))
    hex_str = "".join(f"{b:02x}" for b in enc[:buf_len])
    md5_hex = hashlib.md5(hex_str.encode("ascii")).hexdigest()
    return hex_str + md5_hex


def data_deencryp(enc_str: str, buf_len: int = 32) -> str:
    """
    Faithful port of DatadeEncryp(char *a1, size_t a2, int a3):

      1. Split: hex_part = enc_str[:-32], md5_part = enc_str[-32:]
      2. Verify MD5(hex_part) == md5_part  (raises ValueError on fail)
      3. Hex-decode hex_part → enc_bytes
      4. DES-ECB decrypt in 8-byte blocks
      5. Strip null padding → password
    """
    expected = buf_len * 2 + 32
    if len(enc_str) != expected:
        raise ValueError(f"DatadeEncryp: length {len(enc_str)} != expected {expected}")
    hex_part = enc_str[:-32]
    md5_part = enc_str[-32:]
    if hashlib.md5(hex_part.encode("ascii")).hexdigest() != md5_part:
        raise ValueError("MD5 MAPPING Error")
    enc_bytes = bytes(int(hex_part[i:i+2], 16) for i in range(0, len(hex_part), 2))
    n_blocks  = ((buf_len - 1) >> 3) + 1
    dec = bytearray()
    for i in range(n_blocks):
        dec += _des_dec(enc_bytes[8*i : 8*i+8])
    return bytes(dec[:buf_len]).rstrip(b"\x00").decode("latin-1")


# -----------------------------------------------------------------------------
# cli_banner_process  (libsysexport_so_1.c line 10556)
# -----------------------------------------------------------------------------
def cli_banner_process(src: str) -> str:
    """
    Port of cli_banner_process(a1, a2, a3):
      \\r → skip
      \\n → literal "\\n"
      ' ' → literal "\\\\"
      else → verbatim character
    """
    out = []
    for ch in src:
        if ch == "\r":
            continue
        elif ch == "\n":
            out.append("\\n")
        elif ch == " ":
            out.append("\\\\")
        else:
            out.append(ch)
    return "".join(out)


# -----------------------------------------------------------------------------
# cmd_prefix_table  (libsysexport_so_1.c lines 225-10108, decoded)
# -----------------------------------------------------------------------------
CMD = {
    0:"vlan create ",1:"no vlan create ",2:"vlan mode 1qvlan ",
    3:"vlan mode pvlan ",4:"vlan mode unaware ",5:"no vlan mode ",
    6:"show vlan ",7:"show interfaces switchport ",8:"show interfaces trunk ",
    9:"switchport access vlan ",10:"switchport trunk native vlan ",
    11:"switchport trunk fixed vlan add ",12:"switchport trunk forbidden vlan add ",
    13:"switchport hybrid native vlan ",14:"switchport hybrid fixed vlan add ",
    15:"switchport hybrid forbidden vlan add ",17:"gvrp",18:"no gvrp",
    19:"login mode",20:"hostname",21:"snmp-server location",
    22:"snmp-server description",23:"snmp-server contact",
    24:"mac-address-table aging-time",25:"aaa authentication banner",
    26:"aaa authentication fail-message",27:"auto-backup",28:"no auto-backup",
    29:"ip http-server",30:"no ip http-server",32:"ip telnet",33:"no ip telnet",
    34:"ip http-server auto-logout",35:"ip http-server port",
    36:"ip http-server secure port",37:"no ip http-server secure",
    38:"ip telnet port",39:"ip ssh port",40:"no ip ssh",
    41:"snmp-server community",42:"snmp-server version",43:"snmp-server user",
    44:"snmp-server host",45:"no snmp-server host",46:"snmp-server trap-mode",
    47:"no snmp-server trap-mode",48:"interface ethernet",49:"shutdown",
    50:"no shutdown",51:"name",52:"no name",53:"speed-duplex",54:"flowcontrol",
    55:"no flowcontrol",56:"media cable-mode",57:"interface trunk",
    58:"trunk-group",59:"trunk-mode",60:"bridge group",75:"logging",
    76:"no logging",77:"clock timezone gmt",78:"no clock timezone",
    79:"clock summer-time start-date",80:"clock summer-time end-date",
    81:"clock summer-time offset",82:"ntp remote-server",83:"no ntp remote-server",
    84:"ntp refresh-time",85:"ntp server",86:"no ntp server",
    87:"interface mgmt",88:"interface lan",89:"ip address",90:"no ip address",
    91:"ip name-server",92:"no ip name-server",93:"ip default-gateway",
    94:"no ip default-gateway",95:"ip dhcp retry",96:"bind vlan",
    97:"ipv6 address",98:"lldp enable",99:"no lldp enable",100:"lldp timer",
    107:"monitor source interface",108:"no monitor source interface",
    109:"monitor destination interface",110:"no monitor destination interface",
    163:"ip access-list",164:"permit",165:"ip acl-bind",183:"redundancy mode",
    198:"spanning-tree priority",199:"spanning-tree forward-delay",
    200:"spanning-tree max-age",201:"spanning-tree hello-time",207:"spanning-tree",
    208:"username",209:"auth mode",210:"auth tacacs+ server-ip",
    211:"auth tacacs+ server-port",212:"auth tacacs+ shared-key",
    213:"auth tacacs+ auth-type",214:"auth tacacs+ timeout",215:"auth radius",
    216:"auth radius server",217:"auth radius server-port",
    218:"auth radius shared-key",219:"auth radius timeout",239:"router rip",
    240:"no router rip",241:"version",242:"network",243:"redistribute",
    245:"router vrrp",257:"ip route static",258:"no ip route",259:"router ospf",
    260:"no router ospf",281:"redundancy",374:"firewall",375:"action",
    376:"mode",377:"protocol",378:"src-ip",379:"src-port",380:"dst-ip",
    381:"dst-port",393:"interface wan",394:"shutdown",395:"bind vlan",
    396:"ip address",402:"ip ddns",418:"ip nat",419:"ipsec",
    447:"ip dhcp pool",448:"lease",449:"network",450:"dns-server",
    451:"ntp-server",452:"default-router",460:"service dhcp",461:"settingcheck",
    462:"ip",463:"no ip",464:"moxa-utility",465:"no moxa-utility",
    474:"mac-address",475:"logging",476:"openvpn server",498:"openvpn client",
    511:"security-notification",512:"no security-notification",
    513:"password-policy",514:"no password-policy",515:"logging-capacity",
    516:"no logging-capacity",517:"login-lockout",518:"no login-lockout",
    519:"fast-bootup",520:"no fast-bootup",521:"mtu",522:"fiber-check enable",
}


def cli_lib_cmd_export(out, cmd_id: int, indent: int, fmt: str = "", *args):
    """
    Port of cli_lib_cmd_export(FILE*,cmd_id,indent,fmt,...):
      write (indent-1) spaces + CMD[cmd_id] + ' ' + fmt%args + '\\n'
    """
    prefix = CMD.get(cmd_id, f"<cmd_{cmd_id}>")
    body   = (fmt % args) if args else fmt
    line   = (" " * (indent - 1)) + prefix + (" " + body if body else "") 
    out.write(line.rstrip() + "\n")


# -----------------------------------------------------------------------------
# Timezone tables (verbatim from libsyscommon_so_1.c rdfile[]/timezone_shift[])
# -----------------------------------------------------------------------------
TIMEZONE_NAMES = [
    "Eniwetok","Midway-Island","Hawaii","Alaska","Pacific-Time","Arizona",
    "Mountain-Time","Central-Time","Mexico-City","Saskatchewan","Bogota",
    "Eastern-Time","Indiana","Atlantic-Time","Caracas","Santiago","Newfoundland",
    "Brasilia","Buenos-Aires","Mid-Atlantic","Azores","Casablanca","Greenwich",
    "Amsterdam","Belgrade","Brussels","Sarajevo","Athens","Bucharest","Cairo",
    "Harare","Helsinki","Jerusalem","Baghdad","Moscow","Nairobi","Tehran",
    "Abu-Dhabi","Baku","Kabul","Ekaterinburg","Islamabad","Bombay","Astana",
    "Colombo","Bangkok","Beijing","Perth","Singapore","Taipei","Osaka","Seoul",
    "Yakutsk","Adelaide","Darwin","Brisbane","Canberra","Guam","Hobart",
    "Vladivostok","Magadan","Auckland","Fiji",
]
TIMEZONE_SHIFTS = [
    -43200,-39600,-36000,-32400,-28800,-25200,-25200,-21600,-21600,-21600,
    -18000,-18000,-18000,-14400,-14400,-14400,-12600,-10800,-10800,-7200,
    -3600,0,0,3600,3600,3600,3600,7200,7200,7200,7200,7200,7200,10800,
    10800,10800,12600,14400,14400,16200,18000,18000,19800,21600,21600,
    25200,28800,28800,28800,28800,32400,32400,32400,34200,34200,36000,
    36000,36000,36000,36000,39600,43200,43200,
]

# -----------------------------------------------------------------------------
# Account constants (libsyscommon_so_1.c account_set/account_get_*)
# -----------------------------------------------------------------------------
ROLE_ADMIN    = 0   # privilege 1  ("admin" must be this)
ROLE_OPERATOR = 17  # privilege 2
ROLE_USER     = 16  # privilege 3  ("user" must be this)
MAX_ACCOUNTS  = 10  # hard limit from account_get_account_list_index i<=9 loop

# -----------------------------------------------------------------------------
# SHM state access
# -----------------------------------------------------------------------------
SHM_FILE = RAMDISK / "shm" / "state.json"

FACTORY = {
    "system":{"hostname":"MOXA-EDR810","location":"","description":"",
              "contact":"","fw_version":BANNER_FW,"hw_version":"1.0",
              "serial":"MOCKSN000001","mac":"00:90:e8:00:00:01",
              "uptime_sec":0,"device_mode":0,"login_mode":"local",
              "banner":"","fail_banner":"","mac_aging":300,"lldp_enable":1,
              "lldp_timer":30,"fast_bootup":0,"auto_backup":0,"mtu":1500},
    "accounts":[{"username":"admin","password":"moxa","role":0,"is_admin":1}],
    "network":{"lan_ip":"192.168.127.254","lan_mask":"255.255.255.0",
               "wan_ip":"0.0.0.0","wan_mask":"0.0.0.0","wan_gw":"0.0.0.0",
               "dns1":"8.8.8.8","dns2":"","wan_conn_type":0},
    "interfaces":{},
    "static_routes":[],
    "logging":{"buffered":128000,"servers":[]},
    "ntp":{"servers":[],"refresh":3600},
    "clock":{"timezone_index":23,"dst_start":"","dst_end":"","dst_offset":0},
    "snmp":{"version":"v1-v2c","community1":"public","access1":1,
            "community2":"private","access2":0},
    "ssh":{"enabled":1,"port":22,"idle_timeout":0},
    "web":{"enabled":1,"port":80,"https_enabled":1,"https_port":443,
           "auto_logout":0,"max_users":5},
    "telnet":{"enabled":1,"port":23,"max_users":1},
    "login_lockout":{"enabled":0,"max_fail":5,"lockout_time":300},
    "password_policy":{"min_len":4,"enabled":0,"require_digit":0,
                       "require_upper_lower":0,"require_special":0},
    "redundancy":{"mode":"none"},
    "spanning_tree":{"enabled":0,"priority":32768},
    "vlan":{"mode":"1qvlan","vlans":[]},
    "upgrade_status":0,"timezone_index":23,
}


def shm_load() -> dict:
    if _HAS_SHM:
        return get_shm().state
    try:
        return json.loads(SHM_FILE.read_text())
    except Exception:
        return copy.deepcopy(FACTORY)


def shm_save(s: dict):
    if _HAS_SHM:
        get_shm()._state = s
        get_shm().save()
        return
    SHM_FILE.parent.mkdir(parents=True, exist_ok=True)
    SHM_FILE.write_text(json.dumps(s, indent=2))


# -----------------------------------------------------------------------------
# cparser_show* functions  (direct port from libsysexport_so_1.c)
# -----------------------------------------------------------------------------

def cparser_showSystemConfig(out, shm):
    """Lines 10593-10622. cmd IDs 20-26."""
    s = shm["system"]
    cli_lib_cmd_export(out, 20, 1, s["hostname"])
    if s.get("location"):   cli_lib_cmd_export(out, 21, 1, s["location"])
    if s.get("description"):cli_lib_cmd_export(out, 22, 1, s["description"])
    if s.get("contact"):    cli_lib_cmd_export(out, 23, 1, s["contact"])
    if s.get("mac_aging", 300) != 300:
        cli_lib_cmd_export(out, 24, 1, "%d", s["mac_aging"])
    if s.get("banner"):
        cli_lib_cmd_export(out, 25, 1, cli_banner_process(s["banner"]))
    if s.get("fail_banner"):
        cli_lib_cmd_export(out, 26, 1, cli_banner_process(s["fail_banner"]))


def cparser_showUserConfiguration(out, shm):
    """
    Lines 14295-14323.
    username <n> password <encrypted> privilege <N>
    Role → privilege:
      ROLE_OPERATOR(17) → priv 2
      ROLE_USER(16)     → priv 3
      ROLE_ADMIN(0)     → priv 1
    is_admin=1 → also emit "username <n> privilege 4"
    """
    for acc in shm.get("accounts", []):
        uname = acc["username"]
        enc   = data_encryp(acc.get("password", ""))
        role  = acc.get("role", ROLE_ADMIN)
        priv  = 2 if role == ROLE_OPERATOR else (3 if role == ROLE_USER else 1)
        cli_lib_cmd_export(out, 208, 1, "%s password %s privilege %d", uname, enc, priv)
        if acc.get("is_admin"):
            cli_lib_cmd_export(out, 208, 1, "%s privilege %d", uname, 4)


def cparser_showLoginModeConfig(out, shm):
    cli_lib_cmd_export(out, 19, 1, shm["system"].get("login_mode", "local"))


def cparser_showNetworkConfig(out, shm):
    n = shm["network"]
    cli_lib_cmd_export(out, 88, 1, "")
    if n.get("lan_ip") and n["lan_ip"] != "0.0.0.0":
        cli_lib_cmd_export(out, 89, 2, "%s %s", n["lan_ip"],
                           n.get("lan_mask","255.255.255.0"))
    if n.get("wan_ip") and n["wan_ip"] != "0.0.0.0":
        cli_lib_cmd_export(out, 393, 1, "")
        cli_lib_cmd_export(out, 396, 2, "%s %s", n["wan_ip"],
                           n.get("wan_mask","255.255.255.0"))
    if n.get("wan_gw") and n["wan_gw"] != "0.0.0.0":
        cli_lib_cmd_export(out, 93, 1, n["wan_gw"])
    for k in ("dns1","dns2"):
        if n.get(k):
            cli_lib_cmd_export(out, 91, 1, n[k])


def cparser_showInterfaceConfig(out, shm):
    for port, cfg in shm.get("interfaces", {}).items():
        cli_lib_cmd_export(out, 48, 1, port)
        if cfg.get("description"):
            cli_lib_cmd_export(out, 51, 2, cfg["description"])
        if cfg.get("shutdown"):
            cli_lib_cmd_export(out, 49, 2, "")
        else:
            cli_lib_cmd_export(out, 50, 2, "")
        if cfg.get("speed_duplex"):
            cli_lib_cmd_export(out, 53, 2, cfg["speed_duplex"])


def cparser_showStaticRouteConfig(out, shm):
    """Lines 12266-12305. cmd ID 257."""
    for r in shm.get("static_routes", []):
        cli_lib_cmd_export(out, 257, 1, "%s %s %s %s %d",
                           r.get("name","route1"), r.get("dst","0.0.0.0"),
                           r.get("mask","0.0.0.0"), r.get("gw","0.0.0.0"),
                           r.get("metric",1))
        if not r.get("enabled", True):
            cli_lib_cmd_export(out, 257, 1, "%s disable", r.get("name","route1"))


def cparser_showSyslogConfig(out, shm):
    """Lines 11848-11868. cmd IDs 75/76."""
    for i, srv in enumerate(shm.get("logging",{}).get("servers",[]), 1):
        cli_lib_cmd_export(out, 75, 1, "%s %d %d",
                           srv.get("host",""), srv.get("port",514), i)
        if not srv.get("enabled", True):
            cli_lib_cmd_export(out, 76, 1, "enable %d", i)
    buf = shm.get("logging",{}).get("buffered", 0)
    if buf:
        out.write(f"logging buffered {buf}\n")


def cparser_showTimeConfig(out, shm):
    """clock timezone and NTP."""
    tz = shm.get("timezone_index", 23)
    if 0 <= tz < len(TIMEZONE_NAMES):
        shift = TIMEZONE_SHIFTS[tz]
        h, m  = abs(shift)//3600, (abs(shift)%3600)//60
        sign  = "+" if shift >= 0 else "-"
        cli_lib_cmd_export(out, 77, 1, "%s%02d%02d" % (sign, h, m))
    for srv in shm.get("ntp",{}).get("servers",[]):
        cli_lib_cmd_export(out, 82, 1, srv)
    refresh = shm.get("ntp",{}).get("refresh", 3600)
    if refresh != 3600:
        cli_lib_cmd_export(out, 84, 1, "%d", refresh)


def cparser_showLldpConfig(out, shm):
    s = shm["system"]
    cli_lib_cmd_export(out, 98 if s.get("lldp_enable",1) else 99, 1, "")
    t = s.get("lldp_timer", 30)
    if t != 30:
        cli_lib_cmd_export(out, 100, 1, "%d", t)


def cparser_showAccessConfig(out, shm):
    """HTTP / Telnet / SSH enable+port. Lines 14349-14380."""
    w  = shm.get("web", {})
    t  = shm.get("telnet", {})
    ss = shm.get("ssh", {})
    cli_lib_cmd_export(out, 29 if w.get("enabled",1) else 30, 1, "")
    if w.get("port",80) != 80:
        cli_lib_cmd_export(out, 35, 1, "%d", w["port"])
    if w.get("https_enabled",1) and w.get("https_port",443) != 443:
        cli_lib_cmd_export(out, 36, 1, "%d", w["https_port"])
    cli_lib_cmd_export(out, 32 if t.get("enabled",1) else 33, 1, "")
    if t.get("port",23) != 23:
        cli_lib_cmd_export(out, 38, 1, "%d", t["port"])
    if not ss.get("enabled",1):
        cli_lib_cmd_export(out, 40, 1, "")
    elif ss.get("port",22) != 22:
        cli_lib_cmd_export(out, 39, 1, "%d", ss["port"])


def cparser_showPwPolicyConfig(out, shm):
    """Lines 13420-13439. cmd IDs 513/514."""
    pp = shm.get("password_policy", {})
    cli_lib_cmd_export(out, 513, 1, "minimum-length %d", pp.get("min_len",4))
    for flag, label in [("enabled","complexity-check"),
                        ("require_digit","complexity-check digit"),
                        ("require_upper_lower","complexity-check alphabet"),
                        ("require_special","complexity-check special-characters")]:
        cli_lib_cmd_export(out, 513 if pp.get(flag) else 514, 1, label)


def cparser_showLoginLockoutConfig(out, shm):
    """Lines 13443-13451. cmd IDs 517/518."""
    ll = shm.get("login_lockout", {})
    cli_lib_cmd_export(out, 517 if ll.get("enabled") else 518, 1, "")
    cli_lib_cmd_export(out, 517, 1, "retry-threshold %d", ll.get("max_fail",5))
    cli_lib_cmd_export(out, 517, 1, "lockout-time %d",    ll.get("lockout_time",300))


def cparser_showFastBootupConfig(out, shm):
    """Lines 13477-13483."""
    cli_lib_cmd_export(out, 519 if shm["system"].get("fast_bootup") else 520, 1, "")


def cparser_showVlanConfig(out, shm):
    v = shm.get("vlan", {})
    mode_map = {"pvlan":3, "unaware":4}
    cli_lib_cmd_export(out, mode_map.get(v.get("mode","1qvlan"), 2), 1, "")
    for vid in v.get("vlans", []):
        cli_lib_cmd_export(out, 0, 1, "%d", vid)


def cparser_showRedundancyConfig(out, shm):
    mode = shm.get("redundancy",{}).get("mode","none")
    if mode != "none":
        cli_lib_cmd_export(out, 183, 1, mode)


def cparser_showSpanningTreeConfig(out, shm):
    st = shm.get("spanning_tree", {})
    if st.get("enabled"):
        cli_lib_cmd_export(out, 207, 1, "")
        if st.get("priority",32768) != 32768:
            cli_lib_cmd_export(out, 198, 1, "%d", st["priority"])


# -----------------------------------------------------------------------------
# export_file_init  (libsysexport_so_1.c line 14510)
# Make_CliConfigurationFile ordering (line 14526)
# -----------------------------------------------------------------------------
def export_file_init(out, shm):
    out.write(f"! ---------- {shm['system']['hostname']} ----------\n")


def export_running_config(out, shm):
    """Full running-config export, matching Make_CliConfigurationFile loop order."""
    export_file_init(out, shm)
    cparser_showSystemConfig(out, shm)
    cparser_showLoginModeConfig(out, shm)
    cparser_showUserConfiguration(out, shm)
    cparser_showAccessConfig(out, shm)
    cparser_showLldpConfig(out, shm)
    cparser_showTimeConfig(out, shm)
    cparser_showNetworkConfig(out, shm)
    cparser_showVlanConfig(out, shm)
    cparser_showInterfaceConfig(out, shm)
    cparser_showStaticRouteConfig(out, shm)
    cparser_showSyslogConfig(out, shm)
    cparser_showPwPolicyConfig(out, shm)
    cparser_showLoginLockoutConfig(out, shm)
    cparser_showFastBootupConfig(out, shm)
    cparser_showRedundancyConfig(out, shm)
    cparser_showSpanningTreeConfig(out, shm)
    out.write("end\n")


# -----------------------------------------------------------------------------
# print_banner  (SSH shell entry point banner)
# -----------------------------------------------------------------------------
def print_banner(shm: dict, username: str = "admin"):
    admin = next((a for a in shm["accounts"] if a["username"] == "admin"), None)
    if admin and admin.get("password") == "moxa":
        print("\nPlease change default password in consideration of higher security level.\n")
    print(f"{'':20}{BANNER_MODEL:<20}  {BANNER_FW:<6} {BANNER_BUILD:<15}{'':16}\r")
    print("-" * 80 + "\r")


# -----------------------------------------------------------------------------
# Top-level help table  (from the "?" screenshot)
# -----------------------------------------------------------------------------
HELP_TABLE = [
    ("quit",      "Exit Command Line Interface"),
    ("exit",      "Exit Command Line Interface"),
    ("reload",    "Halt and Perform a Cold Restart"),
    ("terminal",  "Configure Terminal Page Length"),
    ("copy",      "Import or Export File"),
    ("save",      "Save Running Configuration to Flash"),
    ("ping",      "Send Echo Messages"),
    ("clear",     "Clear Information"),
    ("show",      "Show System Information"),
    ("configure", "Enter Configuration Mode"),
]

SHOW_TOPICS = [
    ("running-config",  "Current operating configuration"),
    ("version",         "System hardware and software status"),
    ("interfaces",      "Interface status and configuration"),
    ("ip",              "IP information (route / address)"),
    ("users",           "User accounts"),
    ("logging",         "Logging configuration"),
    ("clock",           "System clock and timezone"),
    ("ntp",             "NTP associations"),
    ("vlan",            "VLAN information"),
    ("spanning-tree",   "Spanning tree topology"),
    ("redundancy",      "Redundancy configuration"),
    ("lldp",            "LLDP configuration"),
    ("snmp",            "SNMP configuration"),
    ("login-lockout",   "Login lockout configuration"),
    ("password-policy", "Password policy configuration"),
]


def _show(args, shm):
    import io
    topic = args[0] if args else ""
    if not topic or topic == "?":
        for c, d in SHOW_TOPICS:
            print(f"  {c:<30}- {d}")
        return
    buf = io.StringIO()
    if topic == "running-config":
        export_running_config(buf, shm)
        print(buf.getvalue(), end="")
    elif topic == "version":
        s = shm["system"]
        h, rem = divmod(s.get("uptime_sec",0), 3600)
        m, se  = divmod(rem, 60)
        print(f"  Moxa {BANNER_MODEL}")
        print(f"  Firmware Version : {s.get('fw_version', BANNER_FW)}")
        print(f"  Hardware Version : {s.get('hw_version','1.0')}")
        print(f"  Serial Number    : {s.get('serial','')}")
        print(f"  MAC Address      : {s.get('mac','')}")
        print(f"  Hostname         : {s['hostname']}")
        print(f"  System Uptime    : {h:02d}h:{m:02d}m:{se:02d}s")
    elif topic in ("interfaces","interface"):
        sub  = args[1] if len(args) > 1 else ""
        ifaces = shm.get("interfaces", {})
        if not sub or sub == "?":
            print(f"  {'Interface':<14}{'State':<8}{'Description'}")
            print(f"  {'-'*14}{'-'*8}{'-'*24}")
            for p, cfg in ifaces.items():
                state = "up" if not cfg.get("shutdown") else "down"
                print(f"  {p:<14}{state:<8}{cfg.get('description','')}")
        else:
            port = args[2] if len(args) > 2 else sub
            cfg  = ifaces.get(port, {})
            state = "up" if not cfg.get("shutdown") else "down"
            print(f"  {port}: {state}")
            print(f"    Description  : {cfg.get('description','')}")
            print(f"    Speed/Duplex : {cfg.get('speed_duplex','auto')}")
    elif topic == "ip":
        sub = args[1] if len(args) > 1 else ""
        n   = shm["network"]
        if sub in ("route","routes",""):
            print(f"  {'Destination':<22}{'Gateway':<18}{'Metric'}")
            print(f"  {'-'*22}{'-'*18}{'-'*8}")
            for r in shm.get("static_routes",[]):
                print(f"  {r['dst']+'/'+r['mask']:<22}{r['gw']:<18}{r.get('metric',1)}")
        elif sub in ("address","addr"):
            print(f"  LAN : {n['lan_ip']} / {n['lan_mask']}")
            if n.get("wan_ip") and n["wan_ip"] != "0.0.0.0":
                print(f"  WAN : {n['wan_ip']} / {n['wan_mask']}")
    elif topic == "users":
        print(f"  {'Username':<20}{'Role':<14}{'Privilege'}")
        for a in shm.get("accounts",[]):
            rname = {0:"admin",16:"user",17:"operator"}.get(a.get("role",0),"user")
            priv  = {0:1,17:2,16:3}.get(a.get("role",0),1)
            print(f"  {a['username']:<20}{rname:<14}{priv}")
    elif topic == "logging":
        lg = shm.get("logging",{})
        print(f"  Buffered  : {lg.get('buffered',0)} bytes")
        for i, srv in enumerate(lg.get("servers",[]),1):
            print(f"  Server {i}  : {srv.get('host','')} port {srv.get('port',514)}")
    elif topic == "clock":
        now = datetime.now(timezone.utc).replace(tzinfo=None)
        tz  = shm.get("timezone_index",23)
        tz_name  = TIMEZONE_NAMES[tz] if 0<=tz<len(TIMEZONE_NAMES) else "GMT"
        shift    = TIMEZONE_SHIFTS[tz] if 0<=tz<len(TIMEZONE_SHIFTS) else 0
        h, m     = abs(shift)//3600, (abs(shift)%3600)//60
        print(f"  {now.strftime('%Y-%m-%d %H:%M:%S')} UTC{'+' if shift>=0 else '-'}{h:02d}:{m:02d} ({tz_name})")
    elif topic == "ntp":
        ntp = shm.get("ntp",{})
        for srv in ntp.get("servers",[]):
            print(f"  Server: {srv}")
        print(f"  Refresh: {ntp.get('refresh',3600)}s")
    elif topic == "vlan":
        v = shm.get("vlan",{})
        print(f"  Mode: {v.get('mode','1qvlan')}")
        for vid in v.get("vlans",[]):
            print(f"  VLAN {vid}")
    elif topic == "spanning-tree":
        st = shm.get("spanning_tree",{})
        print(f"  State    : {'enabled' if st.get('enabled') else 'disabled'}")
        print(f"  Priority : {st.get('priority',32768)}")
    elif topic == "redundancy":
        print(f"  Mode : {shm.get('redundancy',{}).get('mode','none')}")
    elif topic == "lldp":
        s = shm["system"]
        print(f"  LLDP  : {'enabled' if s.get('lldp_enable') else 'disabled'}")
        print(f"  Timer : {s.get('lldp_timer',30)}s")
    elif topic == "snmp":
        sn = shm.get("snmp",{})
        acc = ["rw","ro","no-access"]
        print(f"  Version     : {sn.get('version','v1-v2c')}")
        print(f"  Community 1 : {sn.get('community1','public')} ({acc[sn.get('access1',1)]})")
        print(f"  Community 2 : {sn.get('community2','private')} ({acc[sn.get('access2',0)]})")
    elif topic == "login-lockout":
        ll = shm.get("login_lockout",{})
        print(f"  Enabled   : {'yes' if ll.get('enabled') else 'no'}")
        print(f"  Threshold : {ll.get('max_fail',5)} retries")
        print(f"  Lockout   : {ll.get('lockout_time',300)}s")
    elif topic == "password-policy":
        pp = shm.get("password_policy",{})
        print(f"  Enabled          : {'yes' if pp.get('enabled') else 'no'}")
        print(f"  Min length       : {pp.get('min_len',4)}")
        print(f"  Require digit    : {'yes' if pp.get('require_digit') else 'no'}")
        print(f"  Require case     : {'yes' if pp.get('require_upper_lower') else 'no'}")
        print(f"  Require special  : {'yes' if pp.get('require_special') else 'no'}")
    else:
        print(f"  % Unknown topic: {topic!r}")


def _configure(shm: dict, hostname: str):
    """Configuration mode REPL (simplified cparser configure terminal)."""
    model = hostname
    print("  Enter config commands. End with 'end' or 'exit'.")
    while True:
        try:
            raw = input(f"{model}(config)# ").strip()
        except (EOFError, KeyboardInterrupt):
            print(); break
        if not raw:
            continue
        tok = raw.split()
        cmd, rest = tok[0].lower(), tok[1:]
        if cmd in ("end","exit","quit"):
            break
        elif cmd == "?":
            print("  hostname / interface / ip / username / logging / no")
        elif cmd == "hostname" and rest:
            shm["system"]["hostname"] = rest[0]
            model = rest[0]
            print(f"  Hostname → {rest[0]!r}")
        elif cmd == "username" and len(rest) >= 4:
            u = rest[0]
            try:
                pw  = rest[rest.index("password")+1]
                prv = int(rest[rest.index("privilege")+1])
            except (ValueError, IndexError):
                print("  % Syntax: username <name> password <pw> privilege <1-4>")
                continue
            role = {1:ROLE_ADMIN,2:ROLE_OPERATOR,3:ROLE_USER,4:ROLE_ADMIN}.get(prv, ROLE_USER)
            accs = shm.setdefault("accounts",[])
            ex   = next((a for a in accs if a["username"]==u), None)
            if ex:
                ex["password"],ex["role"] = pw, role
            else:
                accs.append({"username":u,"password":pw,"role":role,
                              "is_admin":1 if role==ROLE_ADMIN else 0})
            print(f"  User {u!r} updated.")
        elif cmd == "ip" and rest:
            if rest[0]=="route" and len(rest)>=3:
                dst_pf, gw = rest[1], rest[2]
                if "/" in dst_pf:
                    dst, plen = dst_pf.split("/",1)
                    m = 0xFFFFFFFF << (32-int(plen)) & 0xFFFFFFFF
                    mask = socket.inet_ntoa(struct.pack(">I",m))
                else:
                    dst, mask, gw = rest[1], rest[2], rest[3] if len(rest)>3 else rest[2]
                shm.setdefault("static_routes",[]).append(
                    {"name":f"route{len(shm['static_routes'])+1}",
                     "dst":dst,"mask":mask,"gw":gw,"metric":1,"enabled":True})
                print(f"  Route {dst}/{mask} via {gw} added.")
        elif cmd == "interface" and rest:
            _iface_mode(shm, rest[-1])
        elif cmd == "logging" and rest and rest[0]=="buffered" and len(rest)>1:
            shm.setdefault("logging",{})["buffered"] = int(rest[1])
        elif cmd == "no" and rest:
            if rest[0]=="ip" and len(rest)>2 and rest[1]=="route":
                dst = rest[2]
                shm["static_routes"] = [r for r in shm.get("static_routes",[])
                                          if r.get("dst") != dst]
        else:
            print(f"  % Unknown: {raw!r}")


def _iface_mode(shm, port):
    cfg = shm.setdefault("interfaces",{}).setdefault(port,{})
    while True:
        try:
            raw = input(f"(config-if:{port})# ").strip()
        except (EOFError, KeyboardInterrupt):
            print(); break
        if not raw: continue
        tok = raw.split(); cmd, rest = tok[0].lower(), tok[1:]
        if cmd in ("end","exit"): break
        elif cmd == "description" and rest: cfg["description"] = " ".join(rest)
        elif cmd == "shutdown":             cfg["shutdown"] = True
        elif cmd == "no" and rest and rest[0]=="shutdown": cfg["shutdown"] = False
        elif cmd == "speed-duplex" and rest: cfg["speed_duplex"] = rest[0]
        else: print(f"  % Unknown: {raw!r}")


# -----------------------------------------------------------------------------
# Main REPL
# -----------------------------------------------------------------------------
def repl(shm: dict, username: str = "admin"):
    hostname = shm["system"]["hostname"]
    prompt   = f"{hostname}>> "
    page_len = 24
    print_banner(shm, username)

    while True:
        try:
            raw = input(prompt).strip()
        except (EOFError, KeyboardInterrupt):
            print(); break
        if not raw:
            continue
        tok = raw.split()
        cmd, args = tok[0].lower(), tok[1:]

        if cmd in ("quit","exit"):
            print("  Exiting CLI.")
            break
        elif cmd == "?":
            print()
            for c, d in HELP_TABLE:
                print(f"  {c:<16}- {d}")
            print(prompt, end="", flush=True)
        elif cmd == "reload":
            print("  Proceed with reload? [confirm] ", end="", flush=True)
            if input().strip().lower() in ("","y","yes"):
                print("  Reloading..."); sys.exit(0)
        elif cmd == "terminal":
            if args and args[0]=="length" and len(args)>1:
                page_len = int(args[1])
                print(f"  Terminal length set to {page_len}")
            else:
                print("  Usage: terminal length <0-512>")
        elif cmd == "copy":
            if not args or args[0]=="?":
                print("  running-config startup-config  - save to flash")
                print("  startup-config running-config  - restore from flash")
                print("  running-config tftp <host>     - export via TFTP")
            elif " ".join(args[:2]) == "running-config startup-config":
                shm_save(shm); print("  Saved.")
            else:
                print(f"  (mock) copy {' '.join(args)}")
        elif cmd == "save":
            shm_save(shm); print("  Running configuration saved to flash.")
        elif cmd == "ping":
            host = args[0] if args else ""
            if not host:
                print("  Usage: ping <host> [repeat <N>]")
            else:
                n = 5
                if "repeat" in args:
                    try: n = int(args[args.index("repeat")+1])
                    except Exception: pass
                print(f"\n  Sending {n} ICMP echo(s) to {host}:")
                for _ in range(n):
                    try:
                        t0 = time.time()
                        s  = socket.create_connection((host,80),timeout=1)
                        s.close()
                        print(f"  Reply from {host}: time={int((time.time()-t0)*1000)}ms")
                    except Exception:
                        print("  Request timed out.")
                print()
        elif cmd == "clear":
            if not args or args[0]=="?":
                print("  logging   - clear log buffer")
                print("  counters  - clear interface counters")
                print("  arp       - clear ARP table")
            elif args[0]=="logging":
                shm.setdefault("logging",{})["buffer"] = []
                print("  Log buffer cleared.")
            else:
                print(f"  (mock) clear {' '.join(args)}")
        elif cmd == "show":
            _show(args, shm)
        elif cmd == "configure":
            _configure(shm, hostname)
            hostname = shm["system"]["hostname"]
            prompt   = f"{hostname}>> "
            shm_save(shm)
        else:
            print(f"  % Unknown command: {cmd!r}  (type '?' for help)")


# -----------------------------------------------------------------------------
# Entry point
# -----------------------------------------------------------------------------
def main():
    import argparse, io
    ap = argparse.ArgumentParser(description=f"Moxa {BANNER_MODEL} CLI mock")
    ap.add_argument("--export",  action="store_true")
    ap.add_argument("--show",    nargs="+")
    ap.add_argument("--user",    default="admin")
    ap.add_argument("--state",   default=None)
    ap.add_argument("--daemon",  action="store_true",
                    help="Start background SHM daemon (requires moxa_ipc.py)")
    ap.add_argument("--decrypt", metavar="ENC",
                    help="Decrypt a DataEncryp hash back to password")
    ap.add_argument("--encrypt", metavar="PW",
                    help="Show DataEncryp hash of a password")
    args = ap.parse_args()

    if args.encrypt:
        enc = data_encryp(args.encrypt)
        print(f"password  : {args.encrypt!r}")
        print(f"encrypted : {enc}")
        print(f"length    : {len(enc)} chars (buf=32, {32*2}+32={32*2+32})")
        return

    if args.decrypt:
        try:
            pw = data_deencryp(args.decrypt)
            print(f"decrypted : {pw!r}")
        except ValueError as e:
            print(f"Error: {e}", file=sys.stderr)
            sys.exit(1)
        return

    shm = shm_load()
    if args.state:
        try:
            shm = json.loads(Path(args.state).read_text())
        except Exception as e:
            print(f"Warning: {e}", file=sys.stderr)

    if args.daemon:
        try:
            from moxa_ipc import MoxaDaemon
            d = MoxaDaemon("cliagent")
            d.start()
            print("SHM daemon running. Ctrl-C to stop.")
            try:
                while True:
                    time.sleep(1)
            except KeyboardInterrupt:
                d.stop()
        except ImportError:
            print("moxa_ipc.py not found", file=sys.stderr)
        return

    if args.export:
        export_running_config(sys.stdout, shm)
        return

    if args.show:
        _show(args.show, shm)
        return

    repl(shm, username=args.user)


if __name__ == "__main__":
    main()
