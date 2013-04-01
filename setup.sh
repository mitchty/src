#!/usr/bin/env ksh
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
dothome=${src_dir}/dotfiles
cd ${HOME}

for file in $(cd ${dothome} && ls -d *); do
  dotfile=".${file}"
  source=${dothome}/${file}
  cd ${HOME}
  args='-s'
  if [[ -d ${source} ]]; then
    args=${args}F
  else
    args=${args}f
  fi
  ln="ln ${args} ${source} ${dotfile}"
  echo $ln
  $ln
done
