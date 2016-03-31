#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 11-14-01  1.0  K. Crosby     First Release
# 12-07-01  1.1  K. Crosby     Changed check for prior existence of hard links.


use strict;
use File::Basename;
use File::Copy;


my ($version) = 1.1;


# Define constants


# Declare input variables
my ($indir, $outdir);


# Declare read variables
my ($blkfile, @blkfiles);
my ($copystr, @copyfiles);
my ($linkstr, $linkfile, @linkfiles);
my ($somefile);
my ($imgdir, %imgdirs);


# Declare output variables


# Declare calculated variables
my ($somedir, $somebase);


# Declare other variables


##############################################################################
# PARSE INPUTS
##############################################################################

die "Usage:  " . basename($0) . " indir outdir\n" unless (@ARGV == 2);


##############################################################################
# GET FULL PATH OF FILENAMES
##############################################################################

($indir, $outdir) = @ARGV[0,1];

for $somedir (\($indir, $outdir)) {
  $$somedir .= "/";
  unless ($$somedir =~ m!^/!) {
    $$somedir =~ s!^./!!g;                     # remove leading "./"
    $$somedir = $ENV{'PWD'} . "/" . $$somedir; # add current dir
  }
  $$somedir =~ s!//+!/!g;                      # remove duplicate "/"s
}

die "The output directory must be different than the input directory!"
  if ($indir eq $outdir);


##############################################################################
# DETERMINE IMAGE DIRECTORIES
##############################################################################

@blkfiles = glob("$indir*.blk");  # call glob as function for interpolation
foreach $blkfile (@blkfiles) {
  open (BLKFILE, "$blkfile") || die "Can't open $blkfile for reading! $!\n";
  
  while (<BLKFILE>) { # i.e. $_ = <BLKFILE>
    # simulate switch statement
    /^\bImageDir\b/i && do {
      $imgdir = (split)[1] . "/";
      $imgdir =~ s!//+!/!g;       # remove duplicate "/"s
      $imgdirs{$imgdir}++;        # just define it
      last;
    };
  }
  
  close (BLKFILE) || die "Can't close $blkfile! $!\n";
}


##############################################################################
# DETERMINE FILENAMES
##############################################################################

# determine glob string
$copystr = "";
$linkstr = "";
foreach $imgdir (keys %imgdirs) {
  $copystr .= " $imgdir*.{ras,tn}";
  $linkstr .= " $imgdir*.{tif{f,},jp{e,}g}";
}
$copystr .= " $indir*.{blk,mdb,cns,rpt,sen,rso,ctl}";

# call glob as function for interpolation
@copyfiles = glob $copystr;
@linkfiles = glob $linkstr;


##############################################################################
# CREATE HARD LINKS, IF POSSIBLE
##############################################################################

$somefile = $linkfiles[0];
($somebase, $somedir) = fileparse($somefile);
$linkfile = $outdir . $somebase;
print "Attempting to create hard link to \"$somefile\" ...\n";
if (link $somefile, $linkfile) {
  print "Hard linking to \"$somefile\" from \"$outdir\" successful!\n";
  print "Continuing ...\n\n";
  shift @linkfiles;
  foreach $somefile (@linkfiles) {
    ($somebase, $somedir) = fileparse($somefile);
    $linkfile = $outdir . $somebase;
    print "Hard linking to \"$somefile\" \"$outdir\" ...\n";
    link $somefile, $linkfile;
  }
}
elsif (-e $outdir . basename($linkfiles[-1])) {
  print "Images already linked or copied.\n";
}
else {
  # check if last file already linked
  print "Unable to hard link images.  Copying instead ...\n";
  unshift @copyfiles, @linkfiles;
}

print "\n";


##############################################################################
# COPY FILES
##############################################################################

foreach $somefile (@copyfiles) {
  print "Copying \"$somefile\" to \"$outdir\" ...\n";
  copy $somefile, $outdir || die "Unable to copy \"$somefile\"! $!\n";
}


##############################################################################
# MODIFY BLOCK FILES
##############################################################################

@blkfiles = glob("$outdir*.blk");  # call glob as function for interpolation
foreach $blkfile (@blkfiles) {
  system("blkpath", $blkfile);
}
