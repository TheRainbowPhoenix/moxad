import re
import os
import sys
import shutil

def convert_asp_to_jinja(src_dir, dst_dir):
    os.makedirs(dst_dir, exist_ok=True)

    for root, dirs, files in os.walk(src_dir):
        rel_path = os.path.relpath(root, src_dir)
        dst_root = os.path.join(dst_dir, rel_path)
        os.makedirs(dst_root, exist_ok=True)

        for file in files:
            src_file = os.path.join(root, file)
            dst_file = os.path.join(dst_root, file)
            
            if file.endswith(('.asp', '.js', '.html', '.css', '.xml')):
                try:
                    with open(src_file, 'r', encoding='latin-1') as f:
                        content = f.read()

                    def replacer(match):
                        inner = match.group(1).strip()
                        # specific conversions
                        # comments
                        if inner.startswith('--') or inner.startswith('//'):
                            return '{# ' + inner + ' #}'
                        
                        # remove trailing semicolon if present
                        if inner.endswith(';'):
                            inner = inner[:-1].strip()
                        
                        if inner.startswith('='):
                            return '{{ ' + inner[1:].strip() + ' }}'
                        else:
                            # if it's a function call, we need to pass it
                            if 'net_Web_show_value' in inner:
                                # We need to execute the macro or function call
                                # Jinja doesn't execute function calls natively like that if they don't return anything
                                # unless we echo them.
                                return '{{ ' + inner + ' | safe }}'
                            
                            return '{{ ' + inner + ' | safe }}'

                    # 1. Includes
                    content = re.sub(r'<!--#include file="([^"]+)"-->', r'{% include "\1" ignore missing %}', content)

                    # 2. Simple expressions/function calls
                    content = re.sub(r'<%([\s\S]*?)%>', replacer, content)

                    # 3. Form action replacements
                    content = re.sub(r'(?i)action\s*=\s*["\']/goform/([^"\']+)["\']', r'action="/goform/\1"', content)

                    # 4. In init.asp there is location.replace("loginHistory.asp") which breaks out of normal flow if not handled
                    if file == "init.asp":
                        content = content.replace('location.replace("loginHistory.asp");', 'location.replace("/home.asp");')

                    with open(dst_file, 'w', encoding='utf-8') as f:
                        f.write(content)
                except Exception as e:
                    print(f"Error processing {src_file}: {e}")
                    
            else:
                # copy static files
                shutil.copy2(src_file, dst_file)

if __name__ == "__main__":
    convert_asp_to_jinja(os.path.join(os.path.dirname(__file__), '../root/magicP/WebServer/web'), os.path.join(os.path.dirname(__file__), 'web_jinja'))
