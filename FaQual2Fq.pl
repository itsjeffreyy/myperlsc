#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2015.04.16
# usage: FaQual2Fq.pl

use strict;
use Getopt::Long;
use Data::Dumper;

my $fa="";
my $qual="";
my $out="";
GetOptions(
	"fasta|fa=s" => \$fa,
	"qual|qu=s" => \$qual,
	"out|o=s" => \$out,
);

if(!$out){
	($out)=$fa=~/(.+)\.fa/;
}
$out.="\.fq";

open(OUT,">$out");

# load fasta and quality file
open(INfa,"<$fa")|| die "open $fa: $!\n";
open(INqu,"<$qual")|| die "open $qual: $!\n";

while(<INfa>){
	# get title
	chomp $_;
	my ($t)=$_=~/^>(.+)/;
	
	# get sequence 
	my $seq="";
	while (<INfa>){
		if($_=~/^>/){
			seek(INfa,-length($_),1);
			last;
		}
		chomp;
		$seq.=$_;
	}
	
	<INqu>;
	# get quality score
	my @qualscore=();
	while (<INqu>){
		if($_=~/^>/){
			seek(INqu,-length($_),1);
			last;
		}
		chomp;
		push(@qualscore,split(" ",$_));
	}
	
	my $qualcode="";
	foreach my $s (@qualscore){
		$s+=33;
		$qualcode.=chr($s);
	}
	print OUT "\@$t\n$seq\n\+$t\n$qualcode\n";
}
close INfa;
close INqu;
close OUT;
