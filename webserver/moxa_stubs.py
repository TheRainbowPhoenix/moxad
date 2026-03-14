from moxa_show_value import *


DEMO_SYS_PROV = {
    # SRV_TRUNK_SETTING (ctl_id=1) : Port trunk group membership
    # Used with: if(SRV_TRUNK_SETTING[i].trkgrp == 0) { ... } else { ... }
    # trkgrp: 0 = standalone port, 1+ = trunk group ID (ports with same trkgrp are bonded)
    1: {
        'item_size': 4,
        'item_count': 10,  # 10 ports (EDR-810)
        'fields': [
            # trkgrp: trunk group ID (0 = no trunk, 1-255 = group number)
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'trkgrp', 'count': 1, 'offset': 0},
            # Optional padding/reserved fields can be added here if needed
        ],
        'rows': [
            # Port 0 (WAN): standalone
            {'trkgrp': '0', 'id': 0},
            # Port 1 (LAN): standalone
            {'trkgrp': '0', 'id': 1},
            # Port 2: in trunk group 1 (LAG with port 3)
            {'trkgrp': '1', 'id': 2},
            # Port 3: in trunk group 1 (LAG with port 2)
            {'trkgrp': '1', 'id': 3},
            # Ports 4-9: standalone
            {'trkgrp': '0', 'id': 4},
            {'trkgrp': '0', 'id': 5},
            {'trkgrp': '0', 'id': 6},
            {'trkgrp': '0', 'id': 7},
            {'trkgrp': '0', 'id': 8},
            {'trkgrp': '0', 'id': 9},
        ]
    },

    18: { # SRV_IP_CLIENT
        'item_size': 64,
        'item_count': 1,  # Single WAN interface config
        'fields': [
            # Field layout mirrors C struct packing (with natural alignment)
            {'type': FTYPE_UINT16,     'size': 2,  'name': 'vid',        'count': 1, 'offset': 0},
            {'type': FTYPE_UINT8,      'size': 1,  'name': 'type_ip',    'count': 1, 'offset': 2},
            {'type': FTYPE_UINT8,      'size': 1,  'name': 'enabled',    'count': 1, 'offset': 3},  # padding/flag
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'staticip',   'count': 1, 'offset': 4},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'netmask',    'count': 1, 'offset': 20},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'gateway',    'count': 1, 'offset': 36},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dns1',       'count': 1, 'offset': 52},
            # Optional: add more fields as needed (dns2, ifname, etc.)
        ],
        'rows': [
            {
                # Default WAN config - matches JS logic expectations:
                # - vid='0' --> untagged/WAN interface
                # - type_ip='0' --> static IP mode
                'vid': '0',
                'type_ip': '0',        # 0=Static, 1=DHCP, 2=PPPoE
                'enabled': '1',
                'staticip': '192.168.1.100',
                'netmask': '255.255.255.0',
                'gateway': '192.168.1.1',
                'dns1': '8.8.8.8',
            }
        ]
    },
    22: {
        'item_size': 32, 'item_count': 2,
        'fields': [
            {'type': FTYPE_UINT16, 'size': 2, 'name': 'vid', 'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'ifname', 'count': 1, 'offset': 2},
        ],
        'rows': [
            {'vid': '10', 'ifname': 'br0'},
            {'vid': '20', 'ifname': 'br1'},
        ]
    },
    25: {
        'item_size': 48, 'item_count': 2,
        'fields': [
            {'type': FTYPE_UINT16, 'size': 2, 'name': 'vlanid', 'count': 1, 'offset': 0},
            {'type': FTYPE_UINT8,  'size': 1, 'name': 'port0',  'count': 1, 'offset': 2},
            {'type': FTYPE_UINT8,  'size': 1, 'name': 'port1',  'count': 1, 'offset': 3},
            # ... port2-port9 as needed
        ],
        'rows': [
            {'vlanid': '10', 'port0': '1', 'port1': '0', 'port2': '1'},  # VLAN 10: ports 0,2
            {'vlanid': '20', 'port0': '0', 'port1': '1', 'port2': '0'},  # VLAN 20: port 1
        ]
    },
    34: {  #SRV_SYSINFO
        'item_size': 32, 'item_count': 1,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'loginfailmsg',   'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'loginmsg',   'count': 1, 'offset': 1},
        ],
        'rows': [
            {'loginfailmsg': 'TODO: loginfailmsg', 'loginmsg': 'TODO: loginmsg'}
        ]
    },
    # SRV_ROUTING_TABLE (ctl_id=79) : Routing table entries
    79: {
        'item_size': 64,
        'item_count': 14,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'type',   'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dest',   'count': 1, 'offset': 16},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'nhop',   'count': 1, 'offset': 32},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'ifname', 'count': 1, 'offset': 48},
            {'type': FTYPE_UINT8,      'size': 1,  'name': 'metric', 'count': 1, 'offset': 64},
        ],
        'rows': [
            {'type': 'Connect', 'dest': '192.168.127.1', 'nhop': '100.100.100.254', 'ifname': 'wan1', 'metric': '15'},
            {'type': 'RIP', 'dest': '192.168.1.254', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Static', 'dest': '100.100.100.100', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Static', 'dest': '100.100.100.101', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Connect', 'dest': '100.100.100.102', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Connect', 'dest': '100.100.100.103', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Connect', 'dest': '100.100.100.104', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'RIP', 'dest': '100.100.100.105', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.106', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.107', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.108', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.109', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.110', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
            {'type': 'Kernel', 'dest': '100.100.100.111', 'nhop': '100.100.100.254', 'ifname': 'wan2', 'metric': '15'},
        ]
    },

    # SRV_BRG (ctl_id=142) : Bridge interface config (single object, not array)
    142: {
        'item_size': 32,
        'item_count': 1,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'ip',   'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'mask', 'count': 1, 'offset': 16},
        ],
        'rows': [
            {'ip': '192.168.1.1', 'mask': '255.255.255.0'}
        ]
    },

    # SRV_CERREQ (ctl_id=72) : Certificate request form data
    72: {
        'item_size': 128,
        'item_count': 1,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 4,  'name': 'ct',        'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 4,  'name': 'days',      'count': 1, 'offset': 4},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'state',     'count': 1, 'offset': 8},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'local',     'count': 1, 'offset': 16},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'org',       'count': 1, 'offset': 24},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'orgunit',   'count': 1, 'offset': 32},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'name',      'count': 1, 'offset': 40},
            {'type': FTYPE_STRING_REF, 'size': 32, 'name': 'mailaddr',  'count': 1, 'offset': 56},
        ],
        'rows': [
            {
                'ct': 'TW', 'days': '365', 'state': 'TAP', 'local': 'HT',
                'org': 'MOXA', 'orgunit': 'IEI', 'name': 'aries',
                'mailaddr': 'aries.wang@moxa.com'
            }
        ]
    },

    # SRV_CERGT (ctl_id=73) : Certificate grant list
    73: {
        'item_size': 96,
        'item_count': 3,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'cerday',      'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'cerpem',      'count': 1, 'offset': 8},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'cerorgunit',  'count': 1, 'offset': 24},
            {'type': FTYPE_STRING_REF, 'size': 32, 'name': 'cermailaddr', 'count': 1, 'offset': 32},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'cerpw',       'count': 1, 'offset': 64},
        ],
        'rows': [
            {'cerday': '365', 'cerpem': 'moxa', 'cerorgunit': 'IEI', 'cermailaddr': 'iei.net@moxa.com', 'cerpw': '123456'},
            {'cerday': '30', 'cerpem': 'iei', 'cerorgunit': 'IVN', 'cermailaddr': 'ivn.net@moxa.com', 'cerpw': 'moxaiei'},
            {'cerday': '3650', 'cerpem': 'g903', 'cerorgunit': 'DAC', 'cermailaddr': 'dac.net@moxa.com', 'cerpw': 'moxanet'},
        ]
    },

    # SRV_DHCP (ctl_id=20) : DHCP server config per interface
    20: {
        'item_size': 128,
        'item_count': 3,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_netmask', 'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 4,  'name': 'dhcp_en',      'count': 1, 'offset': 16},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_ip1',     'count': 1, 'offset': 20},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_ip2',     'count': 1, 'offset': 36},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'dhcp_lease',   'count': 1, 'offset': 52},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_gateway', 'count': 1, 'offset': 60},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_dns1',    'count': 1, 'offset': 76},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_dns2',    'count': 1, 'offset': 92},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_ntp',     'count': 1, 'offset': 108},
        ],
        'rows': [
            {
                'dhcp_netmask': '255.255.255.0', 'dhcp_en': '1',
                'dhcp_ip1': '192.168.127.100', 'dhcp_ip2': '192.168.127.200',
                'dhcp_lease': '86400', 'dhcp_gateway': '192.168.127.254',
                'dhcp_dns1': '192.168.127.11', 'dhcp_dns2': '192.168.127.12',
                'dhcp_ntp': '192.168.127.13',
            },
            {
                'dhcp_netmask': '255.255.255.0', 'dhcp_en': '1',
                'dhcp_ip1': '192.168.2.100', 'dhcp_ip2': '192.168.2.200',
                'dhcp_lease': '16400', 'dhcp_gateway': '192.168.2.254',
                'dhcp_dns1': '192.168.2.11', 'dhcp_dns2': '192.168.2.12',
                'dhcp_ntp': '192.168.2.13',
            },
            {
                'dhcp_netmask': '255.255.255.0', 'dhcp_en': '0',
                'dhcp_ip1': '192.168.3.100', 'dhcp_ip2': '192.168.3.200',
                'dhcp_lease': '3600', 'dhcp_gateway': '192.168.3.254',
                'dhcp_dns1': '192.168.3.11', 'dhcp_dns2': '192.168.3.12',
                'dhcp_ntp': '192.168.3.13',
            },
        ]
    },

    # SRV_DHCP_PIP (ctl_id=110) : DHCP static IP reservations
    110: {
        'item_size': 128,
        'item_count': 3,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 4,  'name': 'enable',       'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 4,  'name': 'port',         'count': 1, 'offset': 4},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'hostip',       'count': 1, 'offset': 8},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_netmask', 'count': 1, 'offset': 24},
            {'type': FTYPE_STRING_REF, 'size': 8,  'name': 'dhcp_lease',   'count': 1, 'offset': 40},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_gateway', 'count': 1, 'offset': 48},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_dns1',    'count': 1, 'offset': 64},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_dns2',    'count': 1, 'offset': 80},
            {'type': FTYPE_STRING_REF, 'size': 16, 'name': 'dhcp_ntp',     'count': 1, 'offset': 96},
        ],
        'rows': [
            {
                'enable': '0', 'port': '1', 'hostip': '192.168.127.50',
                'dhcp_netmask': '255.255.255.0', 'dhcp_lease': '10',
                'dhcp_gateway': '192.168.127.254', 'dhcp_dns1': '192.168.127.11',
                'dhcp_dns2': '192.168.127.12', 'dhcp_ntp': '192.168.127.13',
            },
            {
                'enable': '1', 'port': '2', 'hostip': '192.168.127.51',
                'dhcp_netmask': '255.255.255.0', 'dhcp_lease': '50',
                'dhcp_gateway': '192.168.127.254', 'dhcp_dns1': '192.168.127.11',
                'dhcp_dns2': '192.168.127.12', 'dhcp_ntp': '192.168.127.13',
            },
            {
                'enable': '1', 'port': '3', 'hostip': '192.168.1.12',
                'dhcp_netmask': '255.255.255.0', 'dhcp_lease': '99',
                'dhcp_gateway': '192.168.127.254', 'dhcp_dns1': '192.168.127.11',
                'dhcp_dns2': '192.168.127.12', 'dhcp_ntp': '192.168.127.13',
            },
        ]
    },

    # SRV_DHCP_SVR_MODE (ctl_id=109) : DHCP server mode (single object)
    109: {
        'item_size': 8,
        'item_count': 1,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'mode', 'count': 1, 'offset': 0},
        ],
        'rows': [
            {'mode': '0'}  # 0=server, 1=relay, 2=disabled
        ]
    },

    95: {
        'item_size': 64,
        'item_count': 1,
        'fields': [
            # Protocol enable flags (3 = string ref for '0'/'1')
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'moxa_utility', 'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'telnet',         'count': 1, 'offset': 4},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ssh',            'count': 1, 'offset': 8},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'http',           'count': 1, 'offset': 12},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'https',          'count': 1, 'offset': 16},
            # Port numbers (4 = uint8/uint16)
            {'type': FTYPE_UINT8,      'size': 2, 'name': 'telnet_port',    'count': 1, 'offset': 20},
            {'type': FTYPE_UINT8,      'size': 2, 'name': 'ssh_port',       'count': 1, 'offset': 22},
            {'type': FTYPE_UINT8,      'size': 2, 'name': 'http_port',      'count': 1, 'offset': 24},
            {'type': FTYPE_UINT8,      'size': 2, 'name': 'https_port',     'count': 1, 'offset': 26},
            # Additional settings
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ping_response',          'count': 1, 'offset': 28},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'maxuser_http_https',     'count': 1, 'offset': 32},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'maxuser_telnet_ssh',     'count': 1, 'offset': 36},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'webAutoLogoutNum',       'count': 1, 'offset': 40},
        ],
        'rows': [
            {
                'moxa_utility': '1', 'telnet': '1', 'ssh': '1', 'http': '1', 'https': '1',
                'telnet_port': '23', 'ssh_port': '22', 'http_port': '80', 'https_port': '443',
                'ping_response': '0',
                'maxuser_http_https': '5',
                'maxuser_telnet_ssh': '5',
                'webAutoLogoutNum': '5',
            }
        ]
    },

    124: {
        'item_size': 32,
        'item_count': 1,
        'fields': [
            {'type': FTYPE_STRING_REF, 'size': 32, 'name': 'cfgimport_pw', 'count': 1, 'offset': 0},
            # Add more fields if needed: cfgexport_pw, etc.
        ],
        'rows': [
            # Default: password not set ('0' = disabled per firmware convention)
            {'cfgimport_pw': '0'}
            # To enable: {'cfgimport_pw': '1'} or {'cfgimport_pw': 'my_secret'}
        ]
    },

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
    },
    # SRV_TR2SET (ctl_id=93) : TurboRing configuration settings
    93: {
        'item_size': 64,
        'item_count': 1,
        'fields': [
            # Enable flags (3 = string ref for '0'/'1')
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'tr2_enabled',    'count': 1, 'offset': 0},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'coupling_enabled','count': 1, 'offset': 4},
            # Ring 1 config
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring1',          'count': 1, 'offset': 8},
            {'type': FTYPE_UINT8,      'size': 1, 'name': 'ring1_master',   'count': 1, 'offset': 12},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring1_port1',    'count': 1, 'offset': 13},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring1_port2',    'count': 1, 'offset': 17},
            # Ring 2 config
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring2',          'count': 1, 'offset': 21},
            {'type': FTYPE_UINT8,      'size': 1, 'name': 'ring2_master',   'count': 1, 'offset': 25},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring2_port1',    'count': 1, 'offset': 26},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'ring2_port2',    'count': 1, 'offset': 30},
            # Coupling config
            {'type': FTYPE_UINT8,      'size': 1, 'name': 'coupling',       'count': 1, 'offset': 34},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'coupling_1st',   'count': 1, 'offset': 35},
            {'type': FTYPE_STRING_REF, 'size': 4, 'name': 'coupling_2nd',   'count': 1, 'offset': 39},
        ],
        'rows': [
            {
                'tr2_enabled': '1',
                'ring1': '1', 'ring1_master': '1', 'ring1_port1': '1', 'ring1_port2': '2',
                'ring2': '0', 'ring2_master': '0', 'ring2_port1': '3', 'ring2_port2': '4',
                'coupling_enabled': '0', 'coupling': '1', 'coupling_1st': '7', 'coupling_2nd': '8',
            }
        ]
    },

    # SRV_RSTP_SETTING (ctl_id=112) : RSTP bridge/global parameters
    # Used with: fnLoadForm(myForm, SRV_RSTP_SETTING, SRV_RSTP_SETTING_type)
    112: {
        'item_size': 16,
        'item_count': 1,  # Single object, not array
        'fields': [
            # Bridge priority: 0-15 --> 0, 4096, 8192, ... 61440
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'bridge_priority', 'count': 1, 'offset': 0},
            # Hello time: 1-2 seconds
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'hello_time',    'count': 1, 'offset': 1},
            # Forward delay: 4-30 seconds
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'forward_delay', 'count': 1, 'offset': 2},
            # Max age: 6-40 seconds
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'max_age',       'count': 1, 'offset': 3},
        ],
        'rows': [
            {
                'bridge_priority': '8',    # 8 --> 32768 (default)
                'hello_time': '1',         # 1 second
                'forward_delay': '15',     # 15 seconds
                'max_age': '20',           # 20 seconds
            }
        ]
    },

    # SRV_RSTP_PORT (ctl_id=111) : Per-port RSTP settings (array)
    # Used with: SRV_RSTP_PORT[idx].port_enable, etc.
    111: {
        'item_size': 32,
        'item_count': 10,  # 10 ports (EDR-810)
        'fields': [
            # Port enable flag: 0=disabled, 1=enabled
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'port_enable', 'count': 1, 'offset': 0},
            # Edge port: 0=False, 1=Force Edge
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'edge_port',   'count': 1, 'offset': 1},
            # Port priority: 0-15 --> 0, 16, 32, ... 240
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'port_priority','count': 1, 'offset': 2},
            # Port cost: 1-200000000 (stored as string for JS compatibility)
            {'type': FTYPE_STRING_REF, 'size': 12, 'name': 'port_cost', 'count': 1, 'offset': 3},
            # Port status: 0=Link Down, 1=Blocking, 2=Listening, 3=Learning, 4=Forwarding, 5=Disabled
            {'type': FTYPE_UINT8, 'size': 1, 'name': 'port_status', 'count': 1, 'offset': 15},
        ],
        'rows': [
            # Port 0 (WAN)
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '4'},
            # Port 1 (LAN)
            {'port_enable': '1', 'edge_port': '1', 'port_priority': '8', 'port_cost': '20000', 'port_status': '4'},
            # Ports 2-9: mixed states for demo
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '4'},
            {'port_enable': '0', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '5'},  # Disabled
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '12', 'port_cost': '10000', 'port_status': '3'}, # Learning
            {'port_enable': '1', 'edge_port': '1', 'port_priority': '4', 'port_cost': '50000', 'port_status': '4'},
            {'port_enable': '0', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '0'},  # Link Down
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '1'},  # Blocking
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '4'},
            {'port_enable': '1', 'edge_port': '0', 'port_priority': '8', 'port_cost': '20000', 'port_status': '4'},
        ]
    },
}