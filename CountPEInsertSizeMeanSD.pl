#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: CountPEInsertSizeMeanSD.pl PE.distance
#Standard Deviation

use strict;
use Data::Dumper;
use Getopt::Long;

my $all=0;
my $account=0;
my $mean=0;
# load PE.distance and record all and account
open(IN,"<$ARGV[0]")|| die "open $ARGV[0]:$!\n";
while(<IN>){
	my @a=split("\t",$_); chomp $a[-1];
	$account+=$a[1];
	$all+=$a[0]*$a[1];
}
close IN;

# count mean
$mean=$all/$account;

# count standard deviation
my $var=0;
my $sd=0;
open(IN,"<$ARGV[0]")|| die "open $ARGV[0]:$!\n";
while(<IN>){
	my @a=split("\t",$_); chomp $a[-1];
	$var+=(($a[0]-$mean)**2)*$a[1];
	
}
$sd=($var/$account)**0.5;
printf ("Account: %d\nMean: %.2f\nSD: %.2f\n",$account,$mean,$sd);
