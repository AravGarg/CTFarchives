#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include<unistd.h>

int main()
{
	char buf[20];
	read(0,buf,20);
	write(1,buf,20);
}
