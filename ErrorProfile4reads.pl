#!/usr/bin/perl -w 
# usage: ErrorProfile4reads.pl reads.fq
# writer: Jeffreyy Yu
# date: 2015.05.21

use strict;
use Data::Dumper;
use Getopt::Long;

# load the reads to record quality
my $readnumber=0;
my @epsum=();
open(IN,"<$ARGV[0]")|| die "open $ARGV[0]: $!\n";
while(<IN>){
	$readnumber++;
	<IN>;<IN>;
	$_=<IN>; chomp $_;
	my @qs=split("",$_);
	my @ep=map{10**(-(ord($_)-33)/10)}@qs;
	for(my $i=0;$i<=$#ep;$i++){
		$epsum[$i]+=$ep[$i];
	}
}
close IN;

#my @epmean=map{sprintf("%.4f",$_/$readnumber)}@epsum;
my @epmean=map{$_/$readnumber}@epsum;
my $i=0;
for (@epmean){
	$i++;
	print"$i\t$_\n";
}
