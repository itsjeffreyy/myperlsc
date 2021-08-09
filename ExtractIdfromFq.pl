#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# load fastq
my @ids=();
open(IN,"<$ARGV[0]")|| die "Cannot open $ARGV[0]: $!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	<IN>;<IN>;<IN>;
	if($l1=~/^@(\S+)/){
		push(@ids,$1);
	}
}
close IN;

foreach my $i (sort (@ids)){
	print "$i\n";
}
