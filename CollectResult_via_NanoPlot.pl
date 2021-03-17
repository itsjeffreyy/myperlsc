#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# load multiple NanoPlot/NanoStats.txt files
foreach my $nanostat (@ARGV){
	my ($read,$base,$leng,$qual)=();
	open(IN,"<$nanostat") || die "open $nanostat: $!\n";
	<IN>;
	# mean read length
	my $l2=<IN>; chomp $l2;
	my @l2=split(" ",$l2);
	$leng=$l2[-1];

	# mean read uality
	my $l3=<IN>; chomp $l3;
	my @l3=split(" ",$l3);
	$qual=$l3[-1];

	<IN>;<IN>;
	# read number
	my $l7=<IN>; chomp $l7;
	my @l7=split(" ",$l7);
	$read=$l7[-1];

	<IN>;
	# total base number
	my $l9=<IN>; chomp $l9;
	my @l9=split(" ",$l9);
	$base=$l9[-1];
	close IN;
	print "$nanostat\n$read\n$base\n$leng\n$qual\n\n";
}
