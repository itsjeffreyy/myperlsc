#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2013.05.28
# version:0.2
# usage:

use strict;
use Data::Dumper;
use Getopt::Long;

my $plot="";
GetOptions(
	"plot|p" => \$plot,
);

if(-e "*.png"){
	`rm *_group*.value.png`;
	`rm *_group*.value`;
}

# load the groups file (heatmap.groups)
my %groupgenevalue=();
open(IN,"<$ARGV[0]")|| die "open file $ARGV[0]:$!\n";
my $title=<IN>;
my %groupcount=();
my %groupsum=();
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my $gene=shift @a;
	my $group=shift @a;
	$groupcount{$group}++;
	push(@{$groupgenevalue{$group}},"$gene\t".join("\t",@a));
	for (my $i=0;$i<=$#a;$i++){
		$groupsum{$group}[$i]+=$a[$i];
	}
}
close IN;

# gfn: group file name
my @gfn=();
foreach my $gr (sort {$a<=>$b}(keys %groupgenevalue)){
	my ($fn)=$ARGV[0]=~/(\S+)\.groups/;
	$fn.="\_group"; $fn.=$gr."\.value";
	my ($fnl)=$ARGV[0]=~/(\S+)\.groups/;
	$fnl.="\_group"; $fnl.=$gr."\.list";
	push(@gfn,$fn);
	open(OUT,">$fn");
	open(OUT1,">$fnl");
	my @t=split("\t",$title);
	print OUT "$t[0]\t";
	shift @t; shift @t;
	print OUT join("\t",@t);

	foreach (@{$groupgenevalue{$gr}}){
		print OUT "$_\n";
		my @aa=split("\t",$_);
		print OUT1 "$aa[0]\n";
	}

	my @average=();
	foreach (@{$groupsum{$gr}}){
		my $aver=sprintf("%.6f",$_/$groupcount{$gr});
		push(@average,$aver);
	}
	print OUT "average\t".join("\t",@average)."\n";
	close OUT;
	close OUT1;
}

if(!$plot){exit 0;}

# create R plot script
foreach my $f (@gfn){
	my ($gr)=$f=~/\S+_group(\d+)\.value/;
	# file R plot
	my $frp=$f; $frp.="\.Rplot";
	open(Rplot,">$frp");
	print Rplot "data <- read.table(\"./$f\",sep=\"\\t\",header=TRUE,row.names=1)\n";
	print Rplot "png(filename='$f.png')\n";
	print Rplot "#plot(t(data[1,]), col='#FF00CC', type='o', pch='', lwd=2, xlab='', ylab='')\n";
	for (my $i=1;$i<=$groupcount{$gr};$i++){
		print Rplot "plot(t(data[$i,]),  type='o', xlab='', ylab='', ylim=c(-2,2), xlim=c(1,4),axes=FALSE)\n";
		print Rplot "par(new=T)\n";
	}
	my $last=$groupcount{$gr}+1;
	print Rplot "plot(t(data[$last,]), col='#FF00CC',lwd=2, type='o',xlab='', ylab='', ylim=c(-2,2), xlim=c(1,4))\n";
	print Rplot "box()\n";
	my $sum=@{$groupgenevalue{$gr}};
	print Rplot "title(main='group$gr\_sum.$sum', line=1, cex=1.5)\n";
	print Rplot "mtext('condition', side=1, line=2, col='black', cex=1.5)\n";
	print Rplot "mtext('FPKM (z-score)', side=2, line=2, col='black', cex=1.5)\n";
	print Rplot "dev.off()";
	close Rplot;
	`R --vanilla -f $frp`;
	`rm $frp`;
}
