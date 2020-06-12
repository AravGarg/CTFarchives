#include<stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

int main()
{
	int fd;
	fd=open("flag.txt",0,1);
	printf("%d\n",fd);
}
