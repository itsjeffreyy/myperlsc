#!/usr/bin/perl -w
use strict;

print &Timestamp."\n";

###
my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
# time
my $time = sprintf("%04d-%02d-%02d %02d:%02d:%02d",$year+1900, $mon+1, $mday,$hour,$min,$sec);
print "$time\n";

my $timestamp = sprintf("%02d:%02d:%02d", $hour, $min, $sec);
print "$timestamp\n";
# date
my @months = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @days = qw(Sun Mon Tue Wed Thu Fri Sat Sun);
my $ryear=$year+1900;
print "$days[$wday] $months[$mon] $mday $ryear\n";



#########################################################
sub Timestamp{
	my $datetimestamp = localtime(time);
	return $datetimestamp;
}
