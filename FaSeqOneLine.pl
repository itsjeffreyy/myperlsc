#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# note: The sequence inSome fasta file not in one line, so this program make sequence in one line
# date: 2015.10.14

use strict;
use Data::Dumper;
use Getopt::Long;

# load fasta file
my $seq="";
open (IN,"<$ARGV[0]")||die "open $ARGV[0]:$!\n";
while(<IN>){
	if($_=~/^>/){
		if($seq){
			print "\n$_";
		}else{
			print "$_";
		}
	}else{
		$seq="$_";
		chomp $_;
		print "$_";
	}
}
close IN;
