#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 03-26-01  1.0  K. Crosby     First Release
# 08-01-01  1.1  K. Crosby     Added full path, version, and timestamp.
# 10-05-01  1.2  K. Crosby     Changed '/^Photo:\s*$ImageKey\s*/i' line to
#                              handle multiple spaces and non-word boundaries
#                              such as $ImageKey = "P1-CAMC-".
# 01-28-02  1.3  K. Crosby     Changed header line to look for "Frame" instead
#                              of not a double quote, which Donn has forgotten
#                              to put into the files.


use strict;
use POSIX qw(strftime);   # for timestamping using strftime function
use File::Basename;

my ($version) = 1.3;


# Define constants
my ($border) = ("#" x 78) . "\n";
my ($flag) = -999.99;


# Declare input variables
my (@trackfiles, $rasfile, $rptfile);
my ($sd_x, $sd_y, @PointIDs);


# Declare read variables
my ($ImageKey, $SensorKey, @T2DaffineVect, @T2DaffineMat); # RAS parms
my (@Xcomg, @Ycphi, @Zckap);
my (@EOImage, @EOImageStdDev); # RPT parms
my ($start_frame);


# Declare output variables
my ($imgfile);


# Declare calculated variables
my ($no_rows, @columns, $no_columns, $no_files);
my ($dir, $base);
my ($now);


# Declare other variables
my ($somefile);
my ($i, $j, $m, $n);
my ($col_no, $line, $header, %location);
my ($filler, @numbers, @frame, @time, @x, @y);


##############################################################################
# PARSE INPUTS
##############################################################################

die "Usage: mkimg -ras rasfile -rpt rptfile -pid ptID1 ptID2 ...
             -trk trackfile1 trackfile2 ...
             -sd std_x std_y -img imgfile\n" unless @ARGV;

@trackfiles = ();
@PointIDs = ();
while ($_ = $ARGV[0]) {
  shift;
  #print "$_\n";
  /^-ras/ && do { ($rasfile) = @ARGV; };
  /^-rpt/ && do { ($rptfile) = @ARGV; };
  /^-sd/ && do { ($sd_x, $sd_y) = @ARGV[0,1]; shift; };
  /^-img/ && do { ($imgfile) = @ARGV; };
  if (/^-trk/) {
    do { push(@trackfiles, $ARGV[0]); shift; }
    while @ARGV && $ARGV[0] =~ /^[^-]/;
  }
  if (/^-pid/) {
    do { push(@PointIDs, $ARGV[0]); shift; }
    while @ARGV && $ARGV[0] =~ /^[^-]/;
  }
}

die "Need RAS file!\n" unless $rasfile && -e $rasfile;
die "Need RPT file!\n" unless $rptfile && -e $rptfile;
die "Need Standard Deviations!\n" unless $sd_x && $sd_y;
die "Need IMG file!\n" unless $imgfile;
die "Need Nanotrack input files!\n" unless @trackfiles;
die "Need Point Identifiers!\n" unless @PointIDs;

print "trackfiles:\t@trackfiles\n";
print "rasfile:\t$rasfile\n";
print "rptfile:\t$rptfile\n";
print "sd_x:\t$sd_x\tsd_y:\t$sd_y\n";
print "PointIDs:\t@PointIDs\n";
print "imgfile:\t$imgfile\n";


##############################################################################
# GET FULL PATH OF FILENAMES
##############################################################################

for $somefile (\($rasfile, $rptfile, (@trackfiles), $imgfile)) {
  ($base, $dir) = fileparse($$somefile);
  unless ($base =~ m!^&! || $dir =~ m!^/!) {
    $dir =~ s!^./!!g;                              # remove leading "./"
    $$somefile = $ENV{'PWD'} . '/' . $dir . $base; # add current directory
    
  }
  $$somefile =~ s!//+!/!g;          # remove duplicate "/"s
}


##############################################################################
# READ INPUTS
##############################################################################

# read RAS file
open (RASFILE, "$rasfile") || die "Can't open $rasfile for reading! $!\n";

while (<RASFILE>) { # i.e. $_ = <RASFILE>
  chomp;
  # simulate switch statement
  /\bImageKey\b/i && do { ($ImageKey) = (split)[1] ;};
  /\bSensorKey\b/i && do { ($SensorKey) = (split)[1]; };
  /\bT2DAffineVec/i && do { (@T2DaffineVect) = (split)[1..2]; };
  /\bT2DAffineMat/i && do { (@T2DaffineMat) = (split)[1..4]; };
}

#print "$ImageKey\n$SensorKey\n(@T2DaffineVect)\n(@T2DaffineMat)\n";

close (RASFILE) || die "Can't close $rasfile! $!\n";

# read RPT file
open (RPTFILE, "$rptfile") || die "Can't open $rptfile for reading! $!\n";

while (<RPTFILE>) {
  chomp;
  if (/^Photo:\s*$ImageKey\s*/i) { # search for appropriate photo
    #<RPTFILE>; # ---------------
    #<RPTFILE>; # Position                     Orientation 
    while (<RPTFILE>) { # i.e. $_ = <RPTFILE>
      chomp;
      /^Xc/ && do { @Xcomg = split; };
      /^Yc/ && do { @Ycphi = split; };
      /^Zc/ && do { @Zckap = split; last; };
    }
    last;
  }
}
@EOImage =
  ($Xcomg[1], $Ycphi[1], $Zckap[1], $Xcomg[5], $Ycphi[5], $Zckap[5]);
@EOImageStdDev = 
  ($Xcomg[3], $Ycphi[3], $Zckap[3], $Xcomg[7], $Ycphi[7], $Zckap[7]);

#print "(@EOImage)\n(@EOImageStdDev)\n";

close (RPTFILE) || die "Can't close $rptfile! $!\n";


# open Nanotrack files
$no_files = @trackfiles;
foreach $j (0..$no_files-1) {
  # find header
  open (NANOFILE, $trackfiles[$j]) ||
    die "Can't open $trackfiles[$j] for reading! $!\n";
  while (defined($line = <NANOFILE>)) {
    chomp($line);
    if ($line =~ /^Frame/ && $line =~ /-*X-*/) {
      $header = $line;
      last; # break out of while loop
    }
  }
  
  # determine which columns are included in header
  @columns = split /\s+/, $header;
  $no_columns = @columns;
  foreach $col_no (0..$no_columns-1) {
    $columns[$col_no] =~ s/-//g;
    $columns[$col_no] =~ s/ID/Frame/g;
    $location{$columns[$col_no]} = $col_no;
  }
  
  $filler = " $flag" x ($no_columns-1);
  
  # extract numbers
  $i = 0;
  while (defined($line = <NANOFILE>)) {
    chomp($line);
    if ($line =~ /[-.\d]/) {
      $line =~ s/--/$filler/;
      @numbers = split /\s+/, $line;
    }
    $frame[$i] = $i;
    #$frame[$i] = $numbers[$location{'Frame'}];
    $start_frame = $numbers[$location{'Frame'}] if $i == 0;
    if ($location{'Time'} && $numbers[$location{'Time'}] >= 0) {
      if (defined($time[$i])) {
	$time[$i] = $numbers[$location{'Time'}] if $time[$i] > $numbers[$location{'Time'}];
      }
      else {
	$time[$i] = $numbers[$location{'Time'}];
      }
    }
    $x[$i][$j] = $numbers[$location{'X'}];
    $y[$i][$j] = $numbers[$location{'Y'}];
    $i++;
  }

  # add filler to previous x and y columns if necessary
  $no_rows = $i if $j == 0;
  if ( $no_rows < $i ) {
    foreach $m ($no_rows..$i-1) {
      foreach $n (0..$j-1) {
	$x[$m][$n] = $y[$m][$n] = $flag;
      }
    }
    $no_rows = $i;
  } elsif ( $no_rows > $i ) {
    foreach $m ($i..$no_rows-1) {
      $x[$m][$j] = $y[$m][$j] = $flag;
    }
  }

  close (NANOFILE) || die "Can't close $trackfiles[$j]!";
} # end foreach


##############################################################################
# WRITE OUTPUT
##############################################################################

open (IMGFILE, ">$imgfile") ||
  die "Can't open $imgfile for writing! $!\n";


##############################################################################
      
print IMGFILE "$border";
printf IMGFILE "%s MKIMG OUTPUT %s\n", ('#' x 32), ('#' x 32);
printf IMGFILE "%s Version %3.1f %s\n", ('#' x 33), $version
  , ('#' x 32);
print IMGFILE "$border";
print IMGFILE "\n";

printf IMGFILE "#Input RAS File\t\"%s\"\n", $rasfile;
printf IMGFILE "#Input Report File\t\"%s\"\n", $rptfile;
foreach $j (0..$no_files-1) {
  printf IMGFILE "#Input Track File #%d\t\"%s\"\n", $j, $trackfiles[$j];
}
print IMGFILE "\n";

printf IMGFILE "#Output Image File \"%s\"\n\n", $imgfile;


##############################################################################

# write RAS file components
print IMGFILE "# Sensor ID EO Parameters and Image Coordinates\n";

print IMGFILE "# Image Name\n";
printf IMGFILE "%-15s %s\n", "ImageKey", $ImageKey;

print IMGFILE "# Sensor Name\n";
printf IMGFILE "%-15s %s\n", "SensorKey", $SensorKey;

print IMGFILE "# 2-D Affine Transform Information\n";
printf IMGFILE "%-15s %f %f\n", "T2DaffineVect", @T2DaffineVect;
printf IMGFILE "%-15s %f %f %f %f\n", "T2DaffineMat", @T2DaffineMat;


# write RPT file components
printf IMGFILE "%-15s %8s %8s %8s %9s %9s %9s\n",
  '# EO Parameters',
  'X', 'Y', 'Z', 'Omega', 'Phi', 'Kappa';
printf IMGFILE "%-15s %8.3f %8.3f %8.3f %9.5f %9.5f %9.5f\n",
  'EOImage', @EOImage;

printf IMGFILE "%-23s %5s %5s %5s %9s %9s %9s\n",
  '# Std Dev EO Parameters',
  'SD-X', 'SD-Y', 'SD-Z', 'SD-Omega', 'SD-Phi', 'SD-Kappa';
printf IMGFILE "%-23s %5.3f %5.3f %5.3f %9.5f %9.5f %9.5f\n",
  'EOImageStdDev', @EOImageStdDev;


# write point identifiers
printf IMGFILE "%-23s", "# Point ID Labels";
foreach $j (1..$no_files) {
  printf IMGFILE "pt%d ", $j;
}
print IMGFILE "\n";
printf IMGFILE "%-23s", "PointIDs";
print IMGFILE "@PointIDs[0..$no_files-1]\n";


# write Nanotrack coordinates
print IMGFILE "# Multi-point Image Coordinates per Frame\n";
print IMGFILE "# Frame \"0\" corresponds to actual frame \"$start_frame\"\n";
printf IMGFILE "# %-5s %-5s", 'Frame', 'Time';
foreach $j (0..$no_files-1) {
  printf IMGFILE " %2s(pt%d)  %-7s%-4s %-4s",
  'X', ($j+1), 'Y', 'SD-X', 'SD-Y';
}
print IMGFILE "\nImageCoords\n";
foreach $i (0..$no_rows-1) {
  $time[$i] = 0 if (!defined($time[$i]));
  printf IMGFILE "%-7d %5.3f", $frame[$i], $time[$i];
  foreach $j (0..$no_files-1) {
    printf IMGFILE " %7.2f %7.2f %4.2f %4.2f", 
    $x[$i][$j], $y[$i][$j], $sd_x, $sd_y;
  }
  print IMGFILE "\n";
}

  
##############################################################################

print IMGFILE "\n";
print IMGFILE "$border";
$now = strftime "%KC", localtime;
printf IMGFILE "%s TIMESTAMP %s %s\n", ('#' x 19), $now, ('#' x 19);
print IMGFILE "$border";
print IMGFILE "\n";


##############################################################################

close (IMGFILE) || die "Can't close $imgfile! $!\n";
