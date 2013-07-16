#!/usr/bin/env perl
#
# Because ifconfig output is... overly verbose.
#
# Output information from ifconfig -a like so:
#   interface:mtu ipv4/cidr mac_address ipv6_addr(if applicable)
#   ipv6 is not yet in place due to a: lazy, b: can't use it yet.
#

use strict;
use Socket;
use Sys::Hostname;

my ($fqdn_regexp) = qr/([0-9,a-z,A-Z,\-,\_]+)\.([0-9,a-z,A-Z,\-,\_]+)\.(com|gov)/;

#
# converts a 1-word (4 byte) signed or unsigned integer into a dotted decimal
# ip address.
#
sub int2ip {
  my $n=int(pop);
  return(sprintf("%d.%d.%d.%d", ($n>>24)&0xff,($n>>16)&0xff,
    ($n>>8)&0xff,$n&0xff));
};

#
# Convert a host/ip/netmask/cidr/etc.... to a hash of information
# Example: host.domain.tld/24 will get the ip and calculate the netmask info
#  equally if host.domain.tld corresponds with 1.2.3.4 the following is valid
#  1.2.3.4/255.255.255.0 would obtain the same information.
#
# die()'s if anything isn't kosher.
#
# Ultra long function, probably needs to be looked at for condensing/splitting.
#
sub cidr2raw {
  my $rawinput = pop;
  my ($lhs, $rhs, $j, $uip) = (undef, undef, undef, undef);
  my ($ucidr) = 0;
  my ($network, $bits, $netmask, $broadcast, $low, $high);

  if ($rawinput =~ qr/(.*)\/(.*)/){
      $lhs = $1; $rhs = $2;
  }else{
    die "Input: $rawinput not expected.\n";
  };

  #
  # Handle ip/hostname for left hand side.
  if ($lhs =~ qr/(\d+)\.(\d+)\.(\d+)\.(\d+)/){
    foreach my $dotted (($1,$2,$3,$4)){
      if (($dotted > 255) or ($dotted < 0)){
        die "FATAL: ipv4 address entered, $lhs entered is impossible, $dotted is not between 0-255.\n";
      };
    };
    $uip = "$1.$2.$3.$4";
  };
  #
  # Handle the netmask/cidr for the right hand side,
  #
  # All input netmasks are converted to a cidr address for notation
  if ($rhs =~ qr/^(\d+)$/){ # /cidr
    $ucidr = $1;
    die "FATAL: Invalid CIDR <$ucidr>.$!\n" if (($ucidr > 32) or ($ucidr < 0));
  }elsif ($rhs =~ qr/(0[xX])?([0-9,a-f,A-F]{7})/){ # /0xhexnetmask
    my $trimmed = $2;
    my $insane = 0;
    foreach my $byte (split('', unpack("B32", pack("H*", $trimmed)))){
      ($byte) ? $ucidr++ : $insane++;
      die "FATAL: $rhs is not a valid hex netmask.$!\n" if ($insane and $byte);
    };
  }elsif ($rhs =~ qr/(\d+)\.(\d+)\.(\d+)\.(\d+)/){ # /255.255.255.0 form
    my @a = ($1, $2, $3, $4);
    my $insane = 0;
    foreach my $t (@a){
      die "FATAL: Netmask out of range. Input <$rhs> Invalid <$t>$!\n" if (($t < 0) or ($t > 255));
    };
    foreach my $byte (split('', unpack("B32", pack("C4", @a)))){
      ($byte) ? $ucidr++ : $insane++;
      die "FATAL: $rhs is not a valid netmask.$!\n" if ($insane and $byte);
    };
  }else{
    die "FATAL: Unknown or invalid netmask value entered. <$rhs>\n";
  };

  #
  # Network math GO! This is the meat of the function.
  my (@uip) = split(/\./, $uip);
  $network = 0;
  for ($j = 0; $j <= $#uip; $j++){
    $network += int($uip[$j])<<((3-$j)*8);
  };

  $bits = 0; $j = 0;
  for ($j = 31 - $ucidr; $j >= 0; $j--){
    $bits |= 1<<$j;
  };

  $netmask = 0xffffffff^$bits;
  $low = ($network&$netmask);
  $high = ($network&$netmask)+$bits-1;
  $broadcast = ($network&$netmask)|$bits;

  #
  # Throw the info back, they get a hash with zie info they may/may not need.
  # All up to the caller what they want to use.
  #
  return ("inet4" => $uip,
          "netmask" => int2ip($netmask),
          "broadcast" => int2ip($broadcast),
          "cidr" => $ucidr,
          "router" => int2ip($low+1),
          "network" => int2ip($low),
          "high" => int2ip($high),
          );
};

open IFCONFIG, "ifconfig -a |";
our @ifout = <IFCONFIG>;
close IFCONFIG;

# This seems wrong but it makes parsing easier due to solaris
# non root ifconfig not displaying the mac address. Reverse the output.
#
@ifout = reverse(@ifout);

our ($ifname, $ifether, $ifmtu, $ifipv4, $ifnetmask, $ifipv6) = (undef,undef,undef,undef,undef,undef);
sub printiface{
  # Handle solaris not showing the mac address when not root.
  #
  if (not $ifether and (($^O eq "darwin") || ($^O eq "linux"))){
    return;
  };

  if ($ifname =~ m/lo.*/){
    # we got a stupid loopback in here somehow, reset and return.
    ($ifname, $ifether, $ifmtu, $ifipv4, $ifnetmask, $ifipv6) = (undef,undef,undef,undef,undef,undef);
    return;
  };

  if ($ifname and $ifmtu and $ifipv4 and $ifnetmask and 1){
    my %netinfo = cidr2raw("$ifipv4\/$ifnetmask");
    $ifnetmask = $netinfo{"cidr"};
    $ifether = lc($ifether);
    printf "%-16s %-18s %-17s\n", "$ifname\:$ifmtu", "$ifipv4\/$ifnetmask", $ifether;
    ($ifname, $ifether, $ifmtu, $ifipv4, $ifnetmask, $ifipv6) = (undef,undef,undef,undef,undef,undef);
  };
};

foreach my $line (@ifout) {
  # Darwin/solaris
  if ($line =~ m/ether\s([:,0-9,a-f,A-F]{11,})/){
    $ifether = $1;
  }elsif ($line =~ m/^(.*)\:\s+.*mtu\s(\d+)/){
    $ifname = $1;
    $ifmtu = $2;
  }elsif ($line =~ m/inet\s(\d+\.\d+\.\d+\.\d+)\snetmask\s(0[xX])?([a-f,A-F,0-9]{8})/){
    $ifipv4 = $1;
    $ifnetmask = $3;
  # Linux
  }elsif ($line =~ m/MTU\:(\d+)/){
    if ($ifmtu) { # We are on a new interface, reset things.
      ($ifname, $ifether, $ifmtu, $ifipv4, $ifnetmask, $ifipv6) = (undef,undef,undef,undef,undef,undef);
    };
    $ifmtu = $1;
  }elsif ($line =~ m/inet\saddr\:(\d+\.\d+\.\d+\.\d+).*Mask\:(\d+\.\d+\.\d+\.\d+)/){
    $ifipv4 = $1;
    $ifnetmask = $2;
  }elsif ($line =~ m/^([\w,\:\d+]+)\s+.*HWaddr\s([:,0-9,a-f,A-F]{11,})/){
    $ifname = $1;
    $ifether = $2;
  }elsif ($line =~ m/^lo.*Loopback/){
    # Just reset things, will fix the parsing later.
    ($ifname, $ifether, $ifmtu, $ifipv4, $ifnetmask, $ifipv6) = (undef,undef,undef,undef,undef,undef);
  # Others?
  };
  printiface();
};
