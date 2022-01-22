#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# load genome fasta
open(INfa,"<$ARGV[0]")|| die "Cannot open Fasta $ARGV[0]: $!\n";
my $t="";
my %chr_seq=();
while(<INfa>){
	chomp;
	if($_=~/^>(\S+)/){
		$t=$1;
	}else{
		$chr_seq{$t}.=$_;
	}

}
close INfa;


# load annovar result
open (INanno,"<$ARGV[1]")|| die "Cannot open wANNOVAR result TXT $ARGV[1]: $!\n";
my $h=<INanno>; chomp $h;
my @annovar_head=split("\t",$h);
# 1  'Chr';
# 2  'Start';
# 3  'End';
# 4  'Ref';
# 5  'Alt';
# 6  'Func.refGene';
# 7  'Gene.refGene';
# 8  'GeneDetail.refGene';
# 9  'ExonicFunc.refGene';
# 10 'AAChange.refGene';
# 30 'dbSNP';
# 31 'COSMIC_ID';
# 32 'COSMIC_DIS';
# 33 'ClinVar_SIG';
# 34 'ClinVar_DIS';
# 35 'ClinVar_ID';
# 36 'ClinVar_DB';
# 37 'ClinVar_DBID';

# record ClinVar, COSMIC, dbSNP
my %annovar_info=();
while(<INanno>){
	chomp;
	
	my @a=split("\t",$_);
	my ($chr,$start,$end,$ref,$alt)=@a[0..4];
	grep{$_=~s/\\x2c/,/g}@a[32..36];
	
	if($ref ne '-' && $alt ne '-'){
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{"info"}=join("\t",@a[0..6])."\t$a[8]"; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{"AA"}=$a[9]; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'dbSNP'}=$a[29]; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'COSMIC'}=join("\t",@a[30..31]); 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'ClinVar'}=join("\t",@a[32..35]); 
	}else{
		my $fn = substr($chr_seq{$chr},$start-2,1); # first nucleotide
		$a[1]-=1;

		if($a[3] eq '-'){
			$a[3]=$fn;
		}else{
			$a[3]=$fn.$a[3];
		}

		if($a[4] eq '-'){
			$a[4]=$fn;
		}else{
			$a[4]=$fn.$a[4];
		}

		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{"info"}=join("\t",@a[0..6])."\t$a[8]"; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{"AA"}=$a[9]; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'dbSNP'}=$a[29]; 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'COSMIC'}=join("\t",@a[30..31]); 
		$annovar_info{"$a[0]\t$a[1]\t$a[3]\t$a[4]"}{'ClinVar'}=join("\t",@a[32..35]); 

	}
}
close INanno;

#print Dumper %annovar_info;

# create title
my $output_head=join("\t",@annovar_head[0..6])."\t".join("\t",@annovar_head[8..9])."\t".join("\t",@annovar_head[29..35]);

# load hgvs result
my %hgvs_info=();
open(INhgvs,"<$ARGV[2]") || die "Cannot open HGVS $ARGV[2]: $!\n";
while(<INhgvs>){
	chomp;
	my @a=split("\t",$_);
	# chr posi ref alt NC_info NM_info NP_info
	if($a[5] eq 'intron'){
		$hgvs_info{"$a[0]\t$a[1]\t$a[2]\t$a[3]"}=join("\t",@a[4..5]);
	}else{
		$hgvs_info{"$a[0]\t$a[1]\t$a[2]\t$a[3]"}=join("\t",@a[4..6]);
	}
}
close INhgvs;
#print Dumper %hgvs_info;

print "$output_head\n";
# load self variant calling results and output combined result
open(INvcf,"<$ARGV[3]") || die "Cannot open vcf $ARGV[3]: $!\n";
while(<INvcf>){
	chomp;
	# CHROM  POS     ID      REF     ALT     QUAL    FILTER  INFO
	if($_=~/^#/){
		next;
	}
	my @b=split("\t",$_);
	my $key="$b[0]\t$b[1]\t$b[3]\t$b[4]";
	if($annovar_info{$key}){
		print "$annovar_info{$key}{info}\t$annovar_info{$key}{AA}\t$annovar_info{$key}{dbSNP}\t$annovar_info{$key}{COSMIC}\t$annovar_info{$key}{ClinVar}\n";
	}

}
close INvcf;
