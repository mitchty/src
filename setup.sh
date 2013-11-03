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
    (cd ${HOME} && git clone https://github.com/mxcl/homebrew)
  fi

  PATH=${brew_home}/bin:${PATH}
  # brew taps
  #
  # mgzip is more for shits cause pigz is better but it compiles still
  # so why not
  set -e
  brew tap mitchty/mgzip && brew install mgzip --HEAD
  brew tap mitchty/entr && brew install entr
  brew tap mitchty/fruitstrap && brew install fruitstrap --HEAD
  brew tap homebrew/dupes # need it for better rsync
  brew tap homebrew/science # need it for R

  # Make tmux and copy/paste useful
  brew install reattach-to-user-namespace
  # use        ^^^^^ cause copy/paste is useful to have
  brew install tmux --wrap-pbcopy-and-pbpaste
  # make a cocoa emacs, cause normal emacs on osx is shit
  brew install emacs --cocoa
  # and all the other crap normal osx is missing.
  # Should gate this to only 10.9 until go 1.2 is out proper
  brew install --devel go

  # normally ^^^ would've been in here
  brew install htop openssl llvm pigz pv ack git iperf nmap sntop postgres rsync iftop python mercurial tree osxutils pbzip2 bzr pngcrush pypy wget ispell gfortran r

  # mpv is a nice little player compared to vlc
  brew tap mpv-player/mpv && brew install mpv --with-bundle --HEAD
}

# ok this is workable if sudoers has:
# %admin ALL=/usr/sbin/installer -verbose -pkg /Volumes/Command\ Line\ Tools\ \(Mountain\ Lion\) -target / NOPASSWD: ALL
#
# Will need to figure out the rest of the installers names so I can enumerate them all
#
# Yeah so need to figure this out for 10.9/10.8/10.7
# It is a bit of a mess to be honest.
# 10.9 has commandline tools, but you can have/use xcode as well.
# bit of a crazy situation
function osx_setup {
  hdiutil mount ~/Downloads/command_line_tools_for_os_x_mountain_lion_xcode_5_developer_preview_6.dmg
  sudo /usr/sbin/installer -verbose -pkg /Volumes/Command*/*.mpkg -target /
  hdiutil detach /Volumes/Command*
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
osx)
  osx_setup
  ;;
home)
  $0 default
  if [[ "$(os_type)" == "osx" ]]; then
    $? && $0 osx_setup && $0 homebrew
  fi
  $? && \
  $0 orb && \
  $0 ruby && \
  $0 perl && \
  $0 python
  ;;
*)
  default
  ;;
esac
