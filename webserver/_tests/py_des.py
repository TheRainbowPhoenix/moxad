# Pure Python DES implementation to match OpenSSL DES_encrypt1 exactly
# We'll use the standard DES S-boxes and permutations
import hashlib, struct

# ---- Pure Python DES ECB (single key, OpenSSL-compatible) ----
# IP, FP permutation tables, S-boxes, P-box, E-expansion are standard DES

PC1 = [57,49,41,33,25,17,9,1,58,50,42,34,26,18,10,2,59,51,43,35,27,19,
       11,3,60,52,44,36,63,55,47,39,31,23,15,7,62,54,46,38,30,22,14,6,
       61,53,45,37,29,21,13,5,28,20,12,4]
PC2 = [14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,26,8,16,7,27,20,13,2,
       41,52,31,37,47,55,30,40,51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32]
SHIFTS = [1,1,2,2,2,2,2,2,1,2,2,2,2,2,2,1]
IP = [58,50,42,34,26,18,10,2,60,52,44,36,28,20,12,4,62,54,46,38,30,22,14,6,
      64,56,48,40,32,24,16,8,57,49,41,33,25,17,9,1,59,51,43,35,27,19,11,3,
      61,53,45,37,29,21,13,5,63,55,47,39,31,23,15,7]
FP = [40,8,48,16,56,24,64,32,39,7,47,15,55,23,63,31,38,6,46,14,54,22,62,30,
      37,5,45,13,53,21,61,29,36,4,44,12,52,20,60,28,35,3,43,11,51,19,59,27,
      34,2,42,10,50,18,58,26,33,1,41,9,49,17,57,25]
E  = [32,1,2,3,4,5,4,5,6,7,8,9,8,9,10,11,12,13,12,13,14,15,16,17,16,17,18,19,
      20,21,20,21,22,23,24,25,24,25,26,27,28,29,28,29,30,31,32,1]
P  = [16,7,20,21,29,12,28,17,1,15,23,26,5,18,31,10,2,8,24,14,32,27,3,9,19,13,
      30,6,22,11,4,25]
SBOXES = [
  [[14,4,13,1,2,15,11,8,3,10,6,12,5,9,0,7],[0,15,7,4,14,2,13,1,10,6,12,11,9,5,3,8],
   [4,1,14,8,13,6,2,11,15,12,9,7,3,10,5,0],[15,12,8,2,4,9,1,7,5,11,3,14,10,0,6,13]],
  [[15,1,8,14,6,11,3,4,9,7,2,13,12,0,5,10],[3,13,4,7,15,2,8,14,12,0,1,10,6,9,11,5],
   [0,14,7,11,10,4,13,1,5,8,12,6,9,3,2,15],[13,8,10,1,3,15,4,2,11,6,7,12,0,5,14,9]],
  [[10,0,9,14,6,3,15,5,1,13,12,7,11,4,2,8],[13,7,0,9,3,4,6,10,2,8,5,14,12,11,15,1],
   [13,6,4,9,8,15,3,0,11,1,2,12,5,10,14,7],[1,10,13,0,6,9,8,7,4,15,14,3,11,5,2,12]],
  [[7,13,14,3,0,6,9,10,1,2,8,5,11,12,4,15],[13,8,11,5,6,15,0,3,4,7,2,12,1,10,14,9],
   [10,6,9,0,12,11,7,13,15,1,3,14,5,2,8,4],[3,15,0,6,10,1,13,8,9,4,5,11,12,7,2,14]],
  [[2,12,4,1,7,10,11,6,8,5,3,15,13,0,14,9],[14,11,2,12,4,7,13,1,5,0,15,10,3,9,8,6],
   [4,2,1,11,10,13,7,8,15,9,12,5,6,3,0,14],[11,8,12,7,1,14,2,13,6,15,0,9,10,4,5,3]],
  [[12,1,10,15,9,2,6,8,0,13,3,4,14,7,5,11],[10,15,4,2,7,12,9,5,6,1,13,14,0,11,3,8],
   [9,14,15,5,2,8,12,3,7,0,4,10,1,13,11,6],[4,3,2,12,9,5,15,10,11,14,1,7,6,0,8,13]],
  [[4,11,2,14,15,0,8,13,3,12,9,7,5,10,6,1],[13,0,11,7,4,9,1,10,14,3,5,12,2,15,8,6],
   [1,4,11,13,12,3,7,14,10,15,6,8,0,5,9,2],[6,11,13,8,1,4,10,7,9,5,0,15,14,2,3,12]],
  [[13,2,8,4,6,15,11,1,10,9,3,14,5,0,12,7],[1,15,13,8,10,3,7,4,12,5,6,11,0,14,9,2],
   [7,11,4,1,9,12,14,2,0,6,10,13,15,3,5,8],[2,1,14,7,4,10,8,13,15,12,9,0,3,5,6,11]],
]

def _perm(block_bits, table):
    return [block_bits[t-1] for t in table]

def _to_bits(data: bytes) -> list:
    bits = []
    for b in data:
        for i in range(7,-1,-1):
            bits.append((b >> i) & 1)
    return bits

def _from_bits(bits: list) -> bytes:
    result = []
    for i in range(0, len(bits), 8):
        byte = 0
        for j in range(8):
            byte = (byte << 1) | bits[i+j]
        result.append(byte)
    return bytes(result)

def _des_key_schedule(key: bytes):
    kb = _to_bits(key)
    k = _perm(kb, PC1)
    C, D = k[:28], k[28:]
    subkeys = []
    for shift in SHIFTS:
        C = C[shift:] + C[:shift]
        D = D[shift:] + D[:shift]
        subkeys.append(_perm(C+D, PC2))
    return subkeys

def _des_block(block: bytes, subkeys: list, encrypt: bool) -> bytes:
    bb = _to_bits(block)
    perm = _perm(bb, IP)
    L, R = perm[:32], perm[32:]
    ks = subkeys if encrypt else list(reversed(subkeys))
    for sk in ks:
        # Expansion E
        ER = _perm(R, E)
        # XOR with subkey
        xored = [ER[i]^sk[i] for i in range(48)]
        # S-box substitution
        sout = []
        for s in range(8):
            chunk = xored[6*s:6*s+6]
            row = (chunk[0]<<1)|chunk[5]
            col = (chunk[1]<<3)|(chunk[2]<<2)|(chunk[3]<<1)|chunk[4]
            sout += [int(b) for b in f'{SBOXES[s][row][col]:04b}']
        # P permutation
        f = _perm(sout, P)
        newR = [L[i]^f[i] for i in range(32)]
        L, R = R, newR
    return _from_bits(_perm(R+L, FP))

_MOXA_SUBKEYS = _des_key_schedule(b"MOXA2DES")

def des_ecb_encrypt(block8: bytes) -> bytes:
    return _des_block(block8, _MOXA_SUBKEYS, True)

def des_ecb_decrypt(block8: bytes) -> bytes:
    return _des_block(block8, _MOXA_SUBKEYS, False)

def data_encryp(password: str, buf_len: int = 32) -> str:
    buf = bytearray(buf_len)
    pw = password.encode('latin-1')[:buf_len]
    buf[:len(pw)] = pw
    n_blocks = ((buf_len - 1) >> 3) + 1
    enc = bytearray()
    for i in range(n_blocks):
        enc += des_ecb_encrypt(bytes(buf[8*i:8*i+8]))
    hex_str = ''.join(f'{b:02x}' for b in enc[:buf_len])
    md5_raw = hashlib.md5(hex_str.encode('ascii')).digest()
    md5_hex = ''.join(f'{b:02x}' for b in md5_raw)
    return hex_str + md5_hex

def data_deencryp(enc_str: str, buf_len: int = 32) -> str:
    expected = buf_len * 2 + 32
    if len(enc_str) != expected:
        raise ValueError(f"Length: expected {expected} got {len(enc_str)}")
    hex_part = enc_str[:-32]
    md5_part = enc_str[-32:]
    if hashlib.md5(hex_part.encode('ascii')).hexdigest() != md5_part:
        raise ValueError("MD5 MAPPING Error")
    enc_bytes = bytes(int(hex_part[i:i+2],16) for i in range(0,len(hex_part),2))
    n_blocks = ((buf_len - 1) >> 3) + 1
    dec = bytearray()
    for i in range(n_blocks):
        dec += des_ecb_decrypt(enc_bytes[8*i:8*i+8])
    return bytes(dec[:buf_len]).rstrip(b'\x00').decode('latin-1')

print("Round-trip tests:")
for pw in ["moxa","admin","Adm1n@moxa","test123!","Oper1234!","a"*31]:
    enc = data_encryp(pw)
    dec = data_deencryp(enc)
    ok = "OK" if dec == pw else f"FAIL got {dec!r}"
    print(f"  {pw[:20]!r:22} --> {enc[:16]}... {ok}")

# Cross-check with cryptography lib (TripleDES key*3 is same as DES for single key)
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import warnings
with warnings.catch_warnings():
    warnings.simplefilter("ignore")
    c = Cipher(algorithms.TripleDES(b"MOXA2DES"*3), modes.ECB(), backend=default_backend())
    enc2 = c.encryptor()
    ssl_result = enc2.update(b"moxa\x00\x00\x00\x00") + enc2.finalize()

our_result = des_ecb_encrypt(b"moxa\x00\x00\x00\x00")
print(f"\nCross-check DES block 'moxa\\x00*4':")
print(f"  ours:    {our_result.hex()}")
print(f"  openssl: {ssl_result.hex()}")
print(f"  match: {our_result == ssl_result}")