#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<time.h>
#include<unistd.h>
#define _XOPEN_SOURCE

int main(int argc,char **argv){
	struct tm tm={0};
	char *s = strptime((char *)argv[1],"%Y-%m-%d %H:%M:%S", &tm);
	printf("%ld\n",mktime(&tm));
	return 0;	
}
