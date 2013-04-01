#!/usr/sbin/dtrace -qs

#pragma D option quiet

syscall::exec*:return
/$1 == uid/
{
  printf("%Y %s RC(%d) zone(%s)\n", walltimestamp, curpsinfo->pr_psargs, arg1, zonename);
}
