#include <sys/mman.h>
#include<stdio.h>

int main()

{	
	void *p=NULL;
	p=mmap(NULL,0x1024,7,0x22,0,0);
	printf("%p\n",p);
}
