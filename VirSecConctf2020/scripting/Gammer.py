from pwn import *
target=remote('jh2i.com',50012)

print(target.recv())
for i in range(0,0xff):

    payload=i
    target.sendline(p8(payload))
    print(str(payload))
    try:
        target.recvuntil("WRONG!")


