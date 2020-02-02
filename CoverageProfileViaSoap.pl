#!/usr/bin/perl -w
# writer : Jeffreyy Yu
# usage : CoverageProfileViaSoap.pl pe1.soap pe2.soap

use strict;
use Data::Dumper;

my %read1align=();
my %read2align=();
# load the soap result of pe1
# load the soap result of pe2
open(IN1,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
open(IN2,"<$ARGV[1]")||die"open file $ARGV[1]:$!\n";
while(<IN1>){
	chomp $_;
	my @a=split("\t",$_);
	my ($read,$ori,$ctg,$pos)=@a[0,6,7,8];
	push(@{$read1align{$read}},[$ctg,$ori,$pos]);
}
close IN1;

while(<IN2>){
	chomp $_;
	my @a=split("\t",$_);
	my ($read,$ori,$ctg,$pos)=@a[0,6,7,8];
	push(@{$read2align{$read}},[$ctg,$ori,$pos]);
}
close IN2;

print Dumper %read1align;

foreach my $r1 (%read1align){
	foreach my $r2 (%read2align){

		# if the read1 and read2 are not same, next
		if ($r1 ne $r2){next;}

		# the read1 and read2 are same, and the read alignment result is only one
		if (@{$read1align{$r1}} ==1 && @{$read2align{$r1}} ==1){
			if($read1align{$r1}[1] ne @{$read1align{$r1}} !=1)
		}
	}
}
