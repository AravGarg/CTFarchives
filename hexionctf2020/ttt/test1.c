#include<stdio.h>
#include<string.h>
#include<stdlib.h>

int main(int argc,char **argv)
{
	char *name;
	name=malloc(0x10);
	scanf("%s",name);
	printf("%s",name);
}
