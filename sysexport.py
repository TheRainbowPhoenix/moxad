def generate_export_config():
    # Represents the config generation behavior in libsysexport.so.1.c
    config = [
        "! ---------- MOXA-EDR810-Export-Start",
        "hostname MOXA-EDR810",
        "username admin privilege 15 secret 5 $1$mock$aaaaaaaaaaaaaaaa",
        "interface port1",
        " description Uplink",
        " no shutdown",
        "interface port2",
        " description Plant-Net",
        " no shutdown",
        "ip route 0.0.0.0/0 192.168.127.1",
        "logging buffered 128000",
        "end",
    ]
    return "\n".join(config)
