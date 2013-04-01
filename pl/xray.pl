#!/usr/bin/env perl
#
# xray a bunch of files for some text and email upon seeing them in 
# n seconds/whatever
#

use warnings;
use strict;

use IO::Handle;
use Getopt::Long;
use POSIX qw(setsid);
use Sys::Hostname;

our $opt_debug;
our $opt_emails;
our $opt_files;
our $opt_matches;
our $opt_time;
our $opt_glob;

our @matcharr;
our @filearr;
our @emailarr;
our $alerttime = 60;

our %files;
our $hostname = hostname();

GetOptions( 'debug'     => \$opt_debug,
            'd'         => \$opt_debug,
            'h'         => \&opt_help,
            'help'      => \&opt_help,
            'files:s'   => \$opt_files,
            'glob:s'    => \$opt_glob,
            'emails:s'  => \$opt_emails,
            'matches:s' => \$opt_matches,
            'time:i'    => \$opt_time,
          ) or opt_help();


sub opt_help {
  my $rc = pop || 1;
  my $message = <<__END__;
UX: ERROR: invalid syntax
usage:  [--files file1,file2,file3][--emails email1,email2][--glob globstring]
        [--matches 'string','orregexpstring'][-h][--help]

  Options
      --help,-h     Prints this help text.
      --files       Comma delimited list of files that should be run against.
      --glob        Or you can give a glob string e.g. '/foo/bar/*/file*'
      --emails      Comma delimited list of email addresses to be sent to.
      --matches     String that will be placed in a qr/\$val/ block to match.
                    NOTE: Just type in some text to match that text anywhere.
                    All matches count, so if there are two matches of a word,
                    it will count as a single match.
      --time        How long should the script sleep between checks.
                    NOTE: 60 seconds by default.

__END__
  print $message;
  exit $rc;
};

sub matchdata {
  my $f = pop;
  my $ferr = 1;
  updatefile($f);
  open (LOGF, $f) or $ferr = 0;
  if($ferr == 0){
    print "file error\n";
    return $ferr;
  };
  my $position = getvalforfile($f, 'position');
  my $size = getvalforfile($f, 'size');

  my $newmatches = 0;
  my $matchtime = 0;
  # scan from the last position to the current end
  print "pos $position size $size\n" if($opt_debug);
  if($position > $size){
    # wtf? ok, so reset position to 0 and scan anew
    $position = 0;
  };

  seek(LOGF, $position, 0);

  for(my $curpos = $position;<LOGF>; $curpos <= $size){
    my $t = $_;
    $curpos = tell(LOGF);
    print "curpos = $curpos\n" if($opt_debug);
    foreach my $match (@matcharr){
      print "Will match $match\n" if($opt_debug);
      if($t =~ qr/$match/){
        chomp $t;
        print "Matched $match to $t." if($opt_debug);
        $newmatches++;
        $matchtime = time();
      };
    };
  };
  setvalforfile($f, 'position', $size);
  close(LOGF);

  if($newmatches > 0){
    setvalforfile($f, 'matches_total', (getvalforfile($f, 'matches_total') + $newmatches));
    setvalforfile($f, 'last_matched', $newmatches);
  };

  my $lastmatchtime = getvalforfile($f, 'matchtime');
  if($newmatches > 0 and (($matchtime - $lastmatchtime) <= $alerttime)){
    my $text = "$newmatches or more matches in less than $alerttime seconds for file $f";
    if(getvalforfile($f, 'newfile') == 0 and $newmatches > 1){
      $text = "File $f rolled over and had $newmatches detected.\n";
    };
    send_email($f, $text, "CRIT");
  }elsif($newmatches > 0){
    my $text = "$newmatches or more matches outside of the alert period $alerttime seconds";
    send_email($f, $text, "INFO");
  };
  setvalforfile($f, 'newfile', 1) if(getvalforfile($f, 'newfile') == 0);
  setvalforfile($f, 'matchtime', $matchtime) if($matchtime > 0);
};

sub send_email {
  my $howbadisit = pop;
  my $text = pop;
  my $file = pop;
  print "$file: email is $text\n";
  my $mailto = join(' ', @emailarr);
  open MAILX, "| /usr/bin/mailx -s \"$howbadisit xray alert for $hostname file $file\" $mailto";
  chomp($hostname);
  print MAILX "File $file seems to have had $text occur.\n";
  close MAILX;
};

sub sanity_check {
  if(defined($opt_matches) and defined($opt_emails)){
    if(defined($opt_files)){
      my @tmpf = split(",", $opt_files);
      if($#tmpf < 1){
        @tmpf = ("$opt_files");
      };
      foreach my $f (@tmpf){
        chomp $f;
        print "Adding file $f\n";
        push(@filearr, $f);
      };
    };

    if(defined($opt_glob)){
      my @tmpf = glob("$opt_glob");
      foreach my $f (@tmpf){
        chomp $f;
        print "Adding file $f\n";
        push(@filearr, $f);
      };
    };

    if(defined($opt_matches)){
      my @tmpm = split(",", $opt_matches);
      foreach my $m (@tmpm){
        print "Adding match $m\n";
        push(@matcharr, $m);
      };
    };

    if(defined($opt_emails)){
      my @tmpe = split(",", $opt_emails);
      foreach my $e (@tmpe){
        chomp $e;
        print "Adding email $e\n";
        push(@emailarr, $e);
      };
    };

    if(defined($opt_time)){
      $alerttime = $opt_time if($opt_time > 30);
    };

  }else{
    opt_help(2);
  };
};

sub updatefile {
  my $filename = pop;
  if(! -f $filename){
    return;
  };
  my @tmp = stat($filename);
  my $inode = $tmp[1];
  my $size = $tmp[7];
  if(exists($files{$filename})){
    my $i = $files{$filename}{'inode'} || 0;
    if($inode != $i){
      # reset position & inode the rest should be fine as is
      setvalforfile($filename, 'position', 0);
      setvalforfile($filename, 'newfile', 0);
      setvalforfile($filename, 'inode', $inode);
    };
    setvalforfile($filename, 'size', $size);
  }else{
    setvalforfile($filename, 'inode', $inode);
    setvalforfile($filename, 'size', $size);
    setvalforfile($filename, 'position', 0);
    setvalforfile($filename, 'last_matched', 0);
    setvalforfile($filename, 'matches_total', 0);
    setvalforfile($filename, 'matchtime', 0);
    setvalforfile($filename, 'newfile', 0);
  };
};

sub getvalforfile {
  my $val = pop;
  my $file = pop;
  print "Get $file $val is $files{$file}{$val}\n" if($opt_debug);
  return $files{$file}{$val};
};

sub setvalforfile {
  my $parm = pop;
  my $val = pop;
  my $file = pop;
  print "Set $file $val to $parm\n" if($opt_debug);
  $files{$file}{$val} = $parm;
};

sub main {
  sanity_check();

  if($opt_debug){
    print "Debug selected, will not daemonize.\n";
  }else{
    print "Forking Daemon off for running\n";
    chdir '/' or die "Cannot change directory to / at $!";
    umask 0 or die "Unable to set umask at $!";
    open STDIN, '/dev/null' or die "can't redirect STDIN to /dev/null at $!";
    open STDOUT, '>/dev/null';
    open STDERR, '>/dev/null';
    my $ignore = defined(my $pid = fork);
    exit if $pid;
    setsid or die "Cannot start new session at $!";
  };
  foreach my $file (@filearr){
    updatefile($file);
  };
  for(;;){
    foreach my $x (keys(%files)){
      matchdata($x);
    };
    sleep ($alerttime-2);
  };
};

main();
