#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
use strict;
use Data::Dumper;

my $total_leng=0;
my $total_reads=0;
my $total_q=0;
my %leng_count=();
foreach(@ARGV){
	my($reads,$leng,$q_sum)=&SingleFq($_);
	$total_leng+=$leng;
	$total_reads+=$reads;
	$total_q+=$q_sum;
}

my $mean_leng=&Mean_Leng($total_reads, $total_leng);
my ($n50,$l50)=&N50($total_leng);

my $total_mean_q=sprintf("%.2f",$total_q/$total_leng);
my $total_mean_q_show=&commify($total_mean_q);
$total_reads=&commify($total_reads);
$total_leng=&commify($total_leng);
$mean_leng=&commify($mean_leng);
$l50=&commify($l50);
$n50=&commify($n50);

print "Total reads: $total_reads\nTotal length(bp): $total_leng\n";
print "Mean length (bp): $mean_leng\n";
print "Mean quality score: $total_mean_q_show\n";
print "N50 (bp): $n50\nL50: $l50\n";


############################################################
sub SingleFq(){
	my $fq=shift(@_);
	my $leng=0;
	my $reads=0;
	my $qscore_sum=0;
	my $mean_q=0;
	my $rid="";

	if($fq=~/\.fastq$|\.fq$/){	
		open(IN,"<$fq")||die "Cannot open file $fq:$!\n";
		my $out_f=$fq.".stat";
		open(OUT,">$out_f")||die "Cannot write $out_f:$!\n";
		
		while(<IN>){
			if ($_=~/^@(\S+)/){
				chomp;
				my $rid=$1;
			 	my $seq=<IN>; chomp $seq;
				$reads+=1;
				my $r_leng=length($seq);
				$leng+=length($seq);
				$leng_count{length($seq)}+=1;
				<IN>;
				my $q_score=<IN>; chomp $q_score;
				my ($qscore_sum_r,$mean_q_r)=&qscore_sum($q_score);
				print OUT "\@$rid\t$r_leng\t$mean_q_r\n";
				$qscore_sum+=$qscore_sum_r;
			}else{
				print "ERR: $fq is not fastq.\n";
				close IN;
				return (0,0);
			}
		}
		close IN;
		close OUT;
	}elsif($fq=~/\.fastq\.gz$|\.fq\.gz$/){
		my @fq_c=`zcat $fq`; chomp @fq_c;
		my $out_f=$fq.".stat";
		open(OUT,">$out_f")||die "Cannot write $out_f:$!\n";

		while(@fq_c){
			my $c=shift(@fq_c);
			chomp $c;
			if ($c=~/^@(\S+)/){
				my $rid=$1;
			 	my $seq=shift(@fq_c); chomp $seq;
				$reads+=1;
				my $r_leng=length($seq);
				$leng+=length($seq);
				$leng_count{length($seq)}+=1;
				shift(@fq_c);
				my $q_score=shift(@fq_c); chomp $q_score;
				my ($qscore_sum_r,$mean_q_r)=&qscore_sum($q_score);
				print OUT "\@$rid\t$r_leng\t$mean_q_r\n";
				$qscore_sum+=$qscore_sum_r;
			}else{
				print "ERR: $fq is not fastq.\n";
				close IN;
				return (0,0);
			}
		
		}
		close OUT;
	}
	
	$mean_q=sprintf("%.2f",$qscore_sum/$leng);
	my $mean_q_show=&commify($mean_q);
	my $reads_show=&commify($reads);
	my $leng_show=&commify($leng);
	print "$fq: $reads_show reads,\t$leng_show bp, mean_quality: $mean_q_show\n";
	return($reads,$leng,$qscore_sum);
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

sub qscore_sum {
	my $qscore=shift(@_);

	my $q_sum=0;
	my $mean_q=0;
	my @q=split("",$qscore);
	my $q_leng=length($qscore);
	foreach my $s (@q){
		$q_sum+=ord($s)-33;
	}
	$mean_q=sprintf("%.2f",$q_sum/$q_leng);
	return($q_sum,$mean_q);
}
