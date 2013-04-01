#!/usr/bin/env perl
#

require 5.8.4;
use strict;
use warnings;
use Getopt::Long;
use File::Copy;
use Net::netent qw(:FIELDS);
use File::Basename;
use Fcntl qw(:DEFAULT :flock);

# non-std modules
use Expect;
use IO::Pty;

$Expect::Multiline_Matching = 0;

$SIG{USR2}="child_done";

local $| = 1;
our $parentpid=$$;
our @hosts;
our @errorhosts;
our $opt_verbose;
our $opt_debug;
our $opt_hostsfile="/dev/null";
our $opt_hosts;
our $opt_workers=4;
our $opt_cmd;
our $opt_dir;
our $opt_timeout=300;
our $opt_changepass;
our $user_password="NULLPASSWORD";
our $change_password="foobar";
our $outputlvl=0;
our @fharr=(*STDOUT);
our $amt=0;

GetOptions( 'verbose:i'   => \$opt_verbose,
            'v:i'         => \$opt_verbose,
            'hostsfile=s' => \$opt_hostsfile,
            'hosts=s'     => \$opt_hosts,
            'workers=s'   => \$opt_workers,
            'cmd=s'       => \$opt_cmd,
            'dir=s'       => \$opt_dir,
            'timeout=i'   => \$opt_timeout,
            'chgpass'     => \$opt_changepass,
            'debug'       => \$opt_debug,
            'd'           => \$opt_debug,
            'help'        => \&opt_help,
            'h'        => \&opt_help,
          ) or opt_help();


sub opt_help {
  my $rc = pop || 1;
  my $message = <<__END__;
UX: ERROR: invalid syntax
usage: [--hostsfile file][--hosts foo,bar,etc][--workers N][--dir /output/dir]
  [--cmd 'command to run'][--timeout N][--chgpass][--verbose N][-v][--help][-h]

  Options
      --hostsfile       File with a list of hosts to run against.
      --hosts           Comma separated list of hosts to run against.
                        NOTE: If both hosts and hostsfile are specified,
                        a union of the hosts between both arguments is created.
      --workers         Number of work processes to run. Must be larger than 1.
                        Default: 4
      --dir             Save the output of the logins in this directory.
                        Will create directory if necessary.
      --cmd             Command to send to the host.
      --timeout         Set the timeout value in seconds.
                        Default: 300
      --chgpass         Enter password change mode. EXPERIMENTAL
      --verbose,-v      Output extra information to the screen.
      --help,-h         Prints this message.
__END__
  print $message;
  exit $rc;
};

sub preprint {
  my $message = pop;
  my $toprint = pop;
  my $prefix = "";
  my $outlvl = 0;

  $toprint = lc($toprint);

  if($toprint eq "d"){
    $prefix = "DEBUG: ";
  }elsif($toprint eq "n"){
    $prefix = "NOTE: ";
  }elsif($toprint eq "e"){
    $prefix = "ERROR: ";
  }elsif($toprint eq "w"){
    $prefix = "WARNING: ";
  };

  for my $fhs (@fharr){
    if($outlvl >= $outputlvl && $toprint ne "d"){
      print $fhs "$prefix"."$message\n";
    }elsif($opt_debug && $toprint eq "d"){
      print $fhs "$prefix"."$message\n";
    };
  };
};

sub sanity_check {
  # Make sure we aren't running as root, just in case
  #
  (($> != 0) && ($< != 0)) || die "FATAL: Don't run this script as root!\n";

  if($opt_verbose){
    if($opt_verbose >= 0 && $opt_verbose <=4){
      $outputlvl = $opt_verbose;
    }else{
      $outputlvl = 0;
    };
  };

  preprint("n", "Both the hostsfile and hosts switch have been selected.") if(defined($opt_hosts) && $opt_hostsfile ne "/dev/null");

  if(defined($opt_hosts)){
    my @tmpa = split(",", $opt_hosts);
    foreach my $hosta (@tmpa){
      chomp $hosta;
      $hosta = lc($hosta);
      push(@hosts, $hosta);
    };
  };

  if($opt_hostsfile ne "/dev/null"){
    preprint("e", "Hostsfile specified, $opt_hostsfile, is a directory.") if(-d $opt_hostsfile);
    preprint("e", "Current user permissions inadequate to read the file $opt_hostsfile\.") if(-f $opt_hostsfile && ! -r $opt_hostsfile);
    preprint("e", "File specified, $opt_hostsfile, is empty.") if(-f $opt_hostsfile && -z $opt_hostsfile);
    my @tmpb;
    if(-r $opt_hostsfile){
      open HOSTF, "< $opt_hostsfile";
      my @tmp_inner = <HOSTF>;
      close HOSTF;
      @tmpb = @tmp_inner;
    };
    foreach my $hostb (@tmpb){
      chomp $hostb;
      $hostb = lc($hostb);
      if($hostb =~ /\s/){
        preprint("w", "Invalid hostname detected in file. ($hostb)");
        next;
      };
      my @found = grep(/^$hostb$/, @hosts);
      if($#found != 0){
        push(@hosts, $hostb);
      };
    };
  }elsif($opt_hostsfile eq "/dev/null"){
  }else{
    preprint("e", "No such file $opt_hostsfile\.");
    opt_help(2);
  };

  if(!$opt_cmd) {
    preprint("e", "No command specified!");
    opt_help(3);
  };

  if(!$opt_dir) {
    $opt_dir="/tmp";
  }else{
    print "Creating output directory $opt_dir if needed.\n";
    mkdir $opt_dir, 0750 unless -d $opt_dir;
    if(! -d $opt_dir) {die "FATAL: Cannot create or detect output directory $opt_dir\n";};
  };

  $amt = $#hosts + 1;

  if($opt_workers > $amt) {
    $opt_workers = $amt;
  };

  @hosts = sort(@hosts);
  print "Enter password for login run:";
  system("stty -echo");
  $user_password=<STDIN>;
  print "\n";

  if($opt_changepass){
    system("stty echo");
    print "Enter new password for run:";
    system("stty -echo");
    $change_password=<STDIN>;
    print "\n";
  };
  system("stty echo");
};

our $children=0;

sub child_done {
  $children--;
};

sub doit {
  my $host = pop;
  preprint("n", "Starting host $host");
  my $spawn = new Expect("ssh $host") or preprint("e", "Couldn't spawn ssh session to $host\.");
  $spawn->log_file("$opt_dir/$host", "w");
  $spawn->log_stdout(0);
  my $spawn_ok = 0;
  my $cmd_ran = 0;
  my $password_set = 0;
  my $exit_ok = 0;
  my $prompt_ok = 0;
  $spawn->expect($opt_timeout, [qr/assword.*\:\s*$/ => sub{
                        preprint("d", "$host: Found a password prompt");
                        $spawn_ok++;
                        my $fh=shift;
                        preprint("d", "$host: cmd_ran is now $cmd_ran and password_set is now $password_set");
                        if(($opt_changepass) and ($cmd_ran == 1) and ($password_set >= 1)){
                          $fh->send("$change_password\n");
                          preprint("n", "Sent new password to $host\.");
                        }else{
                          $fh->send("$user_password");
                          preprint("n", "Sent password to $host\.");
                          $password_set++;
                        };
                        exp_continue;
                        }],
                      ['(?-m)[\]\$\>\#]\s$', sub{
                        preprint("d", "$host: Found something that looks like a prompt!");
                        $spawn_ok++;
                        my $fh=shift;
                        if(!$prompt_ok){
                          preprint("d", "$host: exporting PS1");
                          $fh->send("PS1=\"<->\";export PS1\n");
                          $prompt_ok++;
                        };
                        exp_continue;
                        }],
                      [qr/\<\-\>/i => sub{
                        preprint("d", "$host: Found my set prompt.");
                        $spawn_ok++;
                        my $fh=shift;
                        if($cmd_ran){
                          if(!$exit_ok){
                            preprint("d", "$host: Adjusting output to handle exit");
                            $fh->send("echo \"RC=\$\?\";PS1=\"\<DONE\>\";export PS1\n");
                            $exit_ok++;
                          };
                        }elsif(!$cmd_ran && !$exit_ok){
                          preprint("n", "Running command on $host");
                          $fh->send("$opt_cmd\n");
                          $cmd_ran++;
                        };
                        exp_continue;
                      }],
                      [qr/\<DONE\>/i => sub{
                        preprint("d", "$host: Sending exit");
                        my $fh=shift;
                        $fh->send("exit\n");
                      }],
                      [eof=> sub{
                        if($spawn_ok){
                          preprint("n", "EOF encountered before timeout for $host\. Most likely the host doesn't exist.");
                          flock(HERRS, LOCK_EX);
                          print HERRS "$host\n";
                        }else{
                          preprint("e", "Could not spawn ssh to $host\.");
                          flock(HERRS, LOCK_EX);
                          print HERRS "$host\n";
                        }
                      }],
                      [timeout=> sub{
                        preprint("e", "Timeout connecting to $host\.");
                        flock(HERRS, LOCK_EX);
                        print HERRS "$host\n";
                      }]);

  $spawn->expect(0);
  $spawn->soft_close();
  $spawn->log_file(undef);
  preprint("n", "Done with $host");
};

sub main {
  sanity_check();
  # Open the log files in write mode
  #
  open LOGF, "> $opt_dir/msglog";
  open HERRS, "> $opt_dir/errorhosts";
  push(@fharr, *LOGF); # this way we can log what happen(s) to the msglog file

  open HOSTSF, "> $opt_dir/allhosts";

  # log the hosts we run on
  #
  foreach my $tmp (@hosts){
    print HOSTSF "$tmp\n";
  };
  preprint("n", "Running $opt_cmd across $amt hosts, $opt_workers at a time.");
  preprint("n", "Began at ".localtime());
  my @fork_child;
  foreach my $host (@hosts){
    while($children >= $opt_workers){
      sleep 1; # don't do anything until we are done with hosts, the USR2 signal handler should decrement us out of this loop
      wait;
    };
    my $child=fork();
    if(!defined($child)){
      preprint("e", "Cannot fork!");
    }elsif($child == 0){
      doit($host);
      kill "USR2", $parentpid;
      exit; #child exit
      die "FATAL: Something went horribly wrong in a child fork!!!\n";
    }else{
      $children++;
      next;
    };
  };

  # Wait for everyone to finish
  #
  1 while (wait() != -1);
  preprint("n", "Completed at ".localtime());
  close LOGF;
  close HERRS;
  close HOSTSF;
  exit(0);
};

main();
