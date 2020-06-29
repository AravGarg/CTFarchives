#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>

int main()

{
	unsigned long *p0,*p1,*p2,*p3;
	p0=malloc(0x500);
	p1=malloc(0x10);
	p2=malloc(0x500);
	p3=malloc(0x10);
	free(p0);
	free(p2);
	malloc(0x500);
	malloc(0x500);
}
