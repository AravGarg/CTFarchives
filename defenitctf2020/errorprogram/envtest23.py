from pwn import *
envi={"LD_PRELOAD":"/media/sf_kalishared/livectfs/pwn2winCTF2020/tukro/libc-2.23.so"}
target=process(['/media/sf_kalishared/tools/itl-master/linkers/x64/ld-2.23.so','./test2'],env=envi)
context.terminal=["tmux","split","-h"]
gdb.attach(target)
target.interactive()
