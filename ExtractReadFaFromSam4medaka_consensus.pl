#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# load the SAM file
my %readid=();
open(IN,"<$ARGV[0]")|| die "Cannot open SAM $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	if($_=~/^@/){next;}
	my @a=split("\t",$_);
	$readid{$a[0]}=1;
}
close IN;

# load fastq file
my %id_leng=();
my %id_seq=();
open(IN,"<$ARGV[1]")|| die "Cannot open FASTQ $ARGV[1]: $!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my $l2=<IN>; chomp $l2;
	my $l3=<IN>; chomp $l3;
	my $l4=<IN>; chomp $l4;
	my ($id)=$l1=~/^\@(\S+)/;
	if($readid{$id}){
		$id_leng{$id}=length($l2);
		$id_seq{$id}=$l2;
	}
}
close IN;

# output the two center and polish reads fasta files
my ($prefix)=$ARGV[0]=~/(\S+).sam/;
my $i=0;
open(OUTc,">$prefix\_center.fasta")|| die "Cannot write $prefix\_center.fasta: $!\n";
open(OUTp,">$prefix\_polish.fasta")|| die "Cannot write $prefix\_polish.fasta: $!\n";
foreach my $id (sort {$id_leng{$b}<=>$id_leng{$a}} (keys %id_leng)){
	$i++;
	if($i==1){
		print OUTc "\>$id\n$id_seq{$id}\n";
	}else{
		print OUTp "\>$id\n$id_seq{$id}\n";
	}
}
close OUTc;
close OUTp;
