#!/usr/bin/env perl
#
# TODO: write stuff here
#

open M, "/sbin/multipath -l -v 2 -d |" or die "Cannot run /sbin/multipath! \@$!\n";
my @m = <M>;
close M;

my %devices = undef;
my $curdev = undef;
my $stopit = 0;

foreach my $line (@m){
  if ($line =~ m/^[0-9,a-f]+\s+(dm\-\d+)/){
    $stopit = 0;
    $curdev = $1;
    $devices{$curdev} = [];
  }elsif ($line =~ m/enabled/ or $stopit){
    $stopit++;
    next;
  }elsif ($line =~ m/\d+\:\d+\:\d+\:\d+\s+(\w+)/){
    $dev = "/dev/$1";
    push(@{$devices{$curdev}}, $dev);
  };
};

sub compare{
  my $x = pop();
  my $y = pop();
  my $iterations = 1_000;
  my $c = 0;

  #
  # See if fdisk reports anything useful existing from the device
  #
  foreach my $device ($x, $y){
    open TMP, "/sbin/fdisk -l $device 3>&1 2>&1 |" or die "Cannot run /sbin/fdisk! \@$!\n";
    my @t = <TMP>;
    close TMP;
    unless (scalar @t > 1){ # if the path is active we will get output even with no valid partition
      print "Device $device appears to have an inactive path. moving on.\n";
      return;
    };
  };

  open(X, $x); open(Y, $y);
  binmode(X); binmode(Y);
  #
  # Ok look for the presense of asc/ascq bytes of 02/04/03,
  # or alternatively 05/25/01. This indicates the path is an inactive
  # clariion snapshot lu.
  #
  seek(X, 0, 0); seek(Y, 0, 0); # start at the beginning
  my $xraw = '';
  my $yraw = '';
  seek(X, 12, 0); seek(Y, 12, 0); # Seek to byte 12 for asc/ascq data
  read(X, $xraw, 2); read(Y, $yraw, 2);
  our ($hxasc, $hxascq) = unpack('H2 H2', $xraw);
  our ($hyasc, $hyascq) = unpack('H2 H2', $yraw);
  #
  # check for 04/03 or 25/01 which indicates an inactive clariion snapshot
  if (((($hxasc eq "04") or ($hyasc eq "04")) and
      (($hxascq eq "03") or ($hyascq eq "03"))) or # 04/03
     ((($hxasc eq "25") or ($hyasc eq "25")) and
      (($hxascq eq "01") or ($hyascq eq "01")))){ # 25/01
    printf "\ninactive clariion lun found asc\/ascq = %02d/%02d\\%02d\/%02d\n", $hxasc, $hxascq, $hyasc, $hyascq,;
    return;
  };

  seek(X, 0, 0); seek(Y, 0, 0); # start at the beginning
  while (){
    $c++;
    $xdata = '';
    $ydata = '';
    # 1k reads? more? less? only the shadow knows
    $recsize = 1 * 2**10;
    $xp = (tell(X) + $recsize);
    $yp = (tell(Y) + $recsize);

    read(X, $xdata, $recsize);
    read(Y, $ydata, $recsize);

    seek(X, $xp, 0); seek(Y, $yp, 0);

    last if ($c > $iterations);

    if ($xdata ne $ydata){
      $before = $xp - $recsize;
      printf "\n asc\/ascq = %02d/%02d\\%02d\/%02d\n", $hxasc, $hxascq, $hyasc, $hyascq,;
      print " Found difference in data between bytes $before/$xp differences follow:";
      @hxdata = unpack('(A8)*', unpack('H*', $xdata));
      @hydata = unpack('(A8)*', unpack('H*', $ydata));
      $l = scalar @hxdata;
      while ($l ge 0){
         $lhs = pop @hxdata;
         $rhs = pop @hydata;
         if ($lhs ne $rhs){
           print "\n\\\-$lhs $rhs";
         };
         $l--;
      };
      last;
    };
  };

  close X; close Y;
};

while (($k,$v) = each %devices){
  my $out = join(',', @{$v});
  my $last = scalar @{$v};
  my $index = ($last > 1) ? 1 : next;
  print "$k => $out\n";
  until ($last le $index){
    $last = $last - 1;
    my $l = @{$v}[$last-1];
    my $r = @{$v}[$last];
    print "\\\-$l\<\=\>$r";
    compare($l, $r);
    print "\n";
  };
};
