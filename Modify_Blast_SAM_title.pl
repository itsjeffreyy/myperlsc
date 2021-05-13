#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my ($ref_file,$query_file)=();
open(IN,"<$ARGV[0]")|| die "Cannot open BLAST SAM  $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	# get ref and query fasta file
	# @PG     ID:0    VN:2.11.0+      CL:blastn -db /home/hgt/Projects/RD_cas9/code/Ref_flank.fa -query nanoq_q8_l1k/barcode08_q8_l1k.fasta -outfmt 17 -out blastn_ref_flank_barcode08_q8_l1k.sam -num_threads 16     PN:blastn
	if($_=~/^\@PG/){
		my @tmp=split("\t",$_);
		foreach (@tmp){
			if($_=~/^CL:/){
				my @tmp2=split(" ",$_);
				foreach (my $i=0; $i< scalar @tmp2; $i++){
					if($tmp2[$i] eq '-db'){
						$ref_file=$tmp2[$i+1];
					}
					if($tmp2[$i] eq '-query'){
						$query_file=$tmp2[$i+1];
					}
				}
				last;
			}
		}
		last;
	}

	# skip other header
	if($_!~/^@/){last;}
}
close IN;

# get ref and query id table
if(! -e $ref_file){
	print "ERR: Cannot open $ref_file: $!\n"; exit;
}
if(! -e $query_file){
	print "ERR: Cannot open $query_file: $!\n"; exit;
}

my %ref=();
my %query=();
open(INref,"<$ref_file") || die "Cannot open $ref_file: $!\n";
my $ref_i=0;
while(<INref>){
	if($_=~/^>(\S+)/){
		$ref{"BL_ORD_ID:$ref_i"}=$1;
		$ref_i++;
	}
}
close INref;

open(INquery,"<$query_file") || die "Cannot open $query_file: $!\n";
my $query_i=1;
while(<INquery>){
	if($_=~/^>(\S+)/){
		$query{"Query_$query_i"}=$1;
		$query_i++;
	}

}
close INquery;

# switch the ref and query title
open(IN,"<$ARGV[0]")|| die "Cannot open BLAST SAM  $ARGV[0]: $!\n";
while(<IN>){
	chomp;

	# deal with header
	if($_=~/^\@SQ/){
		my @a=split("\t",$_);
		my $query_name="";
		foreach (@a){
			if($_=~/SN:(Query_\d+)/){
				$query_name=$query{$1};
			}
		}
		print "$a[0]\tSN:$query_name\t$a[2]\n";
	}elsif($_=~/^@/){
		print "$_\n";
	}else{
		# major information
		my @a=split("\t",$_);
		print "$ref{$a[0]}\t$a[1]\t$query{$a[2]}\t";
		shift(@a);shift(@a);shift(@a);
		print join("\t",@a)."\n";
	}
}
close IN;
