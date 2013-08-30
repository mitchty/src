#!/usr/bin/env ksh
#-*-mode: Shell-script; coding: utf-8;-*-
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
local_files=${local_files:=yes}
dothome=${src_dir}/dotfiles
dotlocal=site/local/dotfiles

function default {
  cd ${HOME}

  dotdirs=(${dothome})

  [[ ${local_files} == 'yes' ]] && dotdirs+=(${dotlocal})

  for adir in ${dotdirs[*]}; do
    if [[ -d $adir ]]; then
      for file in $(cd ${adir} && ls -d *); do
        dotfile=".${file}"
        source=${adir}/${file}
        cd ${HOME}
        args='-sfn'
        ln="ln ${args} ${source} ${dotfile}"
        echo $ln
        $ln
      done
    fi
  done
}

function orb_setup {
  orb_source=${HOME}/.orb/orb.sh
  [[ -f ${orb_source} ]] && . ${orb_source}
}

function ruby_setup {
  orb_setup

  # According to ... someone on the ruby core team the openssl
  # library that ships with 10.8 (maybe 7?) is bad and it refuses to
  # compile openssl, so gem fails to do anything useful with https
  # connections, so on osx use the brew installed openssl library
  if [[ "$(os_type)" == "osx" ]]; then
    export CONFIGURE_OPTS="--with-openssl-dir=`brew --prefix openssl`"
  fi

  orb install --prefix=${orb_ruby_base}/default --rm
  orb use default
  gem install pry pry-doc pry-debugger pry-stack_explorer jist jekyll huffshell\
 teamocil maid
  orb install  --prefix=${orb_ruby_base}/emacs --version=1.9.3-p392\
 -rm
  orb use emacs
}

function perl_setup {
  orb_setup
  opl install --prefix=${orb_perl_base}/default --no-test --rm
  opl use emacs
  cpanm Perl::Tidy Perl::Critic
  opl install --prefix=${orb_perl_base}/emacs --no-test -rm
  opl use emacs
  cpanm Perl::Tidy Perl::Critic
}

function homebrew {
  echo "nyi"
}

case $1 in
orb)
  orb_setup
  ;;
ruby)
  ruby_setup
  ;;
perl)
  perl_setup
  ;;
home)
  $$ default
  $$ orb
  $$ ruby
  $$ perl
  ;;
home-osx)
  $$ default
  $$ homebrew
  $$ orb
  $$ ruby
  $$ perl
  ;;
*)
  default
  ;;
esac
