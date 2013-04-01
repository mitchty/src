#!/usr/bin/env perl
#
# Dumb range script to aid in for loops and shell
#

use warnings;
use Getopt::Long;

our $opt_output;
our $opt_incr=1;
our $opt_start=0;
our $opt_range=1;
our $fmt;

GetOptions( 'r=i',    => \$opt_range,
            's=i',    => \$opt_start,
            'i=i',    => \$opt_incr,
            'o=s',    => \$opt_output,
          );

$fmt = ($opt_output) ? "%".$opt_output." " : "%i ";

for( my $x = $opt_start; $x <= ($opt_range + $opt_start); $x += $opt_incr ){
  printf($fmt, $x);
}; print "\n";
exit 0;
