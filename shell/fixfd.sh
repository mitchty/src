#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

if [[ $2 == "" ]]; then
  echo "Usage: $0 /full/path/existingfile /full/path/newfile [pid1,pid2,pidN]

Examples:
  $0 /var/log/messages /var/log/messages.fixed 42
  $0 /dev/pts/1 /dev/null 12345
"
  exit 0
fi

gdb --version > /dev/null 2>&1
if [[ $? != 0 ]]; then
  echo "No gdb? No dice!"
  exit 1
fi

source_file=$1
dest_file=$2
shift;shift
pids=$*

for pid in ${pids:=$(/sbin/fuser/${source_file} | cut -d ':' -f 2)}; do
  echo "${source_file} in use by pid ${pid}, switching fd to ${dest_file}"
  cmd="call open(\"${dest_file}\", 66, 0666)"
  for fd in $(LANG=C ls -l /proc/${pid}/fd | grep ${source_file} | awk '{print $9;}'); do
    cmd="${cmd}
call dup2(\$1, $fd)"
  done
  cmd="${cmd}
call close(\$1)
detach
quit"
  echo "gdb -q -p ${pid}
${cmd}"
  echo "$cmd" | gdb -q -p ${pid} > /dev/null 2>&1
  echo "sleep(3) for next pid (if any)"
  sleep 3
done
