#!/usr/bin/env ksh
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
dothome=${src_dir}/dotfiles
cd ${HOME}

function clone
{
  name=$*
  site_dir=${HOME}/site/${name}
  source_url="https://mygoddamnwebsite.net/git/site-${name}.git"
  if [[ ! -d ${site_dir} ]]; then
    mkdir -p ${site_dir}
    (cd ${HOME} && git clone ${source_url} ${site_dir})
    if [[ $? != 0 ]]; then
      echo "Something went wrong cloning ${site} to ${site_dir}"
      exit 1
    fi
  else
    echo "${site_dir} already exists, cowardly exiting"
    exit 1
  fi
}

function link
{
  name=$*
  site_dir=${HOME}/site/${name}
  if [[ -d ${site_dir} ]]; then
    echo "linking ${site_dir} to ~/site/local"
    (cd ${HOME}/site && ln -sFf ${name} local)
  else
    echo "site directory ${site_dir} doesn't exist, cowardly exiting"
    exit 1
  fi
}

case $1 in
clone)
  clone $2
  ;;
link)
  link $2
  ;;
*)
  if [[ $1 == '' ]]; then
    echo "Run me with a site name to clone and link that site, or"
    echo "with clone NAME to clone that site or"
    echo "with link NAME to link that site"
  else
    clone $1
    link $1
  fi
  ;;
esac
