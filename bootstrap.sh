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
ansible_verbose=""
[[ "${VERBOSE}" != '' ]] && ansible_verbose=" -v"

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
  cmd="sudo xcodebuild -license accept"
  echo ${cmd}
  ${cmd}

  if [[ ! -d ${brew_home} ]]; then
    cmd="sudo mkdir -p ${brew_home}"
    echo ${cmd}
    ${cmd}
  fi

  if [[ ! -d ${brew_bin} ]]; then
    cmd="sudo mkdir -p ${brew_bin}"
    echo ${cmd}
    ${cmd}
  fi

  cmd="sudo chown ${iam_user}:${iam_group} ${brew_bin} ${brew_home}"
  echo ${cmd}
  ${cmd}

  if [[ ! -e ${brew_bin}/brew ]]; then
    brew_url="https://raw.githubusercontent.com/Homebrew/install/master/install"
    instfile="${TMPDIR}/brew-install"
    if [[ ! -e ${instfile} ]]; then
      echo "Install homebrew for the first time"
      trap "rm -f ${instfile}};exit" INT TERM EXIT
      curl -fsSL -o ${instfile} ${brew_url}
      chmod 755 ${instfile}
      ${instfile} --fast
      rm -f ${instfile}
      trap - INT TERM EXIT
     else
      echo "Already installing?"
      exit 2
    fi
    rm -f ${instfile}
  fi

  export HOMEBREW_BUILD_FROM_SOURCE=yesplease
  export PATH=${brew_bin}:${PATH}

  # eh, just in case
  brew doctor

  if [[ ! -e ${brew_bin}/bin/ansible ]]; then
    cmd="brew install ansible"
    echo ${cmd}
    ${cmd}
  fi
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
    # let this bit fail if it happens
    set +e
    cmd="ansible-playbook ${ansible_verbose} --inventory-file inventory --sudo osx-root.yml"
    echo ${cmd}
    ${cmd}
    set -e

    if [[ $? != 0 ]]; then
      echo "sudo not setup will prompt to do root actions then"
      cmd="ansible-playbook ${ansible_verbose} --ask-sudo-pass --inventory-file inventory --sudo osx-root.yml"
      echo ${cmd}
      ${cmd}
    fi

    for playbook in user homebrew; do
      cmd="ansible-playbook ${ansible_verbose} --inventory-file inventory osx-${playbook}.yml"
      echo ${cmd}
      ${cmd}
    done
  else
    echo "ansible() doesn't do anything on this os yet."
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
  ansible
  exit $?
  ;;
esac
