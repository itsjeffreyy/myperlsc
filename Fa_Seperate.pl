#!/usr/bin/perl -w
use strict;

#my %title_seq=();
#my @title=();
my ($title,$seq)=();

open(IN,"<$ARGV[0]") || die "open Fasta $ARGV[0]: $!\n";
while (<IN>){
	chomp;
	if($_=~/^>(.+)/){
		if($seq){
			my ($fn)=$title=~/(\S+)/;
			$fn.=".fasta";
			open(OUT,">$fn")|| die "Can not write to $fn: $!\n";
			print OUT ">$title\n$seq\n";
			close OUT;
			($title,$seq)=();
		}

		#push(@title,$1);
		$title=$1;
	}else{
		#$title_seq{$title[-1]}.=$_;
		$seq.=$_;
	}
}
my ($fn)=$title=~/(\S+)/;
$fn.=".fasta";
open(OUT,">$fn")|| die "Can not write to $fn: $!\n";
print OUT ">$title\n$seq\n";
close OUT;
close IN;
