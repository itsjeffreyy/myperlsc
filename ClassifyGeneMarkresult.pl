#!/usr/bin/perl -w 
# writer : Jeffreyy Yu
# usage :ClassifyGeneMarkresult.pl Genemark 

use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";

my $filename="";
if($ARGV[0]=~/(.+)\.lst/){
	$filename=$1;
}else{
	$filename=$ARGV[0];
}

my $f1="$filename".".PredictedGenes";
my $f2="$filename"."_PredictedProteins.faa";
my $f3="$filename"."_NucleotideSequence.fna";

open(OUT1,">$f1")||die "open file $ARGV[0]:$!\n";
open(OUT2,">$f2")||die "open file $ARGV[0]:$!\n";
open(OUT3,">$f3")||die "open file $ARGV[0]:$!\n";

while(<IN>){
	chomp $_;
	if($_=~/^FASTA definition line:/){
		print OUT1 "$_\n";

		while(<IN>){
			chomp;
			if($_=~/Predicted proteins:/){ last; }
			print OUT1 "$_\n";
		}

	}

	if($_=~/Predicted proteins:/){
		while(<IN>){
			chomp;
			if($_=~/Nucleotide sequence of predicted genes:/){ last; }
			if(!$_){next;}
			print OUT2 "$_\n";
		}
	}

	if($_=~/Nucleotide sequence of predicted genes:/){
		while(<IN>){
			chomp;
			if($_=~/FASTA definition line:/){ seek(IN,-length($_)-1,1); last; }
			if(!$_){next;}
			print OUT3 "$_\n";
		}
	}
}

close IN;
close OUT1;
close OUT2;
close OUT3;
