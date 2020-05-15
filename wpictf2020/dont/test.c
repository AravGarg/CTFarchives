#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<unistd.h>

int main()
{
	char str[]="arav@twitter";
	char *ret=strchr(str,64);
	printf("%s\n",ret);
}

