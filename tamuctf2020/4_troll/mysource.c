#include<stdio.h>
#include<stdlib.h>
#include<time.h>

int main()
{
	long long int r,t,n,shifted,shifted2;
	srand(time(0));
	char *name="Arav";
	printf("%s\n",name);
	for(int i=0;i<=99;i++)
	{
	u_int32_t eax=rand();
	//printf("%d\n",eax);
	int64_t rdx=eax;
	//printf("%ld\n",rdx);
	rdx=rdx*351843721;
	//printf("%ld\n",rdx);
	rdx=rdx>>32;
	//printf("%ld\n",rdx);
	int32_t edx=rdx;
	//printf("%d\n",edx);
	int32_t ecx=edx;
	//printf("%d\n",ecx);
	ecx=ecx>>13;
	//printf("%d\n",ecx);
	int64_t temp=eax;
	edx=temp>>32;
	//printf("%d\n",edx);
	ecx=ecx-edx;
	//printf("%d\n",ecx);
	edx=ecx;
	//printf("%d\n",edx);
	edx=edx*100000;
	//printf("%d\n",edx);
	eax=eax-edx;
	//printf("%d\n",eax);
	edx=eax;
	//printf("%d\n",edx);
	eax=edx+1;
	printf("%d\n",eax);}
}

