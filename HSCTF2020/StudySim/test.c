#include<stdio.h>
#include<unistd.h>
#include<stdlib.h>
#include<string.h>

int main()
{
	free((char *)(malloc(0xf0)));
	sleep(10);
}
