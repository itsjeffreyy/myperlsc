#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my %id_seq=();
my %id_leng=();
# load the fastq file
open(IN,"<$ARGV[0]")|| die "Cannot open $ARGV[0]: $!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my ($id)=$l1=~/^\@(\S+)/;
	my $l2=<IN>; chomp $l2;
	<IN>;<IN>;
	$id_seq{$id}=$l2;
	$id_leng{$id}=length($l2);
}
close IN;

my $fq_name=`basename $ARGV[0]`; chomp $fq_name;
my $fq_head="";
if($fq_name=~/(.+)\.fastq/ || $fq_name=~/((.+)\.fq)/){
	$fq_head=$1;
}

open(OUTc,">$fq_head\_center.fasta")||die "Cannot write $fq_head\_center.fasta: $!\n";
open(OUTp,">$fq_head\_polish.fasta")||die "Cannot write $fq_head\_polish.fasta: $!\n";
my $i=1;
foreach my $id (sort {$id_leng{$b} <=> $id_leng{$a}} (keys %id_leng)){
	if($i==1){
		print OUTc ">$id\n$id_seq{$id}\n";
	}else{
		print OUTp ">$id\n$id_seq{$id}\n";
	}
	$i++;
}
close OUTc;
close OUTp;
