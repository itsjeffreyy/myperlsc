#!/usr/bin/perl -w
# usage : NewblerAssembly.pl [options]
# ex    : NewblerAssembly.pl -c 4 -pe lib1_1.fq,lib1_2.fq -se lib2.fastq -o test
# note  : This script automatically guesses the input data format, i.e., fastq or fasta.
#       : This script requires "PreparePEData4Newbler.pl" and "PrepareSEFastq4Newbler.pl"
#       : if paired end data and single end fastq files are provided respectively.
 
use strict;
use Getopt::Long;


# load parameters

my @pe=();
my @se=();
my $c=2;
my $outprefix="";

GetOptions(
           "pe=s" => \@pe,
           "se=s" => \@se,
           "cpu=i" => \$c,
           "outprefix=s" => \$outprefix
           );


# process input files

my @file=();
my %aq=();
my %fo=();

my $i=0;
foreach my $f (@se) {
    if($f=~/q$/) {
	$i++;
	`PrepareSEFastq4Newbler.pl $f $outprefix\_selib$i`;
	push(@file,"$outprefix\_selib$i.fasta");
	$aq{"$outprefix\_selib$i.fasta"}="$outprefix\_selib$i.qual";
    } else {
	push(@file,$f);
	$fo{$f}=1;
    }
}

foreach my $l (@pe) {
    $i++;
    my ($f1,$f2)=split(",",$l);
    `PreparePEData4Newbler.pl $f1 $f2 $outprefix\_pelib$i`;
    push(@file,"$outprefix\_pelib$i.fasta");
    if($f1=~/fastq$/ || $f1=~/fq$/) {
	$aq{"$outprefix\_pelib$i.fasta"}="$outprefix\_pelib$i.qual";
    }
}


# run newbler

my $command="runAssembly -o $outprefix -cpu $c ".join(" ",@file);
`$command`;


# remove intermediate files

foreach my $f (@file) {
    if(!$fo{$f}) {
	`rm $f`;
	if($aq{$f}) {
	    `rm $aq{$f}`;
	}
    }
}
