#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2013.09.12
# usage: SoapdenovoCtgGraph2Newbler.pl file.contig file.Arc > file_ContigGraph.txt

use strict;
use Data::Dumper;

if(!$ARGV[0] || !$ARGV[1]){
	&Help;
}


# load contig file
my %ctgcount=();
open (IN,"<$ARGV[0]")|| die "open file $ARGV[0]:$!\n";
my $count=0;
while(<IN>){
	chomp;
	if($_!~/^>/){next;}
	$count++;
	my ($ctg,$leng,$cov)=();
	if($_=~/^>(\d+)\s+length\s+(\d+)\s+cvg_(.+)_tip_\d+/){
		$ctg=$1; $leng=$2; $cov=$3;
	}
	print "$count\t$ctg\t$leng\t$cov\n";
	$ctgcount{$ctg}=$count;
}
close IN;

# load Soapdenovo2 Arc file
open (IN,"<$ARGV[1]")|| die "open file $ARGV[1]:$!\n";
while(<IN>){
	chomp;
	my @a=split(" ",$_);

	# deal with left contig
	my $prelc=shift (@a);
	my $jadgelc=$prelc/2;
	my $lc="";
	if($jadgelc=~/\.5/){
		#$lc="$ctgcount{$prelc}\t3\'";
		$lc="$prelc\t3\'";
	}else{
		#$lc=$ctgcount{$prelc-1};
		$lc=$prelc-1;
		$lc.="\t5\'";
	}
		
	#deal with right contig
	while(@a){
		my $prerc=shift @a;
		my $cov=shift @a;
		my $jadgerc=$prerc/2;
		my $rc="";
		if($jadgerc=~/\.5/){
			#$rc="$ctgcount{$prerc}\t5\'";
			$rc="$prerc\t5\'";
		}else{
			#$rc=$ctgcount{$prerc-1};
			$rc=$prerc-1;
			$rc.="\t3\'";
		}

		print "C\t$lc\t$rc\t$cov\n";
	}
}
close IN;

############################################################
sub Help{
print <<EOF;

usage: SoapdenovoCtgGraph2Newbler.pl file.contig file.Arc > file_ContigGraph.txt
note: This script function is that transfer the Soappdenovo2 Arc formate to newbler contig graph formate.  The file.Arc is the output file Arc file of Soapdenovo2.

EOF
exit;
}
