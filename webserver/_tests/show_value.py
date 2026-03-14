"""
moxa_show_value.py
==================
Pure-Python reimplementation of the Moxa GoAhead firmware extension:
    net_Web_show_value(name)  ->  JavaScript variable declaration string

Reverse-engineered from ARM firmware binary (Moxa EDR/TN series, GoAhead 2.x).

Usage (standalone)
------------------
    from moxa_show_value import net_Web_show_value
    js = net_Web_show_value('SRV_OPENVPN_CLIENT', my_data_provider)

Usage (Jinja2)
--------------
    from moxa_show_value import make_jinja2_global
    env.globals['net_Web_show_value'] = make_jinja2_global(my_data_provider)
    # Template: {{ net_Web_show_value("SRV_OPENVPN_CLIENT") | safe }}

Data provider protocol
----------------------
    def my_provider(ctl_id: int) -> dict | None:
        return {
            'item_size':  int,       # bytes per struct row
            'item_count': int,       # number of rows
            'fields': [             # list of field descriptors
                {'type': int, 'size': int, 'name': str,
                 'count': int, 'offset': int},
                ...
            ],
            'rows': [               # list of row dicts {field_name: str_value}
                {'enable': '1', 'serverIP': '1.2.3.4', ...},
                ...
            ]
        }
        # Return None if ctl_id is unsupported / unreachable
"""
import struct
import binascii
from typing import Callable, Dict, List, Optional

# ---------------------------------------------------------------------------
# Field type constants  (mirroring firmware FTYPE_* enum)
# ---------------------------------------------------------------------------
FTYPE_PADDING        = 0   # struct boundary / ignored
FTYPE_UINT8          = 1
FTYPE_UINT8_ARRAY    = 2   # byte array; valid if any byte non-zero
FTYPE_INT8           = 3
FTYPE_UINT16         = 4
FTYPE_INT16          = 5
FTYPE_UINT32         = 6
FTYPE_BITFIELD       = 7   # 10 named bit-flags: prefix0..9  JS type -> "3"
FTYPE_ALWAYS_VALID   = 8   # row is always considered non-empty
FTYPE_UINT64         = 9
FTYPE_STRING_REF     = 10  # string field; multi-element if count>1
FTYPE_BIT_PER_ROW    = 11  # 10 per-row bits: prefix0_name..  JS type -> "3"
FTYPE_STRUCT_BEGIN   = 12  # struct boundary marker (no JS output)
FTYPE_STRUCT_END     = 13  # struct boundary marker (no JS output)
FTYPE_UINT32_ALT     = 14
FTYPE_NESTED_TABLE   = 16  # recurse into sub-table
FTYPE_ALWAYS_VALID2  = 17  # always valid (same as 8)
FTYPE_STRING_LIST    = 18  # comma-separated string list

# JS type code emitted in the *_type descriptor object
_JS_TYPE: Dict[int, str] = {
    FTYPE_UINT8:        '4',
    FTYPE_UINT8_ARRAY:  '4',
    FTYPE_INT8:         '5',
    FTYPE_UINT16:       '4',
    FTYPE_INT16:        '5',
    FTYPE_UINT32:       '4',
    FTYPE_BITFIELD:     '3',   # emits 10 sub-keys each --> 3
    FTYPE_ALWAYS_VALID: '4',
    FTYPE_UINT64:       '4',
    FTYPE_STRING_REF:   '3',
    FTYPE_BIT_PER_ROW:  '3',
    FTYPE_UINT32_ALT:   '4',
    FTYPE_ALWAYS_VALID2:'4',
    FTYPE_STRING_LIST:  '4',
    FTYPE_NESTED_TABLE: '4',
}

# Bitfield sub-key prefix (off_20D8EC -> string "port")
BITFIELD_PREFIX = 'port'

# ctl_ids that always emit array syntax (even with 1 row)
_ALWAYS_ARRAY = {79, 66, 18, 130}  # ROUTING_TABLE, L2TPD, IP_CLIENT, ...

# ---------------------------------------------------------------------------
# SRV_NAME -> ctl_id lookup table  (extracted from byte_20DB04)
# ---------------------------------------------------------------------------
SRV_TABLE: Dict[str, int] = {
    'SRV_DEBUG': 0,
    'SRV_IPT_FILTER': 7,
    'SRV_IPT_NAT': 9,
    'SRV_IPT_DOS': 10,
    'SRV_IPT_QOS_BW': 11,
    'SRV_IPT_QOS_DOWN': 12,
    'SRV_IPT_QOS_UP,': 13,
    'SRV_SSMTP': 14,
    'SRV_EEVENT': 15,
    'SRV_SSMTP_SEND': 16,
    'SRV_SNMP': 17,
    'SRV_IP_CLIENT': 18,
    'SRV_LAN': 19,
    'SRV_DHCP': 20,
    'SRV_TIMESET': 21,
    'SRV_DST': 22,
    'SRV_NTP': 23,
    'SRV_DDNS': 24,
    'SRV_DHCPSIP': 25,
    'SRV_DHCP_SVR_MODE': 109,
    'SRV_DHCP_PIP': 110,
    'SRV_DO_SET': 26,
    'SRV_ETH_STATUS': 27,
    'SRV_WAN_PPP': 28,
    'SRV_ALIVE': 29,
    'SRV_MAIN_IFANCE': 30,
    'SRV_MAIN_FUN': 31,
    'SRV_REVENT': 32,
    'SRV_LLDP': 33,
    'SRV_SYSINFO': 34,
    'SRV_SYSLOG': 35,
    'SRV_SNMPTRAP': 36,
    'SRV_PASSWD': 37,
    'SRV_SROUTE': 38,
    'SRV_FACTORY_DEFAULT': 39,
    'SRV_RESTART': 40,
    'SRV_LOGIN': 41,
    'SRV_DNS_LIST': 42,
    'WAN1_UP': 43,
    'WAN2_UP': 44,
    'SRV_CONFIRM': 46,
    'SRV_WAN_IP_CHANGE': 47,
    'SRV_FILTER_CONFIRM': 48,
    'SRV_NAT_CONFIRM': 50,
    'SRV_MODEL_NAME': 51,
    'SRV_TYPE_DEF': 53,
    'SRV_EVENT_LOG': 54,
    'SRV_LOG_COUNT': 55,
    'SRV_CFG_UP': 56,
    'SRV_CFG_DL': 57,
    'SRV_LOG_MAKE': 58,
    'SRV_ACCESS': 59,
    'SRV_ACCESS_CONFIRM': 60,
    'SRV_DHCPLEASE': 61,
    'SRV_LOG_FROM_INST': 62,
    'SRV_CALL_WAN_UP': 63,
    'SRV_SMCAST': 101,
    'SRV_DVMRP': 102,
    'SRV_VPNG': 64,
    'SRV_MOXA_DEBUG': 126,
    'SRV_IPSEC': 65,
    'SRV_L2TPD': 66,
    'SRV_CERUP': 69,
    'SRV_CERUPTABLE': 70,
    'SRV_IPSEC_STATUS': 71,
    'SRV_CERREQ': 72,
    'SRV_CERGT': 73,
    'SRV_RIP': 74,
    'SRV_IPSEC_CONN_ACT': 75,
    'SRV_P12UP': 77,
    'SRV_P12UPTABLE': 78,
    'SRV_ROUTING_TABLE': 79,
    'SRV_VRRP': 80,
    'SRV_VRRP_GLOBAL': 81,
    'SRV_VCONF': 6,
    'SRV_VLAN': 4,
    'SRV_MODBUS': 84,
    'SRV_MODBUS_GLOBAL': 85,
    'SRV_VPLAN': 5,
    'SRV_PORT_SETTING': 86,
    'SRV_PORT_LINK_STATUS': 87,
    'SRV_TRUNK_SETTING': 1,
    'SRV_VCONF_ROUT_UPDATE': 96,
    'SRV_AUTH_CERT': 97,
    'SRV_SYSTEM_EVENT': 91,
    'SRV_RDNDNT_SET': 92,
    'SRV_TR2SET': 93,
    'SRV_IGMPSNOOPV3_SET': 94,
    'SRV_PORT_EVENT': 95,
    'SRV_PORT_STATS': 98,
    'SRV_SMCAST_MAC_SETTING': 100,
    'SRV_COS_MAPPING': 103,
    'SRV_TOS_MAPPING': 104,
    'SRV_QOS_CLASSIFICATION': 105,
    'SRV_MIRROR': 106,
    'SRV_USER_ACCOUNT': 107,
    'SRV_AGE_TIME': 108,
    'SRV_RSTP_PORT': 111,
    'SRV_RSTP_SETTING': 112,
    'SRV_RATE_LIMIT': 113,
    'SRV_UI_MGMT': 114,
    'SRV_RADIUS': 115,
    'SRV_OSPF_G': 2,
    'SRV_OSPF_A': 3,
    'SRV_OSPF_I': 116,
    'SRV_OSPF_V': 117,
    'SRV_OSPF_AGGRE': 118,
    'SRV_PIMSMS': 119,
    'SRV_PIMSMRPS': 120,
    'SRV_PIMSMSSMS': 121,
    'SRV_MROUTE_MODE': 99,
    'SRV_ABC02': 122,
    'SRV_BCAST_FWD': 123,
    'SRV_CFG_ENC_PW': 124,
    'SRV_BRG': 142,
    'SRV_ZONE_BRG': 145,
    'SRV_OPENVPN_CLIENT': 128,
    'SRV_OPENVPN_SERVER_USER': 129,
    'SRV_OPENVPN_SERVER': 130,
    'SRV_OPENVPN_SERVER_CERT': 131,
    'SRV_RSAKEYGT': 132,
    'SRV_CSR': 133,
    'SRV_MTU_ADJUST': 134,
    'SRV_SECURITY_NOTIFICATION': 135,
    'SRV_FAST_BOOTUP': 136,
    'SRV_PW_POLICY': 138,
    'SRV_LOGIN_LOCKOUT': 139,
    'SRV_EVENTLOG_MGMT': 140,
    'SRV_DDM': 141,
}
def _build_srv_table(_RAW_TABLE_HEX) -> Dict[str, int]:
    """Parse the embedded binary table into {srv_name: ctl_id}."""
    raw   = binascii.unhexlify(_RAW_TABLE_HEX.replace('\n', '').replace(' ', ''))
    ESIZ  = 136
    table = {}
    for off in range(0, len(raw), ESIZ):
        entry = raw[off:off + ESIZ]
        if len(entry) < ESIZ:
            break
        ctl_id = struct.unpack_from('<I', entry, 0)[0]
        name   = entry[4:].split(b'\x00')[0].decode('ascii', errors='replace').strip()
        if name and name not in ('SRV_END',):
            table[name] = ctl_id
    return table

# SRV_TABLE: Dict[str, int] = _build_srv_table(_raw_table_hex_here) 
DataProvider = Callable[[int], Optional[Dict]]


# ---------------------------------------------------------------------------
# Internal renderers
# ---------------------------------------------------------------------------
def _render_type_descriptor(srv_name: str, fields: List[Dict]) -> str:
    """Emit  var NAME_type = {...};\n"""
    parts    = []
    first    = True
    parent_c = 1   # tracks last STRUCT_BEGIN field count

    for f in fields:
        ft = f['type']
        if ft in (FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END, FTYPE_PADDING):
            if ft == FTYPE_STRUCT_BEGIN:
                parent_c = f['count']
            continue
        if ft == FTYPE_NESTED_TABLE:
            break

        sep   = '' if first else ','
        first = False

        count = f['count']
        if ft == FTYPE_STRING_REF:
            count = parent_c
        elif ft in (FTYPE_BITFIELD, FTYPE_BIT_PER_ROW):
            count = 1

        js = _JS_TYPE.get(ft, '0')

        for j in range(count):
            if j:
                parts.append(',')
            idx = '' if count <= 1 else str(j)
            if ft not in (FTYPE_BITFIELD, FTYPE_BIT_PER_ROW):
                parts.append('%s%s:%s' % (f['name'], idx, js))
            else:
                for k in range(10):
                    if k:
                        parts.append(',')
                    if ft == FTYPE_BITFIELD:
                        parts.append('%s%s%d:3' % (BITFIELD_PREFIX, idx, k))
                    else:
                        parts.append('%s%d_%s:3' % (BITFIELD_PREFIX, k, f['name']))

    return 'var %s_type = {%s};\n' % (srv_name, ''.join(parts))


def _escape(value: str) -> str:
    """Escape field value: skip \r, convert \n -> \\n, \ -> \\."""
    out = []
    for ch in value:
        if ch == '\r':
            continue
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\\':
            out.append('\\\\')
        else:
            out.append(ch)
    return ''.join(out)


def _render_field(f: Dict, row: Dict, parent_f: Optional[Dict]=None) -> str:
    """Render one field's key:value pairs as they appear in a JS object literal."""
    ft    = f['type']
    name  = f['name']
    count = f['count']
    parts = []

    if ft in (FTYPE_PADDING, FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END, FTYPE_NESTED_TABLE):
        return ''

    if ft == FTYPE_BITFIELD:
        # 10 bit flags from a single integer: port0:'X', port1:'X', ...
        raw_val = int(row.get(name, '0') or '0')
        for k in range(10):
            if k:
                parts.append(',')
            bit = (raw_val >> k) & 1
            parts.append("%s%d:'%d'" % (BITFIELD_PREFIX, k, bit))
        return ''.join(parts)

    if ft == FTYPE_BIT_PER_ROW:
        parts = []
        for k in range(10):
            key = '%s%d_%s' % (BITFIELD_PREFIX, k, name)
            parts.append('%s:\'%s\'' % (key, _escape(str(row.get(key, '0')))))
        return ','.join(parts)

    if ft == FTYPE_STRING_LIST:
        return '%s:\'%s\'' % (name, _escape(str(row.get(name, ''))))

    if count <= 1:
        return '%s:\'%s\'' % (name, _escape(str(row.get(name, ''))))

    parts = []
    for j in range(count):
        key = '%s%d' % (name, j)
        parts.append('%s:\'%s\'' % (key, _escape(str(row.get(key, row.get(name, ''))))))
    return ','.join(parts)


def _row_is_valid(fields: List[Dict], row: Dict) -> bool:
    for f in fields:
        ft = f['type']
        if ft in (FTYPE_ALWAYS_VALID, FTYPE_ALWAYS_VALID2):
            return True
        if ft in (FTYPE_PADDING, FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END, FTYPE_NESTED_TABLE):
            continue
        val = str(row.get(f['name'], ''))
        if ft == FTYPE_UINT8_ARRAY:
            if val and any(c != '0' for c in str(val).replace(',', '')):
                return True
        else:
            if val and val not in ('', '0'):
                return True
    return False


def _render_rows(srv_name: str, ctl_id: int,
                 fields: List[Dict], rows: List[Dict], item_count: int) -> str:
    use_array = item_count > 1 or ctl_id in _ALWAYS_ARRAY
    row_strs  = []
    for row in rows:
        if not _row_is_valid(fields, row):
            continue
        field_parts = []
        first = True
        for f in fields:
            ft = f['type']
            if ft in (FTYPE_STRUCT_BEGIN, FTYPE_STRUCT_END, FTYPE_PADDING, FTYPE_NESTED_TABLE):
                continue
            rendered = _render_field(f, row)
            if rendered:
                if not first:
                    field_parts.append(',')
                first = False
                field_parts.append(rendered)
        row_strs.append('{%s}' % ''.join(field_parts))

    if use_array:
        return 'var %s=[\n     %s];\n' % (srv_name, ',\n     '.join(row_strs))
    else:
        inner = ','.join(row_strs)
        return 'var %s={%s};\n' % (srv_name, inner.strip('{}'))


# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------
def net_Web_show_value(srv_name: str, data_provider: DataProvider) -> str:
    """
    Reimplements net_Web_show_value() from the Moxa firmware.

    Returns a JS string:
        var NAME_MAX = N;
        var NAME_type = {...};
        var NAME=[{...},{...}];
    """
    ctl_id = SRV_TABLE.get(srv_name)
    if ctl_id is None:
        return '/* net_Web_show_value: unknown SRV %r */\n' % srv_name

    data = data_provider(ctl_id)
    if data is None:
        return '/* net_Web_show_value: no data for %s (ctl_id=%d) */\n' % (srv_name, ctl_id)

    fields     = data.get('fields', [])
    rows       = data.get('rows', [])
    item_count = data.get('item_count', len(rows))

    return (
        'var %s_MAX = %d;\n' % (srv_name, item_count)
        + _render_type_descriptor(srv_name, fields)
        + _render_rows(srv_name, ctl_id, fields, rows, item_count)
    )


def get_srv_table() -> Dict[str, int]:
    """Return a copy of the full SRV_NAME -> ctl_id lookup table."""
    return dict(SRV_TABLE)


def make_jinja2_global(data_provider: DataProvider):
    """
    Create a Jinja2-ready callable.

        env.globals['net_Web_show_value'] = make_jinja2_global(my_provider)

    Template:
        {{ net_Web_show_value("SRV_OPENVPN_CLIENT") | safe }}
    """
    def _fn(name: str) -> str:
        return net_Web_show_value(name, data_provider)
    _fn.__name__ = 'net_Web_show_value'
    return _fn


# ---------------------------------------------------------------------------
# Self-test / demo
# ---------------------------------------------------------------------------
if __name__ == '__main__':
    DEMO = {
        128: {  # SRV_OPENVPN_CLIENT
            'item_size': 64, 'item_count': 2,
            'fields': [
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'enable',     'count': 1, 'offset': 0},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'clientId',   'count': 1, 'offset': 1},
                {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'serverIP',   'count': 1, 'offset': 2},
                {'type': FTYPE_UINT16,     'size': 2,  'name': 'serverPort', 'count': 1, 'offset': 18},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'devType',    'count': 1, 'offset': 20},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'protoType',  'count': 1, 'offset': 21},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'compLzo',    'count': 1, 'offset': 22},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'encCipher',  'count': 1, 'offset': 23},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'tlsAuth',    'count': 1, 'offset': 24},
                {'type': FTYPE_UINT8,      'size': 1,  'name': 'clientAuth', 'count': 1, 'offset': 25},
                {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'username',   'count': 1, 'offset': 26},
                {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'userpasswd', 'count': 1, 'offset': 42},
            ],
            'rows': [
                {'enable':'1','clientId':'1','serverIP':'180.1.1.1','serverPort':'1194',
                 'devType':'0','protoType':'0','compLzo':'1','encCipher':'1',
                 'tlsAuth':'0','clientAuth':'0','username':'aaa1','userpasswd':'1234'},
                {'enable':'0','clientId':'2','serverIP':'180.1.2.0','serverPort':'1194',
                 'devType':'1','protoType':'1','compLzo':'1','encCipher':'2',
                 'tlsAuth':'1','clientAuth':'1','username':'bbb1','userpasswd':'1234'},
            ]
        }
    }
    print(net_Web_show_value('SRV_OPENVPN_CLIENT', DEMO.get))
    print("SRV_TABLE entries:", len(SRV_TABLE))

    try:
        from jinja2 import Environment
        env = Environment()
        env.globals['net_Web_show_value'] = make_jinja2_global(DEMO.get)
        tmpl = env.from_string('{{ net_Web_show_value("SRV_OPENVPN_CLIENT") | safe }}')
        print("--- Jinja2 ---")
        print(tmpl.render())
    except ImportError:
        print("(jinja2 not installed)")
