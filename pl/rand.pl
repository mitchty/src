#!/usr/bin/env perl
#
# Just spew out a random number based on the inputs.
# Arguments are -r range i.e. 100-150 would have a range of 50.
# -s start i.e. 100 - 150 would start at 100
# -i specifies whether to output as an integer or not
# rand.pl -i -r 50 -s 100 would allow for a random integer from 100-150 to be
# output
#
# Default output is a floating point number from 0 to 1.
#
use File::Find;
use Getopt::Long;

local $opt_range = 1;
local $opt_start = 0;
local $opt_integer;

sub opt_help(){
  my $rc = pop || 1;
  my $message = <<__END__;
UX: ERROR: invalid syntax
usage: [-r range][-s start][-i][-h][--help]

  Options
      --help,-h    Prints this help message.
      -r           Indicates the numeric range, i.e. 50 indicates 0..50
                   Default: 1
      -s           Indicates the numeric start.
                   Default: 0
      -i           Output integers instead of floats. Rounds to nearest integer.
__END__
  print $message;
  exit $rc;
};

GetOptions( 'r=i',  => \$opt_range,
            's=i',  => \$opt_start,
            'i',    => \$opt_integer,
            'h',    => \&opt_help,
            'help', => \&opt_help,
    ) or opt_help();

my $rand = rand($opt_range) + $opt_start;
$rand = ($opt_integer) ? int($rand+0.5) : $rand;
print "$rand\n";
exit 0;
