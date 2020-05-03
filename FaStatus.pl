#!/usr/bin/perl -w
# usage : FaStatus.pl seqence.fa
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
my $total_reads=0;
foreach(@ARGV){
	my($reads,$leng)=&SingleFa($_);
	$total_leng+=$leng;
	$total_reads+=$reads;
}
print "Total: $total_reads reads,\t$total_leng bp\n";

############################################################
sub SingleFa(){
	my $fa=shift(@_);
	open(IN,"<$fa")||die "open file $fa:$!\n";
	my $leng=0;
	my $reads=0;
	while(<IN>){
		if ($_!~/^>/){
		 	my $seq=<IN>; chomp $seq;
			$leng+=length($seq);
		}elsif ($_=~/^>/){
			$reads+=1;
		}else{
			print "ERR: $fa is not fasta.\n";
			close IN;
			return (0,0);
		}
	}
	close IN;
	print "$fq: $reads reads,\t$leng bp\n";
	return($reads,$leng);
}
