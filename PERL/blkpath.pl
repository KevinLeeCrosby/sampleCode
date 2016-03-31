#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 09-21-01  1.0  K. Crosby     First Release
# 11-14-01  1.1  K. Crosby     Added switches, changed default directories,
#                              checked for the existence of files and
#                              directories, renamed from pathfix to blkpath.


use strict;
use File::Basename;
use File::Copy;
#use File::Glob ':glob';  # to handle whitespace in filematching (doesn't work)


my ($version) = 1.1;


# Define constants


# Declare input variables
my ($blkinfile, $blkoutfile, $ctldir, $mdbdir, $sendir, $imgdir);


# Declare read variables
my ($somefile);


# Declare output variables


# Declare calculated variables
my ($issame);
my ($issen, $isimg);
my ($tempfile);
my ($indir, $inbase);
my ($outdir, $outbase);
my ($somedir, $somebase);


# Declare other variables



##############################################################################
# PARSE INPUTS
##############################################################################

die
  "Usage:  " . basename($0) .
  " blkinfile [-o blkoutfile|blkoutdir] [-c ctldir] [-m mdbdir]                     [-s sendir] [-i imgdir]\n"
unless @ARGV;


##############################################################################
# PARSE COMMAND LINE
##############################################################################

$blkinfile = shift;
while ($_ = $ARGV[0]) {
  shift;
  /^-o/ && do { ($blkoutfile) = @ARGV; };
  /^-c/ && do { ($ctldir) = @ARGV; };
  /^-m/ && do { ($mdbdir) = @ARGV; };
  /^-s/ && do { ($sendir) = @ARGV; };
  /^-i/ && do { ($imgdir) = @ARGV; };
}


##############################################################################
# GET FULL PATH OF FILENAMES
##############################################################################

($inbase, $indir) = fileparse($blkinfile);
unless ($inbase =~ m!^&! || $indir =~ m!^/!) {
  $indir =~ s!^./!!g;                  # remove leading "./"
  $indir = $ENV{'PWD'} . "/" . $indir; # add current directory
  $blkinfile = $indir . $inbase;
}
$blkinfile =~ s!//+!/!g;               # remove duplicate "/"s

$blkoutfile = $blkinfile unless defined($blkoutfile);
$blkoutfile .= "/$inbase" if -d $blkoutfile; # make same filename as before
($outbase, $outdir) = fileparse($blkoutfile);
unless ($outbase =~ m!^&! || $outdir =~ m!^/!) {
  $outdir =~ s!^./!!g;                      # remove leading "./"
  $outdir = $ENV{'PWD'} . "/" . $outdir;    # add current directory
  $blkoutfile = $outdir . $outbase;
}
$blkoutfile =~ s!//+!/!g;                    # remove duplicate "/"s

for $somedir (\($ctldir, $mdbdir, $sendir, $imgdir)) {
  $$somedir = $outdir unless defined($$somedir); # make same default directory
  $$somedir .= "/";
  unless ($$somedir =~ m!^/!) {
    $$somedir =~ s!^./!!g;                     # remove leading "./"
    $$somedir = $ENV{'PWD'} . "/" . $$somedir; # add current dir
  }
  $$somedir =~ s!//+!/!g;                      # remove duplicate "/"s
}

$issen = glob("$sendir*.{sen,rso}");   # call as function for interpolation
$isimg = glob("$imgdir*.{ras,tn,tif{f,},jp{e,}g}");


die "Need input file!\n" unless $blkinfile && -e $blkinfile;

#print "blkinfile:\t$blkinfile\n";
#print "blkoutfile:\t$blkoutfile\n";
#print "ctldir:\t$ctldir\n";
#print "mdbdir:\t$mdbdir\n";
#print "sendir:\t$sendir\n";
#print "imgdir:\t$imgdir\n";


##############################################################################
# DETERMINE TEMPFILE NAME
##############################################################################

$issame = ($blkinfile eq $blkoutfile);
$tempfile = $blkoutfile;
$tempfile .= '~~~' if ($issame);



##############################################################################
# READ INPUTS AND WRITE OUTPUT
##############################################################################

# read IN file
open (BLKINFILE, "$blkinfile") || die "Can't open $blkinfile for reading! $!\n";

# write OUT (TEMP) file
open (TEMPFILE, ">$tempfile") || die "Can't open $tempfile for writing! $!\n";

while (<BLKINFILE>) { # i.e. $_ = <BLKINFILE>
  # simulate switch statement
  /^\bModelPath\b/i && do {
    ($somebase, $somedir) = fileparse((split)[1]);
    $somefile = $outdir . $somebase;
    s/$somedir/$mdbdir/g if -f $somefile;
  };
  /^\bControl\b/i && do {
    ($somebase, $somedir) = fileparse((split)[1]);
    $somefile = $outdir . $somebase;
    s/$somedir/$ctldir/g if -f $somefile;
  };
  /^\bSensorDir\b/i && $issen && do {
    $somedir = (split)[1];
    s/$somedir/$sendir/g;
  };
  /^\bImageDir\b/i && $isimg && do {
    $somedir = (split)[1];
    s/$somedir/$imgdir/g;
  };
  print TEMPFILE;
}

# close IN and OUT (TEMP) files
close (BLKINFILE) || die "Can't close $blkinfile! $!\n";
close (TEMPFILE) || die "Can't close $tempfile! $!\n";


##############################################################################
# MOVE TEMPFILE, IF NECESSARY
##############################################################################

(move $tempfile, $blkoutfile || die "Unable to overwrite original file! $!\n")
  if ($issame);
