from pwn import *
libc=ELF('/media/sf_kalishared/tools/The_Night-master/libcs/libc6_2.27-3ubuntu1_amd64.so')
envi={"LD_PRELOAD":"/media/sf_kalishared/tools/The_Night-master/libcs/libc6_2.27-3ubuntu1_amd64.so"}
target=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.27.so','./test'],env=envi)
context.terminal=["tmux","split","-h"]
gdb.attach(target)
target.interactive()

