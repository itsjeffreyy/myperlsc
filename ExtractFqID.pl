#!/usr/bin/perl -w
use strict;
use Data::Dumper;
open(IN,"<$ARGV[0]")|| die "open $ARGV[0]: $!\n";
my $fn=`basename $ARGV[0]`; chomp $fn;
my $outn=$fn."IDlist";
open(OUT,">$outn");
while(<IN>){
	if($_=~/^@(\S+)/){
		print OUT "$1\n";
	}else{
		print "ERR: Not Fastq format.\n";
		exit;
	}
	<IN>;<IN>;<IN>;
}
close IN;
close OUT;
