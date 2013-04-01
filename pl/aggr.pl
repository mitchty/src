#!/usr/bin/env perl
#
# Print aggregate times for a command to be run, like time/ptime.
#
# Default run 10 times to aggregate. -n N to change to however many runs needed.
#

use Benchmark;
use Getopt::Long;

our $opt_iter = 10;
GetOptions( 'n:i',  => \$opt_iter,
            'h',    => \&opt_help);

sub opt_help {
  my $rc = pop || 1;
  my $message = <<__END__;
UX: ERROR: invalid syntax
usage: [-n iterations][-h]

  Options
      -n                Number of iterations.
      -h                Print help message.
__END__
  print $message;
  exit $rc;
};

timethis($opt_iter, 'system(@ARGV)');
