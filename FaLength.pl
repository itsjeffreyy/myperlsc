#!/usr/bin/perl -w 
# writer: Jeffreyy Yu
# Uasge: FaLength.pl file.fasta output
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
		$id="$1\-$i";	
	}else{
		$sq{$id}.=$_;
	}
}
close IN;

foreach (keys %sq){
	$sl{$_}=length($sq{$_});
}

open(OUT,">unsort.stat");
foreach my $s(keys %sl){
	print OUT "$s\t$sl{$s}\n";
}
close OUT;

my $output="";
if (defined $ARGV[1]){
	$output=$ARGV[0];
}else{
	$output="$ARGV[0].lengstat";
}

`sort -k2 -n ./unsort.stat > $output `;
`rm unsort.stat`;
