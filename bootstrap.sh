#!/usr/bin/env sh
#
# Cause... lazy
#
#-*-mode: Shell-script; coding: utf-8;-*-
script=$(basename $0)
dir=$(cd $(dirname $0); pwd)
iam=${dir}/${script}

base=${HOME}/Developer/github.com/mitchty
[[ ! -d ${base} ]] && mkdir -p ${base}

git clone https://github.com/mitchty/src ${base}/src

cd ${base}/src

./setup.sh
