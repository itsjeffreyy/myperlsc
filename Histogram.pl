#!/usr/bin/perl -w
# usage: Histogram.pl [option] velvet_stat.txt
#        option:
#        scal start,end  ex: 10,20
#        the default is 0,50
# writer: Jeffreyy Yu

use strict;
use Data::Dumper;
use Getopt::Long;

my $scal="";
my ($s,$e)=(0,50);
my $filename=$ARGV[0];
my $plotfile="$ARGV[0].plot";

GetOptions(
	"xscal=s" => \$scal,
);


if($scal){
	($s,$e)=split(",",$scal);
}

open(PlotOUT,">$plotfile");
print PlotOUT <<EOF;
data = read.table("./$filename",header=TRUE)
png("./$ARGV[0]_histogram.png")
hist(data\$short1_cov,xlim=range($s,$e),breaks=1000000)
dev.off()
EOF

close PlotOUT;
`R --vanilla -f ./$plotfile`;
`rm $plotfile`;
