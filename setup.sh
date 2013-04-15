#!/usr/bin/env ksh
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
dothome=${src_dir}/dotfiles

function default {
  cd ${HOME}

  for file in $(cd ${dothome} && ls -d *); do
    dotfile=".${file}"
    source=${dothome}/${file}
    cd ${HOME}
    args='-sfn'
    ln="ln ${args} ${source} ${dotfile}"
    echo $ln
    $ln
  done
}

function orb_setup {
  which git > /dev/null 2>&1
  if [[ $? == 0 ]]; then
    [[ ! -d ${HOME}/src/orb/.git ]] && cd ~/src && git submodule update --init
  else
    echo "git not found. Cannot checkout orb submodule!"
    exit 1
  fi
}

function ruby_setup {
  orb_setup
  [[ -f ~/src/orb/orb.sh ]] && . ~/src/orb/orb.sh
  ~/src/orb/ruby-install --prefix=${orb_ruby_base}/default --rm
  orb use default
  gem install pry pry-doc pry-debugger pry-stack_explorer jist jekyll huffshell\
 teamocil maid
  ~/src/orb/ruby-install --prefix=${orb_ruby_base}/emacs --version=1.9.3-p392\
 -rm
  orb use emacs
  cpanm Perl::Tidy Perl::Critic
}

function perl_setup {
  orb_setup
  [[ -f ~/src/orb/orb.sh ]] && . ~/src/orb/orb.sh
  ~/src/orb/perl-install --prefix=${orb_perl_base}/default --no-test --rm
  ~/src/orb/perl-install --prefix=${orb_perl_base}/emacs --no-test -rm
  opl use emacs
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
