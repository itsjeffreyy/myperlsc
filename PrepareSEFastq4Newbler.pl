#!/usr/bin/perl -w
# usage : PrepareSEFastq4Newbler.pl se1.fastq se2.fastq ... output_prefix

use strict;
use Getopt::Long;


# get quality score offset

my $qso=33;

GetOptions("q=i" => \$qso);


# load PE libraries and convert them for Newbler

my $out=pop(@ARGV);
open(OUTS,">$out.fasta") || die "open $out.fasta: $!\n";
open(OUTQ,">$out.qual") || die "open $out.qual: $!\n";

my $i=0;
foreach my $fn (@ARGV) {
    open(IN,"<$fn") || die "open $fn: $!\n";
    while(<IN>) {
	$i++;
	my $r=<IN>; chomp $r;
	<IN>;
	my $q=<IN>; chomp $q;
	my @q=map(ord($_)-$qso,split("",$q));
	$q=join(" ",@q);
    
	print OUTS ">READ$i\n$r\n";
	print OUTQ ">READ$i\n$q\n";
    }
    close IN;
}
close OUTS;
close OUTQ;
