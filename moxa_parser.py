#!/usr/bin/env python3
import argparse
import sys
import os
import sysexport

class MoxaParser:
    def __init__(self, is_admin=False):
        self.is_admin = is_admin
        self.mode = "exec"
        self.hostname = "MOXA"

    def get_prompt(self):
        if self.mode == "exec":
            return f"{self.hostname}# "
        elif self.mode == "config":
            return f"{self.hostname}(config)# "
        return f"{self.hostname}# "

    def cmdloop(self):
        while True:
            try:
                line = input(self.get_prompt())
            except EOFError:
                print()
                break

            line = line.strip()
            if not line:
                continue

            parts = line.split()
            cmd = parts[0]

            if cmd == "?":
                self.do_help()
            elif cmd in ("quit", "exit"):
                if self.mode == "config":
                    self.mode = "exec"
                else:
                    break
            elif cmd == "reload":
                print("Proceed with reload to factory default? [Y/n]")
            elif cmd == "terminal":
                pass
            elif cmd == "copy":
                pass
            elif cmd == "save":
                pass
            elif cmd == "ping":
                pass
            elif cmd == "clear":
                pass
            elif cmd == "show":
                self.do_show(parts[1:])
            elif cmd == "configure":
                self.mode = "config"
            else:
                print("Parse error")

    def do_show(self, args):
        if not args:
            print("Incomplete command")
        elif args[0] == "running-config":
            print(sysexport.generate_export_config())
        else:
            print("Parse error")

    def do_help(self):
        if self.is_admin:
            print("Login by Admin Account")
        else:
            print("Login by User Account")

        print("Command Description")
        print("quit Exit Command Line Interface")
        print("exit Exit Command Line Interface")
        print("reload Halt and Perform a Cold Restart")
        print("terminal Configure Terminal Page Length")
        print("copy Import or Export File")
        print("save Save Running Configuration to Flash")
        print("ping Send Echo Messages")
        print("clear Clear Information")
        print("show Show System Information")
        print("configure Enter Configuration Mode")

def sub_C9DC(a1):
    if a1 == 5:
        # net_Web_SendData_And_Recv_Confirm 5
        print("partial CLI_Cfg_Up")
        return 0
    elif a1 == 0:
        # net_Web_SendData_And_Recv_Confirm 3
        print("restore to dedfaul setting")
        return 1
    else:
        # net_Web_SendData_And_Recv_Confirm 1
        print("CLI_Cfg_Up")
        return a1

def sub_CAC8():
    # Make_CliConfigurationFile
    print("Configure File is exporting now, please wait.\r")

    try:
        with open("/mnt/ramdisk/MOXA_CFG.ini", "w") as f:
            f.write(sysexport.generate_export_config())
    except:
        pass

    print("passwd =  \n ")
    return 0

def sub_D138(filename, a3):
    # a3 = 0 or 1
    # Check if file has header '! ---------- '
    # Print lines where parse error
    print(f"Reading file {filename}")
    if not os.path.exists(filename):
        print("Invalid file")
        return 1

    # We will simulate the checks
    with open(filename, 'r') as f:
        lines = f.readlines()
        if not lines or not lines[0].startswith("! ----------"):
            print("Invalid file\r\n")
            return 1
    return 0

def main():
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument('-a', action='store_true')
    parser.add_argument('-c', type=str)
    parser.add_argument('-d', type=str)
    parser.add_argument('-g', action='store_true')
    parser.add_argument('-i', action='store_true')
    parser.add_argument('-l', type=str)
    parser.add_argument('-p', action='store_true')
    parser.add_argument('-s', type=int)
    parser.add_argument('-x', action='store_true')
    parser.add_argument('-z', action='store_true')

    args, unknown = parser.parse_known_args()

    logname = os.getenv("LOGNAME", "admin") # default to admin
    is_admin = False
    if logname == "admin":
        is_admin = True
        print("\nPlease change default password in consideration of higher security level.\n")

    print(f"{'':<20}{'MOXA EDR-810 Series':<20}  {'':<6} {'':<15}{'':<16}\r")
    print("--------------------------------------------------------------------------------\r")

    if args.c is not None and not args.i and not args.z:
        print(f"config_file = {args.c}")
        if args.c == "exit":
            sys.exit(0)

    if args.g:
        print("Make CLI Config")

    if args.p:
        print(f"pid = {os.getpid()}")

    if args.x:
        print("Request from magic168")

    if args.i:
        if args.c is not None:
            # We mock the dos2unix call that happens here
            os.system(f"dos2unix -u {args.c} >/dev/null 2>&1")
            ret = sub_D138(args.c, 0)
            print(f"ret = {ret}")
            if args.x:
                sub_C9DC(ret)
            sys.exit(ret)

    if args.g:
        ret = sub_CAC8()
        print(f" ret = {ret} \n")
        sys.exit(ret)

    if not args.z:
        if len(sys.argv) == 1 or args.a or args.l:
            cli = MoxaParser(is_admin=is_admin)
            try:
                cli.cmdloop()
            except KeyboardInterrupt:
                print()
            sys.exit(0)
        else:
            sys.exit(0)

    if args.z:
        if args.s is not None:
            ret = sub_C9DC(args.s)
            sys.exit(ret)

        if args.c is not None:
            os.system(f"dos2unix -u {args.c} >/dev/null 2>&1")
            ret = sub_D138(args.c, 1)
            sys.exit(ret)

    sys.exit(0)

if __name__ == '__main__':
    main()
