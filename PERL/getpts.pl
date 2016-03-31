#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 05-02-01  1.0  K. Crosby     First Release
# 07-18-01  1.1  K. Crosby     Fixed missed tracks and full path, and
#                              output version and timestamp to files.
# 01-07-03  1.2  K. Crosby     Now accepts any number of residual pairs.
# 01-23-03  1.3  K. Crosby     Fixed data with no space after "N/A".


#use strict;               # won't work for file handle
use POSIX qw(strftime);   # for timestamping using strftime function
use File::Basename;

my ($version) = 1.3;


# Define constants
my ($border) = ("#" x 116) . "\n";


# Declare input variables
my ($ptsfile);


# Declare read variables
my ($frame_no, $id, @numbers);


# Declare output variables
my ($filename);


# Declare calculated variables
my ($dir, $base);
my ($now);


# Declare other variables
my (%line) = ();
my (%count, @blank);
my ($no_res_pairs);
my ($num_fmt);


##############################################################################

# Parse command line
$ptsfile = (@ARGV ? shift : "&STDIN"); 


##############################################################################

# Get full path of filename
($base, $dir) = fileparse($ptsfile);
unless ($base =~ m!^&! || $dir =~ m!^/!) {
  $dir =~ s!^./!!g;                            # remove leading "./"
  $ptsfile = $ENV{'PWD'} . '/' . $dir . $base; # add current working directory

}
$ptsfile =~ s!//+!/!g;          # remove duplicate "/"s


##############################################################################

open (PTSFILE, "$ptsfile") || die "Can't open $ptsfile for reading! $!\n";

while (<PTSFILE>) {
  chomp;
  /^\#Frame\sNumber:/ && do { # search for next frame number
    ($frame_no) = (split)[2];
    print ( $frame_no % 10 ? "." : $frame_no );
    print "\n" unless $frame_no % 50;
    %count = ();  # reset counters
    @blank = ();
    #<PTSFILE>; #OBJECT POINT REPORT
    #<PTSFILE>; #
    #<PTSFILE>; #Units: unknown
    #<PTSFILE>; #
    #<PTSFILE>; #Point        X        Y        Z      Sig X  Sig Y  Sig Z ...
    #<PTSFILE>; #-------------------------------------------------------------
    while (<PTSFILE>) { # i.e. $_ = <PTSFILE>
      /^\s/ && do { last; };
      /^Bundle\sSigma\sReference:/i && do { last; };
      chomp;
      /^\w/ && do {
        s!N/A!$& !gi;  # Sometimes file contains N/A+[0-9]* or N/A-[0-9]*
	($id, @numbers) = split;
        $no_res_pairs = (@numbers - 9) / 2;
	$filename = $ptsfile . "." . $id;
	unless ( $line{$id} ) {
	  open ($id, ">$filename") ||
	    die "Can't open $filename for writing! $!\n";

	  print $id "$border";
	  printf $id "%s GETPTS OUTPUT %s\n", ('#' x 51), ('#' x 50);
	  printf $id "%s Version %3.1f %s\n", ('#' x 52), $version, ('#' x 51);
	  print $id "$border";
	  print $id "\n";

	  print $id "#Point Identifier $id\n";
	  print $id "#\n";
	  print $id "#Input from File \"$ptsfile\"\n";
	  print $id "#Output to File \"$filename\"\n";
	  print $id "#\n";
	  printf $id 
	    "%-6s %5s %9s %9s %11s %7s %7s %8s %6s %7s %6s %7s",
	    "#Frame", "X", "Y", "Z", "Sig X", "Sig Y", "Sig Z",
	    "#Photos", "AV_MC", "MAX_MC", "rx1", "ry1";
          for (my $i = 2; $i <= $no_res_pairs; $i++) {
            printf $id " %7s %7s", ("rx" . $i), ("ry" . $i);
          }
          printf $id "\n";
	}
	$line{$id} = [$frame_no, @numbers];
	$count{$id}++;
        $num_fmt = "%-6s %8s %9s %9s %8s %7s %7s %5s %9s %7s";
        $num_fmt .= " %7s %7s" x $no_res_pairs . "\n";
	printf $id $num_fmt, @{$line{$id}};
      };
    } # end while

    # account for missing tracks
    foreach $id (keys %line) { $count{$id}++ }
    foreach $id (keys %count) {
      push @blank, $id unless $count{$id} > 1;
    }
    foreach $id (@blank) { # write blanks to file
      printf $id "%-6s\n", $frame_no;
    }

  }
} # end while
print "\n\n";


##############################################################################

$now = strftime "%KC", localtime;
foreach $id (keys %line) {
  print $id "\n";
  print $id "$border";
  printf $id "%s TIMESTAMP %s %s\n", ('#' x 38), $now, ('#' x 38);
  print $id "$border";
  print $id "\n";

  close($id) || die "Can't close $ptsfile.$id! $!\n";
}


##############################################################################

close (PTSFILE) || die "Can't close $ptsfile! $!\n";
