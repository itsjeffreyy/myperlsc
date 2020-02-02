#!/usr/bin/perl -w
# usage : ShuffleSplitFastq2Fasta.pl f1_1.fq,f1_2.fq f2_1.fq,f2_2.fq ... n basename 
# note  : This shuffles and splits PE data into n files with a given basenbame. 
# date  : 2012.01.23

use strict;


# set output files
# bn : basename
# nof: number of output files
# ofh: output file handle

my $bn=pop(@ARGV);
my $nof=pop(@ARGV);
my @pef=@ARGV;

my @ofh=();
for(my $i=1;$i<=$nof;$i++) {
    open($ofh[$i-1],">$bn\_$i.fa") || die "open $bn\_$i.fa: $!\n";
}


# shuffle and split PE files
# ri  : read index
# pefi: paired-end file index
# ofi : output file index

my $ri=0;
for(my $pefi=0;$pefi<@pef;$pefi++) {
    my ($f1,$f2)=split(",",$pef[$pefi]);
    open(IN1,"<$f1") || die "open $f1: $!\n";
    open(IN2,"<$f2") || die "open $f2: $!\n";

    while(<IN1>) {
	$ri++;

	print {$ofh[0]} ">$ri/1\n";
	$_=<IN1>;
	print {$ofh[0]} $_;
	<IN1>;
	<IN1>;
	
	<IN2>;
	print {$ofh[0]} ">$ri/2\n"; 
	$_=<IN2>;
	print {$ofh[0]} $_;
	<IN2>;
	<IN2>;
	
	for(my $ofi=2;$ofi<=$nof;$ofi++) {
	    if(<IN1>) {
		print {$ofh[$ofi-1]} ">$ri/1\n";
		$_=<IN1>;
		print {$ofh[$ofi-1]} $_; 
		<IN1>;
		<IN1>;
		
		<IN2>;
		print {$ofh[$ofi-1]} ">$ri/2\n"; 
		$_=<IN2>;
		print {$ofh[$ofi-1]} $_;
		<IN2>;
		<IN2>;
	    } else {
		last;
	    }
	}
    }
    close IN1;
    close IN2;
}

for(my $ofi=1;$ofi<=$nof;$ofi++) {
    close $ofh[$ofi-1];
}
