#!/usr/bin/perl -w
# writer: Jeffreyy Yu, notehan
# date: 2013.05.22
# version: v2.1

use strict;
use Getopt::Long;
use Data::Dumper;

#######################################################
# This script required R package:
# gplots (heatmap.2)
#######################################################


my $dist="dist";#(corr)
my $out="heatmap";
my $data="";
my $size=1000;
my $group=1;
my @scale=("-10","10","0.5");

GetOptions(
		"dist|d=s" => \$dist,
		"data=s"   => \$data,
		"out|o=s"  => \$out,
		"size|s=s" => \$size,
		"group|g=s"=> \$group,
		"heatmapscale|hs=s{,}" => \@scale,
		);

if(!$data){
	print "ERR: No Input!!\n";
	&Help;
}

my $figure=$out."\.png";
my $Rplot="$out"."\.Rplot";
my $cutree="$out"."\.cutree";
my $rank="$out"."\.rank";
open(R,">$Rplot");

if($dist eq "dist"){
print R <<EOF;
data <- read.table("./$data",sep="\\t",header=TRUE,row.names=1)
data_matrix <- data.matrix(data)
png(filename="./$figure",width = $size, height = $size)
library("gplots")
#hm <- heatmap.2(data_matrix)
bk <- seq($scale[0], $scale[1], by=$scale[2])
hm <- heatmap.2(data_matrix,breaks=bk,col=greenred,scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.5)
dev.off()
rank <- labels(hm\$carpet)
sink("./$rank")
rank
sink()
hc.rows <- hclust(dist(data))
out <- cutree (hc.rows,k=$group)
sink("./$cutree")
out
sink()
EOF
}

if($dist eq "corr"){
print R <<EOF;
data <- read.table("./$data",sep="\\t",header=TRUE,row.names=1)
data_matrix <- data.matrix(data)
png(filename="./$figure",width = $size, height = $size)
library("gplots")
#hm <- heatmap.2(data_matrix, distfun=function(x) as.dist((1-cor(t(x)))/2))
bk <- seq($scale[0], $scale[1], by=$scale[2])
hm <- heatmap.2(data_matrix, distfun=function(x) as.dist((1-cor(t(x)))/2), breaks=bk,col=greenred,scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.5)
dev.off()
rank <- labels(hm\$carpet)
sink("./$rank")
rank
sink()
hc.rows <- hclust(as.dist((1-cor(t(data)))/2))
out <- cutree (hc.rows,k=$group)
sink("./$cutree")
out
sink()
EOF
}

close R;

system("R --vanilla -f $Rplot");
system("rm $Rplot");

my $fn=$out."\.groups";
open(OUT,">$fn");

open(IN,"$data")|| die "open file $data:$!\n";
my $line=<IN>; chomp $line;
my @line=split("\t",$line);
my $a=shift(@line);
print OUT "$a\tgroups\t".join("\t",@line)."\n";

my %geneexp=();
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my $aa=shift @a;
	$geneexp{$aa}=join("\t",@a);
}
close IN;

open(IN,"<$cutree")|| die "open file $cutree :$!\n";
my %genegroup=();
while(<IN>){
	my @a=split(" ",$_);  chomp $a[-1];
	my $g=<IN>;
	my @g=split(" ",$g);  chomp $g[-1];
	for(my $i=0;$i<=$#a;$i++){
		$genegroup{$a[$i]}=$g[$i];
	}
}
close IN;

open(IN,"<$rank")|| die "open file $rank :$!\n";
my @treegene=();
while(<IN>){
	if($_=~/\[\[2\]\]/){last;}
}
while(<IN>){
	if($_ eq "\n"){last;}
	chomp;
	my @a=split(" ",$_);
	shift @a;
	foreach (@a){
		my ($gene)=$_=~/\"(\S+)\"/;
		push(@treegene,$gene);
		
	}
}
close IN;


my @rtreegene=reverse @treegene;


foreach(@rtreegene){
	print OUT "$_\t$genegroup{$_}\t$geneexp{$_}\n";
}
close OUT;

system("rm $cutree");
system("rm $rank");
######################################################################
sub Help{
print <<EOF;

usage: Heatmap.pl --dist dist/corr --data file

EOF
exit 0;
}
