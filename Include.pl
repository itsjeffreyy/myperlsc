#!/usr/bin/perl -w
use strict;

# include list
my @ex=();
open(INin,"<$ARGV[1]")|| die "open $ARGV[1]: $!\n";
while(<INin>){
	chomp;
	push(@ex,$_);
	#my @a=split("\t",$_);
	#push(@ex,$a[0]);
}
close INin;

open(IN1,"<$ARGV[0]")|| die "open $ARGV[0]: $!\n";
while(<IN1>){
	chomp;
	#my @a=split("\t",$_);
	my $check=0;
	foreach my $e (@ex){
		#if($_=~/$e/){
		if($_ eq $e){
		#if($a[1] eq $e){
			$check =1;
			#last;
		}
	}
	if($check == 1){
		print "$_\n";
	}
}
close IN1;
