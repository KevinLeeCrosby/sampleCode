#!/bin/perl -w

# DATE      VER  NAME          DESCRIPTION
# 08-19-08  1.0  K. Crosby     First Release


use strict;
use Win32::OLE;

my ($drive, $server);
my $persistent = 1; # 1 => true, 0 => false
my $objNetwork = Win32::OLE->CreateObject('WScript.Network');

die
  "Usage:  map drive server\n"
unless @ARGV == 2;

($drive, $server) = @ARGV[0,1];

#$drive =~ s!:!!g; # colonectomy (removes colon)
#$server =~ s!\\!\\\\!g; # double up on backslashes
#print "$0 $drive $server\n";

$objNetwork->MapNetworkDrive($drive, $server, $persistent);


