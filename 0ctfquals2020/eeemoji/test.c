#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>
#include<wchar.h>

int main()
{
	wchar_t *wc=malloc(0x4);
	wc=fgetws(wc,4,stdin);
	printf("%s\n",wc);
	printf("%ls\n",wc);
}
