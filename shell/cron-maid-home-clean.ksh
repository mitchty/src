#!/bin/sh
#
# Meant to be run from cron. Uses maid to keep directories clean and tidy.
#
. ${HOME}/.src/orb/orb.sh
orb use default

maid clean --dry-run
maid clean
