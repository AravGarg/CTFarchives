#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>

int main(int argc,char **argv)
{
	char **array=malloc(9*sizeof(void *));
	for(int i=1;i<10;i++)
	{
		*(array+i-1)=(char *)malloc(i*16);
	}
	for(int i=1;i<10;i++)
	{
		free(*(array+i-1));
		sleep(5);
	}
}
