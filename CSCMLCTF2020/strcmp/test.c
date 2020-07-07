#include<stdlib.h>
#include<stdio.h>
#include<string.h>
#include<unistd.h>

int main()
{
	FILE *fp=fopen("./abc.txt","r");
	printf("%d\n",sizeof(_IO_FILE));
}
