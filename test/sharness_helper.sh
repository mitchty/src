#!/usr/bin/env sh
#-*-mode: Shell-script; coding: utf-8;-*-
time=$(perl -e 'print time() . "\n";')

setup_sandbox()
{
  for thing in $(ls -d ../../* | grep -v test | grep -v dotfiles); do
    cp -rp ${thing} .
  done
}
