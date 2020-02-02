#!/usr/bin/perl -w

use strict;
use Data::Dumper;

# load the fasta file
#my %fa=();
#my $id="";
open (IN,"<$ARGV[0]")|| die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp;
	if($_=~/^>(.*)/){
#		$id=$1;
		print "$_\n";
	}else{
#		$fa{$id}.=$_;
		my $seq=uc($_);
		print "$seq\n";
	}
}	
close IN;
