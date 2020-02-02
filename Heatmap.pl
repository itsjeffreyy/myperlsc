#!/usr/bin/perl -w
use strict;
use Getopt::Long;
use Data::Dumper;

my $dist="dist";#(corr)
my $out="heatmap";
my $data="";
my $size=1000;
my $group=1;

GetOptions(
	"dist|d=s" => \$dist,
	"data=s"   => \$data,
	"out|o=s"  => \$out,
	"size|s=s" => \$size,
	"group|g=s"=> \$group,
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
heat <- heatmap(data_matrix)
dev.off()
sink("./$rank")
heat
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
heat <- heatmap(data_matrix)
dev.off()
sink("./$rank")
heat
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

open(IN,"$data")|| die "open file $data:$!\n";
my @rankgene=();
<IN>;
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	push(@rankgene,$a[0]);
}
close IN;

open(IN,"<$rank")|| die "open file $rank :$!\n";
my @treegene=();
while(<IN>){
	if($_=~/\$rowInd/){
		while(<IN>){
			if($_ eq "\n"){last;}
			chomp;
			my @a=split(" ",$_);
			shift @a;
			map{ push(@treegene,$_) }@a;
		}
	}
}
close IN;

my @rtreegene=reverse @treegene;
my $fn=$out.".heatmap_gene_rank";
open(OUT,">$fn");
foreach(@rtreegene){
#	print OUT "$_\t$rankgene[$_-1]\n";
	print OUT "$rankgene[$_-1]\n";
}
close OUT;

system("rm $rank");
######################################################################
sub Help{
print <<EOF;

usage: Heatmap.pl --dist dist/corr --data file

EOF
exit 0;
}
