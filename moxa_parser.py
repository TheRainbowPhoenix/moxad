#!/usr/bin/env python3
import argparse
import sys
import os

def sub_C9DC(a1):
    if a1 == 5:
        print("partial CLI_Cfg_Up")
        return 0
    elif a1 == 0:
        print("restore to dedfaul setting")
        return 1
    else:
        print("CLI_Cfg_Up")
        return a1

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

    # Add dummy unparsed args to not fail on unknown args
    args, unknown = parser.parse_known_args()

    # The actual C code prints a header:
    # printf("%-20s%-20s  %-06s %-15s%-16s\r\n", "", v30, v28, v27, "");
    # puts("--------------------------------------------------------------------------------\r");
    print(f"{'':<20}{'MOXA EDR-810 Series':<20}  {'':<6} {'':<15}{'':<16}\r")
    print("--------------------------------------------------------------------------------\r")

    if args.c is not None:
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
            ret = 0
            print(f"ret = {ret}")
            if args.x:
                sub_C9DC(ret)
            sys.exit(ret)

    if args.g:
        print("Configure File is exporting now, please wait.\r")
        print("passwd =  \n ")
        print(" ret = 0 \n")
        sys.exit(0)

    if not args.z:
        sys.exit(0)

    if args.z:
        if args.s is not None:
            ret = sub_C9DC(args.s)
            sys.exit(ret)

        if args.c is not None:
            sys.exit(0)

    sys.exit(0)

if __name__ == '__main__':
    main()
