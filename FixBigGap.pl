#!/usr/bin/perl -w
#writer: jeffreyy Yu
#usage : FixBigGap.pl bbh allpath_ctg.fa newbler_ctg.fa

use strict;
use Algorithm::NeedlemanWunsch;
use Data::Dumper;

# catch out the big gap allpath contig and newbler contig.
# load bbh file
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	if($_=~/target/){<IN>;last;}
}

my %nbiggap=();
while(<IN>){
	my ($ac)=$_=~/^contig_(\d+)/;
	$ac.="+";
	while(<IN>) {
		if($_ eq "\n") { last; }
		my @a=split("\t",$_); chomp $a[-1];
		my ($nc)=$a[9]=~/contig0+(\d+)/;
		$nc.=$a[8];
		my @len=split(",",$a[18]);

		# allpath contig information
		my @as=split(",",$a[20]);
		my @astart=map($_+1,@as);
		my @aend=();

		#newbler contig information
		my @ns=split(",",$a[19]);
		my @nstart=map($_+1,@ns);
		my @nend=();

		for (my $i=0;$i< @len;$i++){
			my $ae=$as[$i]+$len[$i];
			push(@aend,$ae);

			my $ne=$ns[$i]+$len[$i];
			push(@nend,$ne);
		}

		for (my $i=0;$i< @len;$i++){
			if($astart[$i+1] && $astart[$i+1]-$aend[$i]-1 > 5){
				my $ngapsize=$astart[$i+1]-$aend[$i]-1;
				push (@{$nbiggap{$ac}},[$nc,$aend[$i],$astart[$i+1],$aend[$i+1],$nend[$i],$nstart[$i+1],$nend[$i+1],$ngapsize]);
			}
		}
	}
}
close IN;

# load allpath contig sequence
open(IN,"<$ARGV[1]")||die"open file $ARGV[1]:$!\n";

my %allpathctg=();
my $acid="";;
while(<IN>){
	chomp $_;
	if($_=~/^>contig_(\d+)/){
		$acid=$1;
	}else{
		$allpathctg{"$acid+"}.=$_;
	}
}
close IN;

for my $aid (keys %allpathctg){
	my $cs=$allpathctg{$aid};
	$aid=~tr/+-/-+/;
	$allpathctg{$aid}=RC($cs);
}

# load newbler contig sequence
open(IN,"<$ARGV[2]")||die"open file $ARGV[2]:$!\n";

my %newblerctg=();
my $ncid="";
while(<IN>){
	chomp $_;
	if($_=~/^>contig0+(\d+)/){
		$ncid=$1;
	}else{
		$newblerctg{"$ncid+"}.=$_;
	}

}
close IN;

for my $nid (keys %newblerctg){
	my $cs=$newblerctg{$nid};
	$nid=~tr/+-/-+/;
	$newblerctg{$nid}=RC($cs);
}


# global alignment 
# Needleman–Wunsch algorithm

my $matcher = Algorithm::NeedlemanWunsch->new(\&score_sub);
my $score = $matcher->align(
		\@a,
		\@b,
		{   align     => \&on_align,
		shift_a => \&on_shift_a,
		shift_b => \&on_shift_b,
		select_align => \&on_select_align
		});


#############################################################################
sub RC{
	my $s=shift;
	$s=reverse $s;
	$s=~tr/ATCGatcg/TAGCtagc/;
	return $s;
}

sub score_sub {
	if (!@_) {
		return -2; # gap penalty
	}
	return ($_[0] eq $_[1]) ? 1 : -1;
}
