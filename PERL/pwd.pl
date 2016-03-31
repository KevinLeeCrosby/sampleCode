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
my ($somedir);


# Declare other variables


##############################################################################
# GET FULL PATH
##############################################################################

$somedir = getcwd; # add current dir
$somedir =~ s!/!\\!g if ($^O =~ /Win32/);

print "$somedir\n";

