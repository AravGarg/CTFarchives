from pwn import *
libc=ELF('/media/sf_kalishared/livectfs/RCTF2020/note/libc-2.29.so')
envi={"LD_PRELOAD":"/media/sf_kalishared/livectfs/RCTF2020/note/libc-2.29.so"}
target=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.29.so','./test'],env=envi)
context.terminal=["tmux","split","-h"]
gdb.attach(target)
target.interactive()

