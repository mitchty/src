#!/usr/bin/env ksh
#-*-mode: Shell-script; coding: utf-8;-*-
dir=$(cd $(dirname $0) && echo $(pwd))
file=$(basename $0)

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")

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

function homebrew_sync
{
  homebrew_cache_dir=/Library/Caches/Homebrew
  brew_cache_home=${homebrew_cache_dir}/homebrew
  if [[ ! -d ${brew_cache_home}/.git ]]; then
    (cd ${homebrew_cache_dir} && git clone https://github.com/homebrew/homebrew)
  else
    (cd ${brew_cache_home} && git pull)
  fi
  [[ $? != 0 ]] && echo git clone/pull failed && exit 127

  brew_home=${HOME}/homebrew
  rsync --hard-links --checksum -avz --progress --delete --delete-before ${brew_cache_home}/ ${brew_home}

  PATH=${brew_home}/bin:${PATH}
}

function homebrew_setup {
  homebrew_sync

  # Find out when crap breaks faster...ish
  set -e
  # brew taps
  brew tap mitchty/yuck && brew install yuck

  brew tap homebrew/dupes # need it for better rsync
  brew tap homebrew/science # need it for R
  brew tap homebrew/versions # for perl/maybe llvm34 dunno

  # Make tmux and copy/paste useful
  brew install reattach-to-user-namespace
  # use        ^^^^^ cause copy/paste is useful to have
  brew install tmux --wrap-pbcopy-and-pbpaste
  # make a cocoa emacs, cause normal emacs on osx is shit
  brew install emacs --cocoa --srgb

  # Need to rebuild this prior to python otherwise things break on compile.
  brew install llvm --with-clang --disable-assertions

  # mpv is a nice little player compared to vlc, though now it requires
  # docutils to compile, what the shit, keeping track of HEAD is annoying.
  brew install python
  pip install docutils
  pip install howdoi
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
  brew install asciidoc \
    ag \
    htop \
    openssl \
    pigz \
    xz \
    pv \
    ack \
    git \
    gpg \
    keychain \
    iperf \
    nmap\
    sntop \
    rsync \
    entr \
    iftop \
    tree \
    pbzip2 \
    bzr \
    pngcrush \
    wget \
    ispell \
    perl518\
    python3 \
    pypy \
    mercurial \
    go \
    rust \
    gcc49 \
    r

  # Keeping this separate for the moment, ghc does... interesting things
  # with the c preprocessor, clang no likey.
  #
  # So basically, compile ghc from source with current gcc version.
  # Update its settings file with the full path to said gcc
  # (this matters as even if PATH is right, must be fully qualified)
  #
  # Then finally, install haskell-platform so we get cabal and stuff.
  brew install ghc --build-from-source --cc=gcc-4.9
  brew install cabal-install

  cabal install happy \
    alex \
    ghci-ng \
    ghc-mod \
    structured-haskell-mode \
    sylish-haskell
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
homebrew_sync)
  homebrew_sync
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
