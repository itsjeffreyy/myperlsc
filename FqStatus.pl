#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
my $total_reads=0;
my %leng_count=();
foreach(@ARGV){
	my($reads,$leng)=&SingleFq($_);
	$total_leng+=$leng;
	$total_reads+=$reads;
}

my $mean_leng=&Mean_Leng($total_reads, $total_leng);
my ($n50,$l50)=&N50($total_leng);

$total_reads=&commify($total_reads);
$total_leng=&commify($total_leng);
$mean_leng=&commify($mean_leng);
$l50=&commify($l50);
$n50=&commify($n50);

print "Total reads: $total_reads\nTotal length(bp): $total_leng\n";
print "Mean length (bp): $mean_leng\n";
print "N50 (bp): $n50\nL50: $l50\n";


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
			$leng_count{length($seq)}+=1;
			<IN>;<IN>;
		}else{
			print "ERR: $fq is not fastq.\n";
			close IN;
			return (0,0);
		}
	}
	close IN;
	my $reads_show=&commify($reads);
	my $leng_show=&commify($leng);
	print "$fq: $reads_show reads,\t$leng_show bp\n";
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
sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
