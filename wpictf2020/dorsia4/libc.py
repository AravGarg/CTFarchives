from pwn import *
libc=ELF('/media/sf_kalishared/tools/The_Night-master/libcs/libc6_2.27-3ubuntu1_amd64.so')
print(hex(libc.symbols["printf"]))
print(hex(libc.symbols["__isoc99_scanf"]))


