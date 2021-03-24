#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# variable
my $split=1;

# options
GetOptions(
	"split|s=i" => \$split,
);

# extract the file head
my $fa_f=$ARGV[0];
my ($fa_h)=$fa_f=~/(.+)(?:.fa|.fasta)/;

# check format
open(IN,"<$fa_f")|| die "open Fasta $fa_f:$!\n";
my $l1=<IN>; chomp $l1;
my $l2=<IN>; chomp $l2;
if($l1!~/^>/ ){
	print "ERR: $fa_f not a Fasta file.\n";
	exit;
}
close IN;

# check line number
my @a=split(" ",`wc -l $fa_f`); chomp @a;
my $line_num=$a[0];
if($line_num % 2 != 0){
	print "ERR: $fa_f not a Fasta file.\n";
	exit;
}
# get the total read numbers
my $read_num=$line_num/2;

# set read numbers in one file
my $read_num_split_fa=int($read_num/$split);

# open fasta
my $file_num=1;
my $reads_s=0;
open(IN,"<$fa_f")|| die "open Fasta $fa_f:$!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my $l2=<IN>; chomp $l2;

	if($reads_s == $read_num_split_fa && $file_num < $split){
		$reads_s=0;
		close OUT;
		$file_num++;
	}
	if($reads_s==0){
		open(OUT,">$fa_h-$file_num.fasta")||die "Write to $fa_h-$file_num.fasta: $!\n";
	}

	print OUT "$l1\n$l2\n";
	$reads_s++;
}
close IN;
close OUT;
