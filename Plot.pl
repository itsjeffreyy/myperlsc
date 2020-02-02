#!/usr/bin/perl -w
# writer: Jeffreyy Yu
use strict;
use Data::Dumper;
my $filename=$ARGV[0];
my ($title)=$ARGV[0]=~/(.+)\.\S+/;
my $plotfile.="$title\.plot";
open(PlotOUT,">$plotfile");
print PlotOUT <<EOF;


table<-read.table('./$filename')
insert<-table[[1]]
account<-table[[2]]

png(filename="./$ARGV[0]_distribution.png",width = 500, height = 500)
mar=c(4, 10, 2, 1)

#plot(insert,account,type='h',main='Paired-end insert length distribution $title')

plot(insert,account,xlim=c(0,800),ylim=c(0,2.1),type='l',main='Paired-end insert length distribution $title',xlab="Insert length (b)",ylab="Account (x100000)", yaxt='n',xaxt='n')

axis(1,at=seq(0,800,by=100))
axis(2,at=seq(0,2.1,by=0.3),las=2,mgp=c(20,1,0))

#axis(2,at=seq(0,140000,by=20000),las=2 )

#mtext('123', line=5, side=2)

dev.off()
EOF

close PlotOUT;
`R --vanilla -f ./$plotfile`;
`rm $plotfile`;
