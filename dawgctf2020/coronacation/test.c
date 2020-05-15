#include<stdio.h>
#include<string.h>

int main()
{
	int n;
	unsigned long int p=0x11111111;
	printf("%p%n\n",p,&n);
	printf("%d\n",n);
}
