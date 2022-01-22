#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my %ctg_leng=();
my %ctg_cov=();
my %ctg_ref_cov=();


# load blast result
open(IN,"<$ARGV[0]") || die "Cannot open $ARGV[0]: $!\n";
while(<IN>){
# blast result format 
#1.  qseqid      query or source (e.g., gene) sequence id
#2.  sseqid      subject  or target (e.g., reference genome) sequence id
#3.  sseqname
#4.  pident      percentage of identical matches
#5.  length      alignment length (sequence overlap)
#6.  mismatch    number of mismatches
#7.  gapopen     number of gap openings
#8.  qstart      start of alignment in query
#9.  qend        end of alignment in query
#10.  sstart      start of alignment in subject
#11.  send        end of alignment in subject
#12.  evalue      expect value
#13.  bitscore    bit score
	my @a=split("\t",$_); chomp @a;

	my ($c_name,$c_leng)=$a[0]=~/(\S+)\|(\d+)/;
	if(!$ctg_leng{$c_name}){
		$ctg_leng{$c_name}=$c_leng;
	}
	
	my ($c_start,$c_end)=();
	if($a[7] < $a[8]){
		($c_start,$c_end)=($a[7],$a[8]);
	}else{
		($c_start,$c_end)=($a[8],$a[7]);
	}
	#print "$c_name\t$a[1]\t$c_start\t$c_end\t".($c_end-$c_start+1)."\n";
	for (my $i=$c_start; $i<=$c_end; $i++){
		$ctg_cov{$c_name}[$i]=1;
		$ctg_ref_cov{"$c_name\:$a[1]"}[$i]=1;
		#print "11\t$c_name\t$a[1]\t$i\n";
	}
}
close IN;

#print Dumper %ctg_cov;
#print Dumper %ctg_ref_cov;

#foreach my $ctg (keys %ctg_leng){
#	my $cover=0;
#	for (my $l=1; $l<= $ctg_leng{$ctg}; $l++){
#		if($ctg_cov{$ctg}[$l] && $ctg_cov{$ctg}[$l]>0 ){
#			$cover++;
#		}
#	}
#	my $coverage=sprintf("%.2f",$cover/$ctg_leng{$ctg}*100);
#	print "$ctg\t$coverage\n";
#}


my %plasmid_ref_covperc=();
foreach my $ctg_ref (sort (keys %ctg_ref_cov)){
	my ($ctg,$ref)=$ctg_ref=~/(\S+)\:(\S+)/;
	my $cover=0;
	for (my $l=1; $l<= $ctg_leng{$ctg}; $l++){
		if($ctg_ref_cov{$ctg_ref}[$l] && $ctg_ref_cov{$ctg_ref}>0 ){

			#print "22\t$ctg\t$ref\t$l\n";
			$cover++;
		}
	}
	my $coverage=$cover/$ctg_leng{$ctg}*100;
	#print "$ctg\t$ref\t$coverage\t$cover\t$ctg_leng{$ctg}\n";
	$plasmid_ref_covperc{$ctg}{$ref}=$coverage;
}

foreach my $p (sort (keys %plasmid_ref_covperc)){
	foreach my $r (sort {$plasmid_ref_covperc{$p}{$b} <=> $plasmid_ref_covperc{$p}{$a}} (keys %{$plasmid_ref_covperc{$p}})){
		print "$p\t$r\t$plasmid_ref_covperc{$p}{$r}\n";
	}
}
