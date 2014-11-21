#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
export script=$(basename "$0")
export dir=$(cd "$(dirname "$0")"; pwd)
export iam=${dir}/${script}
