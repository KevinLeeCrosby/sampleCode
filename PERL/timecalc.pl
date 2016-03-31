#!/bin/perl

# DATE      VER  NAME          DESCRIPTION
# 01-29-01  1.0  K. Crosby     First Release
# 05-30-01  2.0  K. Crosby     Added support for more than two cameras.
#                              Added support for Vertical Interval GMT.
#                              Added full path, version, and timestamp.


use strict;
use timecalc;
use POSIX qw(strftime);   # for timestamping using strftime function
use File::Basename;

my ($version) = 2.0;


# Define constants
my ($start_record_delta)  = tcr->new(qw(00 00 00 30 00));
my ($end_record_delta) = tcr->new(qw(00 00 03 30 00));

my ($border) = ("%" x 78) . "\n";
my (@class) = qw(gmt vigmt tcr);


# Declare input variables
my ($filename);
my ($no_tapes, @tape_id, $tape);
my ($thrust_gmt);    # subtest thruster pulse times (GMT)
my ($input, $output, $time);
my ($final, @final);
my (@time_initial);  # initial time synch for each tape
my (@time_ending);   # ending time synch for each tape
my (@bias); # bias relating viGMT to GMT (if necessary)


# Declare calculated variables
my ($dir, $base);
my (@bias_initial, @bias_ending);  # bias for each tape
my (@bias_delta);
my (@thrust_time);       # subtest thruster pulse times for each tape
my (@video_initial);  # initial time synch for each tape
my (@video_ending);   # ending time synch for each tape
my (@video_delta);
my (@video_seconds, @video_frames);

my ($now);


# Declare other variables
my ($i);
my ($key, $inkey, $outkey, @usedkeys);


##############################################################################

# Give instructions to user

print "\n";
print "$border";
print "$border";
printf "%s WELCOME TO THE TIME CALCULATOR %s\n", ('%' x 23), ('%' x 23);
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

# Parse command line
$filename = (@ARGV ? shift : "&STDOUT"); 


##############################################################################

# Get full path of filename
($base, $dir) = fileparse($filename);
unless ($base =~ m!^&! || $dir =~ m!^/!) {
  $dir =~ s!^./!!g;                             # remove leading "./"
  $filename = $ENV{'PWD'} . '/' . $dir . $base; # add current working directory

}
$filename =~ s!//+!/!g;          # remove duplicate "/"s


##############################################################################

# Prompt user for inputs
print "\n\n";
print "$border";
print "Subtest Thruster Pulse Time\n";
print "$border";
print "\n";
  
print "Please enter GMT Time for Test Pulse:\n  ";
chomp($input = <STDIN>);
$thrust_gmt = gmt->newstr($input);

  
##############################################################################

print "\n\n";
print "$border";
print "Tape Identifiers\n";
print "$border";
print "\n";

print "Please enter number of tapes:  ";
chomp($no_tapes = <STDIN>);
print "\n";


##############################################################################

for ($tape = 0; $tape < $no_tapes; $tape++) {
  do {
    print "Please enter Tape Identifier for Tape #" . ($tape+1) . 
      " (16 chars or less):\n  ";
    chomp($tape_id[$tape] = <STDIN>);
    $tape_id[$tape] =~ s/\s+/ /g; # compress whitespace
    $tape_id[$tape] =~ s/^\s+//g; # remove leading whitespace
    $tape_id[$tape] =~ s/\s+$//g; # remove trailing whitespace
  } while length($tape_id[$tape]) > 16 && print "TOO LONG!  TRY AGAIN!\n";
  print "\n";
}


##############################################################################

for ($tape = 0; $tape < $no_tapes; $tape++) {

  print "\n\n";
  print "$border";
  print "Initial Time Synch for \"" . $tape_id[$tape] . "\"\n";
  print "$border";
  print "\n";

  print "Please enter first initial time for Tape \""
    . $tape_id[$tape] . "\":\n  ";
  chomp($input = <STDIN>);
  print "\n";
  $time = input->newstr($input);
  $inkey = ref $time;
  $time_initial[$tape]{$inkey} = $time->clone();

  do {
    print "Please enter second initial time for Tape \""
      . $tape_id[$tape] . "\":\n  ";
    chomp($input = <STDIN>);
    $time = input->newstr($input);
    $outkey = ref $time;
  } while (($inkey eq $outkey) &&
           print "INITIAL TIMES MUST BE IN DIFFERENT FORMATS!  TRY AGAIN!\n");
  $time_initial[$tape]{$outkey} = $time->clone();

  # Swap time keys, if necessary, based on time hierarchy (GMT->viGMT->TCR)
  if ($outkey->isa($inkey)) {
    $key = $inkey;
    $inkey = $outkey;
    $outkey = $key;
  }

  # Store time keys for later
  @usedkeys = ($inkey, $outkey);


  ############################################################################

  # Initial Time Bias (in GMT or viGMT) (valid combos are vg, tg, or tv)
  $bias_initial[$tape] =
    $time_initial[$tape]{$inkey} - $time_initial[$tape]{$outkey};


  ############################################################################

  print "\n\n";
  print "$border";
  print "Ending Time Synch for \"" . $tape_id[$tape] . "\"\n";
  print "$border";
  print "\n";

  print "Do you have Ending Times for synching \"" . $tape_id[$tape] . 
    "\" (y|[n])?  ";
  chomp($final[$tape] = <STDIN>);

  if ( $final[$tape] =~ /^[yY]/ ) {
    $final = "defined"; # define $final variable (different than @final)
    print "\n";
    
    print "Please enter first ending time for Tape \""
      . $tape_id[$tape] . "\":\n  ";
    chomp($input = <STDIN>);
    print "\n";
    $time = input->newstr($input);
    $inkey = ref $time;
    $time_ending[$tape]{$inkey} = $time->clone();
    
    do {
      print "Please enter second ending time for Tape \""
	. $tape_id[$tape] . "\":\n  ";
      chomp($input = <STDIN>);
      $time = input->newstr($input);
      $outkey = ref $time;
    } while (($inkey eq $outkey) &&
	     print "ENDING TIMES MUST BE IN DIFFERENT FORMATS!  TRY AGAIN!\n");
    $time_ending[$tape]{$outkey} = $time->clone();
    
    ##########################################################################

    # Swap time keys, if necessary, based on time hierarchy (GMT->viGMT->TCR)
    if ($outkey->isa($inkey)) {
      $key = $inkey;
      $inkey = $outkey;
      $outkey = $key;
    }
  }
  else {
    foreach $key (@usedkeys) {
      $time_ending[$tape]{$key} = $time_initial[$tape]{$key}->clone();
    }
  }


  ############################################################################

  # Ending Time Bias (in GMT or viGMT) (valid combos are vg, tg, or tv)
  $bias_ending[$tape] =
    $time_ending[$tape]{$inkey} - $time_ending[$tape]{$outkey};


  ############################################################################

  # Difference in Time Bias (in GMT or viGMT) (valid combos are gg, gv, or vv)
  $bias_delta[$tape] = abs($bias_initial[$tape] - $bias_ending[$tape]);

  
  ############################################################################

  # Retrive time keys
  ($inkey, $outkey) = @usedkeys;


  ############################################################################

  # Subtest Thruster Pulse Times (in GMT)
  # t(o) = f1(g) = g + o; (valid combos are gg, gv, or vv)
  $thrust_time[$tape]{gmt} = $thrust_gmt->clone();
  if (exists $time_initial[$tape]{gmt}) { # (i.e. gv or gt)
    $thrust_time[$tape]{$inkey} = ($thrust_gmt + $bias_initial[$tape])
      ->convert($inkey);
  }
  else { # (i.e. vt)
    print "\n\n";
    print "$border";
    print "Relate GMT to Vertical Interval GMT for \"" . 
      $tape_id[$tape] . "\"\n";
    print "$border";
    print "\n";

    print "Please enter approximate time bias in seconds relating \"GMT\" to \"viGMT\"\n  for Tape \"" . $tape_id[$tape] . "\" (i.e. viGMT - GMT = s) [ss.sss]:\n  ";
    chomp($input = <STDIN>);
    $input .= '.0' if (split (/\D+/, $input) < 2); # add ms if necessary
    $bias[$tape] = gmt->newstr($input);

    $thrust_time[$tape]{$outkey} = ($thrust_gmt + $bias[$tape])
      ->convert($outkey);     # $outkey will be "vigmt"
    $thrust_time[$tape]{$inkey} =
      ($thrust_gmt + $bias[$tape] + $bias_initial[$tape])
	->convert($inkey);    # $inkey will be "tcr"
  }

  foreach $key (keys %{$thrust_time[$tape]}) { # will include $thrust_gmt
    # Video Segment to be Digitized
    $video_initial[$tape]{$key} =
      $thrust_time[$tape]{$key} - $start_record_delta;
    $video_ending[$tape]{$key} =
      $thrust_time[$tape]{$key} + $end_record_delta;
  }

  $video_delta[$tape] =
    $video_ending[$tape]{$outkey} - $video_initial[$tape]{$outkey};

  $video_seconds[$tape] = $video_delta[$tape]->getseconds();
  $video_frames[$tape] = $video_delta[$tape]->convert('tcr')->getframes();
}

  
##############################################################################

# Generate Headers
my ($header1, $header2, $header3);

$header1 = $header2 = $header3 = "";
for ($tape = 0; $tape < $no_tapes; $tape++) {
  $header1 .= sprintf "  %-16s", $tape_id[$tape]; 
  $header2 .= sprintf "  %-16s", "(Tape " . ($tape+1) . ")";
  $header3 .= sprintf "  %-16s", "-" x 16;
}


##############################################################################

# Report Results

open (FILENAME, ">$filename") ||
  die "Can't open $filename for writing! $!\n";

print "\n\n";
print "$border";
unless ($filename =~ /^&/) {
  print "Generating Report in File \"$filename\"\n";

  ############################################################################

  print FILENAME "$border";
  printf FILENAME "%s TIMECALC OUTPUT %s\n", ('%' x 31), ('%' x 30);
  printf FILENAME "%s Version %3.1f %s\n", ('%' x 33), $version, ('%' x 32);
  print FILENAME "$border";
  print FILENAME "\n";

  print FILENAME "Output to File \"$filename\"\n\n";

}
else {
  print "Report\n";
}
print "$border";
print "\n";


##############################################################################

print  FILENAME " Initial\n";
printf FILENAME "  Time  %s\n", $header1;
printf FILENAME "  Synch %s\n", $header2;
printf FILENAME "--------%s\n", $header3;

for ($i = 0; $i < 3 ; $i++) {
  printf FILENAME "  %s ", $class[$i]->cunits;
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    $output = " ";
    $output = $time_initial[$tape]{$class[$i]}->clone()
      if exists($time_initial[$tape]{$class[$i]});
    printf FILENAME "  %16s", $output;
  }
  print  FILENAME "\n";
}

printf FILENAME "--------%s\n", $header3;
printf FILENAME "  Bias: ";

for ($tape = 0; $tape < $no_tapes; $tape++) {
  printf FILENAME "  %16s", $bias_initial[$tape];
}
print  FILENAME "\n\n";


##############################################################################

if ( defined($final) )  {

  print  FILENAME " Ending \n";
  printf FILENAME "  Time  %s\n", $header1;
  printf FILENAME "  Synch %s\n", $header2;
  printf FILENAME "--------%s\n", $header3;

  for ($i = 0; $i < 3 ; $i++) {
    printf FILENAME "  %s ", $class[$i]->cunits;
    for ($tape = 0; $tape < $no_tapes; $tape++) {
      $output = " ";
      if ( $final[$tape] =~ /^[yY]/ ) {
	$output = $time_ending[$tape]{$class[$i]}->clone()
	  if exists($time_ending[$tape]{$class[$i]});
      }
      else {
	$output = "      N / A     " if $i == 1; # change for viGMT
      }
      printf FILENAME "  %16s", $output;
    }
    print  FILENAME "\n";
  }
  
  printf FILENAME "--------%s\n", $header3;
  printf FILENAME "  Bias: ";
  
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    printf FILENAME "  %16s",
    ( $final[$tape] =~ /^[yY]/ ? $bias_ending[$tape] : " ");
  }
  print  FILENAME "\n\n";

}


##############################################################################

if ( defined($final) )  {

  printf FILENAME "  Delta %s\n", $header1;
  printf FILENAME "  Bias  %s\n", $header2;
  printf FILENAME "--------%s\n", $header3;

  print  FILENAME "        ";
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    printf FILENAME "  %16s", 
    ( $final[$tape] =~ /^[yY]/ ? $bias_delta[$tape] : "      N / A     " );
  }
  print  FILENAME "\n\n";

  print  FILENAME "        ";
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    printf FILENAME "  %-16s",
    ( $final[$tape] =~ /^[yY]/ ? "  APPROVED ___  " : " ");
  }
  print  FILENAME "\n\n";

  print  FILENAME "        ";
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    printf FILENAME "  %-16s",
    ( $final[$tape] =~ /^[yY]/ ? "  REJECTED ___  " : " ");
  }
  print  FILENAME "\n\n";

}


##############################################################################

print  FILENAME " Subtest\n";
printf FILENAME "Thruster\n";
printf FILENAME "  Pulse %s\n", $header1;
printf FILENAME "  Time  %s\n", $header2;
printf FILENAME "--------%s\n", $header3;

for ($i = 0; $i < 3 ; $i++) {
  printf FILENAME "  %s ", $class[$i]->cunits;
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    $output = " ";
    $output = $thrust_time[$tape]{$class[$i]}->clone()
      if exists($thrust_time[$tape]{$class[$i]});
    printf FILENAME "  %16s", $output;
  }
  print  FILENAME "\n";
}
print  FILENAME "\n";


##############################################################################

print  FILENAME "  Video*\n";
printf FILENAME " Segment\n";
printf FILENAME "  to be %s\n", $header1;
printf FILENAME "Captured%s\n", $header2;
printf FILENAME "--START-%s\n", $header3;

for ($i = 0; $i < 3 ; $i++) {
  printf FILENAME "  %s ", $class[$i]->cunits;
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    $output = " ";
    $output = $video_initial[$tape]{$class[$i]}->clone()
      if exists($video_initial[$tape]{$class[$i]});
    printf FILENAME "  %16s", $output;
  }
  print  FILENAME "\n";
}
printf FILENAME "---END--%s\n", $header3;
for ($i = 0; $i < 3 ; $i++) {
  printf FILENAME "  %s ", $class[$i]->cunits;
  for ($tape = 0; $tape < $no_tapes; $tape++) {
    $output = " ";
    $output = $video_ending[$tape]{$class[$i]}->clone()
      if exists($video_ending[$tape]{$class[$i]});
    printf FILENAME "  %16s", $output;
  }
  print  FILENAME "\n";
}
printf FILENAME "--------%s\n", $header3;

print  FILENAME "Seconds:";
for ($tape = 0; $tape < $no_tapes; $tape++) {
  printf FILENAME "  %16.2f", $video_seconds[$tape];
}
print  FILENAME "\n";
print  FILENAME " Frames:";
for ($tape = 0; $tape < $no_tapes; $tape++) {
  printf FILENAME "  %16.2f", $video_frames[$tape];
}
print  FILENAME "\n";
print  FILENAME "  * Include 30 seconds of video before the initial pulse\n";
print  FILENAME "    and 3 minutes and 30 seconds after the initial pulse.\n";


##############################################################################

print FILENAME "\n";
print FILENAME "$border";
$now = strftime "%KC", localtime;
printf FILENAME "%s TIMESTAMP %s %s\n", ('%' x 19), $now, ('%' x 19);
print FILENAME "$border";
print FILENAME "\n";


##############################################################################

close (FILENAME) || die "Can't close $filename! $!\n";

