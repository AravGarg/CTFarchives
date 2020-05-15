#include <sys/types.h>
#include <sys/wait.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

char *gunzip="gunzip\x00";
char *binsh="/bin/sh\x00";
char *sh="sh\x00";
char *buf;
char *buf2;
char *minusc="-c\x00";
void subprocess(char *,int *,int *);
void gets_fd(char *,int);

int main()
{
	int *pipe1wfd,*pipe2rfd,nbytesread;
	subprocess(gunzip,pipe1wfd,pipe2rfd);
	memset(buf,'\x00',0x200);
	nbytesread=read(0,buf,0x200);
	write(pipe1wfd,buf,nbytesread);
	close(pipe1wfd);
	memset(buf2,'\x00',0x200);
	gets_fd(buf2,pipe2rfd);
	fwrite(buf2,1,0x200,______)			//incomplete		
	return;
}

void subprocess(char *gunzip,int *pipe1wfd,int *pipe2rfd)
{
	int *pipe1fd,*pipe2fd,cid;
	if(pipe(pipe1fd)==-1)			// create pipe1
	{
		perror("pipe");
		exit(EXIT_FAILURE);
	}
	if(pipe(pipe2fd)==-1)			// create pipe2
	{
		perror("pipe");
		exit(EXIT_FAILURE);
	}
	cid=fork();
	if(cid<0)				// create child		
	{
		perror("fork");
		exit(EXIT_FAILURE);
	}
	if(cid==0)				//child process can only read from stdin through pipe1 and write to stdout through pipe2
	{
		close(*(pipe1fd+1));		// close write fd of pipe1
		dup2(*pipe1fd,0);		// read fd of pipe1 is made stdin
		close(*pipe2fd);		// close read fd of pipe2
		dup2(*(pipe2fd+1),0);		// write fd of pipe2 is made stdout
		execl(binsh,sh,minusc,gunzip,0);// execute gunzip
	}
	else					//parent process
	{
		*pipe1wfd=pipe1fd[1];		//1st arguement is assigned write fd of pipe1
		*pipe2rfd=pipe2fd[0];		//2nd arguement is assinged read fd of pipe2
		close(*(pipe2fd+1));		//close write fd of pipe2 
	}
}

void gets_fd(char *buf2,int pipe2rfd)
{
	int dupstdin;
	dupstdin=dup(0);
	dup2(pipe2rfd,0);
	gets(buf2);				/* BUFFER OVERFLOW????*/
	dup2(dupstdin,0);
	return;
}
