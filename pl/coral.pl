#!/usr/bin/env perl
die "DO NOT USE ME UNTIL FIXED\n";
use strict;
use warnings;
use 5.012;
use English qw(-no_match_vars);
use Readonly;

use Modern::Perl;
use Term::ANSIColor qw(:constants);
use Proc::ProcessTable;
use Tree::Simple;
use Data::TreeDumper;
use Smart::Comments;

my $proctable = Proc::ProcessTable->new()->table();

my $nodetart_level;
my $ptree_init;
my $ptree_pid;
my $ptree_parent;
my %match_pids;
my $match_this;

if ( $ARGV[0] && $ARGV[0] =~ /^\d+$/mxs ) {    # passed a pid like 123
  ## no critic (Variables::ProhibitPunctuationVars)
  $match_this = qr/^$&\b/mxs;
} elsif ( $ARGV[0] && $ARGV[0] =~ /.*/mxs ) {    # passed a string like zsh
  ## no critic (Variables::ProhibitPunctuationVars)
  $match_this = qr/$&/mxs;
}

# Just recursively add children to the tree. Nothing overly special
# Second argument is the pid we are adding nodes to.

sub build_tree {
  my $tree       = shift;
  my $parent_pid = shift;

  for ( @{$proctable} ) {
    my $ppid = $_->ppid;
    my $pid  = $_->pid;
    my $cmd  = $_->cmndline;

    if ( $parent_pid == $ppid && $pid == $parent_pid ) {
      next;    # handle the init(ish) pid, just skip it basically
    } elsif ( $parent_pid == $ppid ) {
      my $output = $_->pid . q{ } . $_->cmndline;
      if ( matches($_) ) {
        $match_pids{ $_->pid } = $tree->getDepth();
      }
      build_tree( Tree::Simple->new( matchit($output), $tree ), $pid );
    }
  }
  return $tree;
}

# Returns given string with the match reverse videod

sub matchit {
  my $what = shift;
  my $ret  = $what;

  if ( $what =~ $match_this ) {
    ## no critic (Variables::ProhibitPunctuationVars)
    ## no critic (Variables::ProhibitMatchVars)
    $ret = $` . REVERSE . $& . RESET . $';
  }

  return $ret;
}

# returns if a process object matches, really naive.

sub matches {
  my $what = shift;
  my $pid  = $what->pid;
  my $cmd  = $what->cmndline;
  my $m    = "$pid $cmd";
  return ( $m =~ $match_this );
}

# Loop through the proctable array and find init, or its equivalent.

for ( @{$proctable} ) {
  my $pid    = $_->pid;
  my $cmd    = $_->cmndline;
  my $output = "$pid $cmd";
  $ptree_pid = $pid;

  if ( $cmd eq '(kernel_task)' ) {    # osx
    unless ($match_this) {
      ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
      $match_this = qr/[(]kernel[_]task[)]/mxs;
      $match_pids{ $_->pid } = -1;
    }
    $nodetart_level = 0;    # osx gives us pid 0, which is the mach scheduler
    $ptree_init = Tree::Simple->new( matchit($output) );
  } elsif ( $cmd =~ /^init[ ]\[\d+\]/mxs ) {    # linux
    unless ($match_this) {
      ## no critic (ValuesAndExpressions::ProhibitMagicNumbers)
      $match_this = qr/init[ ]\[\d+\]/mxs;
      $match_pids{ $_->pid } = -1;
    }
    $nodetart_level = 1;
    $ptree_init     = Tree::Simple->new( matchit($output) );
  }
  $ptree_parent = $output;
  last if $ptree_init;
}

build_tree( $ptree_init, $ptree_pid );

# Filter for Data::DumpTree, determines what gets printed not called by my code

sub filter_pids {
  my $node = shift;

  # TODO: refactor this whole thing, its mad complex.
  if ( 'Tree::Simple' eq ref $node ) {
    my $counter = 0;

    unless ( $ARGV[0] ) {    # By default we print everything, obviously.
      return (
        'ARRAY', $node->{_children},
        map { [ $counter++, $_->{_node} ] }
          @{ $node->{_children} }    # index generation
      );

    } else {    # shit, now we have to do work, makes this mad slow

      # This is sorta convoluted but it works to my desires and is somewhat
      # straightforward.
      #
      # If this node contains a node with a pid, either in its children
      # or one of its parents pids matches %match_pids, it prints.
      #
      # else it doesn't. Thats it.

      my $printok;

      # quick handle if we are a matching pid, this is the easiest case

      if ( exists $match_pids{ $node->getNodeValue =~ qr/\d+\b/mxs } ) {
        $printok++;
      } else {

        # ok, lets find out if one of this nodes children has a matching pid.

        for ( $node->getAllChildren() ) {
          if ( $_->getNodeValue =~ qr/\d+\b/mxs ) {
            my $tmpchild = $_->getNodeValue;
### $tmpchild
            ## no critic (Variables::ProhibitMatchVars)
            ## no critic (Variables::ProhibitPunctuationVars)
            if ( exists $match_pids{$&} ) {
              $printok++;
              last;
            }
          }
        }

        # Now look for parents that may match
        my $depth  = $node->getDepth();
        my $parent = $node;

        while ( $depth > -2 ) {
          $parent = $parent->getParent();

          if ( $parent eq 'root' ) {
            $printok++;
### Hit root node
            last;
          }

          if ( $parent->getNodeValue() =~ qr/\d+\b/mxs ) {
            ## no critic (Variables::ProhibitMatchVar)
            ## no critic (Variables::ProhibitPunctuationVar)
            if ( exists $match_pids{$&} ) {
              $printok++;
              last;
            }
          }
        }
      }

      if ($printok) {
        return (
          'ARRAY', $node->{_children},
          map { [ $counter++, $_->{_node} ] }
            @{ $node->{_children} }    # index generation
        );
      } else {
        my $tmp = $node->getNodeValue();
### $tmp
        return;
      }
    }

    return ( Data::TreeDumper::DefaultNodesToDisplay($node) );
  }
}

# Use Data::DumpTree to print the Tree::Simple objects.

say DumpTree(
         $ptree_init, "pid process\n$ptree_parent",
         QUOTE_VALUES        => 1,
         USE_ASCII           => 0,
         START_LEVEL         => $nodetart_level,
         DISPLAY_OBJECT_TYPE => 0,
         DISPLAY_ADDRESS     => 0,
         NO_WRAP             => 1,
         COLOR_LEVELS => [ [ GREEN, CYAN, RED, BLUE, YELLOW, MAGENTA ], RESET ],
         FILTER       => \&filter_pids,
);

### %match_pids
