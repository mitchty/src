#!/usr/bin/env perl
#
# Print out stat() information, i.e. filename, dir/file/link etc...
# and sha1/md5 checksum if it is a file. Uses openssl binary already installed.
#
# Example filename uid gid {link=>/to/file,file,dir} sha1sum
#

use File::Find;
my @files = ();

sub prune {
  if (-d $_) {
    push(@files, [$File::Find::name, (stat($_))[4], (stat($_))[5],
                  "directory", "no_sha1_digest"]);
  }elsif (-l $_) {
    push(@files, [$File::Find::name, (lstat($_))[4], (lstat($_))[5],
                  "link=>".readlink($_), "no_sha1_digest"]);
  }elsif (-f $_) {
    push(@files, [$File::Find::name, (stat($_))[4], (stat($_))[5], "file",
                  (split(m/\s+/, `openssl sha1 '$_'`))[1]]);
  }else{
    #ignore...
  };
};

find(\&prune, $ARGV[0]);

map { print "$$_[0]\t$$_[1]\t$$_[2]\t$$_[3]\t$$_[4]\n" }sort{ $$a[0] <=> $$b[0] } @files;
