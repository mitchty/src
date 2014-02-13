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
    (
      cd ${HOME} &&
      git clone https://github.com/Homebrew/homebrew &&
      # Needed so I can get --with-static until its merged into mainline
      # homebrew, maybe if at this point.
      cd ${HOME}/homebrew &&
      git remote add mitchty https://github.com/mitchty/homebrew &&
      git merge --no-edit mitchty/master
    )
  fi

  PATH=${brew_home}/bin:${PATH}

  # Find out when crap breaks faster...ish
  set -e
  # brew taps
  #
  # mgzip is more for shits cause pigz is better but it compiles still
  # so why not keep it around. Compressing things on a 25k still remains
  # a fun memory.
  brew tap mitchty/mgzip && brew install mgzip --HEAD
  brew tap mitchty/fruitstrap && brew install fruitstrap --HEAD
  brew tap homebrew/dupes # need it for better rsync
  brew tap homebrew/science # need it for R
  brew tap homebrew/versions # for perl/maybe llvm34 dunno

  # Make tmux and copy/paste useful
  brew install reattach-to-user-namespace
  # use        ^^^^^ cause copy/paste is useful to have
  brew install tmux --wrap-pbcopy-and-pbpaste
  # make a cocoa emacs, cause normal emacs on osx is shit
  brew install emacs --cocoa --srgb

  # So I can have static glib archive as its not yet in mainline homebrew for
  # over a month, still waiting on the merge request.
  # Merge request is https://github.com/Homebrew/homebrew/pull/25505
  brew install glib --with-static

  # Need to rebuild this prior to python otherwise things break on compile.
  brew install llvm34 --with-clang --HEAD

  # mpv is a nice little player compared to vlc, though now it requires
  # docutils to compile, what the shit, keeping track of HEAD is annoying.
  brew install python
  pip install --upgrade setuptools
  pip install --upgrade pip
  pip install docutils;
  brew tap mpv-player/mpv &&
  brew install --HEAD libass-ct &&
  brew install mpv --with-bundle

  # Link mpv/emacs.app into ~/Applications
  home_app_dir=${HOME}/Applications
  [[ ! -d ${home_app_dir} ]] && mkdir -p ${home_app_dir}
  brew linkapps --local

  # Remove the stupid python .app links, this was simpler when I could
  # not have mpv require docutils as I could just leave it at the end.
  for crap in "Build Applet.app" "IDLE.app" "Python Launcher.app"; do
    if [[ -e ~/Applications/"${crap}" ]]; then
      stupid_app="${HOME}/Applications/${crap}"
      echo rm ${stupid_app}
      rm "${stupid_app}"
    fi
  done

  # just install vanilla postgres no language support needed really.
  brew install postgres --no-perl --no-tcl --without-python

  # install the "rest", aka make osx a bit more useful/unixy to use.
  brew install ag htop openssl pigz xz pv ack git iperf nmap sntop rsync \
    entr iftop tree pbzip2 bzr pngcrush wget ispell perl518 python3 pypy \
    mercurial go rust
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
  echo "osx_setup needs to be fixed for mavericks and crap you lazy turd."
#  hdiutil mount ~/Downloads/command_line_tools_for_os_x_mountain_lion_xcode_5_developer_preview_6.dmg
#  sudo /usr/sbin/installer -verbose -pkg /Volumes/Command*/*.mpkg -target /
#  hdiutil detach /Volumes/Command*
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
links)
  default
  ;;
*)
  default
  ;;
esac
