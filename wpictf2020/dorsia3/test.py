from pwn import *
libc=ELF('/media/sf_kalishared/tools/The_Night-master/libcs/libc6_2.27-3ubuntu1_i386.so')
print(hex(libc.symbols["system"]))
print(hex(libc.search("/bin/sh\x00").next()))

