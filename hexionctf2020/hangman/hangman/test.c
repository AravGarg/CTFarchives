#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h> 
#include <unistd.h> 

unsigned int countLinesNum(char *filename)
{
    FILE *file = NULL;
    unsigned int count = 0;
    char c;

    file = fopen(filename, "r");

    if (!file)
    {
        puts("Failed to load list of words...");
        exit(1);
    }

    for (c = getc(file); c != EOF; c = getc(file))
    {
        if (c == '\n')
        {
            count++;
        }
    }

    fclose(file);

    return count;
}

int main()
{
	/*int num=countLinesNum("words.list");
	FILE *file=fopen("words.list","r");
	char *word=malloc(0x20);
	for(int i=0;i<num;i++)
	{
		printf("%s\n",fgets(word,0x20,file));
		printf("%d\n",strlen(word));
	}
	fclose(file);*/
	char *c=1234;
	printf("%d\n",sizeof(c));
	printf("%p\n",c);
	printf("%p\n",&c);
	printf("%d\n",c);
	printf("%p\n",&c[0]);
	printf("%p\n",c[0]);
}

