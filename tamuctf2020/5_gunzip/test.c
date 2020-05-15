#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>

int main()
{
	char *gunzip="gunzip\x00";
	char *binsh="/bin/sh\x00";
	char *sh="sh\x00";
	char *minusc="-c\x00";
	execl(binsh,sh,minusc,gunzip,'\x00');
	return 0;
}
