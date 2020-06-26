#include<unistd.h>
#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int main()
{
	free(malloc(0x10));
	sleep(10);
}
