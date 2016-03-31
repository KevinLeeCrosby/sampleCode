#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 08-19-08  1.0  K. Crosby     First Release


use strict;
use Win32::OLE;

my $drive;
my $force = 1; # 1 => true, 0 => false
my $update = 1; # 1 => true, 0 => false
my $objNetwork = Win32::OLE->CreateObject('WScript.Network');

die
  "Usage:  unmap drive\n"
unless @ARGV == 1;

$drive = $ARGV[0];

#$drive =~ s!:!!g; # colonectomy (removes colon)
#$server =~ s!\\!\\\\!g; # double up on backslashes
#print "$0 $drive $server\n";

$objNetwork->RemoveNetworkDrive($drive, $force, $update);


