#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void prepare_death() {
    gid_t gid = getegid();
    setresgid(gid, gid, gid);
    setbuf(stdout, NULL);
}

void print_flag() {
    FILE* f = fopen("flag.txt", "r");
    char str[256];
    fgets(str, 256, f);
    printf("%s\n", str);
}

int main() {
    prepare_death();
    char comm[256];
    char* names[10];
    char* secret = malloc(32);
    strcpy(secret, "REDACTED\n");
    for (int i = 0; i < 10; i++)
        names[i] = 0;
    while (1) {
        printf("Enter the index of the name in the range [0,9]\n");
        fgets(comm, 200, stdin);
        int ind = atoi(comm);
        if (ind < 0 || ind >= 10)
            continue;
        printf("Enter the length of the next name or -1 to delete that name or 0 to print that name\n");
        fgets(comm, 200, stdin);
        int n = atoi(comm);
        if (n > 0) {
            if (names[ind] != 0) {
                free(names[ind]);
                names[ind] = 0;
            }
            names[ind] = calloc(n, 1);
            fgets(names[ind], n + 2, stdin);
            if (strcmp(names[ind], secret) == 0) {
                print_flag();
                return 0;
            }
        } else if (n == -1) {
            if (names[ind] != 0) {
                free(names[ind]);
                names[ind] = 0;
            }
        } else if (n == 0) {
            printf("%s\n", names[ind]);
        }
    }
    return 0;
}
