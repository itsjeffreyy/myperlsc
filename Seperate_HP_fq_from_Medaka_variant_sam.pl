#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
# Usage:
# Seperate_HP_fq_from_Medaka_variant_sam.pl round_0_hap_mixed_phased.bam read.fastq

my $prefix="output";

GetOptions(
	"prefix|p=s" => \$prefix,
);

# load the fastq file
my %id_seq=();
my %id_qua=();
open(IN,"<$ARGV[1]")|| die "Cannot open $ARGV[1]: $!\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my ($id)=$l1=~/^\@(\S+)/;
	my $seq=<IN>; chomp $seq;
	<IN>;
	my $qua=<IN>; chomp $qua;
	$id_seq{$id}=$seq;
	$id_qua{$id}=$qua;
}
close IN;

# output the phase1 and phase2 reads
my $p1_fq="$prefix\_phase1.fastq";
my $p2_fq="$prefix\_phase2.fastq";
my $chimera_fq="$prefix\_chimera.fastq";

# load the bam file by medaka variant
my $bam_f=$ARGV[0];
my %phase1_read=();
my %phase2_read=();
my %total_read=();
my ($head)=$bam_f=~/(\S+).bam/;
my $sam_f=$head.".sam";
`samtools view -h $bam_f -o $sam_f`;
open(IN,"<$sam_f")|| die "Cannot open $sam_f: $!\n";
while(<IN>){
	if($_=~/^@/){next;}
	chomp;
	my @a=split("\t",$_);
	my $id=$a[0];
	my @tags=@a[11..(scalar @a-1)];
	$total_read{$id}=1;

	foreach my $t (@tags){
		if($t=~/^HP\:i\:(\d)/){
			if($1 == 1){
				$phase1_read{$id}=1;
			}elsif($1 == 2){
				$phase2_read{$id}=1;
			}	
			last;
		}
	}
}
close IN;

# output the reads
open(OUT1,">$p1_fq")|| die "Cannot write $p1_fq\n";
open(OUT2,">$p2_fq")|| die "Cannot write $p2_fq\n";
open(OUTc,">$chimera_fq")|| die "Cannot write $chimera_fq\n";
foreach my $id (keys %total_read){
	if($phase1_read{$id}){
		print OUT1 "\@$id\n$id_seq{$id}\n\+\n$id_qua{$id}\n";
	}elsif($phase2_read{$id}){
		print OUT2 "\@$id\n$id_seq{$id}\n\+\n$id_qua{$id}\n";
	}else{
		print OUTc "\@$id\n$id_seq{$id}\n\+\n$id_qua{$id}\n";
	}
}
close OUT1;
close OUT2;
close OUTc;
