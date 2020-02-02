#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
my $len=0;
while(<IN>){
	if ($_=~/^@/){
	 	my $seq=<IN>; chomp $seq;
		$len+=length($seq);
		<IN>;<IN>;
	}
}
close IN;
print "Fastq $ARGV[0] Total= $len\n";
