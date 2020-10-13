from pwn import *
for i in range(0xffffffff):
	print(i)
	v1=i
	v2=i-0x1010101
	v1=0xffffffff-v1
	v1=v1&v2
	if(v1&0x80808080!=0):
		print("Win ="+str(i))
		break
