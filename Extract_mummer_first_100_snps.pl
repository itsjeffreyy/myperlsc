#!/usr/bin/perl -w
use strict;
use Data::Dumper;
my ($i,$lines)=(1,100);

open(OUT, "> ./mummer_ref_ctg_snps_$lines.tsv") || die "write ./mummer_ref_ctg_snps_$lines.tsv: $!\n";
open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";
while(<IN>){
	while(<IN>){
		if($_=~/^\[P1\]/){last;}
	}

	while(<IN>){
		if($i <= $lines){
			my @a=split("\t",$_); chomp $a[-1];
			print OUT ("$a[10]\t$a[0]\t$a[1]\t$a[2]\t$a[3]\t$a[11]\t$a[8]\t$a[9]\n");
			$i++;
		}
	}
}
close IN;
close OUT;
