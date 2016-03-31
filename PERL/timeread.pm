#!/bin/perl

sub timeread {

  use strict;
  use timecalc;
  use POSIX qw(floor);
  
  
  # Define constants
  my ($border) = ("%" x 78) . "\n";
  my (@class) = qw(gmt vigmt tcr);
  
  
  # Declare read variables
  my ($no_tapes, @tape_id);
  my (@time_initial);  # initial time synch for each tape
  my (@thrust_time);    # subtest thruster pulse times for each tape
  
  
  # Declare other variables
  my ($i, $j, $tape);
  my ($pattern);
  my (@time);
  
  
  ############################################################################
  
  my ($timecalc) = "&STDIN";
  

  if (@_) {
    $timecalc = shift;
  }
  
  
  # read from "timecalc" output file
  open (TIMECALC, "$timecalc") || die "Can't open $timecalc for reading! $!\n";
  
  
  while (<TIMECALC>) { # i.e. $_ = <TIMECALC>
    chomp;
    
    
    # Search for Initial Time Synch
    /^\s*\bInitial\b/i &&
      do {
	$i = 0;
	while (<TIMECALC>) { # i.e. $_ = <TIMECALC>
	  chomp;
	  
	  /^\s*\bTime\b/i &&
	    do {
	      # Do trick to handle tape identifiers with spaces
	      (@tape_id) = split /\s\s+/;
	      #map { print "\"$_\"\n" } @tape_id; print "\n";
	      splice @tape_id, 0, 2; # like shifting twice
	      #map { print "\"$_\"\n" } @tape_id; print "\n";
	      $no_tapes = @tape_id;
	      next # while (inner loop)
	    };
	  
	  ( $i < 3 ) && /^\s*$class[$i]\b/i &&
	    do {
	      $pattern = $class[$i]->units;
	      # replace units and "N / A" with spaces
	      s!$pattern|N\s*.\s*A!' ' x length($&)!gie;
	      $time[$i] = [split /(\s+)/];
	      $tape = 0;
	      for ($j = 0; $j < @{$time[$i]}; $j++) {
		if ($time[$i][$j] =~ /^\s*$/) {
		  # determine number of columns whitespace spans
		  $tape += floor(length($time[$i][$j])/18);
		}
		else {
		  $time_initial[$tape++]{$class[$i]} = 
		    $class[$i]->newstr($time[$i][$j]);
		}
	      }
	      $i++;
	      next # while (inner loop)
	    };
	  
	  /^\s*\bBias\b/i && last # while (inner loop)
	    
	}
	next # while (outer loop)
      };
    
    
    # Search for Subtest Thruster Pulse Time
    /^\s*\bSubtest\b/i &&
      do {
	$i = 0;
	while (<TIMECALC>) { # i.e. $_ = <TIMECALC>
	  chomp;
	  
	  ( $i < 3 ) && /^\s*$class[$i]\b/i &&
	    do {
	      $pattern = $class[$i]->units;
	      # replace units and "N / A" with spaces
	      s!$pattern|N\s*.\s*A!' ' x length($&)!gie;
	      $time[$i] = [split /(\s+)/];
	      $tape = 0;
	      for ($j = 0; $j < @{$time[$i]}; $j++) {
		if ($time[$i][$j] =~ /^\s*$/) {
		  # determine number of columns whitespace spans
		  $tape += floor(length($time[$i][$j])/18);
		}
		else {
		  $thrust_time[$tape++]{$class[$i]} =
		    $class[$i]->newstr($time[$i][$j]);
		}
	      }
	      $i++;
	      next # while (inner loop)
	    };
	  
	  /^\s*\bBias\b/i && last # while (inner loop)
	    
	}
	last # while (outer loop)
      };
    
  }
  
  close (TIMECALC) || die "Can't close $timecalc! $!\n";
  
  ############################################################################

  # return references to keep arrays
  return (\@tape_id, \@time_initial, \@thrust_time);

}

1; # return true value
