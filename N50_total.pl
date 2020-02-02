#!/usr/bin/perl -w
# usage: N50.pl fa
# writer: Jeffreyy Yu
use strict;


# load data and get fasta length

my %clen=();
my $c="";
my $totallen=0;
open(IN,"<$ARGV[0]") || die "cannot open file $ARGV[0]!\n";
while(<IN>) {
    if($_=~/^>(\S+)/) {
	$c=$1;
    } else {
	chomp $_;
	$clen{$c}+=length($_);
	$totallen+=length($_);
    }
}
close IN;


# get N50 and output

my $n50=0;
my $tl=0;
foreach my $c (sort{$clen{$b}<=>$clen{$a}}(keys %clen)) {
    $tl+=$clen{$c};
    if($tl>=($totallen/2)) {
	$n50=$clen{$c};
	last;
    }
}
print " N50\t$n50\ntotal\t$totallen\n";
