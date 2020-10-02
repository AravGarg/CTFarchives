from pwn import *
libc=ELF('./libc-2.27.so')
print(hex(libc.symbols["__malloc_hook"]))
print(hex(libc.symbols["__printf_function_table"]))
