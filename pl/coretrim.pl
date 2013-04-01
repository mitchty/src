#!/usr/bin/env perl
#
# Try to keep just one core file per process.
# Also remove cores older than 31 days.
#

local %name_index = ("solaris", 7,
                     "linux", 5,
    );
local %array_size = ("solaris", 8,
                     "linux", 6,
    );
my $age = 14;

my (@cores) = glob "/var/core/*" || die "No cores to clean up.\n";
my (%seen) = ();
my (@process) = ();

foreach my $core (@cores){
  my @file = split(/\./, $core);
  if ($#file == $array_size{$^O}){
    my $proc = $file[$name_index{$^O}];
    my @tmp = stat($core);
    my $age = $tmp[10];
    my $now = time();
    if (($now - $age) > ($age*(24*(60*60)))){
      print "Removing $core due to old age. (>$age days)\n";
      unlink($core);
      next;
    };
    unless ($seen{$proc}){
      $seen{$proc} = 1;
      push(@process, $proc);
    };
  };
};

foreach my $proc (@process){
  my @proc_tmp = glob "/var/core/*$proc*";
  my $kept = pop(@proc_tmp);
  chomp($kept);
  print "Retaining $kept for process <$proc>\n";
  foreach my $core_file (@proc_tmp){
    chomp($core_file);
    print "Removing duplicate core file $core_file\n";
    unlink($core_file);
  };
};

exit 0;
