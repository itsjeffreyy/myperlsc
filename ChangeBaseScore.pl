#!/usr/bin/perl -w
#writer: jeffreyy Yu
#usage: ChangeBaseScore.pl basescore .fq > changbasesore.fq
#The basescore have two options 64 and 33.
use strict;
use Data::Dumper;
binmode(STDOUT, ":utf8");

my $q="";
my $cq="";
my @q=();
open(IN,"<$ARGV[1]") || die "open file $ARGV[1]:$!\n";
if($ARGV[0]==64){
	while(<IN>){
		print "$_";
		$_=<IN>;print "$_";
		$_=<IN>;print "$_";
		$q=<IN>;chomp $q;
		$cq="";
		@q=split(//,$q);
		foreach(@q){
			$cq.=chr(ord($_)-64+33);
		}
		print "$cq\n";
	}
}elsif($ARGV[0]==33){
	while(<IN>){
		print "$_";
		$_=<IN>;print "$_";
		$_=<IN>;print "$_";
		$q=<IN>;chomp $q;
		$cq="";
		@q=split(//,$q);
		foreach(@q){
			$cq.=chr(ord($q)-33+64);
		}
		print "$cq\n";
	}
}
close IN;
