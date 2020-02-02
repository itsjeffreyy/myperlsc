#!/usr/bin/perl -w
# writer : Jeffreyy Yu
# usage : CatchAllpaths-LGCtgVariation.pl .efasta .fasta > txt
# Note : .efasta is the allpaths-LG assembler output.

use strict;
use Data::Dumper;

# load allpathctg.efasta
open (IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";

my $acid="";
my %efa=();
while(<IN>){
	chomp;
	
	if($_=~/>contig_(\d+)/){ 
		$acid=$1;
		next;
	}
	
	$efa{$acid}.=$_;
}
close IN;

#open (IN,"<$ARGV[1]")||die "open file $ARGV[1]:$!\n";
#my $i="";
#my %acseq=();
#while(<IN>){
#	chomp;
#	if($_=~/^>contig_(\d+)/){
#		$i=$1; next;
#	}
#	$acseq{$i}.=$_;
#}
#close IN;

# record the ambiguous range
my %acr=();
foreach my $id (keys %efa){
	my $eseq=$efa{$id};
	my $d=0;
	my ($fs,$fe,$es,$ee)=[];
	my $i=index($eseq,"{",0);

	while( $i != -1 ){
		$es=$i+1; $fs=$i-$d;
		$ee=index($eseq,"}",$es)+1;

		my $seqopt=substr($eseq,$es,$ee-$es-1);
		my @a=split(",", $seqopt);
		if($seqopt=~/\,$/){push(@a,".");}

		$fe=length($a[0])+$fs+1;

		for(my $j=0;$j < $#a;$j++){
			if(! $a[$j]){ $a[$j]="."; }
		}

		$d=$ee-$fe+1;
		$i=index($eseq,"{",$ee-2);

#		print "ac_$id\t$fs><$fe\t|".substr($acseq{$id},$fs,$fe-$fs-1)."|\t".join("\t",@a)."\n";
		print "ac_$id\t$fs><$fe\t".join("\t",@a)."\n";

		@{$acr{$id}{"$fs><$fe"}}=@a;
	}
}
