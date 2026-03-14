import os
import json

# 1. Route the RAMDISK to a local folder for this demo before importing moxa_shm
# This ensures we don't write to /tmp and can easily inspect the files!
os.environ["MOXA_RAMDISK"] = "./demo_ramdisk"

from moxa_shm import get_shm, ShmRegion, KEY_SHM_SYSCFG

def hex_dump(data: bytes, prefix=""):
    """Helper to print a nice hex/ASCII dump of raw bytes."""
    hex_str = data.hex()
    # Format hex string with spaces every 2 characters for readability
    spaced_hex = ' '.join(hex_str[i:i+2] for i in range(0, len(hex_str), 2))
    
    # Create an ASCII representation, replacing non-printable chars with '.'
    ascii_repr = ''.join(chr(b) if 32 <= b <= 126 else '.' for b in data)
    
    print(f"{prefix}Hex:   {spaced_hex}")
    print(f"{prefix}ASCII: {ascii_repr}")

def main():
    print(f"=== Moxa Shared Memory (SHM) Demo ===")
    print(f"RAMDISK directory set to: {os.path.abspath(os.environ['MOXA_RAMDISK'])}\n")

    # ---------------------------------------------------------
    # STEP 1: Initialize
    # ---------------------------------------------------------
    print("[1] Initializing MoxaSHM (High-level bus)...")
    shm = get_shm()
    shm.reset() # Force factory defaults to ensure a clean slate

    # ---------------------------------------------------------
    # STEP 2: Read Initial Raw Memory
    # ---------------------------------------------------------
    print("\n[2] Reading initial raw SHM (Region 7890) right after factory reset:")
    with ShmRegion(KEY_SHM_SYSCFG) as mem:
        mode = mem.read_u32(0)
        hostname = mem.read_str(4, 41)
        print(f"  -> Parsed device_mode (offset 0): {mode}")
        print(f"  -> Parsed hostname    (offset 4): '{hostname}'")
        
        print("  Raw bytes (Offsets 0-24):")
        hex_dump(mem.read(0, 24), prefix="    ")

    # ---------------------------------------------------------
    # STEP 3: Exhaustive Modification of High-Level State
    # ---------------------------------------------------------
    print("\n[3] Exhaustively modifying EVERY value in the high-level state...")
    s = shm.state
    
    # System modifications
    s["system"]["hostname"] = "HACKED-EDR-810"
    s["system"]["location"] = "Under the desk"
    s["system"]["description"] = "Test description"
    s["system"]["contact"] = "admin@example.com"
    s["system"]["fw_version"] = "9.99"
    s["system"]["hw_version"] = "2.0"
    s["system"]["serial"] = "HACKEDSN123456"
    s["system"]["mac"] = "00:11:22:33:44:55"
    s["system"]["uptime_sec"] = 9999
    s["system"]["device_mode"] = 1
    s["system"]["login_mode"] = "radius"
    s["system"]["banner"] = "WARNING: UNAUTHORIZED ACCESS PROHIBITED"
    s["system"]["fail_banner"] = "ACCESS DENIED"
    s["system"]["mac_aging"] = 600
    s["system"]["lldp_enable"] = 0
    s["system"]["lldp_timer"] = 60
    s["system"]["fast_bootup"] = 1
    s["system"]["auto_backup"] = 1
    s["system"]["mtu"] = 9000

    # Accounts
    s["accounts"][0]["username"] = "superadmin"
    s["accounts"][0]["password"] = "supermoxa"
    s["accounts"][0]["role"] = 1
    s["accounts"][0]["is_admin"] = 0
    s["accounts"].append({"username": "guest", "password": "guestpass", "role": 2, "is_admin": 0})

    # Network
    s["network"]["lan_ip"] = "10.0.0.1"
    s["network"]["lan_mask"] = "255.0.0.0"
    s["network"]["wan_ip"] = "1.1.1.1"
    s["network"]["wan_mask"] = "255.255.255.255"
    s["network"]["wan_gw"] = "1.1.1.254"
    s["network"]["dns1"] = "1.1.1.1"
    s["network"]["dns2"] = "8.8.4.4"
    s["network"]["wan_conn_type"] = 1
    
    # Other dicts & lists
    s["interfaces"] = {"eth1": {"status": "up"}}
    s["static_routes"] = [{"dest": "0.0.0.0", "mask": "0.0.0.0", "gw": "10.0.0.254"}]
    s["logging"]["buffered"] = 256000
    s["logging"]["servers"] = ["192.168.1.100"]
    s["ntp"]["servers"] = ["pool.ntp.org"]
    s["ntp"]["refresh"] = 7200
    s["clock"]["timezone_index"] = 42
    s["clock"]["dst_start"] = "Mar"
    s["clock"]["dst_end"] = "Nov"
    s["clock"]["dst_offset"] = 60
    s["snmp"]["version"] = "v3"
    s["snmp"]["community1"] = "custom_pub"
    s["snmp"]["access1"] = 0
    s["snmp"]["community2"] = "custom_priv"
    s["snmp"]["access2"] = 1
    s["ssh"]["enabled"] = 0
    s["ssh"]["port"] = 2222
    s["ssh"]["idle_timeout"] = 300
    s["web"]["enabled"] = 0
    s["web"]["port"] = 8080
    s["web"]["https_enabled"] = 0
    s["web"]["https_port"] = 8443
    s["web"]["auto_logout"] = 10
    s["web"]["max_users"] = 10
    s["telnet"]["enabled"] = 0
    s["telnet"]["port"] = 2323
    s["telnet"]["max_users"] = 2
    s["login_lockout"]["enabled"] = 1
    s["login_lockout"]["max_fail"] = 3
    s["login_lockout"]["lockout_time"] = 600
    s["password_policy"]["min_len"] = 8
    s["password_policy"]["enabled"] = 1
    s["password_policy"]["require_digit"] = 1
    s["password_policy"]["require_upper_lower"] = 1
    s["password_policy"]["require_special"] = 1
    s["redundancy"]["mode"] = "mstp"
    s["spanning_tree"]["enabled"] = 1
    s["spanning_tree"]["priority"] = 4096
    s["vlan"]["mode"] = "port-based"
    s["vlan"]["vlans"] = [{"id": 10, "name": "MGMT"}]
    s["upgrade_status"] = 1
    s["timezone_index"] = 42
    
    print("    Saving state... (Writing to state.json & syncing to .shm mmap)")
    shm.save() 

    # ---------------------------------------------------------
    # STEP 4: Verify the JSON Persistence (High-Level Check)
    # ---------------------------------------------------------
    print("\n[4] Verifying the 'state.json' saved the nested attributes correctly:")
    state_file = os.path.join(os.environ["MOXA_RAMDISK"], "shm", "state.json")
    with open(state_file, "r") as f:
        saved_state = json.load(f)
    print(f"  -> File size: {os.path.getsize(state_file)} bytes")
    print(f"  -> ssh.port read from disk    == {saved_state['ssh']['port']} (expected 2222)")
    print(f"  -> web.max_users read from disk == {saved_state['web']['max_users']} (expected 10)")
    print(f"  -> Added 2nd account user == '{saved_state['accounts'][1]['username']}' (expected guest)")


    # ---------------------------------------------------------
    # STEP 5: Verify the Binary File Changed (Low-Level Check)
    # ---------------------------------------------------------
    print("\n[5] Verifying the underlying .shm binary file synchronized key fields:")
    with ShmRegion(KEY_SHM_SYSCFG) as mem:
        new_mode = mem.read_u32(0)
        new_hostname = mem.read_str(4, 41)
        new_location = mem.read_str(45, 81)
        new_contact = mem.read_str(126, 37)
        
        print(f"  -> New device_mode (offset 0): {new_mode}")
        print(f"  -> New hostname    (offset 4): '{new_hostname}'")
        print(f"  -> New location    (offset 45): '{new_location}'")
        print(f"  -> New contact     (offset 126): '{new_contact}'")
        
        print("  Raw bytes (Offsets 0-64):")
        hex_dump(mem.read(0, 64), prefix="    ")

    # ---------------------------------------------------------
    # STEP 6: Direct Low-Level Write
    # ---------------------------------------------------------
    print("\n[6] Writing data directly to SHM using low-level API (bypassing JSON)...")
    with ShmRegion(KEY_SHM_SYSCFG) as mem:
        mem.write_str(4, "LOW-LEVEL-HACKED-NAME", 41)
        print("    Wrote 'LOW-LEVEL-HACKED-NAME' directly to offset 4.")

    # Read it back in a new context manager to prove it stuck
    with ShmRegion(KEY_SHM_SYSCFG) as mem:
        hacked_hostname = mem.read_str(4, 41)
        print(f"    Read back hostname: '{hacked_hostname}'")

    print(f"\nDemo finished! Check the '{os.environ['MOXA_RAMDISK']}/shm' folder.")
    print("You will find 'state.json' and '7890.shm' with your exhaustively injected data.")

if __name__ == "__main__":
    main()