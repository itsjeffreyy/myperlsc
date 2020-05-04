#!/usr/bin/perl -w
# usage : FaStatus.pl seqence.fa
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
my $total_reads=0;
my %leng_count=();
foreach(@ARGV){
	my($reads,$leng)=&SingleFa($_);
	$total_leng+=$leng;
	$total_reads+=$reads;
}

my $mean_leng=&Mean_Leng($total_reads, $total_leng);
my ($n50,$l50)=&N50($total_leng);

print "Total reads: $total_reads\nTotal length(bp): $total_leng\n";
print "Mean length (bp): $mean_leng\n";
print "N50 (bp): $n50\nL50: $l50\n";


############################################################
sub SingleFa(){
	my $fa=shift(@_);
	open(IN,"<$fa")||die "open file $fa:$!\n";
	my $leng=0;
	my $r_leng=0;
	my $reads=0;
	while(<IN>){
		if ($_!~/^>/){
		 	my $seq=$_; chomp $seq;
			$leng+=length($seq);
			$r_leng+=length($seq);
		}elsif ($_=~/^>/){
			$reads+=1;
			$leng_count{$r_leng}+=1 if $r_leng!=0;
			$r_leng=0;
		}else{
			print "ERR: $fa is not fasta.\n";
			close IN;
			return (0,0);
		}
	}
	$leng_count{$r_leng}+=1;
	close IN;
	print "$fa: $reads reads,\t$leng bp\n";
	return($reads,$leng);
}

sub Mean_Leng(){
	my ($reads, $leng)=@_;
	return sprintf("%.2f",$total_leng/$reads);
}

sub N50(){
	my $total_leng=shift @_;
	my ($leng_sum,$l50)=();
	foreach my $leng (sort {$b <=> $a} (keys %leng_count)){
		for (my $i=1; $i<=$leng_count{$leng}; $i++){
			$leng_sum+=$leng;
			$l50+=1;
			#print "$leng\t$leng_count{$leng}\t$i\t$l50\t$leng_sum\t".($total_leng/2)."\t$total_leng\n";
			if($leng_sum >= ($total_leng/2)){
				return ($leng,$l50);
			}
		}
	}
}

