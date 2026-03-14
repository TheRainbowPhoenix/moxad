from flask import Flask, request, send_from_directory, render_template, make_response, redirect
import os
import sys
import json
import logging
from syscommon import make_data_provider
from moxa_shm import get_shm
from moxa_show_value import net_Web_show_value
from moxa_stubs import DEMO_SYS_PROV
from webs_netweb import NetWeb, WebsRec

logger = logging.getLogger(__name__)

WEB_DIR = os.path.join(os.path.dirname(__file__), 'web_jinja')
app = Flask(__name__, template_folder=WEB_DIR, static_folder=WEB_DIR)

nw = NetWeb()

def is_safe_path(base_dir, req_path):
    abs_base = os.path.abspath(base_dir)
    abs_req = os.path.abspath(os.path.join(base_dir, req_path.lstrip('/')))
    return os.path.commonpath([abs_base, abs_req]) == abs_base

def get_context():
    shm = get_shm()
    provider = DEMO_SYS_PROV.get # make_data_provider()
    state = shm.state
    # provide some common functions and variables
    return {
        'net_Web_file_include': lambda: nw.net_Web_file_include(0, ["2"]),
        'net_Web_GetModel_WriteValue': lambda: '0',
        'net_Web_GetNO_WAN_WriteValue': lambda: '2',
        'net_Web_GetModel_DVMRP_WriteValue': lambda: '0',
        'net_Web_GetNO_MAC_PORTS_WriteValue': lambda: '10',
        'LoginCheckAdminPasswd': lambda: 'var showWarning = 0;',
        'net_Web_show_value': lambda x: f'var {x} = [];' if x == 'SRV_VCONF' else f"var {x} = [{{vid:'0'}}];",
        'Lsyscommon_GetAuthority_WriteValue': lambda: '1',
        'Get_Auto_Logout_Time_WriteValue': lambda: '300',
        'get_raudius_enable': lambda: '0',
        'net_Web_csrf_Token': lambda: '""',
        'net_Web_GetMode_WriteValue': lambda: '0',
        'net_webPortDesc': lambda: '',
        'net_Web_Get_SYS_PORTS': lambda: '10',
        'net_Web_IFS_WriteInteger_Have_All_Value': lambda: '0',
        'net_Web_GetModel_VLAN_WriteValue': lambda: '1',
        'net_Web_GetModel_RADIUS_WriteValue': lambda: '1',
        'net_Web_GetMode_VPN_WriteValue': lambda: '1',
        'net_Web_GetMode_L2TP_WriteValue': lambda: '1',
        'net_Web_GetModelName_WriteValue': lambda: '"EDR-810"', # net_Web_GetModelName_WriteValue -> SRV_MODEL_NAME
        'net_Web_Confirm_WriteValue': lambda: '',
        'net_Web_Filter_IFS_WriteValue': lambda: '',
        'net_Web_Get_Radius_Enable': lambda: '0',
        'net_Web_login_init_info': lambda: 'admin',
        'net_Web_GetVERSION_HW_WriteValue': lambda: '"1"',
        'net_webledset1': lambda: '',
        'net_webledset2': lambda: '',
        'net_Web_show_value': lambda x: net_Web_show_value(x, provider),
        'net_websMainifance': lambda: nw.net_websMainifance(),
        'net_websMainfun': lambda: nw.net_websMainfun(),
        'net_websMainevent': lambda: nw.net_websMainevent(),
        'net_websIpset': lambda: nw.net_websIpset(),
        'net_websifanceName': lambda: nw.net_websifanceName(),
        'net_webPortLink': lambda: nw.net_webPortLink(),
        'net_websBridgeifance': lambda: nw.net_websBridgeifance(),
        'net_websEthStatus': lambda: nw.net_websEthStatus(),
        
        'net_webShowRedundantRingDefault': lambda: nw.net_webShowRedundantRingDefault(),
        'net_Web_Get_SYS_TRUNKS': lambda: nw.net_Web_Get_SYS_TRUNKS(),
        'net_WebMacTable': lambda: nw.net_WebMacTable(),
        'net_Web_Get_SYS_PORTS': lambda: nw.net_Web_Get_SYS_PORTS(),
        'net_webPortDesc': lambda: nw.net_webPortDesc(),
        'net_Web_Get_IVL': lambda: nw.net_Web_Get_IVL(),
        'net_webRTType': lambda: nw.net_webRTType(),
        'net_WebARPTable': lambda: nw.net_WebARPTable(),
        'net_webCACERUP': lambda: nw.net_webCACERUP(),
        'net_websDnsList': lambda: nw.net_websDnsList(),
        'net_websBridgeStatus': lambda: nw.net_websBridgeStatus(),
        'net_webledset1': lambda: nw.net_webledset1(),
        'net_Web_GetNO_WAN_WriteValue': lambda: nw.net_Web_GetNO_WAN_WriteValue(),
        'net_Web_GetNO_MAC_PORTS_WriteValue': lambda: nw.net_Web_GetNO_MAC_PORTS_WriteValue(),
        'net_Web_IPT_NAT_WriteValue': lambda: nw.net_Web_IPT_NAT_WriteValue(),
        'net_Web_IPT_WANInfo_WriteValue': lambda: nw.net_Web_IPT_WANInfo_WriteValue(),
        'net_Web_Confirm_WriteValue': lambda: nw.net_Web_Confirm_WriteValue(),
        'net_Web_getConfig_Redundant_and_Fastbootup_WriteValue': lambda: nw.net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(),
        'net_webTr2ShowStatus': lambda: nw.net_webTr2ShowStatus(),
        'net_Web_Port_Status_WriteValue': lambda: nw.net_Web_Port_Status_WriteValue(),
        'net_Web_Root_Bridge_WriteValue': lambda: nw.net_Web_Root_Bridge_WriteValue(),
        'net_Web_getConfig_Redundant_and_Fastbootup_WriteValue': lambda: nw.net_Web_getConfig_Redundant_and_Fastbootup_WriteValue(),
    }

@app.route('/')
def index():
    return redirect('/home.asp')

@app.route('/goform/<path:goform_path>', methods=['GET', 'POST'])
def handle_goform(goform_path):
    if goform_path == 'logout':
        return redirect('/Login.asp')
    
    # Generic goform handler
    print(f"GOFORM called: {goform_path} with args: {request.args} and form: {request.form}")
    
    # A lot of ASP pages expect a JSON response or simply a redirect
    # We can just redirect back to the referer to prevent hanging
    referer = request.headers.get("Referer")
    if referer:
        return redirect(referer)
    return redirect('/home.asp')

@app.route('/xml/net_led_xml')
def xml_led_status():
    """Return LED status XML."""
    try:
        xml_content = nw.net_led_xml()
        return app.response_class(
            response=xml_content,
            status=200,
            mimetype='application/xml'
        )
    except Exception as e:
        logger.error(f"net_led_xml error: {e}")
        return "<error>Internal server error</error>", 500

@app.route('/xml/GetPanelStatus')
def xml_panel_status():
    """Return panel status XML."""
    try:
        xml_content = nw.get_panel_status_xml()
        return app.response_class(
            response=xml_content,
            status=200,
            mimetype='application/xml'
        )
    except Exception as e:
        logger.error(f"GetPanelStatus error: {e}")
        return "<error>Internal server error</error>", 500

@app.route('/<path:filename>', methods=['GET', 'POST'])
def serve_file(filename):
    if request.method == 'POST' and filename == 'Login.asp':
        return redirect('/init.asp')

    if not is_safe_path(app.template_folder, filename):
        return "Bad Request", 400

    filepath = os.path.abspath(os.path.join(app.template_folder, filename.lstrip('/')))

    if not os.path.exists(filepath):
        return "Not Found", 404

    if filename.endswith('.asp'):
        try:
            # We want Jinja to catch undefined variables instead of crashing, but let's just ignore them.
            class MagicDict(dict):
                def __missing__(self, key):
                    return f'/* Missing: {key} */'
            context = MagicDict(**get_context())
            # For simplicity we render from string because some macros might be complex. Or we can just use render_template.
            rendered = render_template(filename, **context)
            response = make_response(rendered)
            response.headers['Content-Type'] = 'text/html'
            return response
        except Exception as e:
            print(f"Jinja error in {filename}: {e}")
            return f"Error rendering file: {e}", 500
    else:
        return send_from_directory(app.static_folder, filename)

if __name__ == '__main__':
    app.jinja_env.globals.update(get_context())
    # Allow any missing variable to resolve to an empty string to avoid rendering errors
    from jinja2 import DebugUndefined
    class SilentUndefined(DebugUndefined):
        def __str__(self):
            return f'/* Missing: {self._undefined_name} */'
        def __call__(self, *args, **kwargs):
            return f'/* Missing Call: {self._undefined_name} */'
    app.jinja_env.undefined = SilentUndefined
    app.run(host='0.0.0.0', port=8080, debug=True)
