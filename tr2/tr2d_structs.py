"""
tr2d_structs.py  —  All data structures, constants, and enumerations
reverse-engineered from the tr2d binary (ARMv7, Moxa MOXAARM11 platform).

Sources
-------
  tr2d binary via IDA MCP  (addresses reference original binary)
  tr2ctrl.c  Hex-Rays decompilation
  tr2d.c     partial Hex-Rays decompilation
"""

import struct
import ctypes
from dataclasses import dataclass, field
from typing import List, Optional
from enum import IntEnum, IntFlag
from compat import (
    default_socket_path, default_lhc_socket_path,
    default_config_path, default_status_path,
)

# ─────────────────────────────────────────────────────────────────────────────
# Protocol / transport constants
# ─────────────────────────────────────────────────────────────────────────────

TR2_SOCKET_PATH   = default_socket_path()
LHC_SOCKET_PATH   = default_lhc_socket_path()
TR2_ETH_IFACE     = "eth0"
TR2_ETH_PROTO     = 0x0003                  # AF_PACKET SOCK_RAW ETH_P_ALL
TR2_CONFIG_FILE   = default_config_path()
TR2_STATUS_FILE   = default_status_path()

# "ethD" magic — first 4 bytes of a valid TR2 BPDU payload (0x1c978 region)
TR2_PKT_MAGIC     = b"ethD"                 # aEthd @ 0x27258
TR2_BPDU_DA       = bytes([0x01, 0x0c, 0xcd, 0x01, 0x00, 0x01])
MCAST_BPDU_DA     = bytes([0x01, 0x80, 0xc2, 0x00, 0x00, 0x00])

# default from dword_27274 = 4 (LHC port count)
LHC_PORT_COUNT    = 4
# wait_timeout = 4 ms  (poll timeout in tr2_ringMain)
DEFAULT_WAIT_MS   = 4
MAX_RINGS         = 2                       # dword_27254[3] = {1,1,1} → 2 ring slots + coupling

# Ring-member list / polling
POLLING_TYPE_RING     = 1
POLLING_TYPE_COUPLING = 2
POLLING_TYPE_LHC      = 32

# Debug levels (SetDebugLevel / log_printf threshold)
LOG_ERROR   = 1
LOG_WARN    = 2
LOG_NOTICE  = 3
LOG_INFO    = 4
LOG_DEBUG5  = 5
LOG_DEBUG6  = 6
LOG_DEBUG7  = 7


# ─────────────────────────────────────────────────────────────────────────────
# tr2ctrl IPC command codes  (cmd word at offset 0 in 524-byte message)
# ─────────────────────────────────────────────────────────────────────────────

class Cmd(IntEnum):
    ACTIVATE    = ord('a')   # 97  — apply new config; payload = serialised TR2Config
    SET_TIMEOUT = ord('i')   # 105 — set wait_timeout ms; payload[0..3] = u32 ms
    STATUS      = ord('s')   # 115 — read status; subtype selects what
    STATUS_W    = ord('w')   # 119 — same as 's', JSON output mode in tr2ctrl
    TEST_TX     = ord('t')   # 116 — trigger transmit; payload[0] = pktType

class StatusSubtype(IntEnum):
    RING     = 0    # returns N × RingInfo (376 B each)
    COUPLING = 1    # returns CouplingInfo (192 B)
    LHC      = 2    # returns N × LHCPortInfo (64 B each)
    CONFIG   = 3    # handled locally (reads /etc/tr2_config.txt), no socket

MSG_SIZE = 0x20C    # fixed request size: write(fd, v4, 0x20Cu)
READ_BUF  = 0x400


# ─────────────────────────────────────────────────────────────────────────────
# Packet types  (pktType field, byte at pkt[6] after "ethD" magic)
# ─────────────────────────────────────────────────────────────────────────────

class PktType(IntEnum):
    POLLING          = 2    # sub_CFD4 path (s1[6]==2 branch in tr2_ringMain)
    BPDU             = 3    # sub_D898 path (s1[6]==3 branch)
    RING_PORT_DOWN   = 4    # tr2_sendRingPortDownNegoPkt
    COUPLER_NEGO     = 5    # tr2_sendCouplerNegoPkt
    COUPLER_TC       = 6    # tr2_sendCouplerTopologyChangedPkt
    FWD_REQUEST      = 7    # tr2_sendForwardingRequestNegoPkt
    LHC              = 8    # LHC_packet check (addr.sa_data[8]==4 → discard raw)


# ─────────────────────────────────────────────────────────────────────────────
# Port states  (Ssc_setPortState / get_portstatus_string)
# ─────────────────────────────────────────────────────────────────────────────

class PortState(IntEnum):
    UNKNOWN    = 0
    DISABLE    = 1
    BLOCKED    = 2
    LEARNING   = 4
    FORWARDING = 5

PORT_STATE_STR = {
    PortState.DISABLE:    "Disable",
    PortState.BLOCKED:    "Blocked",
    PortState.LEARNING:   "Learning",
    PortState.FORWARDING: "Forwarding",
}

# Coupling modes  (strNone[] @ 0x137FC)
class CouplingMode(IntEnum):
    NONE             = 0
    DUAL_HOMING      = 1
    COUPLING_BACKUP  = 2
    COUPLING_PRIMARY = 3

COUPLING_MODE_STR = {
    CouplingMode.NONE:             "None",
    CouplingMode.DUAL_HOMING:      "Dual Homing",
    CouplingMode.COUPLING_BACKUP:  "Coupling Backup",
    CouplingMode.COUPLING_PRIMARY: "Coupling Primary",
}


# ─────────────────────────────────────────────────────────────────────────────
# LHC port flags  (byte_2AA98[64*i + 7] bitmask)
# ─────────────────────────────────────────────────────────────────────────────

class LhcFlags(IntFlag):
    ENABLED   = 0x01
    SELF_LOOP = 0x02
    PARTNER   = 0x04


# ─────────────────────────────────────────────────────────────────────────────
# Config structure  (/etc/tr2_config.txt  ↔  shm_tr2SetConfig)
#
# Binary layout (dword_2AA58 / dword_2AA30, 0x20 bytes):
#   [0]     u32  enabled
#   [1]     u32  ring[0].enabled | (priority<<8)   (LOBYTE/BYTE1 of dword)
#   [2]     ...  (padding / ring[0] spare)
#   [3]     u32  ring[0].port0 | (port1<<8)
#   [4]     u32  ring[1].enabled | (priority<<8)
#   [5]     ...
#   [6]     u32  ring[1].port0 | (port1<<8)
#   [7]     u32  coupling_mode (LOBYTE)
#   [8]     u8   coupling_primary port
#   [9]     u8   coupling_backup  port
#  (sub_13004 default: ring0 ports 9,10  ring1 ports 7,8  coupling mode 0 pri 7 bak 8)
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class RingConfig:
    enabled:  int = 0
    priority: int = 0xFF     # 0=master-priority  0xFF=slave
    port0:    int = 0        # physical port id (1-based as stored, 0-based internally)
    port1:    int = 0

@dataclass
class TR2Config:
    enabled:  int = 0
    rings:    List[RingConfig] = field(default_factory=lambda: [RingConfig(), RingConfig()])
    coupling: 'CouplingConfig' = field(default_factory=lambda: CouplingConfig())

    # ── serialise to 0x20-byte shared-memory block (dword_2AA58 layout) ──
    def pack_shm(self) -> bytes:
        buf = bytearray(0x20)
        struct.pack_into("<I", buf, 0, self.enabled)
        for i, r in enumerate(self.rings):
            base = 4 * (3 * i + 1)
            struct.pack_into("<I", buf, base,
                             (r.enabled & 0xFF) | ((r.priority & 0xFF) << 8))
            struct.pack_into("<I", buf, base + 8,
                             (r.port0 & 0xFF) | ((r.port1 & 0xFF) << 8))
        struct.pack_into("<I", buf, 0x1C,
                         (self.coupling.mode & 0xFF))
        buf[0x1D] = self.coupling.primary_port & 0xFF
        buf[0x1E] = self.coupling.backup_port  & 0xFF
        return bytes(buf)

    @classmethod
    def unpack_shm(cls, data: bytes) -> 'TR2Config':
        cfg = cls()
        cfg.enabled = struct.unpack_from("<I", data, 0)[0]
        for i in range(2):
            base = 4 * (3 * i + 1)
            w1 = struct.unpack_from("<I", data, base)[0]
            w2 = struct.unpack_from("<I", data, base + 8)[0]
            cfg.rings[i] = RingConfig(
                enabled  = w1 & 0xFF,
                priority = (w1 >> 8) & 0xFF,
                port0    = w2 & 0xFF,
                port1    = (w2 >> 8) & 0xFF,
            )
        w3 = struct.unpack_from("<I", data, 0x1C)[0]
        cfg.coupling.mode         = w3 & 0xFF
        cfg.coupling.primary_port = data[0x1D]
        cfg.coupling.backup_port  = data[0x1E]
        return cfg

    @classmethod
    def from_file(cls, path: str = TR2_CONFIG_FILE) -> 'TR2Config':
        """Parse /etc/tr2_config.txt  (mirrors tr2_loadConfig @ 0x129E8)"""
        cfg = cls()
        try:
            with open(path) as f:
                for line in f:
                    line = line.strip()
                    if not line or line.startswith('#') or '=' not in line:
                        continue
                    k, _, v = line.partition('=')
                    k, v = k.strip(), v.strip()
                    if k == "Enabled":
                        cfg.enabled = int(v)
                    elif k in ("Ring0", "Ring1"):
                        idx = int(k[-1])
                        p = v.split()
                        cfg.rings[idx] = RingConfig(
                            enabled  = int(p[0]),
                            priority = 0 if int(p[1]) else 0xFF,
                            port0    = int(p[2]),
                            port1    = int(p[3]),
                        )
                    elif k == "Coupling":
                        p = v.split()
                        cfg.coupling = CouplingConfig(
                            mode         = int(p[0]),
                            primary_port = int(p[1]),
                            backup_port  = int(p[2]),
                        )
        except FileNotFoundError:
            pass
        return cfg

    def to_file(self, path: str = TR2_CONFIG_FILE):
        with open(path, 'w') as f:
            f.write(f"Enabled = {self.enabled}\n")
            for i, r in enumerate(self.rings):
                master_flag = 1 if r.priority == 0 else 0
                f.write(f"Ring{i} = {r.enabled} {master_flag} {r.port0} {r.port1}\n")
            c = self.coupling
            f.write(f"Coupling = {c.mode} {c.primary_port} {c.backup_port}\n")


@dataclass
class CouplingConfig:
    mode:         int = CouplingMode.NONE
    primary_port: int = 0
    backup_port:  int = 0


# ─────────────────────────────────────────────────────────────────────────────
# PortInfo  (embedded ×2 in RingInfo at offsets 336 and 344)
#
# Binary layout (8 bytes, from tr2_showBuffer offsets):
#   [0]  port_id     u8
#   [1]  state       u8   (PortState)
#   [2]  is_down     u8
#   [3]  _pad
#   [4]  lhc_flags   u8
#   [5..7] _pad
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class PortInfo:
    WIRE_SIZE = 8

    port_id:   int = 0
    state:     int = PortState.FORWARDING
    is_down:   int = 0
    lhc_flags: int = 0

    def pack(self) -> bytes:
        b = bytearray(self.WIRE_SIZE)
        b[0] = self.port_id   & 0xFF
        b[1] = self.state     & 0xFF
        b[2] = self.is_down   & 0xFF
        b[4] = self.lhc_flags & 0xFF
        return bytes(b)

    @classmethod
    def unpack(cls, data: bytes) -> 'PortInfo':
        return cls(
            port_id   = data[0],
            state     = data[1],
            is_down   = data[2],
            lhc_flags = data[4] if len(data) > 4 else 0,
        )


# ─────────────────────────────────────────────────────────────────────────────
# RingInfo  (376-byte on-wire structure returned by STATUS/RING)
#
# Offsets from tr2_showBuffer @ 0x995C and tr2_getRingInfo @ 0xA33C:
#   [0..3]    ring_id          u32
#   [4..9]    bpdu_dest        6×u8 MAC
#   [10..17]  bridge_id        8×u8
#   [18..25]  master_id        8×u8 (MAC, padded)
#   [28]      status           u8   1=Healthy 0=Break
#   [29]      unknown_29       u8
#   [30]      active           u8   non-zero = ring enabled
#   [31]      is_master        u8
#   [32]      main_port        u8
#   [33]      backup_port      u8
#   [40]      topo_change_cnt  u8
#   [336..343] port[0]         8 bytes  PortInfo
#   [344..351] port[1]         8 bytes  PortInfo
#   [368..371] master_age      u32  (offset 92*4 = 368)
#   total = 376
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class RingInfo:
    WIRE_SIZE = 376

    ring_id:           int   = 1
    bpdu_dest:         bytes = field(default_factory=lambda: TR2_BPDU_DA)
    bridge_id:         bytes = field(default_factory=lambda: bytes(8))
    master_id:         bytes = field(default_factory=lambda: bytes(8))
    status:            int   = 1          # 1=Healthy
    active:            int   = 1
    is_master:         int   = 0
    main_port:         int   = 0
    backup_port:       int   = 0
    topo_change_count: int   = 0
    master_age:        int   = 0
    ports: List[PortInfo] = field(default_factory=lambda: [PortInfo(), PortInfo()])

    def pack(self) -> bytes:
        b = bytearray(self.WIRE_SIZE)
        struct.pack_into("<I", b, 0, self.ring_id)
        b[4:10]  = (self.bpdu_dest  + bytes(6))[:6]
        b[10:18] = (self.bridge_id  + bytes(8))[:8]
        b[18:26] = (self.master_id  + bytes(8))[:8]
        b[28]    = self.status           & 0xFF
        b[30]    = self.active           & 0xFF
        b[31]    = self.is_master        & 0xFF
        b[32]    = self.main_port        & 0xFF
        b[33]    = self.backup_port      & 0xFF
        b[40]    = self.topo_change_count & 0xFF
        struct.pack_into("<I", b, 368, self.master_age)
        b[336:344] = self.ports[0].pack()
        b[344:352] = self.ports[1].pack()
        return bytes(b)

    @classmethod
    def unpack(cls, data: bytes) -> 'RingInfo':
        r = cls()
        r.ring_id           = struct.unpack_from("<I", data, 0)[0]
        r.bpdu_dest         = bytes(data[4:10])
        r.bridge_id         = bytes(data[10:18])
        r.master_id         = bytes(data[18:26])
        r.status            = data[28]
        r.active            = data[30]
        r.is_master         = data[31]
        r.main_port         = data[32]
        r.backup_port       = data[33]
        r.topo_change_count = data[40]
        r.master_age        = struct.unpack_from("<I", data, 368)[0]
        r.ports[0]          = PortInfo.unpack(data[336:344])
        r.ports[1]          = PortInfo.unpack(data[344:352])
        return r

    def to_dict(self) -> dict:
        return {
            "ring_id":   self.ring_id,
            "status":    "Healthy" if self.status == 1 else "Break",
            "active":    bool(self.active),
            "is_master": bool(self.is_master),
            "master_id": ":".join(f"{b:02x}" for b in self.master_id[:6]),
            "ports": [
                {"id": p.port_id,
                 "state": PORT_STATE_STR.get(p.state, "---"),
                 "is_down": bool(p.is_down)}
                for p in self.ports
            ],
        }


# ─────────────────────────────────────────────────────────────────────────────
# CouplingInfo  (192-byte on-wire structure, STATUS/COUPLING)
#
# Offsets from sub_A7FC @ 0xA7FC and tr2_showBuffer case a1==1:
#   [0]  active   u8
#   [1]  mode     u8   CouplingMode
#   [8]  port1    u8   PortState of coupling port 1
#   [9]  port1_id u8
#   [16] port2    u8   PortState of coupling port 2
#   [17] port2_id u8
#   total = 192
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class CouplingInfo:
    WIRE_SIZE = 192

    active:   int = 0
    mode:     int = CouplingMode.NONE
    port1_id: int = 0
    port1:    int = PortState.FORWARDING
    port2_id: int = 0
    port2:    int = PortState.FORWARDING

    def pack(self) -> bytes:
        b = bytearray(self.WIRE_SIZE)
        b[0]  = self.active   & 0xFF
        b[1]  = self.mode     & 0xFF
        b[8]  = self.port1    & 0xFF
        b[9]  = self.port1_id & 0xFF
        b[16] = self.port2    & 0xFF
        b[17] = self.port2_id & 0xFF
        return bytes(b)

    @classmethod
    def unpack(cls, data: bytes) -> 'CouplingInfo':
        c = cls()
        c.active   = data[0]
        c.mode     = data[1]
        c.port1    = data[8]  if len(data) > 8  else 0
        c.port1_id = data[9]  if len(data) > 9  else 0
        c.port2    = data[16] if len(data) > 16 else 0
        c.port2_id = data[17] if len(data) > 17 else 0
        return c

    def to_dict(self) -> dict:
        return {
            "active": bool(self.active),
            "mode":   COUPLING_MODE_STR.get(self.mode, "Unknown"),
            "port1":  PORT_STATE_STR.get(self.port1, "---"),
            "port2":  PORT_STATE_STR.get(self.port2, "---"),
        }


# ─────────────────────────────────────────────────────────────────────────────
# LHCPortInfo  (64-byte per-port record, STATUS/LHC)
#
# Offsets from tr2_showBuffer case a1==2:
#   [0..5]   link_partner    6×u8 MAC
#   [6]      partner_port    u8
#   [7]      lhc_checking    u8
#   [8]      state           u8
#   [9]      partner_state   u8
#   [10]     lhc_recv        u8
#   [11]     lhc_status      u8
#   [12]     lhc_polling     u8
#   [16]     timer_act_lo    u32
#   [40]     timer_act_hi    u32
#   total = 64
# ─────────────────────────────────────────────────────────────────────────────

@dataclass
class LHCPortInfo:
    WIRE_SIZE = 64

    link_partner:  bytes = field(default_factory=lambda: bytes(6))
    partner_port:  int   = 0
    lhc_checking:  int   = 0
    state:         int   = PortState.FORWARDING
    partner_state: int   = 0
    lhc_recv:      int   = 0
    lhc_status:    int   = 0
    lhc_polling:   int   = 0
    timer_act_lo:  int   = 0
    timer_act_hi:  int   = 0

    def pack(self) -> bytes:
        b = bytearray(self.WIRE_SIZE)
        b[0:6]  = (self.link_partner + bytes(6))[:6]
        b[6]    = self.partner_port  & 0xFF
        b[7]    = self.lhc_checking  & 0xFF
        b[8]    = self.state         & 0xFF
        b[9]    = self.partner_state & 0xFF
        b[10]   = self.lhc_recv      & 0xFF
        b[11]   = self.lhc_status    & 0xFF
        b[12]   = self.lhc_polling   & 0xFF
        struct.pack_into("<I", b, 16, self.timer_act_lo)
        struct.pack_into("<I", b, 40, self.timer_act_hi)
        return bytes(b)

    @classmethod
    def unpack(cls, data: bytes) -> 'LHCPortInfo':
        return cls(
            link_partner  = bytes(data[0:6]),
            partner_port  = data[6],
            lhc_checking  = data[7],
            state         = data[8],
            partner_state = data[9],
            lhc_recv      = data[10],
            lhc_status    = data[11],
            lhc_polling   = data[12],
            timer_act_lo  = struct.unpack_from("<I", data, 16)[0],
            timer_act_hi  = struct.unpack_from("<I", data, 40)[0],
        )


# ─────────────────────────────────────────────────────────────────────────────
# DSA tag helpers  (sub_1B7AC parse / sub_1B89C build)
# Marvell DSA tag is 4 bytes inserted after the 12-byte MAC header.
#
#   byte[0]  0x40 | (egress?0x20:0)   forward tag
#   byte[1]  port << 3
#   byte[2]  high 4 bits of VID
#   byte[3]  low  8 bits of VID
# ─────────────────────────────────────────────────────────────────────────────

def dsa_parse(tag: bytes):
    """Parse 4-byte DSA tag → (src_port, vid)  (mirrors sub_1B7AC)"""
    src_port = tag[1] >> 3
    vid      = ((tag[2] & 0x0F) << 8) | tag[3]
    return src_port, vid

def dsa_build(port: int, vid: int = 0, egress: bool = False) -> bytes:
    """Build 4-byte DSA forward tag  (mirrors sub_1B89C)"""
    b0 = 0x40 | (0x20 if egress else 0)
    b1 = (port & 0x1F) << 3
    b2 = (vid >> 8) & 0x0F
    b3 = vid & 0xFF
    return bytes([b0, b1, b2, b3])


# ─────────────────────────────────────────────────────────────────────────────
# TR2 packet on-wire layout (built in Ssc_sendTR2Packet / Ssc_sendBpduPacket)
#
# Ethernet frame with inserted DSA tag:
#   [0..5]    DA     6 bytes
#   [6..11]   SA     6 bytes
#   [12..15]  DSA    4 bytes  (inserted by frame_send / sub_1B970)
#   [16..17]  ethertype/length  htons(payload_len + 3)
#   [18]      DSAP = 0x42
#   [19]      SSAP = 0x42
#   [20]      ctrl = 0x03
#   [21..]    TR2 payload (type byte + data)
#
# The "ethD" magic lives at payload[0..3] (i.e. frame[21..24]):
#   payload[0..3]   "ethD"
#   payload[4]      reserved?
#   payload[5]      = 1  (always)
#   payload[6]      PktType
#   payload[7..]    type-specific data
# ─────────────────────────────────────────────────────────────────────────────

TR2_HDR_LLCLEN   = 3   # DSAP + SSAP + ctrl
TR2_HDR_OVERHEAD = 6 + 6 + 4 + 2 + TR2_HDR_LLCLEN   # total before payload = 21 bytes
TR2_MIN_FRAME    = 60  # zero-pad to this


def build_tr2_frame(da: bytes, sa: bytes, port: int, ring_id: int,
                    payload: bytes, vid: int = 0, use_mcast_sa: bool = False) -> bytes:
    """
    Build a complete TR2 ethernet frame with DSA tag.
    Mirrors Ssc_sendTR2Packet @ 0x1BE4C + frame_send @ 0x1B970.
    """
    dsa  = dsa_build(port, vid)
    elen = htons_val(len(payload) + TR2_HDR_LLCLEN)
    frame = (da[:6] + sa[:6] + dsa
             + struct.pack(">H", elen)
             + bytes([0x42, 0x42, 0x03])
             + payload)
    # zero-pad to minimum Ethernet frame
    if len(frame) < TR2_MIN_FRAME:
        frame += bytes(TR2_MIN_FRAME - len(frame))
    return frame

def htons_val(v: int) -> int:
    return struct.unpack(">H", struct.pack("<H", v))[0]

def build_tr2_payload(pkt_type: int, ring_id: int, data: bytes) -> bytes:
    """Build TR2 payload (after LLC header): ethD + reserved + type + data"""
    return TR2_PKT_MAGIC + bytes([0x00, 0x01, pkt_type]) + data


# ─────────────────────────────────────────────────────────────────────────────
# IPC message builder / parser  (tr2_doMsgCmd @ 0xC798)
# ─────────────────────────────────────────────────────────────────────────────

def build_msg(cmd: int, subtype: int = 0, payload: bytes = b"") -> bytes:
    """Build a 524-byte IPC request message."""
    buf = bytearray(MSG_SIZE)
    struct.pack_into("<I", buf, 0, cmd)
    struct.pack_into("<I", buf, 4, subtype)
    if payload:
        buf[8:8 + len(payload)] = payload[:MSG_SIZE - 8]
    return bytes(buf)

def parse_msg(data: bytes):
    """Parse a 524-byte IPC request → (cmd, subtype, payload)."""
    cmd     = struct.unpack_from("<I", data, 0)[0]
    subtype = struct.unpack_from("<I", data, 4)[0]
    # 'a' cmd: full config block starts at offset 12 (command+12 in tr2_doMsgCmd)
    payload = data[8:]
    return cmd, subtype, payload


# ─────────────────────────────────────────────────────────────────────────────
# Activate-command config payload layout  (tr2_doMsgCmd 'a' branch @ 0xC9AC)
#
# command[12..]  is the serialised config delta:
#   [0]     u32  enabled
#   [4]     u8   ring[0].enabled
#   [5]     u8   ring[0].priority
#   [12]    u8   ring[0].port0
#   [13]    u8   ring[0].port1
#   [16]    u8   ring[1].enabled
#   [17]    u8   ring[1].priority
#   [24]    u8   ring[1].port0
#   [25]    u8   ring[1].port1
#   [28]    u8   coupling_mode
#   [29]    u8   coupling_primary
#   [30]    u8   coupling_backup
# ─────────────────────────────────────────────────────────────────────────────

def pack_activate_payload(cfg: TR2Config) -> bytes:
    """Serialise TR2Config into the 'a' command payload (31 bytes used)."""
    b = bytearray(31)
    struct.pack_into("<I", b, 0, cfg.enabled)
    for i, r in enumerate(cfg.rings):
        base = 12 * i
        b[4  + base] = r.enabled  & 0xFF
        b[5  + base] = r.priority & 0xFF
        b[12 + base] = r.port0    & 0xFF
        b[13 + base] = r.port1    & 0xFF
    b[28] = cfg.coupling.mode         & 0xFF
    b[29] = cfg.coupling.primary_port & 0xFF
    b[30] = cfg.coupling.backup_port  & 0xFF
    return bytes(b)

def unpack_activate_payload(data: bytes) -> TR2Config:
    cfg = TR2Config()
    cfg.enabled = struct.unpack_from("<I", data, 0)[0]
    for i in range(2):
        base = 12 * i
        cfg.rings[i] = RingConfig(
            enabled  = data[4  + base],
            priority = data[5  + base],
            port0    = data[12 + base],
            port1    = data[13 + base],
        )
    cfg.coupling = CouplingConfig(
        mode         = data[28],
        primary_port = data[29],
        backup_port  = data[30],
    )
    return cfg