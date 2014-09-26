#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
#
# Cause... lazy
#
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

src_dir=$(echo ${dir} | sed -e "s|${HOME}\/||g")
local_files=${local_files:=yes}
dothome=${src_dir}/dotfiles
dotlocal=${HOME}/site-local/dotfiles
base=${HOME}/Developer/github.com/mitchty
brew_home=/usr/local

function default {
  if [[ ! -d ${base} ]]; then
    mkdir -p ${base}
    git clone https://github.com/mitchty/src ${base}/src
  else
    cd ${base}/src
    git pull
  fi
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

  rsync --hard-links --checksum -avz --progress --delete --delete-before ${brew_cache_home}/ ${brew_home}

  PATH=${brew_home}/bin:${PATH}
}

function homebrew_setup {
  homebrew_sync

  # Find out when crap breaks faster...ish
  set -e

  export HOMEBREW_BUILD_FROM_SOURCE=yesplease

  brew install reattach-to-user-namespace
  brew install tmux --wrap-pbcopy-and-pbpaste
  brew install mobile-shell

  # So I can get git/gpg up faster, also copy the netrc credential helper
  # so I can use gpg to decrypt ~/.netrc.gpg
  brew install gpg git

  gitver=$(brew info git 2>&1 | head -n 1 | awk '{print $3}' | sed -e 's/,//g')
  gitinstdir=${brew_home}/Cellar/git/${gitver}
  gitcontribnetrc=${gitinstdir}/share/git-core/contrib/credential/netrc/git-credential-netrc
gitlibexecnetrc=${gitinstdir}/libexec/git-core/git-credential-netrc
  ln -sf ${gitcontribnetrc} ${gitlibexecnetrc}

  brew install htop

  # My brew taps.
  brew tap mitchty/yuck
  brew tap mitchty/clang-scan-view
  brew tap mitchty/clang-scan-build
  brew tap mitchty/perl520

  # More up to date rsync
  brew tap homebrew/dupes

  # R can be useful
  brew tap homebrew/science

  # For more up to date perl/llvm at times
  brew tap homebrew/versions

  # This video player is rather spartan, and nice
  brew tap mpv-player/mpv

  # make a cocoa emacs, cause normal emacs on osx is shit
  brew install emacs --cocoa --srgb

  # Need to rebuild this prior to python otherwise things break on compile.
  brew install llvm --with-clang --disable-assertions

  # Install curl with openssl and aysnc dns resolution.
  # Force links so we can use this curl
  brew install curl --with-openssl --with-ares

# need to validate this really needs to happen.
#  brew link curl --force

#  PATH=${HOME}/homebrew/bin:${PATH}
#  export PATH

  # mpv is a nice little player compared to vlc, though now it requires
  # docutils to compile, what the shit, keeping track of HEAD is annoying.
  brew install readline
  brew install sqlite
  brew install gdbm
  brew install python --universal --framework
  brew install docbook
  brew install asciidoc
  brew install brew-pip

# For the love of god, python stuff is annoying
#  pip install docutils
#  pip install howdoi

  # Install this derp ffmpeg video player.
  brew install mpv --with-bundle

  # just install vanilla postgres no language support needed really.
  brew install postgres --no-perl --no-tcl --without-python

  # Setup ruby junk
  brew install ruby
  gem install --no-ri --no-rdoc pry maid jist

  # perl crap
  brew install perl520
  export PATH=$(brew --prefix perl520):${PATH}
  curl -kL http://cpanmin.us | $(brew --prefix perl520)/bin/perl - App::cpanminus
  $(brew --prefix perl520)/bin/cpanm App::rainbarf Perl::Tidy Perl::Critic

  # install the "rest", aka make osx a bit more useful/unixy to use.
  brew install \
    youtube-dl \
    irssi \
    yuck \
    clang-scan-view \
    clang-scan-build \
    ag \
    openssl \
    pigz \
    xz \
    pixz \
    pbzip2 \
    pv \
    keychain \
    iperf \
    nmap\
    sntop \
    rsync \
    entr \
    iftop \
    tree \
    pngcrush \
    wget \
    ispell \
    python3 \
    mercurial \
    go \
    gcc \
    ack \
    ncurses
}

function cabal_init
{
  cabal_cmd="cabal install -j"
  if [[ ${GLOBAL_CABAL} != '' ]]; then
    dotcabal=${HOME}/.cabal
    dotghc=${HOME}/.ghc
    [[ -d ${dotcabal} ]] && rm -fr ${dotcabal}
    [[ -d ${dotghc} ]] && rm -fr ${dotghc}
    cabal_cmd="${cabal_cmd} --global"
  fi

  cabal update

  echo "remote-repo: stackage:http://www.stackage.org/stackage/93a8bcca1e05c6bdc30ff391ecad800e688bd268" >> ~/.cabal/config

  cabal update

  cabal install cabal-install

  set +e
  ${cabal_cmd} \
    happy \
    alex \
    c2hs \
    hi \
    hlint \
    hspec \
    cgrep \
    stylish-haskell \
    hasktags \
    shake \
    hoogle \
    cabal-meta \
    pandoc \

  ${cabal_cmd} install ghc-mod
}

function cabal_backup
{
  dotcabal=${HOME}/.cabal
  dotghc=${HOME}/.ghc
  epoch=$(date +%s)
  backup_file=${HOME}/cabal-backup-${epoch}.txz
  (cd ${HOME} &&  tar cf - ${dotcabal} ${dotghc} | pixz -9 -o ${backup_file})
}

case $1 in
cabal)
  cabal_init
  ;;
cabal-backup)
  cabal_backup
  ;;
homebrew)
  homebrew_setup
  ;;
homebrew_sync)
  homebrew_sync
  ;;
osx)
  osx_setup
  ;;
home)
  $0 default
  if [[ "$(os_type)" == "osx" ]]; then
    $? && $0 osx_setup && $0 homebrew
  fi
  exit $?
  ;;
*)
  default
  ;;
esac
