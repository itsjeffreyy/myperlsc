#!/usr/bin/perl -w 
# writer: Jeffreyy Yu
# Uasge: FaLength.pl file.fasta output
use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^@(.+)/){
		print "\@$1\t";
		$_=<IN>;chomp $_;
		print length($_)."\n";
		<IN>;<IN>;
	}
}
