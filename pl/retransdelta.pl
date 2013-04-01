#!/usr/bin/env perl
#
# Quick perl script that will save retransbyte totals to a file. Format is
# Epoch:tcpRetransBytes|tcpInInorderBytes|tcpInUnorderBytes\n
# ...usw...
#
# Then you can report on the saved data with -r to see the delta of
# retransmitted packets to total packets sent.
#
# If one of the tcpIn*Bytes counters rolls over it just reports a negative
# number, Its only for one 5 minute interval and i'm too lazy to find out
# the maximum value for both counters to make it "proper".
#

use Getopt::Long;
use POSIX qw(strftime setsid);
use IO::Handle;
use Fcntl;

my $opt_debug;
my $opt_file;
my $opt_read;
my $opt_interval = 240;

GetOptions( 'f=s', =>\$opt_file,
            'r', =>\$opt_read,
            'i=i', =>\$opt_interval,
            'd', =>\$opt_debug,
    );

if ($opt_read){
  sysopen(FH, $opt_file, O_RDONLY);
  my @input = <FH>;
  close FH;
  my $now = time();
  my $r = $now % 300;
  $now = ($now - $r) + 300;# round up to the nearest 5 minutes
  my $last = $now;
  my $last_retrans = 0;
  my $last_inorderbytes = 0;
  my $last_unorderbytes = 0;
  my @cmd_array = qx(/usr/bin/netstat -s);
  foreach my $line (@cmd_array){
    $last_retrans = $1 if($line =~ /.*tcpRetransBytes\s*\=\s*(\d+).*/);
    $last_inorderbytes = $1 if($line =~ /.*tcpInInorderBytes\s*\=\s*(\d+).*/);
    $last_unorderbytes = $1 if($line =~ /.*tcpInUnorderBytes\s*\=\s*(\d+).*/);
  };
  my $tmp_retrans = $last_retrans;
  my $tmp_inorderbytes = $last_inorderbytes;
  my $tmp_unorderbytes = $last_unorderbytes;

  foreach my $line (reverse(@input)){
    if($line =~ /(\d+)\:(\d+)\:(\d+)\:(\d+)/){
      if (($last - $1) > $opt_interval){
        my $delta_chg = $last_retrans - $tmp_retrans;
        if ($delta_chg > 0){
          my $bytes_chg =($last_inorderbytes - $tmp_inorderbytes) + ($last_unorderbytes - $tmp_unorderbytes);
          my $pct_chg = ($delta_chg / $bytes_chg) * 100;
          my $output = strftime("%D %T", localtime($last));
          $output = $output . " to ";
          $output = $output . strftime("%D %T", localtime($1));
          $output = $output . " \x{0394}$delta_chg\/$bytes_chg = \%";
          $output = $output. sprintf("%.2f", $pct_chg). "\n";
          binmode STDOUT, ":utf8" if ($] >= 5.008000);
          print $output;
        };
        $last_retrans = $tmp_retrans;
        $last_inorderbytes = $tmp_inorderbytes;
        $last_unorderbytes = $tmp_unorderbytes;
        $last = $1;
      };
      $tmp_retrans = $2;
      $tmp_inorderbytes = $3;
      $tmp_unorderbytes = $4;
    };
  };
}else{
  if ($opt_debug){
    print "Debug selected, not daemonizing.\n";
  }else{
    print "Forking Daemon off for running\n";
    chdir '/' or die "Cannot change directory to / at $!";
    umask 0 or die "Unable to set umask at $!";
    open STDIN, '/dev/null' or die "can't redirect STDIN to /dev/null at $!";
    open STDOUT, '>/dev/null';
    open STDERR, '>/dev/null';
    my $lead = fork;
    # Double fork
    if ($lead) {
      setsid or die "Cannot start new session at $!";
      exit;
    };
    my $pid = fork;
    exit if ($pid);
  };
  while(1){
    my @cmd_array = qx(/usr/bin/netstat -s);
    my $retrans = 0;
    my $inorderbytes = 0;
    my $unorderbytes = 0;
    my $now = time();

    foreach my $line (@cmd_array){
      $retrans = $1 if($line =~ /.*tcpRetransBytes\s*\=\s*(\d+).*/);
      $inorderbytes = $1 if($line =~ /.*tcpInInorderBytes\s*\=\s*(\d+).*/);
      $unorderbytes = $1 if($line =~ /.*tcpInUnorderBytes\s*\=\s*(\d+).*/);
    };

    sysopen(FH, $opt_file, O_WRONLY|O_APPEND|O_CREAT, 0644) or die $!;
    print FH "$now\:$retrans\:$inorderbytes\:$unorderbytes\n";
    close FH;
    sleep 60;
  };
};

exit 0;
