from flask import Flask, request, send_from_directory, render_template, make_response, redirect
import os
import re
import sys

app = Flask(__name__)
# Point directly to the root files
WEB_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../root/magicP/WebServer/web'))

def is_safe_path(base_dir, req_path):
    # Ensure path traversal is blocked
    abs_base = os.path.abspath(base_dir)
    abs_req = os.path.abspath(os.path.join(base_dir, req_path.lstrip('/')))
    return os.path.commonpath([abs_base, abs_req]) == abs_base

def process_asp(filepath):
    try:
        with open(filepath, 'r', encoding='latin-1') as f:
            content = f.read()
    except Exception as e:
        return f"Error reading file: {e}"

    # 1. Includes
    content = re.sub(r'<% net_Web_file_include\(\); %>', '<script src="moxa_common.js"></script>', content)

    # 2. Values
    # In C: MODEL_EDR_G903 is likely a define, let's just return a number or match what js expects
    content = re.sub(r'<% net_Web_GetModel_WriteValue\(\); %>', '1', content) # EDR_G903 or something
    content = re.sub(r'<% net_Web_GetNO_WAN_WriteValue\(\); %>', '2', content)
    content = re.sub(r'<% net_Web_GetNO_MAC_PORTS_WriteValue\(\); %>', '10', content)

    # login script
    content = re.sub(r'<%LoginCheckAdminPasswd\(\);%>', 'var showWarning = 0;', content)

    # 3. Other common tags
    content = re.sub(r'<%net_websMainifance\(\);%>', '', content)
    content = re.sub(r'<%net_websMainfun\(\);%>', '{}', content)
    content = re.sub(r'<%net_websMainevent\(\);%>', '', content)
    content = re.sub(r'<%net_websIpset\(\);%>', '', content)
    content = re.sub(r'<%net_websifanceName\(\);%>', '', content)
    content = re.sub(r'<%net_webPortLink\(\);%>', '', content)
    content = re.sub(r'<%net_websBridgeifance\(\);%>', '', content)
    content = re.sub(r"<%net_Web_show_value\('SRV_VCONF'\);%>", "var SRV_VCONF = [];", content)
    content = re.sub(r"<%net_Web_show_value\('SRV_IP_CLIENT'\);%>", "var SRV_IP_CLIENT = [{vid:'0'}];", content)

    # 4. <!--#include file="lan_data"-->
    content = re.sub(r'<!--#include file="([^"]+)"-->', r'/* Included: \1 */', content)

    # Specific mocks that expect numbers (e.g. radius_enable)
    content = re.sub(r'<% get_raudius_enable\(\); %>', '0', content)

    # Catch any remaining ASP tags
    content = re.sub(r'<%[^>]+%>', '/* Backend Call Stubbed */', content)

    return content

@app.route('/')
def index():
    return redirect('/home.asp')

@app.route('/goform/logout', methods=['GET', 'POST'])
def handle_logout():
    return redirect('/Login.asp')

@app.route('/<path:filename>', methods=['GET', 'POST'])
def serve_file(filename):
    # Handle Login Post
    if request.method == 'POST' and filename == 'Login.asp':
        return redirect('/home.asp')

    # Mitigate Path Traversal
    if not is_safe_path(WEB_DIR, filename):
        return "Bad Request", 400

    filepath = os.path.abspath(os.path.join(WEB_DIR, filename.lstrip('/')))

    if not os.path.exists(filepath):
        return "Not Found", 404

    if filename.endswith('.asp'):
        content = process_asp(filepath)
        response = make_response(content)
        response.headers['Content-Type'] = 'text/html'
        return response
    else:
        return send_from_directory(WEB_DIR, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
