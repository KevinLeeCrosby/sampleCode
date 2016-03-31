#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 04-29-05  1.0  K. Crosby     First Release


use strict;
use Cwd;
#use File::Basename;
#use File::Copy;


my ($version) = 1.0;


# Define constants


# Declare input variables


# Declare read variables


# Declare output variables


# Declare calculated variables
my ($filesep);


# Declare other variables


##############################################################################
# PARSE INPUTS
##############################################################################


##############################################################################
# GET FULL PATH OF FILENAMES
##############################################################################

#my @keys = sort keys %ENV;

#for my $somekey (@keys) {
#  print "$somekey\n";
#}

($^O =~ /Win32/) ? ($filesep = "\\") : ($filesep = "/");

print "$filesep";

