 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>

 #define MEGABYTE 1024*1024

 int main(int argc, char *argv[])
 {
         void *myblock = NULL;
         int count = 0;
         char ch,*mem;

         if ( argv[1] == NULL ) {
                 printf("usage: blast <memmory space>\n");
                 exit(0);
         }

         int memReq = 0;
         memReq = strtol (argv[1],&mem,10);

         //while (1)
         while (count < memReq)
         {
                 myblock = (void *) malloc(MEGABYTE);
                 if (!myblock) break;
                 memset(myblock,1, MEGABYTE);
                 printf("Currently allocating %d MB\n", ++count);
         }

         do {
                 printf("Hit 'y' to exit...\n");
                 scanf("%c",&ch);
         } while ( ch == 'y' );

         free(myblock);
         exit(0);
 }
