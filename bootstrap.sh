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
base_home=${base}/src
brew_home=/usr/local
iam_user=$(id -u -nr)
iam_group=$(id -g -nr)
brew_bin=${brew_home}/bin
brew_itself=${brew_bin}/brew

function default {
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "Making sure that xcode/git runs"
    echo sudo xcodebuild -license accept
    sudo xcodebuild -license accept
  fi

  if [[ ! -d ${base_src} ]]; then
    echo mkdir -p ${base}
    mkdir -p ${base}
    echo git clone https://github.com/mitchty/src ${base}/src
    git clone https://github.com/mitchty/src ${base}/src
  else
    echo cd ${base}/src
    cd ${base}/src
    echo git pull
    git pull
  fi

  echo cd ${HOME}
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

function homebrew_setup {
  # Find out when crap breaks faster...ish
  set -e

  echo "Making sure that xcode/git runs"
  echo sudo xcodebuild -license accept
  sudo xcodebuild -license accept

  if [[ ! -d ${brew_home} ]]; then
    echo sudo mkdir -p ${brew_home}
    sudo mkdir -p ${brew_home}
  fi

  if [[ ! -d ${brew_bin} ]]; then
    echo sudo mkdir -p ${brew_bin}
    sudo mkdir -p ${brew_bin}
  fi

  echo sudo chown ${iam_user}:${iam_group} ${brew_bin} ${brew_home}
  sudo chown ${iam_user}:${iam_group} ${brew_bin} ${brew_home}

  ruby -e \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  export HOMEBREW_BUILD_FROM_SOURCE=yesplease
  export PATH=${brew_bin}:${PATH}

  echo brew install ansible
  brew install ansible
}

function cabal_init
{
  cabal_cmd="cabal install -j"
  if [[ ${GLOBAL_CABAL} != '' ]]; then
    dotcabal=${HOME}/.cabal
    dotghc=${HOME}/.ghc
    dotcabalosx=${HOME}/Library/Haskell
    if [[ -d ${dotcabal} ]]; then
      echo rm -fr ${dotcabal}
      rm -fr ${dotcabal}
    fi
    if [[ -d ${dotghc} ]]; then
      echo rm -fr ${dotghc}
      rm -fr ${dotghc}
    fi
    if [[ -d ${dotcabalosx} ]]; then
      echo rm -fr ${dotcabalosx}
      rm -fr ${dotcabalosx}
    fi

    cabal_cmd="${cabal_cmd} --global"
  fi

  cabal update

  echo "remote-repo: stackage:http://www.stackage.org/stackage/93a8bcca1e05c6bdc30ff391ecad800e688bd268" >> ${dotcabal}/config

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

  ${cabal_cmd} ghc-mod
  ${cabal_cmd} hindent
}

function cabal_backup
{
  dotcabal=${HOME}/.cabal
  dotghc=${HOME}/.ghc
  epoch=$(date +%s)
  backup_file=${HOME}/cabal-backup-${epoch}.txz
  (cd ${HOME} &&  tar cf - ${dotcabal} ${dotghc} | pixz -9 -o ${backup_file})
}

function ansible
{
  cd ${base_home}

  if [[ "$(uname)" == "Darwin" ]]; then
    echo sudo ansible-playbook -i inventory osx-root.yml
    ansible-playbook --inventory-file inventory --sudo osx-root.yml
    echo ansible-playbook -i inventory osx-user.yml
    ansible-playbook --inventory-file inventory osx-user.yml
  fi
}

case $1 in
ansible)
  ansible
  ;;
cabal)
  cabal_init
  ;;
cabal-backup)
  cabal_backup
  ;;
homebrew)
  homebrew_setup
  ;;
*)
  default
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "on osx, going to install homebrew+ansible"
    homebrew_setup
  fi
  exit $?
  ;;
esac
