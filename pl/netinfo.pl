#!/usr/bin/env perl -w
#
# Quick perl script to get the percentage of retransmissions/duplicates
# Useful for diagnostics of network congestion/switch/etc... issues
#
@cmd_array = `/usr/bin/netstat -s`;
$err_high = 25.0;
$warn_med = 15.0;

my $retrans = 0;
my $out_data = 1;
my $in_dups = 0;
my $in_order = 0;
my $in_unorder = 0;
my $in_data = 1;

my $scan = 0;

foreach $_ (@cmd_array){
  if($_ =~ /.*tcpRetransBytes\s*\=\s*(\d+).*/){
    $retrans = $1;
  };
  if($_ =~ /.*tcpOutDataBytes\s*=\s*(\d+).*/){
    $out_data = $1;
  };
  if($_ =~ /.*tcpInDupBytes\s*=\s*(\d+).*/){
    $in_dups = $1;
  };
  if($_ = /.*tcpInInorderBytes\s*=\s*(\d+).*/){
    $in_order = $1;
  };
  if($_ = /.*tcpInUnorderBytes\s*=\s*(\d+).*/){
    $in_unorder = $1;
  };
};

$in_data = $in_order + $in_unorder;

if($retrans == 0){
  $retrans_rate = 0;
}else{
  $retrans_rate = ($retrans / $out_data) * 100 if($retrans > 0);
};
if($in_dups == 0){
  $dups_rate = 0;
}else{
  $dups_rate = ($in_dups / $in_data) * 100 if($in_dups > 0);
};

if($retrans_rate > $err_high){
  print "ERROR: Retransmission rate is greater than $err_high\%, acks not being received quickly enough, check nic configuration and network setup\n";
  $scan = 1;
}elsif($retrans_rate > $warn_med){
  print "WARNING: Retransmission rate is above $warn_med\%. Might indicate a possible problem\n";
};
printf " (tcpRetransBytes/tcpOutDataBytes)*100 = (%d\/%d)*100\n", $retrans, $out_data;
printf "Retransmission rate is: %.2f%%\n", $retrans_rate;

if($dups_rate > $err_high){
  print "ERROR: Duplicate packet rate is greater than $err_high\%, possibly bad hardware or a congested route\n";
  $scan = 1;
}elsif($dups_rate > $warn_med){
  print "WARNING: Duplicate packet rate is above $warn_med\%. Might indicate a possible problem\n"
};
printf " (tcpInDupBytes/(tcpInInorderBytes+tcpInUnorderBytes))*100 = (%d\/(%d\+%d))*100\n", $in_dups, $in_order, $in_unorder;
printf "Duplicate rate is: %.2f%%\n", $dups_rate;

if($scan == 1){
  print "\nDump of interface statistics because of high duplicates and/or retransmissions.\n";
  @ifconfig_out = `/usr/sbin/ifconfig -a`;
  foreach $line (@ifconfig_out){
    if($line =~ m/^([a-z]+)(\d+)\:\sflags/g){
      next if("lo" eq $1);
      @kstat_out = `kstat -p $1:$2::'/collisions|framing|crc|code_violations|tx_late_collisions/'`;
      # god do I hate this posix thing
      print "Interface: $1, instance: $2\n";
      if(($? >> 8) == 1){
        print "This is a virtual interface, unable to get kstat information!\n";
      };
      my $errors = 0;
      foreach $kline (@kstat_out){
        if($kline =~ m/.*\:(\w+).*(\d+)$/g){
          if($2 > 0){
            $errors = 1;
             print " $1\t$2\n";
          };
        }elsif($kline =~ m/.*(\w+).*(\d+)$/g){
          if($2 > 0){
            $errors = 1;
             print " $1\t$2\n";
          };
        }else{
          chomp $kline;
          print "??? $kline\n";
        };
      };
      print "No errors found on this interface.\n" if($errors == 0);
      $errors = 0;
    };
  };
};

exit 0;
