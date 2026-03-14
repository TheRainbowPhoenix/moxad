
# Mock WebsRec class for testing
import json
import logging
import os
import xml.etree.ElementTree as ET
from xml.dom import minidom
from typing import Optional, Dict, Any
from typing import Optional
from syscommon import Read_FW_Info, format_fw_version, get_cached_fw_version

logger = logging.getLogger(__name__)

class WebsRec:
    def __init__(self):
        self.output = []
    def write(self, text: str):
        self.output.append(text)
    def get_html(self) -> str:
        return "".join(self.output)


def _pretty_xml(elem: ET.Element) -> str:
    """Convert ElementTree element to pretty-printed XML string."""
    rough = ET.tostring(elem, encoding='unicode')
    rough = rough.replace('&lt;![CDATA[', '<![CDATA[').replace(']]&gt;', ']]>')
    parsed = minidom.parseString(rough)
    return parsed.toprettyxml(indent="  ").replace('<?xml version="1.0" ?>', '<?xml version="1.0"?>').strip()


def _stub_gpio_state() -> int:
    """Stub GPIO state reader : returns deterministic test values."""
    # Bitmask: pw1=32, pw2=16, fault=0x100, DI=0x4000, DO=0x8000
    # Return all LEDs "on" for demo
    return 0x40 | 0x20 | 0x10 | 0x100 | 0x4000 | 0x8000


def _stub_thermal() -> float:
    """Stub thermal sensor : returns fixed value in deci-degrees (e.g., 425 = 42.5°C)."""
    return 425  # 42.5°C


def _stub_hw_version() -> int:
    """Stub hardware version : 1=old, 2=new (with VRRP/VPN LEDs)."""
    return 2


def _stub_redundancy_status() -> Dict[str, bool]:
    """Stub redundancy/coupling status flags."""
    return {
        'master_active': True,   # v63[34] or v63[35]
        'coupled': True,         # v63[36]
    }


def _stub_device_name() -> str:
    """Stub device hostname."""
    return "EDR-810-DEMO"


def _stub_interface_ips() -> Dict[str, str]:
    """Stub interface IP addresses."""
    return {
        'eth0': '192.168.1.10',
        'eth1': '10.0.0.10',
        'br0': '172.16.0.1',
    }


def _stub_port_info(count: int = 10) -> list[Dict[str, Any]]:
    """Stub port metadata for panel diagram."""
    ports = []
    for i in range(count):
        ports.append({
            'id': i + 1,
            'label': f'Port{i+1}',
            'type': 'copper' if i % 2 == 0 else 'fiber',  # alternate for demo
            'role': ['WAN', 'LAN', 'BR'][i % 3],
            'coord_x': 100 + i * 30,
            'coord_y': 200 + (i % 5) * 40,
            'link_speed': [10, 100, 1000][i % 3] if i % 3 != 0 else 0,  # 0 = disconnected
            'led_img': f"EDR-810_LED_{'Green' if i % 2 == 0 else 'Orange'}.png",
        })
    return ports


def _stub_panel_offsets() -> tuple[int, int]:
    """Stub panel diagram offset values."""
    return 15, 30  # leftOffset, topOffset


def _stub_image_path() -> str:
    """Stub panel background image path."""
    return "image/EDR-810_device_panel.png"


def _stub_led_labels() -> Dict[str, Dict[str, Any]]:
    """Stub LED label metadata (name, coords, size)."""
    return {
        'state':   {'label': 'SYS', 'x': 50, 'y': 80, 'w': 13, 'h': 6},
        'pw1':     {'label': 'PWR1', 'x': 50, 'y': 100, 'w': 13, 'h': 6},
        'pw2':     {'label': 'PWR2', 'x': 50, 'y': 120, 'w': 13, 'h': 6},
        'fault':   {'label': 'FLT', 'x': 50, 'y': 140, 'w': 13, 'h': 6},
        'master':  {'label': 'MST', 'x': 50, 'y': 160, 'w': 13, 'h': 6},
        'coupler': {'label': 'CPL', 'x': 50, 'y': 180, 'w': 13, 'h': 6},
        'vrrp_m':  {'label': 'VRRP', 'x': 50, 'y': 200, 'w': 13, 'h': 6},
        'vpn':     {'label': 'VPN', 'x': 50, 'y': 220, 'w': 13, 'h': 6},
    }

class NetWeb:
    def __init__(self, syscommon: Optional['SysCommon'] = None):
        self._sc = syscommon

    def net_Web_file_include(
        self,
        traversal: int=0,
        init: Optional[list[str]] = None,
    ) -> int:
        """
        Generate versioned JavaScript includes for Moxa web UI.
        
        Mirrors decompiled C function behavior:
        - Reads firmware version from flash
        - Builds relative path prefix if traversal==1 and init provided
        - Outputs <script> tags for common_XXXX.js and doc_XXXX.js
        - Adds inline init scripts (checkCookie, touchLasttime)
        
        Args:
            self: Unused (request context placeholder)
            webs_rec: Response object with .write(str) method
            traversal: If 1 and init provided, enable path traversal prefix
            init: List with single string element: path depth (e.g., ["2"] --> "../../")
        
        Returns:
            0 on success (matching C convention)
        """
        webs_rec = WebsRec()
        # Step 1: Get firmware version string (cached)                         
        version_str = get_cached_fw_version()  # e.g., "01020304"
        
        # Step 2: Build relative path prefix (if enabled)                      
        path_prefix = ""
        if traversal == 1 and init and init[0]:
            try:
                depth = int(init[0])
                path_prefix = "../" * max(0, depth)  # Prevent negative repeats
            except ValueError:
                pass  # Ignore invalid integers, like atoi() in C
        
        # Step 3: Helper to write script tags                                  
        def write_script(src: str) -> None:
            webs_rec.write(f'<script language="JavaScript" src="{path_prefix}{src}"></script>\n')
        
        # Step 4: Output versioned external scripts                            
        # write_script(f"common_{version_str}.js")
        write_script(f"common.js")
        # write_script(f"doc_{version_str}.js")
        write_script(f"doc.js")
        
        # Step 5: Output inline initialization scripts                         
        webs_rec.write('<script language="JavaScript">')
        webs_rec.write("checkCookie();")
        webs_rec.write("touchLasttime();")
        webs_rec.write("</script>")
        
        return webs_rec.get_html()

    def net_led_xml(self) -> str:
        """
        Generate LED status XML (stubbed version of net_led_xml).
        
        Returns pretty-printed XML with:
        - Device name, interface IPs
        - Power/fault/master LED states (GPIO-based)
        - Thermal reading, DI/DO status
        - USB readiness, VRRP/VPN LEDs (if HW v2)
        - Auto-logout timeout
        """
        root = ET.Element('led')
        
        # Device info
        ET.SubElement(root, 'devname').text = _stub_device_name()
        
        # Interface IPs
        ips = _stub_interface_ips()
        for iface, ip in ips.items():
            ET.SubElement(root, iface).text = ip
        
        # GPIO-based LED states (with CDATA-wrapped <img> tags like original)
        gpio = _stub_gpio_state()
        
        def led_img(name: str, mask: int, on_img: str, off_img: str) -> ET.Element:
            img = on_img if (gpio & mask) else off_img
            el = ET.SubElement(root, name)
            el.text = f'<![CDATA[<img border="0" src="image/{img}" width="13" height="6">]]>'
            return el
        
        led_img('pw1', 0x20, 'LED-Yellow.jpg', 'LED-No.jpg')
        led_img('pw2', 0x10, 'LED-Yellow.jpg', 'LED-No.jpg')
        led_img('fault_led', 0x100, 'LED-Red.jpg', 'LED-No.jpg')  # inverted logic in original
        
        # Redundancy LEDs
        redun = _stub_redundancy_status()
        led_img('master_led', 0, 
                'LED-Green.jpg' if redun['master_active'] else 'LED-No.jpg',
                'LED-No.jpg')
        led_img('coupling_led', 0,
                'LED-Green.jpg' if redun['coupled'] else 'LED-No.jpg',
                'LED-No.jpg')
        
        # Thermal (format as X.Y like original: thermal / 10, thermal % 10)
        thermal = _stub_thermal()
        ET.SubElement(root, 'thermal').text = f"{thermal // 10}.{thermal % 10}"
        
        # DI/DO (inverted logic: 0 = active in original)
        ET.SubElement(root, 'DI').text = str(int((gpio & 0x4000) == 0))
        ET.SubElement(root, 'DO').text = str(int((gpio & 0x8000) == 0))
        
        # USB status (stubbed as ready)
        usb_ready = ET.SubElement(root, 'usb_ready')
        usb_ready.text = 'ready / removable'
        led_img('usb_led', 0, 'LED-Green.jpg', 'LED-No.jpg')  # toggle in original, stubbed static
        
        # HW v2 features: VRRP/VPN LEDs
        if _stub_hw_version() == 2:
            led_img('vrrp_m_led', 0x80000, 'LED-Green.jpg', 'LED-No.jpg')
            led_img('vpn_led', 0x20000, 'LED-Green.jpg', 'LED-No.jpg')
        
        # Auto-logout timeout (original: 60000 * cf_sys_timeout; stub 5 min = 300s)
        ET.SubElement(root, 'Auto-Logout_Time').text = str(60000 * 5)
        
        final_xml = _pretty_xml(root)
        return final_xml.replace('&lt;![CDATA[', '<![CDATA[').replace(']]&gt;', ']]>')

    def get_panel_status_xml(self) -> str:
        """
        Generate panel status XML (stubbed version of GetPanelStatus).
        
        Returns pretty-printed XML with:
        - Panel background image + offsets
        - Port definitions (label, coords, type-based image)
        - Port speed LEDs (only for linked ports)
        - System LED states (power, fault, master, etc.) with coordinates
        """
        root = ET.Element('panel_info')
        
        # Panel metadata
        ET.SubElement(root, 'img_file').text = _stub_image_path()
        left_off, top_off = _stub_panel_offsets()
        offset_el = ET.SubElement(root, 'offest')
        offset_el.set('leftOffset', str(left_off))
        offset_el.set('topOffset', str(top_off))
        
        # Port definitions
        ports = _stub_port_info()
        labels = _stub_led_labels()
        
        for p in ports:
            # Determine port image based on type/role (mirrors original logic)
            if p['type'] == 'fiber':
                img = f"Fiber-{p['role']}.png"
            else:
                side = 'right' if p['id'] % 2 == 0 else ''  # alternate sides
                img = f"Copper-{p['role']}{f'-{side}' if side else ''}.png"
            
            port_el = ET.SubElement(root, 'port')
            port_el.set('label', p['label'])
            port_el.set('coord_x', str(p['coord_x']))
            port_el.set('coord_y', str(p['coord_y']))
            port_el.set('img_src', f"image/{img}")
            
            # Speed LED (only if link is up)
            if p['link_speed'] > 0:
                speed_img = (
                    "EDR-810_LED_Green.png" if p['link_speed'] == 1000 else
                    "EDR-810_LED_Orange.png"
                )
                speed_el = ET.SubElement(root, 'portspeed')
                speed_el.set('label', p['label'])
                speed_el.set('coord_x', str(p['coord_x'] + 5))   # slight offset
                speed_el.set('coord_y', str(p['coord_y'] - 10))
                speed_el.set('img_src', f"image/{speed_img}")
        
        # System LED states (with coordinates from stubbed metadata)
        gpio = _stub_gpio_state()
        redun = _stub_redundancy_status()
        hw_ver = _stub_hw_version()
        
        def state_led(name: str, key: str, mask: Optional[int], 
                     on_status: bool, img: str) -> None:
            meta = labels.get(key, {})
            status = int((gpio & mask) != 0) if mask is not None else int(on_status)
            el = ET.SubElement(root, name)
            el.set('label', meta.get('label', key.upper()))
            el.set('coord_x', str(meta.get('x', 50)))
            el.set('coord_y', str(meta.get('y', 80)))
            el.set('width', str(meta.get('w', 13)))
            el.set('height', str(meta.get('h', 6)))
            el.set('status', str(status))
            el.set('img_src', f"image/{img}")
        
        # Order matches original: state, pw1, pw2, fault, master, coupler, vrrp_m, vpn
        state_led('led_state', 'state', 0x40, True, 'EDR-810_LED_Round_Green.png')
        state_led('pw1_state', 'pw1', 0x20, True, 'EDR-810_LED_Round_Orange.png')
        state_led('pw2_state', 'pw2', 0x10, True, 'EDR-810_LED_Round_Orange.png')
        state_led('fault_state', 'fault', 0x100, False, 'EDR-810_LED_Round_Red.png')  # inverted
        state_led('master_state', 'master', None, redun['master_active'], 'EDR-810_LED_Round_Green.png')
        state_led('couple_state', 'coupler', None, redun['coupled'], 'EDR-810_LED_Round_Green.png')
        
        if hw_ver == 2:
            state_led('vrrp_m_state', 'vrrp_m', 0x80000, True, 'EDR-810_LED_Round_Green.png')
            state_led('vpn_state', 'vpn', 0x20000, True, 'EDR-810_LED_Round_Green.png')
        
        return _pretty_xml(root)

    # webs_netweb.py : Add these methods to the NetWeb class

    def net_websMainifance(self) -> str:
        """
        Generate wdata array: WAN interface PPPoE/state status.
        Original: cmd_id=30, reads 44 bytes, loops 2 interfaces.
        Returns JS array literal: [{pppoe:'Enable',state:'Connect'},...]
        """
        # Stub data: 3 WAN interfaces (matches your JS example)
        entries = [
            {'pppoe': 'Enable', 'state': 'Connect'},
            {'pppoe': 'N/A', 'state': 'Disconnect'},
            {'pppoe': 'N/A', 'state': 'Connect'},
        ]
        parts = [f"{{pppoe:'{e['pppoe']}',state:'{e['state']}'}}" for e in entries]
        return ',\n\t\t'.join(parts)


    def net_websMainfun(self) -> str:
        """
        Generate wdata1 object: feature flags (ddns, dos, etc.).
        Original: cmd_id=31 (1 byte) + cmd_id=52 (40 bytes).
        Returns JS object literal: {ddns:'Disable',dos:'Enable',...}
        """
        # Stub feature flags : customize per your demo needs
        flags = {
            # 'backup': 'Disable',
            'ddns': 'Disable', 
            'dos': 'Enable',
            # 'calive': 'Enable',
            # 'qos': 'Enable',
        }
        return json.dumps(flags)


    def net_websMainevent(self) -> str:
        """
        Generate wdata2 array: system event log entries.
        Original: reads moxalogfile, parses timestamp + event string.
        Returns JS array literal: [{event:'...',date:'YYYY/MM/DD, HH:MM:SS'},...]
        """
        # Stub log entries : matches your JS example format
        events = [
            {'event': 'Wan 2 Disable', 'date': '2009/10/15, 22:05:10'},
            {'event': 'LAN Disable', 'date': '2009/10/16, 08:18:10'},
            {'event': 'DDNS Enable', 'date': '2009/10/17, 14:35:40'},
            {'event': 'DHCP Disable', 'date': '2009/10/17, 16:45:10'},
            {'event': 'Wan 1 Enable', 'date': '2009/10/19, 10:55:10'},
            {'event': 'Wan 2 Enable', 'date': '2009/10/19, 22:25:10'},
            {'event': 'Check alive Disable', 'date': '2009/10/20, 22:05:10'},
            {'event': 'DNS Disable', 'date': '2009/10/23, 23:18:20'},
            {'event': 'Cold Start Disable', 'date': '2009/10/25, 18:15:16'},
            {'event': 'Wan 1 IP Change', 'date': '2009/10/25, 23:17:32'},
        ]
        parts = [f"{{event:'{e['event']}',time:'{e['date']}'}}" for e in events]
        return ',\n\t\t'.join(parts)


    def net_websIpset(self) -> str:
        """
        Generate wdata3 array: WAN interface IP configuration.
        Original: cmd_id=18, 512-byte records with complex struct layout.
        Returns JS array literal with fields: widx,wsta,wtyp,stip,stmk,stgw,
        ppen,psrv,pusr,ppwd,eusr,epwd,ehnm,vid,mppe,vmac,dns1-3,bcast,proxy_arp,htnm,domn,wmac
        """
        # Stub 3 WAN interfaces (matches your JS usage pattern)
        interfaces = [
            {
                'widx': 0, 'wsta': 1, 'wtyp': 0,  # type 0 = static
                'stip': '192.168.1.100', 'stmk': '255.255.255.0', 'stgw': '192.168.1.1',
                'ppen': 0, 'psrv': '', 'pusr': '', 'ppwd': '',
                'eusr': '', 'epwd': '', 'ehnm': '', 'vid': 0,
                'mppe': 0, 'vmac': '00:11:22:33:44:55',
                'dns1': '8.8.8.8', 'dns2': '8.8.4.4', 'dns3': '',
                'bcast': 1, 'bcastIP': 0, 'proxy_arp': 0,
                'htnm': 'EDR-810', 'domn': 'local', 'wmac': '00-11-22-33-44-55',
            },
            {
                'widx': 1, 'wsta': 1, 'wtyp': 8,  # type 8 = DMZ (for MODEL_EDR_G903 check)
                'stip': '10.0.0.10', 'stmk': '255.255.0.0', 'stgw': '10.0.0.1',
                'ppen': 1, 'psrv': 'vpn.example.com', 'pusr': 'user1', 'ppwd': '***',
                'eusr': '', 'epwd': '', 'ehnm': '', 'vid': 10,
                'mppe': 1, 'vmac': '00:11:22:33:44:56',
                'dns1': '1.1.1.1', 'dns2': '1.0.0.1', 'dns3': '',
                'bcast': 0, 'bcastIP': 1, 'proxy_arp': 1,
                'htnm': 'EDR-810-DMZ', 'domn': 'dmz.local', 'wmac': '00-11-22-33-44-56',
            },
            {
                'widx': 2, 'wsta': 0, 'wtyp': 1,  # type 1 = DHCP
                'stip': '0.0.0.0', 'stmk': '0.0.0.0', 'stgw': '0.0.0.0',
                'ppen': 0, 'psrv': '', 'pusr': '', 'ppwd': '',
                'eusr': '', 'epwd': '', 'ehnm': '', 'vid': 0,
                'mppe': 0, 'vmac': '00:11:22:33:44:57',
                'dns1': '0.0.0.0', 'dns2': '0.0.0.0', 'dns3': '0.0.0.0',
                'bcast': 0, 'bcastIP': 0, 'proxy_arp': 0,
                'htnm': '', 'domn': '', 'wmac': '00-11-22-33-44-57',
            },
        ]
        
        def fmt(iface):
            return (
                f"{{widx:'{iface['widx']}', wsta:'{iface['wsta']}', wtyp:'{iface['wtyp']}', "
                f"stip:'{iface['stip']}', stmk:'{iface['stmk']}', stgw:'{iface['stgw']}', "
                f"ppen:'{iface['ppen']}',psrv:'{iface['psrv']}', pusr:'{iface['pusr']}', ppwd:'{iface['ppwd']}',"
                f"eusr:'{iface['eusr']}', epwd:'{iface['epwd']}', ehnm:'{iface['ehnm']}', vid:'{iface['vid']}', "
                f"mppe:'{iface['mppe']}', "
                f"vmac:'{iface['vmac']}',"
                f"dns1:'{iface['dns1']}',dns2:'{iface['dns2']}',dns3:'{iface['dns3']}', "
                f"bcast:'{iface['bcast']}', bcastIP:'{iface['bcastIP']}', proxy_arp:'{iface['proxy_arp']}', "
                f"htnm:'{iface['htnm']}', domn:'{iface['domn']}', wmac:'{iface['wmac']}' }}"
            )
        
        parts = [fmt(iface) for iface in interfaces]
        return ',\n\t\t'.join(parts)


    def net_websifanceName(self) -> str:
        """
        Generate wdata4 array: interface name mappings.
        Original decomp shows immediate return (stub/empty in firmware).
        Returns empty string for safe JS embedding.
        """
        # Stub: return empty array content
        return ''


    def net_webPortLink(self) -> str:
        """
        Generate wdata5 object: port link status bitmask.
        Original: calls Link_state(), outputs port0:1,port1:0,... format.
        Returns JS object literal: {port0:1,port1:0,...,port9:0}
        """
        # Stub link state: ports 0,2,4,6,8 linked (even ports)
        link_mask = 0b0101010101  # bits 0,2,4,6,8 set
        parts = [f"port{i}:{1 if (link_mask >> i) & 1 else 0}" for i in range(10)]
        return ','.join(parts)


    def net_websBridgeifance(self) -> str:
        """
        Generate wdata6 array: bridge interface status.
        Original: cmd_id=143, reads 46 bytes for pppoe/state.
        Returns JS array literal: [{pppoe:'Enable', state:'Connect'}]
        """
        # Stub bridge config
        entry = {'pppoe': 'Enable', 'state': 'Connect'}
        return f"{{pppoe:'{entry['pppoe']}', state:'{entry['state']}'}}"

    # webs_netweb.py : Add this method to the NetWeb class

    def net_websEthStatus(self) -> str:
        """
        Generate Ethernet interface status array (stubbed version of net_websEthStatus).
        
        Original C function:
        - cmd_id=18: WAN config (512-byte records with IP mode flags)
        - cmd_id=6: Interface addresses (IP, mask, MAC)
        - cmd_id=27: Traffic statistics (rx/tx packets/bytes/errors)
        - Outputs JS array: [{mode:'DHCP_IP', ip:'...', mask:'...', mac:'...', ...}, ...]
        
        Returns JS array literal suitable for:
            var wdata3 = [ {{ net_websEthStatus() | safe }} ];
        
        Key fields for MODEL_EDR_G903 logic:
        - wtyp flag: bit 3 (value 8) = DMZ mode, else WAN
        - if_name: 'WAN' for primary, interface name for others
        """
        # Stub interface data : matches original struct layout expectations
        interfaces = [
            # Primary WAN interface (index 0)
            {
                'mode': 'DHCP_IP',      # STATIC_IP, PPPOE_IP, PPTP_IP also valid
                'ip': '192.168.1.100',
                'mask': '255.255.255.0',
                'mac': '00:11:22:33:44:55',
                'pptpen': 'Disable',    # PPTP enabled flag
                'pptpip': '0.0.0.0',    # PPTP peer IP
                'pppoe': 'Enable',      # PPPoE state
                'status': 'Connect',    # Connect/Disconnect via shm_link_state
                'rx_packets': '12345',
                'tx_packets': '6789',
                'rx_bytes': '9876543',
                'tx_bytes': '1234567',
                'rx_errors': '0',
                'tx_errors': '0',
                'wan_gw': '192.168.1.1',
                'ppp_gw': '10.0.0.1',   # PPP gateway (if PPPoE/PPTP active)
                'if_name': 'WAN',
                'wtyp': 0,              # Type flags: bit3=8 --> DMZ for MODEL_EDR_G903
            },
            # Secondary interface (index 1) : for DMZ/WAN2 logic
            {
                'mode': 'STATIC_IP',
                'ip': '10.0.0.10',
                'mask': '255.255.0.0',
                'mac': '00:11:22:33:44:56',
                'pptpen': 'N/A',        # N/A for non-primary interfaces
                'pptpip': 'N/A',
                'pppoe': 'N/A',
                'status': 'Connect',
                'rx_packets': '5432',
                'tx_packets': '1098',
                'rx_bytes': '4567890',
                'tx_bytes': '876543',
                'rx_errors': '1',
                'tx_errors': '0',
                'wan_gw': 'N/A',        # N/A for non-primary
                'ppp_gw': 'N/A',
                'if_name': 'eth1',      # Actual interface name
                'wtyp': 8,              # Bit 3 set --> DMZ label for MODEL_EDR_G903
            },
        ]
        
        def fmt(iface: dict) -> str:
            """Format one interface as JS object literal."""
            return (
                f"{{ mode:'{iface['mode']}', ip:'{iface['ip']}', mask:'{iface['mask']}', "
                f" mac:'{iface['mac']}',pptpen:'{iface['pptpen']}',pptpip:'{iface['pptpip']}',"
                f"pppoe:'{iface['pppoe']}',status:'{iface['status']}', "
                f"rx_packets:'{iface['rx_packets']}', tx_packets:'{iface['tx_packets']}', "
                f"rx_bytes:'{iface['rx_bytes']}', tx_bytes:'{iface['tx_bytes']}', "
                f"rx_errors:'{iface['rx_errors']}', tx_errors:'{iface['tx_errors']}', "
                f"wan_gw:'{iface['wan_gw']}', ppp_gw:'{iface['ppp_gw']}', "
                f"if_name:'{iface['if_name']}' }}"
            )
        
        parts = [fmt(iface) for iface in interfaces]
        return ',\n\t\t'.join(parts)

    def net_webShowRedundantRingDefault(self) -> str:
        """
        Generate frame src based on redundancy protocol.
        Original: shm_rdndntGetProtocol() == 3 --> turboring2_setting.asp, else rstp_setting.asp
        Returns HTML frame tag for Jinja2 embedding.
        """
        # Stub: default to RSTP; override via self._redundancy_protocol if needed
        protocol = getattr(self, '_redundancy_protocol', 2)  # 2=RSTP, 3=TurboRing
        src = "turboring2_setting.asp" if protocol == 3 else "rstp_setting.asp"
        return f'<frame name="con_redun_setting" scrolling="auto" src="{src}" marginwidth="1" marginheight="1">'


    def net_Web_Get_SYS_TRUNKS(self) -> str:
        """Return number of trunk groups (stub: 4)."""
        return "4"


    def net_WebMacTable(self, show_list: str = "0", show_page: str = "0") -> str:
        """
        Generate MAC address table JS array with optional filtering/pagination.
        
        Original logic:
        - show_list: 0=all, 1=learned, 2=static, 3=mcast, else=port filter
        - show_page: page index (10 entries per page)
        
        Returns JS array literal: [{mac:'...', type:'...', set:'...', vlan:'...', port0:'0',...},...]
        """
        # if self._sc:
        #     try:
        #         data = self._sc.get_all(CTL_MAC_TABLE)  # Define CTL_MAC_TABLE constant
        #         if data and data.get('rows'):
        #             return self._render_mac_table_real(data, show_list, show_page)
        #     except Exception as e:
        #         logger.warning(f"MAC table fetch failed: {e}")
        entries = [
            {'mac': '00-90-e8-0d-ea-f3', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,0,0,0,0,0,0,0]},
            {'mac': '00-90-10-00-aa-f3', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,0,1,1,0,0,1,0,0,0]},
            {'mac': '00-90-e8-dd-ff-ff', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,0,0,0,1,0,0,0,0,0]},
            {'mac': '00-ee-e8-0d-dd-dd', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [1,0,0,0,0,1,0,0,0,0,0,0,1,0]},
            {'mac': '00-ff-e8-0d-ee-0e', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,0,1,0,1,0,1,0,0,0,0,0,0]},
            {'mac': '00-ff-ff-0d-ef-aa', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,0,0,0,0,0,0,0]},
            {'mac': '00-90-e8-0d-ba-ab', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [1,0,0,0,0,1,0,1,0,0,1,0,0,0]},
            {'mac': '00-90-e8-bb-ea-f3', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,1,0,0,0,0,0,1,0]},
            {'mac': '00-90-e8-ab-ea-f3', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,0,0,0,0,0,0,0]},
            {'mac': '00-90-e8-ab-ea-f4', 'type': 'mcast', 'set': 'static', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,0,0,0,0,0,0,0]},
            {'mac': '00-90-e8-ab-ea-f5', 'type': 'mcast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,0,0,0,0,0,0,0]},
            {'mac': '00-90-e8-bd-ea-f3', 'type': 'ucast', 'set': 'learn', 'vlan': '1',
            'ports': [0,0,1,0,0,1,0,1,0,0,0,0,0,0]},
        ]
        
        # Apply show_list filter
        filter_type = int(show_list) if show_list.isdigit() else 0
        if filter_type == 1:  # learned only
            entries = [e for e in entries if e['set'] == 'learn']
        elif filter_type == 2:  # static only
            entries = [e for e in entries if e['set'] == 'static']
        elif filter_type == 3:  # multicast only
            entries = [e for e in entries if e['type'] == 'mcast']
        
        # Apply pagination (10 per page)
        page = int(show_page) if show_page.isdigit() else 0
        start, end = page * 10, (page + 1) * 10
        entries = entries[start:end]
        
        def fmt(e: dict) -> str:
            port_str = ', '.join(f"port{i}:'{e['ports'][i]}'" for i in range(14))
            return (f"{{mac:'{e['mac']}', type:'{e['type']}', set:'{e['set']}', "
                    f"vlan:'{e['vlan']}', {port_str}}}")
        
        parts = [fmt(e) for e in entries]
        return ',\n\t\t'.join(parts)


    def net_Web_Get_SYS_PORTS(self) -> str:
        """Return number of physical ports (stub: 10)."""
        return "10"


    def net_webPortDesc(self) -> str:
        """
        Generate port description array with type flags.
        
        Original: cmd_id=90, reads port metadata with type bitfield.
        Returns JS array: [{desc:'Port1', type:'0x4', index:'eth0'},...]
        
        Type flags (from JS):
        - DSYS_PTYPE_TYPE_COPPER = 0x00
        - DSYS_PTYPE_TYPE_FIBER  = 0x04
        - DSYS_PTYPE_TYPE_COMBO  = 0x08
        """
        # Stub port descriptions : matches EDR-810 layout
        ports = [
            {'desc': 'Port1', 'type': 0x04, 'index': 'eth0'},   # Fiber
            {'desc': 'Port2', 'type': 0x00, 'index': 'eth1'},   # Copper
            {'desc': 'Port3', 'type': 0x04, 'index': 'eth2'},   # Fiber
            {'desc': 'Port4', 'type': 0x00, 'index': 'eth3'},   # Copper
            {'desc': 'Port5', 'type': 0x08, 'index': 'eth4'},   # Combo
            {'desc': 'Port6', 'type': 0x00, 'index': 'eth5'},   # Copper
            {'desc': 'Port7', 'type': 0x04, 'index': 'eth6'},   # Fiber
            {'desc': 'Port8', 'type': 0x00, 'index': 'eth7'},   # Copper
            {'desc': 'Port9', 'type': 0x04, 'index': 'eth8'},   # Fiber
            {'desc': 'Port10', 'type': 0x00, 'index': 'eth9'},  # Copper
        ]
        
        parts = [f"{{desc:'{p['desc']}', type:'0x{p['type']:x}', index:'{p['index']}'}}" for p in ports]
        return ',\n'.join(parts)


    def net_Web_Get_IVL(self) -> str:
        """Return IVL (Independent VLAN Learning) mode (stub: 0=disabled)."""
        return "0"


    def net_webRTType(self, r_type: str = "all") -> str:
        """
        Return routing table type filter from request var.
        Original: reads websGetVar(a2, "r_type", default)
        Returns quoted string for JS embedding: "'all'", "'static'", etc.
        """
        return f"'{r_type}'"


    def net_WebARPTable(self) -> str:
        """
        Generate ARP table JS array (stubbed version of /proc/net/arp parser).
        Returns: [{ip_addr:'...', mac_addr:'...', interface:'...'},...]
        """
        entries = [
            {'ip': '192.168.127.50', 'mac': 'ac:f1:df:79:28:7b', 'iface': 'LAN'},
            {'ip': '192.168.127.51', 'mac': 'ac:f1:df:79:28:7c', 'iface': 'LAN'},
            {'ip': '192.168.127.52', 'mac': 'ac:f1:df:79:28:7d', 'iface': 'LAN'},
            {'ip': '1.1.1.1', 'mac': '00:11:22:33:44:55', 'iface': 'WAN'},
            {'ip': '1.1.1.2', 'mac': '00:11:22:33:44:56', 'iface': 'WAN'},
            {'ip': '1.1.1.3', 'mac': '00:11:22:33:44:57', 'iface': 'WAN'},
        ]
        parts = [f"{{ip_addr:'{e['ip']}', mac_addr:'{e['mac']}', interface:'{e['iface']}'}}" for e in entries]
        return ',\n\t\t'.join(parts)


    def net_webCACERUP(self) -> str:
        """
        Generate CA certificate list JS array (stubbed version of openssl parser).
        Returns: [{ca_name:'...', ca_subject:'...'},...]
        """
        certs = [
            {'name': 'client.pem', 'subject': 'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=ARIES'},
            {'name': 'moxa.pem', 'subject': 'C=TW, ST=TPI, L=HT, O=MOXA, OU=IEI, CN=MOXA-CA'},
            {'name': 'root.pem', 'subject': 'C=TW, ST=TPI, L=HT, O=MOXA, OU=Security, CN=ROOT-CA'},
        ]
        parts = [f"{{ca_name:'{c['name']}', ca_subject:'{c['subject']}'}}" for c in certs]
        return ',\n\t\t'.join(parts)

    def net_websDnsList(self) -> str:
        """
        Generate DNS server list JS array (stubbed version of net_websDnsList).
        Original: cmd_id=42, reads 3 in_addr structs from daemon.
        Returns JS array literal: [{server:'8.8.8.8'}, {server:'1.1.1.1'}, ...]
        """
        # Stub DNS servers : matches expected output format
        dns_servers = ['192.168.1.91', '192.168.1.97', '168.95.1.1']
        parts = [f"{{server:'{ip}'}}" for ip in dns_servers]
        return ',\n\t\t'.join(parts)


    def net_websBridgeStatus(self) -> str:
        """
        Generate bridge interface status array (stubbed version of net_websBridgeStatus).
        Original: cmd_id=144 (traffic stats) + cmd_id=142 (interface config).
        Returns JS array literal with bridge interface objects.
        """
        # Stub bridge interfaces : up to 4 possible bridge ports
        bridges = [
            {
                'mode': 'STATIC_IP',
                'ip': '192.168.1.1',
                'mask': '255.255.255.0',
                'mac': '00:11:22:33:44:55',
                'status': 'Connect',
                'rx_packets': '12345', 'tx_packets': '6789',
                'rx_bytes': '9876543', 'tx_bytes': '1234567',
                'rx_errors': '0', 'tx_errors': '0',
                'if_name': 'br0',
            },
            {
                'mode': 'STATIC_IP',
                'ip': '10.0.0.1',
                'mask': '255.255.0.0',
                'mac': '00:11:22:33:44:56',
                'status': 'Disconnect',
                'rx_packets': '0', 'tx_packets': '0',
                'rx_bytes': '0', 'tx_bytes': '0',
                'rx_errors': '0', 'tx_errors': '0',
                'if_name': 'br1',
            },
        ]
        
        def fmt(b: dict) -> str:
            return (
                f"{{ mode:'{b['mode']}', ip:'{b['ip']}', mask:'{b['mask']}', "
                f" mac:'{b['mac']}',pptpen:'N/A',pptpip:'N/A',pppoe:'N/A',"
                f"status:'{b['status']}', "
                f"rx_packets:'{b['rx_packets']}', tx_packets:'{b['tx_packets']}', "
                f"rx_bytes:'{b['rx_bytes']}', tx_bytes:'{b['tx_bytes']}', "
                f"rx_errors:'{b['rx_errors']}', tx_errors:'{b['tx_errors']}', "
                f"wan_gw:'N/A', ppp_gw:'N/A', if_name:'{b['if_name']}' }}"
            )
        
        parts = [fmt(b) for b in bridges]
        return ',\n\t\t'.join(parts)


    def net_webledset1(self) -> str:
        """
        Generate LED configuration JS object properties (stubbed version of net_webledset1).
        Original: reads device name, interface IPs, GPIO states, thermal, redundancy flags.
        Returns comma-separated JS object properties for embedding in larger object.
        
        Note: Does NOT include trailing comma or braces : caller wraps as needed.
        """
        # Stub values matching original firmware behavior
        props = []
        
        # Device name
        props.append(f"devname:'{_stub_device_name()}'")
        
        # Interface IPs (eth0, eth1)
        ips = _stub_interface_ips()
        props.append(f"eth0:'{ips.get('eth0', '0.0.0.0')}'")
        props.append(f"eth1:'{ips.get('eth1', '0.0.0.0')}'")
        
        # Mode (bridge/route)
        props.append("mode:'bridge'")
        
        # Bridge IP
        props.append(f"br0:'{ips.get('br0', '0.0.0.0')}'")
        
        # Power LEDs (GPIO-based)
        gpio = _stub_gpio_state()
        pw1_img = 'LED-Yellow.jpg' if (gpio & 0x20) else 'LED-No.jpg'
        pw2_img = 'LED-Yellow.jpg' if (gpio & 0x10) else 'LED-No.jpg'
        props.append(f"pw1:'<img border=\"0\" src=\"image/{pw1_img}\" width=\"13\" height=\"6\">'")
        props.append(f"pw2:'<img border=\"0\" src=\"image/{pw2_img}\" width=\"13\" height=\"6\">'")
        
        # Fault LED (inverted logic)
        fault_img = 'LED-No.jpg' if (gpio & 0x100) else 'LED-Red.jpg'
        props.append(f"fault_led:'<fault_led><img border=\"0\" src=\"image/{fault_img}\" width=\"13\" height=\"6\">'")
        
        # Redundancy LEDs
        redun = _stub_redundancy_status()
        master_img = 'LED-Green.jpg' if redun['master_active'] else 'LED-No.jpg'
        coupling_img = 'LED-Green.jpg' if redun['coupled'] else 'LED-No.jpg'
        props.append(f"master_led:'<master_led><img border=\"0\" src=\"images/{master_img}\" width=\"13\" height=\"6\">'")
        props.append(f"coupling_led:'<coupling_led><img border=\"0\" src=\"images/{coupling_img}\" width=\"13\" height=\"6\">'")
        
        # Thermal reading (format as X.Y)
        thermal = _stub_thermal()
        props.append(f"thermal:'{thermal // 10}.{thermal % 10}'")
        
        # USB status (stubbed as not present)
        props.append("usb_ready:'Device not present'")
        props.append("usb_led:'<usb_led><img border=\"0\" src=\"images/LED-No.jpg\" width=\"13\" height=\"6\">'")
        
        # HW v2 features: VRRP/VPN LEDs
        if _stub_hw_version() == 2:
            vrrp_img = 'LED-Green.jpg' if (gpio & 0x80000) else 'LED-No.jpg'
            vpn_img = 'LED-Green.jpg' if (gpio & 0x20000) else 'LED-No.jpg'
            props.append(f"vrrp_m_led:'<vrrp_m_led><img border=\"0\" src=\"image/{vrrp_img}\" width=\"13\" height=\"6\">'")
            props.append(f"vpn_led:'<vpn_led><img border=\"0\" src=\"image/{vpn_img}\" width=\"13\" height=\"6\">'")
        
        return ', '.join(props)


    def net_Web_GetNO_WAN_WriteValue(self) -> str:
        """Return number of WAN interfaces (stub: 1)."""
        return "1"


    def net_Web_GetNO_MAC_PORTS_WriteValue(self) -> str:
        """Return number of MAC-addressable ports (stub: 1)."""
        return "1"

    def net_Web_IPT_NAT_WriteValue(self) -> str:
        """
        Generate NAT/port forwarding rules JS array (stubbed version of net_Web_IPT_NAT_WriteValue).
        Original: cmd_id=9, reads 29-int records (116 bytes), srv type determines field population.
        
        srv types:
        - 1 = Virtual Server (port forwarding): uses ip1, ip2
        - 2 = DMZ Host: uses ip3, ip4
        - 3 = Port Triggering: uses prot (int), ip10, port1, port2
        - 4 = Special Application: uses ip6-ip9, port1, port2
        
        Returns JS array literal: [{srv:1, idx:0, stat:'1', ifs:'wan1', ...}, ...]
        """
        # Stub NAT rules : matches expected output format
        rules = [
            # Virtual Server (srv=1)
            {
                'srv': 1, 'idx': 0, 'stat': '1', 'ifs': 'wan1',
                'prot': '', 'ip1': '192.168.168.168', 'ip2': '192.168.4.252',
                'ip3': '', 'ip4': '', 'ip5': '', 'ip6': '', 'ip7': '', 'ip8': '', 'ip9': '', 'ip10': '',
                'port1': '', 'port2': '', 'otoifid': 0, 'vrrp_binding': 0, 'name': 'WebServer',
            },
            # Port Triggering (srv=3)
            {
                'srv': 3, 'idx': 1, 'stat': '1', 'ifs': 'wan1',
                'prot': 6,  # TCP
                'ip1': '', 'ip2': '', 'ip3': '', 'ip4': '', 'ip5': '',
                'ip6': '10.1.0.168', 'ip7': '10.1.0.254', 'ip8': '192.168.127.1', 'ip9': '192.168.127.50', 'ip10': '',
                'port1': 8080, 'port2': 80, 'otoifid': 0, 'vrrp_binding': 0, 'name': 'GameTrigger',
            },
            # DMZ Host (srv=2)
            {
                'srv': 2, 'idx': 2, 'stat': '1', 'ifs': 'default',
                'prot': '', 'ip1': '', 'ip2': '',
                'ip3': '192.168.168.168', 'ip4': '192.168.168.200',
                'ip5': '', 'ip6': '', 'ip7': '', 'ip8': '', 'ip9': '', 'ip10': '',
                'port1': '', 'port2': '', 'otoifid': 0, 'vrrp_binding': 0, 'name': 'DMZ-Host',
            },
            # Special Application (srv=4)
            {
                'srv': 4, 'idx': 3, 'stat': '1', 'ifs': 'wan2',
                'prot': '', 'ip1': '', 'ip2': '', 'ip3': '', 'ip4': '', 'ip5': '',
                'ip6': '', 'ip7': '', 'ip8': '', 'ip9': '', 'ip10': '168.5.2.1',
                'port1': '800', 'port2': '21', 'otoifid': 0, 'vrrp_binding': 0, 'name': 'FTP-Special',
            },
        ]
        
        def fmt(r: dict) -> str:
            # Format IP fields : convert empty strings to '', numbers to strings as needed
            ips = [f"ip{i}:'{r[f'ip{i}']}'" for i in range(1, 11)]
            ports = [f"port{i}:'{r[f'port{i}']}'" for i in range(1, 3)]
            return (
                f"{{srv:{r['srv']}, idx:{r['idx']},  stat:'{r['stat']}', ifs:'{r['ifs']}', "
                f"prot:'{r['prot']}', {', '.join(ips)}, {', '.join(ports)}, "
                f"otoifid:'{r['otoifid']}', vrrp_binding:'{r['vrrp_binding']}', name:'{r['name']}' }}"
            )
        
        parts = [fmt(r) for r in rules]
        return ',\n\t\t'.join(parts)


    def net_Web_IPT_WANInfo_WriteValue(self) -> str:
        """
        Generate WAN interface info JS array (stubbed version of net_Web_IPT_WANInfo_WriteValue).
        Original: CS_Start/End call reads gateway IP, outputs 2 entries with df_wan flag.
        Returns JS array literal: [{wan_ip:'...', df_wan:0}, {wan_ip:'...', df_wan:1}]
        """
        # Stub WAN interfaces : second is default (df_wan=1)
        wans = [
            {'wan_ip': '192.168.1.91', 'df_wan': 0},
            {'wan_ip': '192.168.1.97', 'df_wan': 1},
        ]
        parts = [f"{{wan_ip:'{w['wan_ip']}', df_wan:{w['df_wan']}}}" for w in wans]
        return ', '.join(parts)


    def net_Web_Confirm_WriteValue(self) -> str:
        """
        Generate confirmation dialog config object (stubbed version of net_Web_Confirm_WriteValue).
        Original: cmd_id=46, reads 5 dwords for stat1-4 and timer.
        Returns JS object literal: {stat1:1, stat2:1, stat3:0, stat4:0, timer:'100'}
        """
        # Stub confirmation settings
        return "{ stat1:1, stat2:1, stat3:0, stat4:0, timer:'100' }"


    def net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(self) -> str:
        """
        Generate redundancy/fastboot config object (stubbed version).
        Original: cmd_id=136 + 93/111, checks shm_rdndntGetProtocol for TurboRing vs RSTP.
        Returns JS object literal: {redundant_enable:'1', fastbootup_enable:'0'}
        """
        # Stub config : enable redundancy, disable fastboot
        return "{redundant_enable:'1', fastbootup_enable:'0'}"


    def net_webTr2ShowStatus(self) -> str:
        """
        Generate TurboRing status array (stubbed version of net_webTr2ShowStatus).
        Original: runs `tr2ctrl -w r` and `tr2ctrl -w c`, parses /var/db/tr2status.
        Returns JS array literal with ring status objects + coupling info.
        """
        # Stub TurboRing status : matches expected output format
        rings = [
            # Active ring (ringid=1)
            {
                'ringid': '1',
                'status': 'Break',
                'master': 'Master',
                'masterId': '00:90:e8:11:11:11',
                'port1Status': '<b>Up,Blocked</b>',
                'port2Status': '<b>Up,Blocked</b>',
                'tcCount': '7',
                'timeSinceTc': '0 days 2 hours 56 mins 52 secs',
            },
            # Disabled ring (ringid=2)
            {
                'ringid': '2',
                'status': 'Disabled',
                'master': '--',
                'masterId': '00:00:00:00:00:00',
                'port1Status': '--',
                'port2Status': '--',
                'tcCount': '0',
                'timeSinceTc': ' ',
            },
            # Coupling info (separate object, no ringid)
            {
                'coupling_mode': 'Dual Homing',
                'coupling_port1': 'Forwarding',
                'coupling_port2': 'Down',
            },
        ]
        
        def fmt(r: dict) -> str:
            # Handle both ring entries and coupling entry
            if 'ringid' in r:
                return (
                    f"{{ringid:'{r['ringid']}', status:'{r['status']}', master:'{r['master']}', "
                    f"masterId:'{r['masterId']}',port1Status:\"{r['port1Status']}\", "
                    f"port2Status:\"{r['port2Status']}\", tcCount:'{r['tcCount']}', "
                    f"timeSinceTc:'{r['timeSinceTc']}' }}"
                )
            else:
                return (
                    f"{{coupling_mode:\"{r['coupling_mode']}\", "
                    f"coupling_port1:\"{r['coupling_port1']}\", "
                    f"coupling_port2:\"{r['coupling_port2']}\" }}"
                )
        
        parts = [fmt(r) for r in rings]
        return ',\n\t\t'.join(parts)

    def net_Web_Port_Status_WriteValue(self) -> str:
        """
        Generate comma-separated port link speeds for 10 ports (stubbed version).
        
        Original logic:
        - Loop ports 0-9
        - CheckPortLink(i): returns 1 if port is up, 0 if down
        - sub_1AFB98(i): returns link speed (10/100/1000) via ioctl GET_PORT_STATE
        - Output: "100, 1000, 0, 10, ..." (comma-separated, no brackets)
        
        Returns plain string for direct embedding: {{ net_Web_Port_Status_WriteValue() | safe }}
        """
        # Stub port link states and speeds : matches EDR-810 10-port layout
        # Index: 0  1   2   3   4   5   6   7   8   9
        link_up = [1, 1, 0, 1, 0, 1, 1, 0, 1, 0]  # CheckPortLink result
        speeds  = [100, 1000, 0, 100, 0, 1000, 100, 0, 1000, 0]  # sub_1AFB98 result
        
        parts = []
        for i in range(10):
            speed = speeds[i] if link_up[i] else 0
            parts.append(str(speed))
        
        return ', '.join(parts)


    def net_Web_Root_Bridge_WriteValue(self) -> str:
        """
        Generate root bridge MAC address string (stubbed version).
        
        Original logic:
        - Opens /mnt/ramdisk/root_bridge
        - Reads first line, strips newline (0x0A --> 0x00)
        - Outputs raw MAC string like "00:90:e8:11:22:33"
        
        Returns plain MAC string for direct embedding.
        """
        # Stub root bridge MAC : matches Moxa OUI prefix
        return "00:90:e8:11:22:33"
        
        # Optional: Real file read fallback (Linux only)
        # if not IS_WINDOWS:
        #     try:
        #         with open("/mnt/ramdisk/root_bridge", "r") as f:
        #             return f.readline().strip()
        #     except FileNotFoundError:
        #         logger.warning("root_bridge file not found")
        # return "00:00:00:00:00:00"  # Fallback


    def net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(self) -> str:
        """
        Generate redundancy/fastboot config object (stubbed version).
        
        Original logic:
        - cmd_id=136: reads fastbootup_enable flag (v8)
        - shm_rdndntGetProtocol(): returns protocol type (3=TurboRing, else=RSTP)
        - If TurboRing (3): cmd_id=93 checks v7[4/14/24] for ring enable
        - Else (RSTP): cmd_id=111 checks v6[i] for port enable flags
        - redundant_enable = 1 if any ring/port enabled, else 0
        
        Returns JS object literal: {redundant_enable:'1', fastbootup_enable:'0'}
        
        JavaScript usage:
            dep_fastboot_redundant.fastbootup_enable  // accesses '0' or '1'
        """
        # Stub config values
        redundant_enable = 1   # Set to 1 if redundancy is active
        fastbootup_enable = 0  # Set to 1 if fast boot is enabled
        
        return f"{{redundant_enable:'{redundant_enable}', fastbootup_enable:'{fastbootup_enable}'}}"
















if __name__ == "__main__":
    import sys
    logging.basicConfig(level=logging.DEBUG, stream=sys.stdout)
    
    # Test 1: Read firmware info
    print("=== Read_FW_Info test ===")
    fw = Read_FW_Info()
    print(f"Raw bytes (hex): {fw.hex()}")
    print(f"Version string : {format_fw_version(fw)}")
    
    # Test 2: Cached version
    print("\n=== Cached version test ===")
    v1 = get_cached_fw_version()
    v2 = get_cached_fw_version()
    print(f"First call : {v1}")
    print(f"Second call: {v2} (should be cached)")
    
    # Test 3: Windows stub override
    print("\n=== Stub override test ===")
    os.environ["MOXA_FW_STUB"] = "DEADBEEF12345678" + "00" * 24
    fw_stub = Read_FW_Info()
    print(f"Stub version: {format_fw_version(fw_stub)}")  # Should be "22219017" (DE AD BE EF as decimal)
    
    # Test 4: net_Web_file_include mock
    print("\n=== net_Web_file_include mock ===")
    class MockWebsRec:
        def __init__(self): self.out = []
        def write(self, s): self.out.append(s)
        def get(self): return "".join(self.out)
    
    rec = MockWebsRec()
    nw = NetWeb()
    html_out = nw.net_Web_file_include(traversal=1, init=["2"])
    print(html_out)