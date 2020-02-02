#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: SD.pl file.LenDis
# Note: This script count the mean and standard deviation of a 454 reads length and account.
# 	The file.LenDis is produce by the "FaLengthDistribution.pl" script, and the file context hastwo colum: group account.

use strict;
use Data::Dumper;
my %la=();

# load file into hash
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	my @idl=split("\t",$_);
	$la{$idl[0]}=$idl[1]; 
}
close IN;

# count mean
my $all=0;
my $account=0;
my $mean=0;
foreach (keys %la){
	$account+=$la{$_};
	$all+=($_*$la{$_});
}
$mean=$all/$account;
#$mean=int $mean;
#print "$account\t$all\t$mean\n";

my $var=0;
foreach(keys %la){
	$var+=($_-$mean)**2*$la{$_};
}

my $sd=0;
$sd=($var/$account)**0.5;
print "$ARGV[0]\nMean:$mean\nStandard Deviation:$sd\n";
