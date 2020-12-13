#!/usr/bin/perl -w
use strict;

# exclude list
my @ex=();
open(INex,"<$ARGV[1]")|| die "open $ARGV[1]: $!\n";
while(<INex>){
	chomp;
	my @a=split("\t",$_);
	push(@ex,$a[0]);
}
close INex;

open(IN1,"<$ARGV[0]")|| die "open $ARGV[0]: $!\n";
while(<IN1>){
	chomp;
	my $check=0;
	foreach my $e (@ex){
		#if($_=~/$e/){
		if($_ eq $e){
			$check =1;
			last;
		}
	}
	if($check == 0){
		print "$_\n";
	}
}
close IN1;
