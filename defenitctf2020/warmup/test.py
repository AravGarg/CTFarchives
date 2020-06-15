from pwn import *
libc=ELF('/media/sf_kalishared/livectfs/pwn2winCTF2020/tukro/libc-2.23.so')
print(libc.symbols["__libc_start_main"])
print(libc.symbols["__free_hook"])
print(libc.symbols["__malloc_hook"])
