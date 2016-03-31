#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 03-26-01  1.0  K. Crosby     First Release


use strict;
use Cwd;

my ($version) = 1.0;


# Define constants
my ($border) = ("#" x 78) . "\n";


# Declare input variables
my ($no_stations, $station);
my (%count, $no_records);
my ($no_points, $point);
my ($sd_x, $sd_y);
my ($rasfile, $inrptfile, $newinrptfile);
my (@PointIDs, @trackfiles, @imgfiles);
my ($senpath, $ctlfile, $cnsfile, $ptsfile, $outrptfile, $rpttype, $seqfile);
my ($freq, $cal);


# Declare read variables


# Declare calculated variables
my ($dir, $base);
my ($pwd) = cwd();


# Declare other variables



##############################################################################

@imgfiles = ();
%count = ();


print "Enter # of Camera Stations:  ";
chomp($no_stations = <STDIN>);

foreach $station (1..$no_stations) {
  print "\n";
  print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
  print "Camera Station #$station\n";
  print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
  print "\n";
  
  do {
    if ($inrptfile) {
      print "Enter input report filename for Camera Station #$station [$inrptfile]:  ";
      chomp($newinrptfile = <STDIN>);
      $inrptfile = $newinrptfile if $newinrptfile;
    }
    else {
      print "Enter input report filename for Camera Station #$station:  ";
      chomp($inrptfile = <STDIN>);
    }
    print "BAD input report filename!!\n\n" unless -e $inrptfile;
  } until -e $inrptfile;

  until ($rasfile && -e $rasfile) {
    print "Enter input RAS filename for Camera Station #$station:  ";
    chomp($rasfile = <STDIN>);
    print "BAD RAS filename!!\n\n" unless -e $rasfile;
  }

  print "Enter # of Points tracked for Camera Station #$station:  ";
  chomp($no_points = <STDIN>);
  
  print "Enter standard deviation in x:  ";
  chomp($sd_x = <STDIN>);

  print "Enter standard deviation in y:  ";
  chomp($sd_y = <STDIN>);

  foreach $point (1..$no_points) {
    print "\n<< Point #$point >>\n";

    print "Enter point identifier for pt$point:  ";
    chomp($PointIDs[$point-1] = <STDIN>);

    # keep track of how many times we've seen this point for record keeping
    $count{$PointIDs[$point-1]}++;

    until ($trackfiles[$point-1] && -e $trackfiles[$point-1]) {
      print "Enter input Nanotrack filename for \"$PointIDs[$point-1]\":  ";
      chomp($trackfiles[$point-1] = <STDIN>);
      print "BAD Nanotrack filename!!\n\n" unless -e $trackfiles[$point-1];
    }
  }

  print "\n";

  print "Enter output IMG filename for Camera Station #$station:  ";
  chomp($imgfiles[$station-1] = <STDIN>);

  print "\nCreating IMG file, \"$imgfiles[$station-1]\".\n";

  system("mkimg -ras $rasfile -rpt $inrptfile -pid @PointIDs -trk @trackfiles -sd $sd_x $sd_y -img $imgfiles[$station-1]");

  $rasfile = $newinrptfile = "";
  @PointIDs = @trackfiles = (); # clear lists
}

# determine how many records based on PointIDs between pairs of camera stations
$no_records = 0;
foreach (keys %count) { # i.e. foreach $_ (keys %count)
  $no_records++ if ($count{$_} > 1);
}


print "\n";
print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
print "FotoG-SEQ Control File\n";
print "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n";
print "\n";

until ($senpath && -d $senpath) {
  print "Enter Sensor Path (Hit Enter for current directory):  ";
  chomp($senpath = <STDIN>);
  $senpath = $pwd unless $senpath;
  print "BAD Sensor Path!!\n\n" unless -d $senpath;
}

until ($ctlfile && -e $ctlfile) {
  print "Enter Control Point filename:  ";
  chomp($ctlfile = <STDIN>);
  print "BAD Control Point filename!!\n\n" unless -e $ctlfile;
}

do {
  print "Enter Constraint filename (Hit Enter for None):  ";
  chomp($cnsfile = <STDIN>);
  print "BAD Constraint filename!!\n\n" unless ! $cnsfile || -e $cnsfile;
} until ! $cnsfile || -e $cnsfile;

print "Enter Output Points filename:  ";
chomp($ptsfile = <STDIN>);

print "Enter Output Report filename:  ";
chomp($outrptfile = <STDIN>);

if ( $no_records > 10 ) {
  $rpttype = 'summary';
  print "\nThere are $no_records records.  Setting Output Report Type to $rpttype.\n";
}
else {
  print "Enter Output Report Type (all|summary):  ";
  chomp($rpttype = <STDIN>);
}

print "Enter frequency of EO Calculations (first|each|file):  ";
chomp($freq = <STDIN>);

$cal = "CAL_NONE";
unless ($freq =~ /file/i) {
  print "Enter Bundle IO Self-Calibration Option\n(CAL_NONE|CAL_F|CAL_FXY|CAL_FXYK|CAL_FXYKP):  ";
  chomp($cal = <STDIN>);
}

print "Enter Output FotoG-SEQ Control filename:  ";
chomp($seqfile = <STDIN>);

print "\nCreating FotoG-SEQ file, \"$seqfile\".\n";

system("mkseq -senpath $senpath -img @imgfiles -ctl $ctlfile -cns $cnsfile -pts $ptsfile -rpt $outrptfile -rpttype $rpttype -freq $freq -cal $cal -seq $seqfile\n");
