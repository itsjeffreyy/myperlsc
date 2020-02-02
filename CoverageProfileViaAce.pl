#!/usr/bin/perl -w
#writer : Jeffreyy Yu
#usage : CoverageProfileViaAce.pl .ace

use strict;
use Data::Dumper;
use Getopt::Long;

my $baseratiocut=0.1;
GetOptions(
		"baseratio|br=f"=> \$baseratiocut,
		);

open(IN,"<$ARGV[0]")|| die"open file $ARGV[0]:$!\n";

my %clen=();
my %cseq=();
my $cid="";
my %rposi=();
my %rseq=();
my %raseq=();
my %rregion=();
my %cposin=();
<IN>; <IN>;

while(<IN>){
	chomp;
#	$_=<IN>; chomp $_;
	my $clen="";
	print "load CO\n";
	if($_=~/^CO\s+contig0+(\d+)\s+(\d+)/){
		$cid=$1;
		$clen=$2;
		print "$cid\n";
	}

	$clen{$cid}=$clen;
	%rposi=();
	%rseq=();
	%raseq=();
	%rregion=();

	my $seq="";
	while(<IN>){
		if($_ eq "\n"){last;}

		chomp;
		$seq.=uc($_);
	}
	@{$cseq{$cid}}=split("",$seq);


	print "load AF\n";
	while(<IN>){
		if($_=~/^BS/){last;}
		if($_!~/^AF/){next;}

		chomp;
		if($_=~/^AF\s+(\S+)\s+(\w+)\s+(\S+)/){
			my $r=$1;
			my $dir=( $2 eq "u" ? "+" : "-" );
			my $rpos=$3;
			$rposi{$r}=$rpos;
		}
	}

	print "load RD & QA\n";
	while(<IN>){
		if($_=~/^CO/){seek(IN,-length($_),1); last;}
		if($_=~/^BS/){next;}
		if($_=~/^DS/){next;}
		if($_ eq "\n"){next;}

		chomp;
		if($_=~/^RD\s+(\S+)\s+(\d+)/){
			my $r=$1;
			my $rlen=$2;
			my $rseq="";
			while(<IN>){
				if($_ eq "\n"){last;}

				chomp;
				$rseq.=$_;
			}
			$rseq{$r}=$rseq;

			while(<IN>){
				chomp;
				if($_=~/^QA\s+(\S+)\s+(\S+)/){
					my $start=$1;
					my $end=$2;
					$rregion{$r}=[$start,$end];
					if($start > 1 ){
						$rposi{$r}=$rposi{$r}+$start-1;
					}
					last;
				}
			}	
		}
		foreach my $k (keys %rseq){
			if($k=~/\./){
				my $len=$rregion{$k}[1]-$rregion{$k}[0]+1;
				$raseq{$k}=substr($rseq{$k},$rregion{$k}[0]-1,$len);
			}else{
				$raseq{$k}=$rseq{$k};
			}
		}
	}

	foreach my $r (keys %raseq){
		my $rlen=length($raseq{$r});
		my @seq=split("",$raseq{$r});
		for(my $p=0;$p < $rlen;$p++){
			my $cposi=$rposi{$r}+$p-1;
			$cposin{$cid}{$cposi}{$seq[$p]}++;
		}
	}
}
close IN;


# %cposinucon: contig position nucleotide contain.
my %cposinucon=();
foreach my $c (keys %clen){
	my $cleng=$clen{$c};
	my $i=0;
#	for my $p (0..$cleng-1){
	for (my $p=0;$p<$cleng-1;$p++){
		my $total=0;

# eliminate the sequence *, and transfer the position to the contigs without *.
		if($cseq{$c}[$p]ne "*"){
			$i++;
# count the total coverage of every position
			foreach my $n (keys %{$cposin{$c}{$p}}){
				$total+=$cposin{$c}{$p}{$n};
			}

# calculate the percentage of every base in every position	
			foreach my $nu (keys %{$cposin{$c}{$p}}){
				if($cposin{$c}{$p}{$nu}/$total >= $baseratiocut){
#					$cposinucon{$c}{$i}{$nu}=$cposin{$c}{$p}{$nu}/$total;
					my $ratio=sprintf("%.2f",$cposin{$c}{$p}{$nu}/$total);
					push (@{$cposinucon{$c}[$i]},"$nu,$ratio");
#					print "$p\t$cseq{$c}[$p]\t$nu\t$i\t$total\t$cposin{$c}{$p}{$nu}\t$ratio\n";
				}
			}
		}
	}
}
# print result
open(OUT,">newblerctg_ambiguous.lst");
foreach my $cid (keys %cposinucon){
	for (my $p =1;$p <= $clen{$cid};$p++){
		if($#{$cposinucon{$cid}[$p]} < 1){next;}
		print OUT "nc_$cid\+\t$p\t".join("\t",@{$cposinucon{$cid}[$p]})."\n";
	}
}
# print time
#my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
#print OUT "\nfile product time\n",scalar localtime,"\n";

close OUT;
