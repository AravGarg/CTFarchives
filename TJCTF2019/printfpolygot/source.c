#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>

void view_team();
void check_date();
void newsletter();
void report_bug(); // vô dụng

bool date_enabled = false;

int main() {
   gid_t gid = getegid();
   setresgid(gid, gid, gid);
   setbuf(stdout, NULL);
   
   printf("Welcome to the brand new Security Consultants Inc. portal!\n");
   char action = 0;
   char line[128];
   while (action != 'x') {
      printf("What would you like to do?\n");
      printf("1.) View the Team!\n");
      printf("2.) Check the date.\n");
      printf("3.) Sign up for our newsletter!\n");
      printf("4.) Report a bug.\n");
      printf("x.) Exit.\n");
      fget  s(line, sizeof line, stdin);
      action = line[0];
      if (action == '1') {
         view_team();
      } else if (action == '2') {
         check_date();
      } else if (action == '3') {
         newsletter();
      } else if (action == '4') {
         report_bug();
      } else if (action != 'x') {
         printf("Sorry, I didn't recognize that.\n");
      }
      printf("\n");
   }
}

void view_team() {
   printf("Here's the team:\n");
   printf("Neil\n");
   printf("Daniel\n");
   printf("Evan (AFK)\n");
   printf("Omkar (AFK)\n\n");
   
   printf("Who's your favorite? ");
   
   char favorite[128];
   fgets(favorite, sizeof favorite, stdin);
   if (strcmp(favorite, "Neil\n") == 0) { //có thể tràn favorite do hàm copy, mà chưa biết để làm gì
      printf("Hey, thanks!\n");
   } else {
      printf("Shame. Can't say I'm a fan of %s", favorite);
   }
}

// apparently calling system() isn't safe? I disabled it so we
// should be fine now.
void check_date() {
   printf("Here's the current date:\n");
   if (date_enabled) {
      system("/bin/date");
   } else {
      printf("Sorry, date has been temporarily disabled by admin!\n");
   }
}

void newsletter() {
   printf("Thanks for signing up for our newsletter!\n");
   printf("Please enter your email address below:\n");
   
   char email[256];
   fgets(email, sizeof email, stdin);
   printf("I have your email as:\n");
   printf(email);
   printf("Is this correct? [Y/n] ");
   char confirm[128];
   fgets(confirm, sizeof confirm, stdin);
   if (confirm[0] == 'Y' || confirm[0] == 'y' || confirm[0] == '\n') {
      printf("Great! I have your information down as:\n");
      printf("Name: Evan Shi\n");
      printf("Email: ");
      printf(email);
   } else {
      printf("Oops! Please enter it again for us.\n");
   }
   
   int segfault = *(int*)0;
   // TODO: finish this method, for now just segfault,
   // we don't want anybody to abuse this
}

void report_bug() {
   printf("Thank you for reporting this critical bug.\n");
   printf("Unfortunately, our dedicated Bug-Squasher, Evan Shi, is on indefinite hiatus.\n");
   printf("Hopefully, he'll be able to squash this bug soon.\n");
}
