#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: TrimContigbyLeng.pl contig.fasta leng
#	 The leng default 100

use strict;
use Data::Dumper;

my $leng="";

# if user doesn't give the leng option the default is 100.
if (defined $ARGV[1]){
	$leng=$ARGV[1];
}else{
	$leng=100;
}

# load the contig fasta file
my %contig=();
my $id="";
open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^>(.+)/){
		$id=$1;
	}else{
		$contig{$id}.=$_;
	}
}
close IN;

# trim the contig by leng and ouput 
my $filename="trimbyleng$leng"."_$ARGV[0]";
open(OUT,">$filename");
foreach my $tid (keys %contig){
	if(length($contig{$tid}) > $leng){
		print OUT ">$tid\n$contig{$tid}\n";
	}
}
close OUT;
