#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
my $total_reads=0;
foreach(@ARGV){
	my($reads,$leng)=&SingleFq($_);
	$total_leng+=$leng;
	$total_reads+=$reads;
}
print "Total: $total_reads reads,\t$total_leng bp\n";

############################################################
sub SingleFq(){
	my $fq=shift(@_);
	open(IN,"<$fq")||die "open file $fq:$!\n";
	my $leng=0;
	my $reads=0;
	while(<IN>){
		if ($_=~/^@/){
		 	my $seq=<IN>; chomp $seq;
			$reads+=1;
			$leng+=length($seq);
			<IN>;<IN>;
		}else{
			print "ERR: $fq is not fastq.\n";
			close IN;
			return (0,0);
		}
	}
	close IN;
	print "$fq: $reads reads,\t$leng bp\n";
	return($reads,$leng);
}
