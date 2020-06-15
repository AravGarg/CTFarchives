#include<unistd.h>
#include<string.h>
#include<stdio.h>
#include<stdlib.h>

int main(int argc,char **argv)
{
	char *p0,*p1;
	p0=malloc(0x38);
	p1=malloc(0x38);
	strncpy(p0,"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",0x38);
	sleep(5);
	free(p0);
	sleep(5);			
	strncpy(p1,"BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB",0x38);
	sleep(5);
	free(p1);
	sleep(10);			
}
