#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# variable
my $split=1;
my $fq_f=$ARGV[0];

# extract the file head
my ($fq_h)=$fq_f=~/(.+)(?:fq|fastq)/;

# options
GetOptions(
	"split|s=i" => \$split,
);

# check format
open(IN,"<$fq_f")|| die "open Fstq $fq_f:$!\n";
my $l1=<IN>; chomp $l1;
my $l2=<IN>; chomp $l2;
my $l3=<IN>; chomp $l3;
my $l4=<IN>; chomp $l4;
if($l1!~/^@/ || $l3 !~/^+/){
	print "ERR: $fq_f not a Fastq file.\n";
	exit;
}
close IN;

# check line number
my $line_num=`wc -l $fq_f`; chomp $line_num;
if($line%4 != 0){
	print "ERR: $fq_f not a Fastq file.\n";
	exit;
}
# get the total read numbers
my $read_num=$line_num/4;

# set read numbers in one file
my $read_num_split_fq=int($read_num/$split);

# open fastq
my $file_num=1;
my $reads_s=0;
open(IN,"<$fq_f")|| die "open Fastq $fq_f:$!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my $l2=<IN>; chomp $l2;
	my $l3=<IN>; chomp $l3;
	my $l4=<IN>; chomp $l4;

	if($reads_s == $read_num_split_fq && $file_num < $split){
		$reads_s=0;
		close OUT;
		$file_num++;
	}
	if($reads_s==0){
	}

	print OUT "$l1\n$l2\n$l3\n$l4\n";
	$reads_s++;
}
close IN;
close OUT;
