#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 09-28-00  1.0  K. Crosby     First Release
# 08-01-01  1.1  K. Crosby     Added full path, version, and timestamp.


use strict;
use POSIX qw(strftime);   # for timestamping using strftime function
use File::Basename;

my ($version) = 1.1;


# Define constants
my ($border) = ("#" x 78) . "\n";


# Declare input variables
my ($senpath, @imgfiles, $ctlfile, $cnsfile, $ptsfile, $rptfile, $seqfile);
my ($rpttype, $freq, $cal);


# Declare output variables
my ($imgfile);


# Declare calculated variables
my ($dir, $base);
my ($now);


# Declare other variables
my ($somefile);
my ($i);


##############################################################################
# PARSE INPUTS
##############################################################################

die "Usage: mkseq -senpath senpath -img imgfile1 imgfile2 ...
             -ctl ctlfile -cns cnsfile -pts ptsfile -rpt rptfile
             -rpttype [all|summary] -freq [first|each|file]
             -cal [CAL_NONE|CAL_F|CAL_FXY|CAL_FXYK|CAL_FXYKP]
             -seq seqfile\n" unless @ARGV;

@imgfiles = ();
$cnsfile = "";
while ($_ = $ARGV[0]) {
  shift;
  #print "$_\n";
  /^-senpath/ && do { ($senpath) = @ARGV; };
  /^-ctl/ && do { ($ctlfile) = @ARGV; };
  /^-cns/ && do { ($cnsfile) = @ARGV unless $ARGV[0] =~ /^-/; };
  /^-pts/ && do { ($ptsfile) = @ARGV; };
  /^-rpt\b/ && do { ($rptfile) = @ARGV; };
  /^-rpttype\b/ && do { ($rpttype) = @ARGV; };
  /^-freq/ && do { ($freq) = @ARGV; };
  /^-cal/ && do { ($cal) = @ARGV; };
  /^-seq/ && do { ($seqfile) = @ARGV; };
  if (/^-img/) {
    do { push(@imgfiles, $ARGV[0]); shift; }
    while @ARGV && $ARGV[0] =~ /^[^-]/;
  }
}

die "Need SEN path!\n" unless $senpath && -d $senpath;
die "Need CTL file!\n" unless $ctlfile && -e $ctlfile;
#die "Need CNS file!\n" unless $cnsfile && -e $cnsfile;
die "Need PTS file!\n" unless $ptsfile;
die "Need RPT file!\n" unless $rptfile;
die "Need Report Type!\n" unless $rpttype;
die "Need EO Frequency!\n" unless $freq;
die "Need Calibration Option!\n" unless $cal;
die "Need IMG file!\n" unless @imgfiles;
die "Need SEQ file!\n" unless $seqfile;

print "senpath:\t$senpath\n";
print "ctlfile:\t$ctlfile\n";
print "cnsfile:\t$cnsfile\n" if $cnsfile;
print "ptsfile:\t$ptsfile\n";
print "rptfile:\t$rptfile\n";
print "rpttype:\t$rpttype\n";
print "freq:\t\t$freq\n";
print "cal:\t\t$cal\n";
print "imgfiles:\t@imgfiles\n";
print "seqfile:\t$seqfile\n";


##############################################################################
# GET FULL PATH OF FILENAMES
##############################################################################

for $somefile (\((@imgfiles), $ctlfile, $cnsfile, $ptsfile, $rptfile,
	       $seqfile)) {
  ($base, $dir) = fileparse($$somefile);
  unless ($base =~ m!^&! || $dir =~ m!^/!) {
    $dir =~ s!^./!!g;                              # remove leading "./"
    $$somefile = $ENV{'PWD'} . '/' . $dir . $base; # add current directory
    
  }
  $$somefile =~ s!//+!/!g;          # remove duplicate "/"s
}


##############################################################################
# WRITE OUTPUT
##############################################################################

open (SEQFILE, ">$seqfile") || die "Can't open $seqfile for writing! $!\n";


##############################################################################
      
print SEQFILE "$border";
printf SEQFILE "%s MKSEQ OUTPUT %s\n", ('#' x 32), ('#' x 32);
printf SEQFILE "%s Version %3.1f %s\n", ('#' x 33), $version
  , ('#' x 32);
print SEQFILE "$border";
print SEQFILE "\n";

printf SEQFILE "#Input Control File\t\"%s\"\n", $ctlfile;
printf SEQFILE "#Input Constraint File\t\"%s\"\n", $cnsfile if $cnsfile;
printf SEQFILE "#Input Points File\t\"%s\"\n", $ptsfile;
printf SEQFILE "#Input Report File\t\"%s\"\n", $rptfile;
$i = 0;
foreach $imgfile (@imgfiles) {
  printf SEQFILE "#Input Image File #%d\t\"%s\"\n", ++$i, $imgfile;
}
print SEQFILE "\n";

printf SEQFILE "#Output Sequence File \"%s\"\n\n", $seqfile;


##############################################################################

print SEQFILE "#        FotoG-SEQ Control File\n";

print SEQFILE "# Sensor Path\n";
printf SEQFILE "%-23s %s\n", "SensorFilePath", $senpath;

print SEQFILE "# Image File Names\n";
foreach $imgfile (@imgfiles) {
  printf SEQFILE "%-23s %s\n", "ImageFilenames", $imgfile;
}

print SEQFILE "# Control Filename\n";
printf SEQFILE "%-23s %s\n", "ControlFilename", $ctlfile;

if ($cnsfile) {
  print SEQFILE "# Constraint Filename\n";
  printf SEQFILE "%-23s %s\n", "ConstraintFilename", $cnsfile;
}

print SEQFILE "# Output Filenames\n";
printf SEQFILE "%-23s %s\n", "OutputPoints", $ptsfile;
printf SEQFILE "%-23s %s\n", "OutputReport", $rptfile;

print SEQFILE "# Frequency of EO Calculations\n";
printf SEQFILE "%-23s %s\n", "EOFreq", $freq;

print SEQFILE "# Controls Bundle IO Self-Calibration Options\n";
printf SEQFILE "%-23s %s\n", "BundleSelfCal", $cal;

print SEQFILE "# Controls Type of Output Report Produced\n";
printf SEQFILE "%-23s %s\n", "OutputReportType", $rpttype;
  

  
##############################################################################

print SEQFILE "\n";
print SEQFILE "$border";
$now = strftime "%KC", localtime;
printf SEQFILE "%s TIMESTAMP %s %s\n", ('#' x 19), $now, ('#' x 19);
print SEQFILE "$border";
print SEQFILE "\n";


##############################################################################
close (SEQFILE) || die "Can't close $seqfile! $!\n";
