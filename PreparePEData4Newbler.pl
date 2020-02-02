#!/usr/bin/perl -w
# usage : PreparePEData4Newbler.pl [options] pe1.fasta/q pe2.fasta/q output_prefix

use strict;
use Getopt::Long;


# get quality score offset

my $qso=33;

GetOptions("q=i" => \$qso);


# load PE libraries and convert them for Newbler

open(IN1,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";
open(IN2,"<$ARGV[1]") || die "open $ARGV[1]: $!\n";
open(OUTS,">$ARGV[2].fasta") || die "open $ARGV[2].fasta: $!\n";

my $fastq = ($ARGV[0]=~/fastq$/ || $ARGV[0]=~/fq$/) ? 1 : 0;
if($fastq==1) {
    open(OUTQ,">$ARGV[2].qual") || die "open $ARGV[2].qual: $!\n";
    
    my $i=0;
    while(<IN1>) {
	$i++;
	my $r1=<IN1>; chomp $r1;
	my $l1=length($r1);
	<IN1>;
	my $q1=<IN1>; chomp $q1;
	my @q1=map(ord($_)-$qso,split("",$q1));
	$q1=join(" ",@q1);
	
	<IN2>;
	my $r2=<IN2>; chomp $r2;
	my $l2=length($r2);
	<IN2>;
	my $q2=<IN2>; chomp $q2;
	my @q2=map(ord($_)-$qso,split("",$q2));
	$q2=join(" ",@q2);
	
	print OUTS ">READ$i"."F template=READ$i dir=F library=PE trim=1-$l1\n$r1\n";
	print OUTS ">READ$i"."R template=READ$i dir=R library=PE trim=1-$l2\n$r2\n";
	print OUTQ ">READ$i"."F template=READ$i dir=F library=PE trim=1-$l1\n$q1\n";
	print OUTQ ">READ$i"."R template=READ$i dir=R library=PE trim=1-$l2\n$q2\n";
    }
    close IN1;
    close IN2;
    close OUTS;
    close OUTQ;

} else {
    my $i=0;
    while(<IN1>) {
	$i++;
	my $r1=<IN1>; chomp $r1;
	my $l1=length($r1);
	
	<IN2>;
	my $r2=<IN2>; chomp $r2;
	my $l2=length($r2);
	
	print OUTS ">READ$i"."F template=READ$i dir=F library=PE trim=1-$l1\n$r1\n";
	print OUTS ">READ$i"."R template=READ$i dir=R library=PE trim=1-$l2\n$r2\n";
    }
    close IN1;
    close IN2;
    close OUTS;
}
