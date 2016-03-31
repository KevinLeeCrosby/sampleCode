#!/bin/perl

# DATE      VER  NAME          DESCRIPTION
# 07-06-01  1.0  K. Crosby     First Release
# 07-20-01  1.1  K. Crosby     Fixed bug that didn't update final calculations
#                              for viGMT and TCR.  Added full path, version,
#                              and timestamp.


use strict;
use timecalc;
use timeread;
use POSIX qw(strftime);   # for timestamping using strftime function
use File::Basename;

my ($version) = 1.1;

  
# Define constants
my ($border) = ("%" x 78) . "\n";
my (@class) = qw(gmt vigmt tcr);
my (@ordinal) = qw(1st 2nd 3rd 4th 5th 6th 7th 8th 9th);


# Declare input variables
my ($timecalc);
my ($filename);
my ($tape_chosen);
my (@movie_name, @first_frame, @first_time);
my (@synch_time, $bias);


# Declare read variables
my ($somefile);
my ($no_tapes, @tape_id);
my (@time_initial);   # initial time synch for each tape
my (@thrust_time);    # subtest thruster pulse times for each tape
my ($tape_id_ref, $time_initial_ref, $thrust_time_ref);


# Declare calculated variables
my ($dir, $base);
my ($tape_last) = 0;
my (@tape_synch);
my (@synch_pair) = ();
my ($no_synchs) = 0;
my ($delta);
my (@have_gmt) = ();
my (@time_fmt_avail, @time_fmt_unavail) = ();

my ($now);

  
# Declare other variables
my ($i, $j, $k, $tape, %count);
my ($key, @key, $inkey, $outkey, $nokey);
my ($input, $output, $time);

my ($header1, $header2, $header3) = "";


##############################################################################

# Give instructions to user

print "\n";
print "$border";
print "$border";
printf "%s WELCOME TO NSYNC %s\n", ('%' x 30), ('%' x 30);
printf "%s Version %3.1f %s\n", ('%' x 33), $version, ('%' x 32);
print "$border";
print "$border";
print "\n";

print "INSTRUCTIONS:\n";
print "   GMT is the default time specified\n";
print "   Vertical Interval GMT is specified by following the time with a \"v\"\n";
print "   Both of these time formats are expressed in the form \"DDD:HH:MM:SS.SSS\"\n";
print "      (days, hours, minutes, seconds, and milliseconds)\n\n";

print "   TCR is specified by following the time with a \"t\" or a \"f\"\n";
print "   This time format is expressed in the form \"DDD:HH:MM:SS:FF\"\n";
print "      (days, hours, minutes, seconds, and frames)\n\n";

print "NOTE:\n";
print "   ALL TIMES ARE DELIMITED BY NON-NUMERIC CHARACTERS.\n";
print "   LEADING DAYS, HOURS, ETC., ARE OPTIONAL.\n";
print "   NUMBERS OUT OF RANGE WILL BE CORRECTED PROPERLY.\n\n";

print "EXAMPLES:\n";
print "   (GMT) =>  146:01:21:54.998 GMT\n";
print "      OR  146 01 21 54.998\n";
print "      OR  146 DAYS, 01 HOURS, 21 MINUTES, 54 SECONDS, 998 MILLISECONDS\n";
print "   (VIGMT) =>  146:01:21:54.998v\n";
print "      OR  146 01 21 54.998 viGMT\n";
print "   (TCR)  =>  256:18:59:04:20f\n";
print "      OR  256 18 59 04 20 tcr\n";
print "      OR  256 DAYS, 18 HOURS, 59 MINUTES, 4 SECONDS, 20 FRAMES\n";


##############################################################################

# Parse command line and if necessary, prompt

if (@ARGV && -f $ARGV[0] && -T $ARGV[0] && open(FILE, "$ARGV[0]")) {
  while (<FILE>) { last if /^\s*%*\s*TIMECALC\s+OUTPUT\s*%*\s*$/i }
  $timecalc = shift unless eof;
  close(FILE);
}
unless ($timecalc) {
  # Prompt for filename
  print "\n\n";
  print "$border";
  print "Enter \"timecalc\" Output Filename\n";
  print "$border";
  print "\n";

  print "Please enter \"timecalc\" output filename:  ";
  chomp($timecalc = <STDIN>);
  print "\n";
}
$filename = (@ARGV ? shift : "&STDOUT"); 


##############################################################################

# Get full path of filenames
for $somefile ( \($filename, $timecalc)) {
  ($base, $dir) = fileparse($$somefile);
  unless ($base =~ m!^&! || $dir =~ m!^/!) {
    $dir =~ s!^./!!g;                              # remove leading "./"
    $$somefile = $ENV{'PWD'} . '/' . $dir . $base; # add current directory
    
  }
  $$somefile =~ s!//+!/!g;          # remove duplicate "/"s
}


##############################################################################

# read "timecalc" output
($tape_id_ref, $time_initial_ref, $thrust_time_ref) = timeread $timecalc;
@tape_id = @$tape_id_ref;  $no_tapes = @tape_id;
@time_initial = @$time_initial_ref;
@thrust_time = @$thrust_time_ref;


##############################################################################

print "\n\n";
print "$border";
print "Enter Movie Name and First Frame Time\n";
print "$border";
print "\n";


##############################################################################

for ($tape = 0; $tape < $no_tapes; $tape++) {
  print "\n";
  print "$border";
  printf "Enter Information for %s Tape \"%s\"\n"
    , $ordinal[$tape], $tape_id[$tape];
  print "$border";
  print "\n";

  # get movie filenames
  print "Please enter movie filename (with path) for \"" . 
    $tape_id[$tape] . "\":\n  ";
  chomp($movie_name[$tape] = <STDIN>);
  $movie_name[$tape] =~ s/^\s+//g; # remove leading spaces
  $movie_name[$tape] =~ s/\s+$//g; # remove trailing spaces
  print "\n";

  # get first valid frame numbers
  print "Please enter first valid frame number for movie \n  \"" . 
    $movie_name[$tape] . "\":  ";
  chomp($first_frame[$tape] = <STDIN>);
  print "\n";

  # get available and unavailable time formats
  @{$time_fmt_avail[$tape]} = @{$time_fmt_unavail[$tape]} = ();
  %count = ();
  foreach (@class, keys %{$time_initial[$tape]}) { #i.e. foreach $_
    $count{$_}++;
  }
  foreach (keys %count) { # i.e. foreach $_
    push @{ $count{$_} > 1 ?
	      $time_fmt_avail[$tape] : $time_fmt_unavail[$tape] }, $_;
  }

  printf "The available time formats are \"%s\" and \"%s\" for Tape \"%s\"\n"
    , $time_fmt_avail[$tape][0]->units, $time_fmt_avail[$tape][1]->units,
    $tape_id[$tape];
  printf "  (The time format \"%s\" is unavailable.)\n"
    , $time_fmt_unavail[$tape][0]->units
      unless $time_fmt_unavail[$tape][0] eq 'gmt';
  
  # get tape times
  do {
    print "Please enter tape time of first valid frame in \"GMT\" or in an available format\n  for movie \"" . $movie_name[$tape] . "\":\n  ";
    chomp($input = <STDIN>);
    $time = input->newstr($input);
  } while ((ref $time ne 'gmt') && $count{ref $time} <= 1 &&
  	   printf "TIME FORMAT \"%s\" IS UNAVAILABLE!  TRY AGAIN!\n"
	   , $time_fmt_unavail[$tape][0]->units);
  $first_time[$tape]{ref $time} = $time->clone();
  print "\n";

  push @have_gmt, $tape if exists($time_initial[$tape]{gmt});

}


##############################################################################

# relate movies
for ($tape = 0; $tape < $no_tapes; $tape++) {
  
  # compute first tape time in GMT (invalid time formats already weeded out)
  $inkey = (keys %{$first_time[$tape]})[0]; # works if only key for this tape
  $nokey = $time_fmt_unavail[$tape][0];
  
  # check if input a format that is already stored in the file
  unless ($inkey eq 'gmt' && $nokey eq 'gmt') {
    $outkey = $time_fmt_avail[$tape][$inkey eq $time_fmt_avail[$tape][0]];
    
    # convert formats
    $first_time[$tape]{$outkey} =
      $time_initial[$tape]{$outkey} +
	($first_time[$tape]{$inkey} - 
	 $time_initial[$tape]{$inkey}) -> convert($outkey);
  }
  
  if ($nokey eq 'gmt') { # need to synch with another tape
    
    print "\n";
    print "$border";
    printf "Synching Movie \"%s\".\n", $movie_name[$tape];
    print "$border";
    print "\n";
    
    printf "No \"GMT\" time available for movie \"%s\".\n"
      , $movie_name[$tape];
    if (@have_gmt) {
      
      
      ########################################################################
      
      # Utilize synching between tapes
      
      print "You must synch this with one of the following movies:\n";
      $j = 0;
      foreach (@have_gmt) {
	printf "  %s movie:  \"%s\"\n", $ordinal[$j++], $movie_name[$_];
      };
      print "\n";
      
      if (@have_gmt == 1) {
	$input = 1;
      }
      else {
	do {
	  printf "Which movie will you synch this with (%s)?  "
	    , (join ', ', @{[1..$j]});
	  chomp($input = <STDIN>);
	} while ($input < 1 && print "TAPE NUMBER TOO SMALL!  TRY AGAIN!\n")
	  || ($input > $j && print "TAPE NUMBER TOO LARGE!  TRY AGAIN!\n");
      }
      $tape_chosen = $have_gmt[--$input];
      print "\n";
      
      @tape_synch = ($tape, $tape_chosen);
      $synch_pair[$no_synchs++] = [ @tape_synch ];
      
      foreach $i (@tape_synch) {
	printf "Movie \"%s\"\n  has stored thruster firing times of:\n"
	  , $movie_name[$i];
	foreach $key (keys %{$thrust_time[$i]}) {
	  print " "x4 . ~$thrust_time[$i]{$key} . "\n"
	    unless ($key eq 'gmt');
	}
	print "\n";
      }
      
      $j = 0;
      foreach $i (@tape_synch) {
	$k = $tape_synch[1-$j]; # reference other synch tape
	printf "Please enter %s synched \"TCR\" or \"viGMT\" time for\n"
	  , $ordinal[$j++];
	#printf "Please enter %s synched frame number, ", $ordinal[$j++];
	#print "\"TCR\", or \"viGMT\" time for\n";
	printf "  movie \"%s\":\n  ", $movie_name[$i];
	chomp($input = <STDIN>);
	print "\n";
	#$input .= 'TCR'; # a way to temporarily change default to TCR
	$synch_time[$i][$k] = input->newstr($input);
	$key[$i] = ref $synch_time[$i][$k];
      }
      
      
      ########################################################################
      
      # Calculate with synch info
      
      # Note: $nokey = 'gmt';
      unless ($inkey eq 'gmt') {
	# $synch_time[$tape_chosen][$tape]{$key[$tape_chosen]}
	# $synch_time[$tape][$tape_chosen]{$key[$tape]}
	$first_time[$tape]{gmt} =
	  $time_initial[$tape_chosen]{gmt} +
	    $synch_time[$tape_chosen][$tape] -
	      $time_initial[$tape_chosen]{$key[$tape_chosen]} -
		$synch_time[$tape][$tape_chosen] +
		  $time_initial[$tape]{$key[$tape]} +
		    $first_time[$tape]{$inkey} -
		      $time_initial[$tape]{$inkey};
	
      }
      else { # i.e. if ($inkey eq 'gmt')
	# $synch_time[$tape][$tape_chosen]{$key[$tape]}
	# $synch_time[$tape_chosen][$tape]{$key[$tape_chosen]}
	$outkey = $time_fmt_avail[$tape][$key[$tape] eq
					 $time_fmt_avail[$tape][0]];
	
	$first_time[$tape]{$key[$tape]} =
	  $synch_time[$tape][$tape_chosen] +
	    ($first_time[$tape]{gmt} -
	     $time_initial[$tape_chosen]{gmt} -
	     $synch_time[$tape_chosen][$tape] +
	     $time_initial[$tape_chosen]{$key[$tape_chosen]}) ->
	       convert($key[$tape]);
	
	$first_time[$tape]{$outkey} =
	  $time_initial[$tape]{$outkey} +
	    ($first_time[$tape]{$key[$tape]} -
	     $time_initial[$tape]{$key[$tape]}) -> convert($outkey);
      } # end unless ($inkey eq 'gmt')
      
    }
    else { # i.e. unless (@have_gmt)
      $outkey = $time_fmt_avail[$tape][$inkey eq
				       $time_fmt_avail[$tape][0]];
      
      print "(or any other movies for that matter!)\n\n";
      
      printf "Please enter time bias in seconds relating \"%s\" to \"%s\"\n"
	, $nokey->units, $outkey->units;
      printf "  for Movie \"%s\" (i.e. %s - %s = s) [ss.sss]:  "
	, $movie_name[$tape], $outkey->units, $nokey->units;
      chomp($input = <STDIN>);
      print "\n";
      $input .= '.0' if (split (/\D+/, $input) < 2); # add ms if necessary
      $bias = gmt->newstr($input);
      $first_time[$tape]{gmt} = $first_time[$tape]{$outkey} + $bias;
    } # end if (@have_gmt)
    
  } # end if ($nokey eq 'gmt')
  
  
  ########################################################################
  
  # determine latest frame time
  $tape_last = $tape if $first_time[$tape]{gmt} > $first_time[$tape_last]{gmt};
  
} # end for ($tape = 0; ...)


##############################################################################

# compute new frame numbers
for ($tape = 0; $tape < $no_tapes; $tape++) {
  unless ($tape == $tape_last) {
    $delta = $first_time[$tape_last]{gmt} - $first_time[$tape]{gmt};
    $first_time[$tape]{gmt} = $first_time[$tape_last]{gmt};
    foreach $key (keys %{$time_initial[$tape]}) {
      #$delta = $first_time[$tape_last]{$key} - $first_time[$tape]{$key};
      $first_time[$tape]{$key} += $delta->convert($key)	unless ($key eq 'gmt');
    }
    $first_frame[$tape] += $delta->convert('tcr')->getframes;
  }
}


##############################################################################

# Generate Headers

for ($tape = 0; $tape < $no_tapes; $tape++) {
  $header1 .= sprintf "  %-16s", $tape_id[$tape]; 
  $header2 .= sprintf "  %-16s", "(Tape " . ($tape+1) . ")";
  $header3 .= sprintf "  %-16s", "-" x 16;
}


##############################################################################

# Report Results

open (FILENAME, ">$filename") ||
  die "Can't open $filename for writing! $!\n";

print "\n";
print "$border";
unless ($filename =~ /^&/) {
  print "Generating Report in File \"$filename\"\n";

  ############################################################################

  print FILENAME "$border";
  printf FILENAME "%s NSYNC OUTPUT %s\n", ('%' x 32), ('%' x 32);
  printf FILENAME "%s Version %3.1f %s\n", ('%' x 33), $version, ('%' x 32);
  print FILENAME "$border";
  print FILENAME "\n";

  print FILENAME "Input from File \"$timecalc\"\n";
  print FILENAME "Output to File \"$filename\"\n\n";

}
else {
  print "Report\n";
}
print "$border";
print "\n";


##############################################################################

# Record synch times, if available

unless (@have_gmt == $no_tapes) { # i.e. unless something was synched
  for ($i == 0; $i < $no_synchs; $i++) {
    ($tape, $tape_chosen) = @{$synch_pair[$i]};
    printf FILENAME "Synched \"%-16s\" at %s\n"
      , $tape_id[$tape], ~$synch_time[$tape][$tape_chosen];
    printf FILENAME "   to   \"%-16s\" at %s\n"
      , $tape_id[$tape_chosen], ~$synch_time[$tape_chosen][$tape];
  }
  print FILENAME "\n";
  print FILENAME "$border";
  print FILENAME "\n";
}


##############################################################################

for ($tape = 0; $tape < $no_tapes; $tape++) {
  printf FILENAME "Tape ID:  %-16s  Movie File: %s\n"
    , $tape_id[$tape], $movie_name[$tape];
}
print FILENAME "\n";


##############################################################################

print  FILENAME " First \n";
printf FILENAME " Frame %s\n", $header1;
printf FILENAME " Times %s\n", $header2;
printf FILENAME "-------%s\n", $header3;

# print time rows
for ($i = 0; $i < 3 ; $i++) {
  printf FILENAME " %s ", $class[$i]->cunits;
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    $output = " ";
    $output = $first_time[$tape]{$class[$i]}->clone()
      if exists($first_time[$tape]{$class[$i]});
    printf FILENAME "  %16s", $output;
  }
  print  FILENAME "\n";
}

# print frame row
printf FILENAME " %s ", 'Frame';
for ($tape = 0; $tape < $no_tapes; $tape++) {
  printf FILENAME "  %16d", $first_frame[$tape];
}
print FILENAME "\n";


##############################################################################

print FILENAME "\n";
print FILENAME "$border";
$now = strftime "%KC", localtime;
printf FILENAME "%s TIMESTAMP %s %s\n", ('%' x 19), $now, ('%' x 19);
print FILENAME "$border";
print FILENAME "\n";


##############################################################################

close (FILENAME) || die "Can't close $filename! $!\n";
