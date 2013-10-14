/*
I don't remember why I needed this, but it comes in useful to demonstrate
what happens when memory is exhausted.

Less useful on linux with default memory policies, as its not actually used.
Just malloc()ing.
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MEBIBYTE 1024*1024

int main(int argc, char *argv[]) {
  void *myblock = NULL;
  int count = 0;
  char ch,*mem;

  if ( argv[1] == NULL ) {
    printf("usage: swapblast <memory size to use in mebibytes>\n");
    exit(0);
  }

  int memReq = 0;
  memReq = strtol (argv[1],&mem,10);

  while (count < memReq) {
    myblock = (void *) malloc(MEBIBYTE);
    if (!myblock) break;
    memset(myblock,1, MEBIBYTE);
    printf("Allocating %d MB\n", ++count);
  }

  do {
    printf("Hit 'ctrl-c' to exit...\n");
    scanf("%c",&ch);
  } while ( 0 );

  free(myblock);
  exit(0);
}
