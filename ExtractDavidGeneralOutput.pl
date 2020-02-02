#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2013.06.25
# version: 0.1
# usage: ExtractDavidClusteringOutput.pl -davidoutput|-david GOstat_output1 GOstat_output2,... [option]
# NOTE: the David clustering output format is like following:
#       Annotation Cluster 1    Enrichment Score: 14.0661862500259
#       Category	Term	Count	%	PValue	Genes	List Total	Pop Hits	Pop Total	Fold Enrichment Bonferroni	Benjamini	FDR
 

use strict;
use Data::Dumper;
use Getopt::Long;

my $sgene="";
my $pvfilter="";
my $count="";
my @davido=();
my $help="";

GetOptions(
	"davidoutput|david=s{,}"=> \@davido,
	"showgene|sg"     => \$sgene,
	"p_value|p=f"  => \$pvfilter,
	"top|t=i"    => \$count,
	"help|h"     => \$help,
);

if(!@davido || $help){
	&Help;
}

foreach my $dof (@davido){

	# set the output file name
	my ($fn)=$dof=~/(\S+).txt/;
	if($sgene){$fn.="_genes";}
	$fn.=".out";

	open(OUT,">./$fn");
	
	# load the David GO or pathway output file
	open(IN,"<$dof")|| die "open file $dof:$!\n";
	while(<IN>){
		my $title=$_; chomp $title;
		my @t=split("\t",$title);
		if($sgene){
			#print OUT "$t[2]\t$t[3]\t$t[6]\t$t[7]\t$t[8]\t$t[4]\t$t[10]\t$t[11]\t$t[12]\t$t[0]\t$t[1]\t$t[5]\n";
			print OUT "$t[2]\t$t[3]\t$t[6]\t$t[7]\t$t[8]\t$t[4]\t$t[11]\t$t[12]\t$t[0]\t$t[1]\t$t[5]\n";
		}else{
			#print OUT "$t[2]\t$t[3]\t$t[6]\t$t[7]\t$t[8]\t$t[4]\t$t[10]\t$t[11]\t$t[12]\t$t[0]\t$t[1]\n";
			print OUT "$t[2]\t$t[3]\t$t[6]\t$t[7]\t$t[8]\t$t[4]\t$t[11]\t$t[12]\t$t[0]\t$t[1]\n";
		}
	
		my $c=0;
		while(<IN>){
			if($_ eq "\n"){print OUT "\n";last;}
			chomp;
			my @a=split("\t",$_);
			#Category	Term	Count	%	PValue	Genes	List Total	Pop Hits	Pop Total	Fold Enrichment Bonferroni	Benjamini	FDR
			#P value
			my $pv=sprintf("%.4e",$a[4]);
			# Gene
			my $gene=$a[5];
			# percentage of the genes over term gene number
			my $percentage=sprintf("%.6f",$a[3]);
	
	
			if($pvfilter && $pv > $pvfilter){next;}
			if($count && $c==$count){next;}
			my $bonferroni=sprintf("%.4e",$a[10]);
			my $benjamini=sprintf("%.4e",$a[11]);
			my $FDR=sprintf("%.4e",$a[12]);
		
			if($sgene){
				#print OUT "$a[2]\t$percentage\t$a[6]\t$a[7]\t$a[8]\t\t$pv\t$bonferroni\t$benjamini\t$FDR\t$a[0]\t$a[1]\t\|$gene\|\n";
				print OUT "$a[2]\t$percentage\t$a[6]\t$a[7]\t$a[8]\t\t$pv\t$benjamini\t$FDR\t$a[0]\t$a[1]\t\|$gene\|\n";
				$c++;
			}else{
				#print OUT "$a[2]\t$percentage\t$a[6]\t$a[7]\t$a[8]\t\t$pv\t$bonferroni\t$benjamini\t$FDR\t$a[0]\t$a[1]\n";
				print OUT "$a[2]\t$percentage\t$a[6]\t$a[7]\t$a[8]\t\t$pv\t$benjamini\t$FDR\t$a[0]\t$a[1]\n";
				$c++;
			}
		}
	}
	close IN;
	close OUT;
}

############################################################
sub Help{

print <<EOF;

usage: ExtractDavidClusteringOutput.pl -davidoutput|-david David_output1 David_output2 ... [option]
option:
	davidoutput|david : the David clustering output files (input files)
	showgene|sg     : if want to show genes, then turn on it.
	p_value|p       : if want to set a cutoff of P value, then give a number
	top|t           : if only want to show top term, then give the number
	clusteringnumber|cn : if only want to show top cluster, then give the number
	help|h          : show help
note:
the David clustering output format is like following:
Annotation Cluster 1    Enrichment Score: 14.0661862500259
Category	Term	Count	%	PValue	Genes	List Total	Pop Hits	Pop Total	Fold Enrichment Bonferroni	Benjamini	FDR
	

EOF
exit 0;
}
