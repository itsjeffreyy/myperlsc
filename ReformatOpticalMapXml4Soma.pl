#!/usr/bin/perl -w
# usage : ReformatOpticalMapXml4Soma.pl xml out_prefix
# note  : This converts the optical map in xml format (output by OpGen) into the format required by soma.

use strict;


# set parameters

my $out = $ARGV[1] ? $ARGV[1] : "optical_map";


# load optical map xml

open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";

my $i=0;
while(<IN>) {
    if($_=~/consensus/) {
	$i++;
	$_=<IN>;
	my ($c)=$_=~/<name>(.+)<\/name>/;

	<IN>; <IN>; <IN>;
	$_=<IN>;
	my ($circularq)=$_=~/<circular>(\w+)<\/circular>/;

	<IN>;
	$_=<IN>;
	my ($enzyme)=$_=~/<enzymes>(\w+)<\/enzymes>/;
	
	$_=<IN>;
	my ($mapblock)=$_=~/<map_block>(.+)<\/map_block>/;
	my @frg=split(" ",$mapblock);
	my @frgsizesd=();
	foreach my $f (@frg) {
	    $f=~/^([\d\.]+)c[\d\.]+m[\d\.]+s([\d\.]+)/;
	    push(@frgsizesd,"$1\t$2");
	}

	open(OUT,">$out\_$i.txt") || die "open $out\_$i.txt: $!\n";
	print OUT "Organism\t$c\t$enzyme\tCIRCULAR=$circularq\n";
	for(my $i=0;$i<@frgsizesd;$i++) {
	    print OUT "$i\t$frgsizesd[$i]\n";
	}
	close OUT;
    }
}
close IN;
