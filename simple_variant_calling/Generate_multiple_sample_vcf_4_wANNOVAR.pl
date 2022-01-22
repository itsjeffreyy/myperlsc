#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# set output file
my $out_f="multi_sample.vcf";
open(OUT,">$out_f")|| die"Cannot write $out_f: $!\n";

# laoad vcf files
my $mark=0;
foreach my $f (@ARGV){
	open(INvcf,"<$f")|| die "Cannot open VCF $f: $!\n";
	
	$mark++;

	while(<INvcf>){
		chomp;
		if($_=~/^#/){
			if($mark==1){
				print OUT "$_\n";
			}
			next;
		}

		my ($sample)=$f=~/(\S+).vcf/;
		print OUT "$_;$sample\n";
	}
	close INvcf;
}

close OUT;
