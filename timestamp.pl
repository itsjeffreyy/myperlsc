#!/usr/bin/perl -w
use strict;
###
my $datetimestamp = localtime(time);
print "$datetimestamp\n";
###
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
# time
my $timestamp = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
print "$timestamp\n";
# date
my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my $ryear=$year+1900;
print "$days[$wday] $months[$mon] $mday $ryear\n";
