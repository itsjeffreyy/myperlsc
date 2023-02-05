#!/usr/bin/perl -w
# usage : FqTotalLength.pl seqence.fq
# writer: Jeffrey Yu
use strict;
use Data::Dumper;
use Getopt::Long;
my ($l_cut,$q_cut)=(0,0);
my @fq_f=();

GetOptions(
	"q|qual=i" => \$q_cut,
	"l|leng=i" => \$l_cut,
	"fq|fastq=s{,}" => \@fq_f,
);

foreach(@fq_f){
	&SingleFqFilter($_);
}

############################################################
sub SingleFqFilter(){
	my $fq=shift(@_);
	my $rid="";

	my $fn_prefix="";
	if($fq=~/(\S+)\.fastq$/ || $fq=~/(\S+)\.fq$/ ||  $fq=~/(\S+)\.fastq.gz$/ ||  $fq=~/(\S+)\.fq.gz$/ ){	
		$fn_prefix=$1;
	}

	if($fq=~/\.fastq$|\.fq$/){	
		open(IN,"<$fq")||die "Cannot open file $fq:$!\n";
		my $out_f=$fn_prefix."\_l$l_cut\_q$q_cut\.fastq";
		open(OUT,">$out_f")||die "Cannot write $out_f:$!\n";
		
		while(<IN>){
			if ($_=~/^@(\S+)/){
				chomp;
				my $rid=$1;
				my $l1=$_; chomp $l1;
			 	my $seq=<IN>; chomp $seq;
				my $l3=<IN>; chomp $l3;
				my $q_score=<IN>; chomp $q_score;

				my $r_leng=length($seq);
				my ($qscore_sum_r,$mean_q_r)=&qscore_sum($q_score);

				if($r_leng < $l_cut){
					next;
				}
				if($mean_q_r < $q_cut){
					next;
				}

				print OUT "$l1\n$seq\n$l3\n$q_score\n";
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
		my $out_f=$fn_prefix."\_l$l_cut\_q$q_cut\.fastq";
		open(OUT,">$out_f")||die "Cannot write $out_f:$!\n";

		while(@fq_c){
			my $c=shift(@fq_c);
			chomp $c;
			if ($c=~/^@(\S+)/){
				my $rid=$1;
				my $l1=$c; chomp $l1;
			 	my $seq=shift(@fq_c); chomp $seq;
				my $l3=shift(@fq_c); chomp $l3;
				my $q_score=shift(@fq_c); chomp $q_score;

				my $r_leng=length($seq);
				my ($qscore_sum_r,$mean_q_r)=&qscore_sum($q_score);

				if($r_leng < $l_cut){
					next;
				}
				if($mean_q_r < $q_cut){
					next;
				}

				print OUT "$l1\n$seq\n$l3\n$q_score\n";
			}else{
				print "ERR: $fq is not fastq.\n";
				close IN;
				return (0,0);
			}
		
		}
		close OUT;
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
