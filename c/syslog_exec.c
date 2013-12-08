#include <syslog.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define command "/usr/bin/clang"

int main(int argc, char *argv[]) {
  setlogmask(LOG_UPTO(LOG_NOTICE));
  openlog(argv[0], LOG_CONS | LOG_PID | LOG_NDELAY, LOG_LOCAL1);
  syslog(LOG_NOTICE, "Arguments passed:");
  for (int i = 1; i < argc; i++)
    syslog(LOG_NOTICE, argv[i]);
  execvp(command, argv);
}
