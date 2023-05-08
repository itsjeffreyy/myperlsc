#!/usr/bin/perl -w 
# writer: Jeffreyy Yu
# Uasge: FqLength.pl file.fastq output
use strict;
use Data::Dumper;

my %sq=();
my %sl=();
my $id="";
my $i=0;
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^@(\S+)/){
		$id="$1";	
		my $seq=<IN>; chomp $seq;
		<IN>;<IN>;

		$sq{$id}=$seq;
		$sl{$id}=length($seq);
		$i++;
	}
}

my $output="";
if (defined $ARGV[1]){
	$output=$ARGV[1];
}else{
	$output="$ARGV[0].lengstat";
}

open(OUT,">$output");
foreach my $s (sort {$sl{$a} <=> $sl{$b}} (keys %sl)){
	print OUT "$s\t$sl{$s}\n";
}
close OUT;

