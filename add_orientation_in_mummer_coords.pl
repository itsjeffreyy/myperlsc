#!/usr/bin/perl -w 
use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")|| die "$!\n";
while(<IN>){
	if($_=~/^\[S1\]/){
		my @t=split("\t",$_); chomp $t[-1];
		print "$t[0]\t$t[1]\t[O1]\t$t[2]\t$t[3]\t[O2]\t".join("\t",@t[4..11])."\n";
		last;
	}
}
while(<IN>){
	my @a=split("\t",$_); chomp $a[-1];
	my $s1=$a[1]-$a[0];
	my $s2=$a[3]-$a[2];
	my ($s1o, $s2o);
	$s1o = ($s1 >= 0 ? '+':'-');
	$s2o = ($s2 >= 0 ? '+':'-');
	print "$a[0]\t$a[1]\t$s1o\t$a[2]\t$a[3]\t$s2o\t".join("\t",@a[4..12])."\n";
}
close IN;
