#!/usr/bin/perl -w 
# writer: Jeffreyy Yu
# Uasge: EvaluateFaLength.pl file.fasta output
use strict;
use Data::Dumper;

my %sq=();
my %sl=();
my $id="";
my $i=0;
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^>(\S+)/){
		$i++;
		#$id="$1\-$i";	
		$id="$1";	
	}else{
		$sq{$id}.=$_;
	}
}
close IN;

foreach (keys %sq){
	$sl{$_}=length($sq{$_});
}

my $output="";
if (defined $ARGV[1]){
	$output=$ARGV[0];
}else{
	$output="$ARGV[0].lengstat";
}

open(OUT,">$output");
foreach my $s (sort {$sl{$a} <=> $sl{$b}} (keys %sl)){
	print OUT "$s\t$sl{$s}\n";
}
close OUT;


