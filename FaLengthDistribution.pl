#!/usr/bin/perl -w 
# writer: Jeffreyy Yu
# Uasge: FaLengthDistribution.pl file.fasta
# Note: This script produce a file .LenDis, the file context is the leng distribution statistic.

use strict;
use Data::Dumper;

my %sq=();
my %sl=();
my %c=();
my $id="";
my $i=0;
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^>(\S+)/){
		$i++;
		$id="$1\-$i";	
	}else{
		$sq{$id}.=$_;
	}
}
close IN;

foreach (keys %sq){
	$sl{$_}=length($sq{$_});
}

foreach my $l(values %sl){
	$c{$l}++;
}

my $filename="$ARGV[0].LenDis";
open(OUT,">$filename");
foreach (sort {$a<=>$b} (keys %c)){
	print OUT "$_\t$c{$_}\n";
}
close OUT;

# plot the distribution by R
my $plotfile="$ARGV[0].plot";
open(PlotOUT,">$plotfile");
print PlotOUT <<EOF;
table<-read.table('./$filename')
leng<-table[[1]]
account<-table[[2]]
png("./$ARGV[0]_distribution.png")
plot(leng,account,xlim=c(0,1000),type='l',main='454 read distribution $ARGV[0]')
axis(1, at=seq(0, 1000, by=50))
axis(2, at=seq(0, 5000, by=500))
dev.off()
EOF

close PlotOUT;
`R --vanilla -f ./$plotfile`;
`rm $plotfile`;
