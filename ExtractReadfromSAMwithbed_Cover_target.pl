#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
# Note:
# ExtractReadfromSAMwithbed.pl target.bed ref_read.sam read.fastq (prefix range)

my $range=100;
my $prefix="out";
if($ARGV[3]){
	$prefix=$ARGV[3];
}
if($ARGV[4]){
	$range=$ARGV[4];
}

# load bed 
# format:
# chr	start	end	name
my %target_region=();
my @target=();
open(IN,"<$ARGV[0]") || die "Cannot open $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	$target_region{$a[3]}="$a[0]\t$a[1]\t$a[2]";
	push(@target,$a[3]);
}
close IN;

# load sam
# format
#  1. QNAME
#  2. FLAG
#  3. RNAME
#  4. POS
#  5. MAPQ
#  6. CIGAR
#  7. RNEXT
#  8. PNEXT
#  9. TLEN
# 10. SEQ
# 11. QUAL
my %target_readid=();
open(IN,"<$ARGV[1]") || die "Cannot open $ARGV[1]: $!\n";
while(<IN>){
	chomp;
	if($_=~/^@/){next;}
	my @a=split("\t",$_);
	if($a[1] eq '4'){next;}
	foreach my $target (keys %target_region){
		my ($ref,$refs,$refe)=split("\t",$target_region{$target});
		if($a[2] ne $ref){next;}
		#print "$a[2]\t$ref\n";
		my $qs=$a[3];
		my $cigar=$a[5];
		my ($qe,$insert)=&ParseCIGAR($qs,$cigar);

		#if($qe <= $refs || $refe <= $qs){next;}
		#$target_readid{$target}{$a[0]}=1;
		#my $q_leng=$qe-$qs+1;
		if($qs <= $refs+$range && $refe-$range <= $qe){
			#print "$a[0]\t". (118364471-$qs) ."\t$qs\t$qe\t". ($qe-118368363) ."\t$q_leng\n";
			$target_readid{$target}{$a[0]}=1;
		}

	}
}
close IN;
#foreach my $a (keys %target_readid){
#	foreach $b (keys %{$target_readid{$a}}){
#		print "$a\t$b\n";
#	}
#}

foreach my $t (@target){
	if(-e "$prefix\_$t\_covered.fastq"){
		`rm -f $prefix\_$t\_covered.fastq`;
	}
}

# extract read fastq
# load fastq
open(IN,"<$ARGV[2]") || die "Cannot open $ARGV[2]: $!\n";
while(<IN>){
	my ($id)=$_=~/^\@(\S+)/; chomp $id;
	my $seq=<IN>; chomp $seq;
	my $l3=<IN>; chomp $l3;
	my $qua=<IN>; chomp $qua;
	foreach my $t (keys %target_readid){
		if($target_readid{$t}{$id}){
			open(OUT,">>$prefix\_$t\_covered.fastq")|| die "Cannot write $prefix\_$t\_covered.fastq: $!\n";
			print OUT "\@$id\n$seq\n$l3\n$qua\n";
			close OUT;
		}
	}
}
close IN;

############################################################
sub ParseCIGAR(){
	my ($start,$cigar)=@_;
	my $add=0;
	my $insert=0;
	while($cigar){
		my $cutleng=0;
		if($cigar=~/^(\d+)(\w)/){
			my $num=$1; my $sig=$2;
			$cutleng=length($num)+length($sig);
			if($sig eq 'M'){
				$add+=$num;
			}elsif($sig eq 'D'){
				$add+=$num;

			}elsif($sig eq 'N'){
				$add+=$num;

			}elsif($sig eq 'I'){
				$insert+=$num;

			}
		}
		$cigar=substr($cigar,$cutleng);
	}
	my $end=$start+$add;
	return ($end,$insert);
}
