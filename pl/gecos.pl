#!/usr/bin/env perl
#
# Dumb wrapper to get the gecos information from a uid/username.

foreach my $input (@ARGV){
  local $gecos = undef;
  local $uid = undef;
  local $name = undef;
  if ( $input =~ m/^\d+$/ ) {
    ( $name,$uid,$gecos ) = ( getpwuid($input) )[0,2,6];
  } else {
    ( $name,$uid,$gecos ) = ( getpwnam($input) )[0,2,6];
  }
  print "$name is '$gecos' uid '$uid'\n" if $gecos;
}
