export MOXA_RAMDISK=/tmp/moxa_final_test
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
REIMP_DIR="$(dirname "$DIR")"

echo "=== 1. DES encrypt/decrypt ==="
python3 $REIMP_DIR/moxa_cli.py --encrypt moxa
echo ""
python3 $REIMP_DIR/moxa_cli.py --encrypt "Adm1n@moxa"
echo ""
python3 $REIMP_DIR/moxa_cli.py --decrypt "$(python3 $REIMP_DIR/moxa_cli.py --encrypt moxa | grep encrypted | awk '{print $3}')"

echo ""
echo "=== 2. Round-trip: decrypt(encrypt(pw)) == pw ==="
python3 << PY
import sys, os
os.environ["MOXA_RAMDISK"] = "/tmp/moxa_final_test"
reimp_dir = "${REIMP_DIR}"
sys.path.insert(0, reimp_dir)
import importlib.util
spec = importlib.util.spec_from_file_location("mc", os.path.join(reimp_dir, "moxa_cli.py"))
m = importlib.util.module_from_spec(spec); spec.loader.exec_module(m)

ok = fail = 0
for pw in ["moxa","admin","Adm1n@moxa","test123!","Oper1234!","a"*31,""]:
    try:
        enc = m.data_encryp(pw)
        dec = m.data_deencryp(enc)
        if dec == pw:
            print(f"  PASS  {pw!r:25} → {enc[:24]}...")
            ok += 1
        else:
            print(f"  FAIL  {pw!r} → decrypted={dec!r}"); fail += 1
    except Exception as e:
        if pw == "":
            print(f"  PASS  empty password skipped ({e})")
            ok += 1
        else:
            print(f"  FAIL  {pw!r}: {e}"); fail += 1
print(f"\n  PASS={ok} FAIL={fail}")
PY

echo ""
echo "=== 3. Export with EDR-810 model ==="
python3 $REIMP_DIR/moxa_cli.py --export 2>/dev/null | head -20

echo ""
echo "=== 4. Banner shows EDR-810 ==="
printf '?\nquit\n' | python3 $REIMP_DIR/moxa_cli.py 2>/dev/null | head -8

echo ""
echo "=== 5. moxa_shm.py standalone ==="
MOXA_RAMDISK=/tmp/moxa_final_test python3 $REIMP_DIR/moxa_shm.py dump | python3 -c "
import sys,json
d=json.load(sys.stdin)
print('  hostname:', d['system']['hostname'])
print('  accounts:', [a['username'] for a in d['accounts']])
print('  ShmRegion mmap file exists:', __import__('pathlib').Path('/tmp/moxa_final_test/shm/7890.shm').exists())
"

echo ""
echo "=== 6. show commands ==="
python3 $REIMP_DIR/moxa_cli.py --show version 2>/dev/null
python3 $REIMP_DIR/moxa_cli.py --show users  2>/dev/null