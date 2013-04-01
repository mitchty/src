#!/usr/bin/env perl
#
# TESTING
use warnings;
use strict;
use Getopt::Long;
use IPC::Open2;
use FileHandle;
use File::Temp qw/tempfile/;
use IO::Handle;

our $opt_bytes;
our $opt_megabyte;
our $opt_kilobyte;
our $opt_gigabyte;
our $opt_debug;

GetOptions(
            'm', => \$opt_megabyte,
            'M', => \$opt_megabyte,
            'K', => \$opt_kilobyte,
            'k', => \$opt_kilobyte,
            'g', => \$opt_gigabyte,
            'G', => \$opt_gigabyte,
            'b', => \$opt_bytes,
            'd', => \$opt_debug,
          );

# For outputing the size of a bunch of blocks in g/m/k depending upon the size
sub block_print {
  my $block_k = 1024;
  my $block_m = 1024**2;
  my $block_g = 1024**3;
  my $outsize = 0;
  my $blocks  = pop;
  my $suffix  = " bytes";
  my $divisor = 1;

  if ($opt_bytes) {
    undef;
  } elsif ($opt_gigabyte) {
    $suffix  = " Gi";
    $divisor = $block_g;
  } elsif ($opt_megabyte) {
    $suffix  = " Mi";
    $divisor = $block_m;
  } elsif ($opt_kilobyte) {
    $suffix  = " Ki";
    $divisor = $block_k;
  } elsif ( $blocks > $block_g ) {
    $suffix  = " Gi";
    $divisor = $block_g;
  } elsif ( $blocks > $block_m ) {
    $suffix  = " Mi";
    $divisor = $block_m;
  } elsif ( $blocks > $block_k ) {
    $suffix  = " Ki";
    $divisor = $block_k;
    $suffix  = " byte";
  }
  $outsize = $blocks / $divisor;

  return sprintf( "%.2f%s", $outsize, $suffix );
}

my $dtracescript = <<ZOMG;
#!/usr/sbin/dtrace -s

#pragma D option quiet
#pragma D option bufsize=16k

BEGIN
{
  /* Not as useful ksyms */
  this->debug_ani_max = `k_anoninfo.ani_max;
  this->debug_ani_phys_resv = `k_anoninfo.ani_phys_resv;
  this->debug_ani_mem_resv = `k_anoninfo.ani_mem_resv;
  this->debug_ani_locked = `k_anoninfo.ani_locked_swap;
  this->debug_availrmem = `availrmem;

  /* RAM */
  this->ram_total = `physinstalled;
  this->ram_unusable  = `physinstalled - `physmem;
  this->ram_locked    = `pages_locked;
  this->ram_used  = `availrmem - `freemem;
  this->ram_freemem   = `freemem;
  this->ram_kernel    = `physmem - `pages_locked - `availrmem;

  /* disk related */
  this->disk_total = `k_anoninfo.ani_max;
  this->disk_reserve = `k_anoninfo.ani_phys_resv;
  this->disk_available = this->disk_total - this->disk_reserve;

  /* actual swap info according to the vm subsystem */
  this->swap_minfree = `swapfs_minfree;
  this->swap_reserve = `swapfs_reserve;

  /* TOTAL_AVAILABLE_SWAP from vm/anon.h */
  this->swap_total = `k_anoninfo.ani_max + (`availrmem - `k_anoninfo.ani_max +
                      `availrmem - `swapfs_minfree > 0 ? `availrmem - `swapfs_minfree : 0);

  /* CURRENT_TOTAL_AVAILABLE_SWAP from vm/anon.h */
  this->swap_avail = `k_anoninfo.ani_max + (`availrmem - `k_anoninfo.ani_phys_resv +
                      `availrmem - `swapfs_minfree > 0 ? `availrmem - `swapfs_minfree : 0);
  this->swap_resv = this->swap_total - this->swap_avail;

  /* multiply values times the kernels' pagesize `_pagesize so we get output in bytes */
  this->debug_ani_max *= `_pagesize;
  this->debug_ani_phys_resv *= `_pagesize;
  this->debug_ani_mem_resv *= `_pagesize;
  this->debug_ani_locked *= `_pagesize;
  this->debug_availrmem *= `_pagesize;

  this->ram_total *= `_pagesize;
  this->ram_unusable *= `_pagesize;
  this->ram_locked *= `_pagesize;
  this->ram_used *= `_pagesize;
  this->ram_freemem *= `_pagesize;
  this->ram_kernel *= `_pagesize;

  this->disk_total *= `_pagesize;
  this->disk_reserve *= `_pagesize;
  this->disk_available *= `_pagesize;

  this->swap_minfree *= `_pagesize;
  this->swap_resv *= `_pagesize;
  this->swap_reserve *= `_pagesize;
  this->swap_avail *= `_pagesize;
  this->swap_total *= `_pagesize;

  printf("debug_ani_max = %d\\n", this->debug_ani_max);
  printf("debug_ani_phys_resv = %d\\n", this->debug_ani_phys_resv);
  printf("debug_ani_mem_resv = %d\\n", this->debug_ani_mem_resv);
  printf("debug_ani_locked = %d\\n", this->debug_ani_locked);
  printf("debug_availrmem = %d\\n", this->debug_availrmem);

  printf("ram_total = %d\\n", this->ram_total);
  printf("ram_unusable = %d\\n", this->ram_unusable);
  printf("ram_locked = %d\\n", this->ram_locked);
  printf("ram_used = %d\\n", this->ram_used);
  printf("ram_freemem = %d\\n", this->ram_freemem);
  printf("ram_kernel = %d\\n", this->ram_kernel);

  printf("disk_total = %d\\n", this->disk_total);
  printf("disk_reserve = %d\\n", this->disk_reserve);
  printf("disk_available = %d\\n", this->disk_available);

  printf("swap_minfree = %d\\n", this->swap_minfree);
  printf("swap_reserve = %d\\n", this->swap_reserve);
  printf("swap_resv = %d\\n", this->swap_resv);
  printf("swap_avail = %d\\n", this->swap_avail);
  printf("swap_total = %d", this->swap_total);
  exit(0);
}
ZOMG

my $output = undef;
{
  my $zone = qx/zonename/;
  die "Run me on the global, not the zone\n" unless $zone ne 'global';
  local $/ = undef;
  my ( $tmpfh, $tmpfilename ) =
    tempfile( KEEP => 0, DIR => '/tmp', SUFFIX => '.d' );
  $tmpfh->print($dtracescript);
  $tmpfh->flush;
  $output = qx{/usr/sbin/dtrace -s $tmpfilename};
  die "Uhoh, rc of $? when running dtrace\n" if $?;
  $tmpfh->close;
}

our %swap = ( $output =~ /^([\w\_]+)\s+\=\s+(\d+)$/mg );

$swap{"swap_free"} = $swap{"swap_avail"} - $swap{"disk_reserve"};
our $pct = ( $swap{"swap_free"} / $swap{"swap_avail"} ) * 100;
printf "\~%.2d%% swap in use\n", $pct;

exit unless $opt_debug;

foreach my $match (qw(debug_ ram_ disk_ swap_)) {
  print "\n";
  foreach my $k ( keys(%swap) ) {
    if ( $k =~ m/$match/ ) {
      my $val = block_print( $swap{$k} );
      printf "%22s => %14s\n", $k, $val;
    }
  }
}
