#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2015.03.11
#

use strict;
use Data::Dumper;
use Getopt::Long;

my %nuclaa=("TTT" => "F","TTC" => "F","TTA" => "L","TTG" => "L","CTT" => "L","CTC" => "L","CTA" => "L","CTG" => "L","ATT" => "I","ATC" => "I","ATA" => "I","ATG" => "M","GTT" => "V","GTC" => "V","GTA" => "V","GTG" => "V","TCT" => "S","TCC" => "S","TCA" => "S","TCG" => "S","CCT" => "P","CCC" => "P","CCA" => "P","CCG" => "P","ACT" => "T","ACC" => "T","ACA" => "T","ACG" => "T","GCT" => "A","GCC" => "A","GCA" => "A","GCG" => "A","TAT" => "Y","TAC" => "Y","TAA" => "*","TAG" => "*","CAT" => "H","CAC" => "H","CAA" => "Q","CAG" => "Q","AAT" => "N","AAC" => "N","AAA" => "K","AAG" => "K","GAT" => "D","GAC" => "D","GAA" => "E","GAG" => "E","TGT" => "C","TGC" => "C","TGA" => "*","TGG" => "W","CGT" => "R","CGC" => "R","CGA" => "R","CGG" => "R","AGT" => "S","AGC" => "S","AGA" => "R","AGG" => "R","GGT" => "G","GGC" => "G","GGA" => "G","GGG" => "G");

my $fna="";
my $seqseq="";
GetOptions(
	"in=s" => \$fna,
	"seq|s=s" => \$seqseq,
);

if($seqseq){
	my $aaseq="";
	my @a=split("",uc($seqseq));
	for(my $i=2; $i<=$#a; $i+=3){
		$aaseq.=($nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} ? $nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} : "+");
	}
	print "$aaseq\n";
}

elsif($fna){
	open(IN,"<$fna")|| die "open $fna: $!\n";
	my %idseq=();
	my $id="";
	my $seq="";
	while(<IN>){
		chomp;
		if($_=~/^>(.+)/ && !$seq){
			$id=$1;
	
		}elsif($_=~/^>(.+)/ && $seq){
			my $aaseq="";
			my @a=split("",uc($seq));
			for(my $i=2; $i<=$#a; $i+=3){
				$aaseq.=($nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} ? $nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} : "+");
			}
			my $aalen=length($aaseq);
			print ">$id\_$aalen"."aa"."\n$aaseq\n";
			#print ">$id\n$aaseq\n";
			$seq="";
			seek(IN,-length($_)-1,1);
			#last;	
	
		}elsif($_!~/^>/){
			$seq.=$_;
			
		}
	}
	
	my $aaseq="";
	my @a=split("",uc($seq));
	for(my $i=2; $i<=$#a; $i+=3){
		$aaseq.=($nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} ? $nuclaa{"$a[$i-2]$a[$i-1]$a[$i]"} : "+");
	}
	my $aalen=length($aaseq);
	print ">$id\_$aalen"."aa"."\n$aaseq\n";
	#print ">$id\n$aaseq\n";
		
	close IN;
}
