#include<stdio.h>
#include<stdlib.h>
#include<unistd.h>
#include<string.h>
#include<sys/types.h>

#define _GNU_SOURCE

void view_team()
{	
	
}

int main()
{
	char option_buf[0x80];
	gid_t rgid;
	char option;
	
	rgid=getegid();
	setresgid(rgid,rgid,rgid);
	setbuf(stdout,NULL);
	puts("Welcome to the brand new Security Consultants Inc. portal!");
	option="\x00";
	
	while(option!="x")
		{
			puts("What would you like to do?");
			puts("1.) View the Team!");
			puts("2.) Check the date.");
			puts("3.) Sign up for our newsletter!");
			puts("4.) Report a bug.");
			puts("x.) Exit.");
			fgets(option_buf,0x80,stdin);
			option=option_buf[0];
			if(option=="1")
				{
					view_team();
				}
			else if(option=="2")
				{
					check_date();
				}
			else if(option=="3")
				{
					newsletter();
				}
			else if(option=="4")
				{
					report_bug();
				}
			else if(option=="x")
				{
					;
				}
			else 
				{
					puts("Sorry, I didn't recognize that.")
				}
			putchar(0xa);
		}
return 0;	
}
