#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my %id_list=();
# load read id list
open(IN,"<$ARGV[0]") || die  "Cannot open $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	$id_list{$_}=1;
}
close IN;

# load fastq file
open(INfq,"<$ARGV[1]") || die "Cannot open Fastq $ARGV[1]: $!\n";
while(<INfq>){
	my $l1=$_;   chomp $l1; 
	my $l2=<INfq>; chomp $l2;
	my $l3=<INfq>; chomp $l3;
	my $l4=<INfq>; chomp $l4;
	
	# check the format
	if($l1 !~/^@/ || $l3!~/^\+/){
		print "ERR: $ARGV[1] not Fastq format!\n Abort\n"; exit;
	}

	# map read id and get the read.
	if($l1=~/^@(\S+)/){
		if($id_list{$1}){
			print "$l1\n$l2\n$l3\n$l4\n";
		}
	}
}
close INfq;
