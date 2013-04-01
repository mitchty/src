#!/usr/bin/env perl
#
# Dumb script to print matches all colorized and stuff.
#

local $ansiesc = "\033";
local $clear = "$ansiesc\[0m";
local ($bold, $black, $red, $green, $yellow, $blue, $magenta, $cyan, $white) =
       ("$ansiesc\[1m", "$ansiesc\[30m", "$ansiesc\[31m", "$ansiesc\[32m", "$ansiesc\[33m", "$ansiesc\[34m", "$ansiesc\[35m", "$ansiesc\[36m", "$ansiesc\[37m");
local ($bgblack, $bgred, $bggreen, $bgyellow, $bgblue, $bgmagenta, $bgcyan, $bgwhite) =
       ("$ansiesc\[40m", "$ansiesc\[41m", "$ansiesc\[42m", "$ansiesc\[43m", "$ansiesc\[44m", "$ansiesc\[45m", "$ansiesc\[46m", "$ansiesc\[47m");

local ($matching,$nonmatching) = ("$bgblack$bold$green", "$blue");
local $match = $ARGV[0] if (exists($ARGV[0]));

for ($j = 1; $j <= $#ARGV; $j++){
  my $file = $ARGV[$j];
  my $matches = 0;
  my $output = "";
  unless (-f $file){
    warn "${clear}$file is not a file, skipping.\n";
    next;
  };
  my $openerr = 0;
  open(FH, "< $file") || $openerr++;
  my @match_input = <FH>;
  close FH;
  if ($openerr) {
    warn "${clear}Cannot open <$ARGV[$j]>\n";
    next;
  };
  for ($i = 1; $i <= ($#match_input + 1); $i++){
    my $postmatch = undef;
    my $match_data = $match_input[($i - 1)];
    my $linenumprinted = 0;
    while ($match_data =~ /$match/gc){
      $output = $output."\@$i " unless($linenumprinted);
      $linenumprinted++;
      $output = $output."$clear$nonmatching$`$clear$matching$&$clear";
      $postmatch = $match_data = "$clear$nonmatching$'$clear";
      $matches++;
    };$output = $output.$postmatch;
  };
  print "$file:\n$output" if $matches;
};
