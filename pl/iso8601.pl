#!/usr/bin/env perl

use strict;
use POSIX qw(strftime);

my $now = time();
my $tz = strftime('%z', localtime($now));
$tz =~ s/(\d{2})(\d{2})/$1:$2/;

print strftime('%Y-%m-%dT%H:%M:%S', localtime($now)) . $tz . "\n";
exit 0;
