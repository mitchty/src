#!/usr/bin/env ksh
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
dothome=${src_dir}/dotfiles
cd ${HOME}

if [[ $1 != '' ]]; then
  mkdir -p ~/site/$1
  git clone https://mygoddamnwebsite.net/git/site-$1.git ~/site/$1
  if [[ $? == 0 ]]; then
    (cd ~/site && ln -sFf $1 local)
  else
    echo "Something went wrong cloning site named $1"
  fi
else
  if [[ -e ~/site/local ]]; then
    echo "local site set to:"
    ls -dl ~/site/local
  else
    echo "no local site setup"
  fi
fi
