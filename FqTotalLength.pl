#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
foreach(@ARGV){
	$total_leng+=&SingleFqLeng($_);
}
print "Total length: $total_leng\n";

############################################################
sub SingleFqLeng(){
	my $fq=shift(@_);
	open(IN,"<$fq")||die "open file $fq:$!\n";
	my $len=0;
	while(<IN>){
		if ($_=~/^@/){
		 	my $seq=<IN>; chomp $seq;
			$len+=length($seq);
			<IN>;<IN>;
		}
	}
	close IN;
	print "$fq: $len\n";
	return($len);
}
