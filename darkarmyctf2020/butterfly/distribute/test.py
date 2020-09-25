from pwn import *
libc=ELF('./butterfly').libc
print(hex(libc.search("/bin/sh\x00").next()))
