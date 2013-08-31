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
    export CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl)"
  fi

  orb install --prefix=${orb_ruby_base}/default --rm
  orb use default
  gem install pry pry-doc pry-debugger pry-stack_explorer jist jekyll huffshell teamocil maid httparty nokogiri rainbow
  if [[ "$(os_type)" == "osx" ]]; then
    gem install cocoapods
  fi
  orb install --prefix=${orb_ruby_base}/emacs -rm
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

function python_setup {
  orb_setup
  opy install --prefix=${orb_python_base}/default --rm
}

function homebrew_setup {
  brew_home=${HOME}/homebrew
  if [[ ! -d ${brew_home} ]]; then
    echo "cloning homebrew"
    (cd ${HOME} && git clone https://github.com/mxcl/homebrew)
  fi

  PATH=${brew_home}/bin:${PATH}
  # brew taps
  brew tap railwaycat/emacsmacport
  brew tap mitchty/mgzip
  brew tap mitchty/entr
  brew tap mitchty/fruitstrap
  brew tap mpv-player/mpv

  brew install reattach-to-user-namespace
  brew install tmux --wrap-pbcopy-and-pbpaste
  brew install emacs --cocoa
  brew install go htop openssl llvm cocoapods pigz pv ack git iperf nmap ntop postgres fruitstrap rsync iftop hg tree osxutils entr mgzip pbzip2 bzr

}

case $1 in
homebrew)
  homebrew_setup
  ;;
orb)
  orb_setup
  ;;
ruby)
  ruby_setup
  ;;
perl)
  perl_setup
  ;;
python)
  python_setup
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
