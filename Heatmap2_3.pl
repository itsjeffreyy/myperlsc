#!/usr/bin/perl -w
# writer: Jeffreyy Yu, notehan
# date: 2013.08.06
# version: v2.3

use strict;
use Getopt::Long;
use Data::Dumper;

#######################################################
# This script required R package:
# gplots (heatmap.2)
#######################################################


my $dist="dist";#(corr)
my $abs="";
my $out="heatmap";
my $data="";
my $size=1000;
my $group=1;
my @scale=();
my $col="heat.colors";#(greenred)

GetOptions(
		"dist|d=s" => \$dist,
		"abs"     => \$abs,
		"data=s"   => \$data,
		"out|o=s"  => \$out,
		"size|s=s" => \$size,
		"group|g=s"=> \$group,
		"heatmapscale|hs=s{,}" => \@scale,
		"color|col=s" => \$col,
		);

if(!$data){
	print "ERR: No Input!!\n";
	&Help;
}

if(!@scale){
	@scale=("-10","10","0.5");
}

# check whether the file include average 
my $tail=`tail -1 $data`;
if($tail=~/^average\t/){
	my $tmp=`wc -l $data`;
	my ($linenum)=$tmp=~/^(\d+)\s+/;
	$linenum--;
	`head \-$linenum $data > $data.tmp`;
	$data.=".tmp";
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
bk <- seq($scale[0], $scale[1], by=$scale[2])
EOF

if($abs){
print R <<EOF;
hm <- heatmap.2(data_matrix,distfun=function(x) as.dist(abs(x),method="euclidean"),breaks=bk,col="$col",scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.5)
EOF
}else{
print R <<EOF;
hm <- heatmap.2(data_matrix,breaks=bk,col="$col",scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.5)
EOF
}

print R <<EOF;
dev.off()
rank <- labels(hm\$carpet)
sink("./$rank")
rank
sink()
EOF

if($abs){
print R <<EOF;
hc.rows <- hclust(dist(abs(data)),method="euclidean")
EOF
}else{
print R <<EOF;
hc.rows <- hclust(dist(data))
EOF
}

print R <<EOF;
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
bk <- seq($scale[0], $scale[1], by=$scale[2])
EOF

if($abs){
print R <<EOF;
hm <- heatmap.2(data_matrix, distfun=function(x) as.dist((1-abs(cor(t(x))))/2), breaks=bk,col="$col",scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.1)
EOF
}else{
print R <<EOF;
hm <- heatmap.2(data_matrix, distfun=function(x) as.dist((1-cor(t(x)))/2), breaks=bk,col="$col",scale="none",key=TRUE, symkey=FALSE, density.info="none", trace="none",cexRow=0.1)
EOF
}

print R <<EOF;
dev.off()
rank <- labels(hm\$carpet)
sink("./$rank")
rank
sink()
EOF

if($abs){
print R <<EOF;
hc.rows <- hclust(as.dist((1-abs(cor(t(data))))/2))
EOF
}else{
print R <<EOF;
hc.rows <- hclust(as.dist((1-cor(t(data)))/2))
EOF
}

print R <<EOF;
out <- cutree (hc.rows,k=$group)
sink("./$cutree")
out
sink()
EOF
}

close R;

#system("R --vanilla -f $Rplot");
`R --vanilla -f $Rplot`;
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

my %groups=(); 
my @sortg=();
open(IN,"<$fn")|| die "open file $fn :$!\n";
<IN>;
my $gg=0;
while(<IN>){
	chomp;
	my @aa=split("\t",$_);
	$groups{$aa[1]}++;
	if($gg != $aa[1]){
		push(@sortg,$aa[1]);
		$gg=$aa[1];
	}
}
close IN;


my $groupstatefile=$fn;
$groupstatefile.="\.state";

#my @gg = (keys %groups);
open(OUT1,">$groupstatefile");
print OUT1 "groups\tsum\n";
print  "groups\tsum\n";
#foreach my $g (1..$#gg+1){
foreach my $g (@sortg){
#foreach my $g (sort(keys %groups)){
	print OUT1 "$g\t$groups{$g}\n";
	print "$g\t$groups{$g}\n";
}
close OUT1;

######################################################################
sub Help{
print <<EOF;

usage: Heatmap.pl --data file
options:
	data             : input data (!!must be given)
	dist|d           : distance matrix type : dist or corr (default: dist)
	abs              : when do clustering, if want to add absolute, then add this option
	out|o            : output file name           (default: heatmap)
	size|s           : the heatmap figure size    (default: 1000) 
	group|g          : clustering group number    (default: 1) 
	heatmapscale|hs  : heatmap color scale        (default: -10 10 0.5) 
	color|col        : heatmap color ex\:greenred (default: heat.colors) 

EOF
exit 0;
}
