# Test the DataEncryp logic using cryptography lib
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend
import hashlib, struct

KEY = b"MOXA2DES"  # 8-byte DES key

def des_ecb_encrypt(block8: bytes, key: bytes = KEY) -> bytes:
    """ECB single-block DES encrypt using OpenSSL-compatible schedule."""
    c = Cipher(algorithms.TripleDES(key * 3), modes.ECB(), backend=default_backend())
    enc = c.encryptor()
    return enc.update(block8) + enc.finalize()

def des_ecb_decrypt(block8: bytes, key: bytes = KEY) -> bytes:
    c = Cipher(algorithms.TripleDES(key * 3), modes.ECB(), backend=default_backend())
    dec = c.decryptor()
    return dec.update(block8) + dec.finalize()

def data_encryp(password: str, buf_len: int = 32) -> str:
    """
    Faithful port of DataEncryp(char *a1, int a2):
      1. Pad password to buf_len bytes, DES-ECB encrypt in 8-byte chunks
      2. Hex-encode the encrypted bytes into 'hex_str'
      3. MD5(hex_str) -> 16 bytes -> append as 32 hex chars
      Result is (buf_len*2) + 32 hex chars total
    """
    # Step 1: copy password into fixed-size buffer (padded with zeros)
    buf = bytearray(buf_len)
    pw_bytes = password.encode('latin-1')[:buf_len]
    buf[:len(pw_bytes)] = pw_bytes
    
    # Step 2: DES-ECB encrypt in 8-byte chunks  
    #   C code: for i=0; (a2-1)>>3 + 1 blocks; encrypt buf[8*i..8*i+7]
    n_blocks = ((buf_len - 1) >> 3) + 1
    enc = bytearray()
    for i in range(n_blocks):
        block = bytes(buf[8*i : 8*i+8])
        enc += des_ecb_encrypt(block)
    
    # Step 3: hex-encode encrypted bytes
    hex_str = ''.join(f'{b:02x}' for b in enc[:buf_len])
    
    # Step 4: MD5(hex_str) -> 32 more hex chars
    md5_raw = hashlib.md5(hex_str.encode('ascii')).digest()
    md5_hex = ''.join(f'{b:02x}' for b in md5_raw)
    
    return hex_str + md5_hex

def data_deencryp(enc_str: str, buf_len: int = 32) -> str:
    """
    Faithful port of DatadeEncryp(char *a1, size_t a2, int a3):
      1. Split enc_str into hex_part (len-32) and md5_part (last 32)
      2. Verify MD5(hex_part) == md5_part
      3. Hex-decode hex_part back to encrypted bytes
      4. DES-ECB decrypt to recover password
    """
    expected_len = buf_len * 2 + 32
    if len(enc_str) != expected_len:
        raise ValueError(f"Length error: expected {expected_len}, got {len(enc_str)}")
    
    hex_part = enc_str[:-32]
    md5_part = enc_str[-32:]
    
    # Verify MD5
    md5_check = hashlib.md5(hex_part.encode('ascii')).hexdigest()
    if md5_check != md5_part:
        raise ValueError("MD5 MAPPING Error")
    
    # Hex-decode
    enc_bytes = bytes(int(hex_part[i:i+2], 16) for i in range(0, len(hex_part), 2))
    
    # DES-ECB decrypt
    n_blocks = ((buf_len - 1) >> 3) + 1
    dec = bytearray()
    for i in range(n_blocks):
        block = enc_bytes[8*i : 8*i+8]
        dec += des_ecb_decrypt(block)
    
    # Trim to null terminator
    result = bytes(dec[:buf_len]).rstrip(b'\x00').decode('latin-1')
    return result

# Test round-trip
for pw in ["moxa", "admin", "Adm1n@moxa", "test123!", "Oper1234!"]:
    enc = data_encryp(pw)
    dec = data_deencryp(enc)
    status = "OK" if dec == pw else f"FAIL (got {dec!r})"
    print(f"  {pw!r:20} --> {enc[:16]}...  decrypt={status}")

print(f"\nEncrypted 'moxa' (32 bytes buf) full = {data_encryp('moxa')}")