from pwn import *
libc=ELF('./libc-2.27.so')
print(hex(libc.symbols["puts"]))
