#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my %title_seq=();
&LoadFa();

# load vcf
my %variants_posi=();
my $title="";
my $tv=0; # total variant
open(IN,"<$ARGV[0]") || die "Cannot open vcf $ARGV[0]: $!\n";
while(<IN>){
	if($_=~/^#/){
		$title.=$_;
		next;
	}
	chomp;
	$tv++;
	my @a=split("\t",$_);
	$variants_posi{$_}=$a[1];
}
close IN;

# sort the variants by position
my @variants_sorted=();
foreach my $v( sort {$variants_posi{$a} <=> $variants_posi{$b}} (keys %variants_posi)){
	my @v=split("\t",$v);
	push(@variants_sorted,\@v);
}

#print Dumper @variants_sorted; next;

# check the position is continuously then combine or output directly
print "$title";

if($tv==1){
	my ($chr,$posi,$id,$ref,$alt)=($variants_sorted[$tv-1][0],$variants_sorted[$tv-1][1],$variants_sorted[$tv-1][2],$variants_sorted[$tv-1][3],$variants_sorted[$tv-1][4]);
	my $fr="";
	if($ref eq '-' || $alt eq '-'){
		$fr=substr($title_seq{$chr},$posi-2,1);
		$posi-=1;
		$ref = ($ref eq '-' ? $fr : $fr.$ref);
		$alt = ($alt eq '-' ? $fr : $fr.$alt);
	}
	print "$chr\t$posi\t$id\t$ref\t$alt\t".join("\t",@{$variants_sorted[$tv-1]}[5..7])."\n";exit;
}

for (my $i=0; $i < $tv-1; $i++){
	if($variants_sorted[$i][0] eq $variants_sorted[$i+1][0] && $variants_sorted[$i][1]+1 == $variants_sorted[$i+1][1]){


		my ($chr,$posi,$id,$ref,$alt)=($variants_sorted[$i][0],$variants_sorted[$i][1],$variants_sorted[$i][2],$variants_sorted[$i][3],$variants_sorted[$i][4]);
		my($af,$dp,$ac)=();
		if($variants_sorted[$i][7]=~/AF=(\S+);DP=(\d+);AC=(\d+)/){
			$af=$1;$dp=$2;$ac=$3;
		}

		$ref.=$variants_sorted[$i+1][3];
		$alt.=$variants_sorted[$i+1][4];
		if($variants_sorted[$i+1][7]=~/AF=(\S+);DP=(\d+);AC=(\d+)/){
			$af=($af < $1 ? $af : $1);
			$dp=($dp < $2 ? $dp : $2);
			$ac=($ac < $3 ? $ac : $3);
		}

		for (my $j=$i+1; $j<$tv-1; $j++){
			if($variants_sorted[$j][0] eq $variants_sorted[$j+1][0] && $variants_sorted[$j][1]+1 == $variants_sorted[$j+1][1]){
				$ref.=$variants_sorted[$j+1][3];
				$alt.=$variants_sorted[$j+1][4];
				if($variants_sorted[$j+1][7]=~/AF=(\S+);DP=(\d+);AC=(\d+)/){
					$af=($af < $1 ? $af : $1);
					$dp=($dp < $2 ? $dp : $2);
					$ac=($ac < $3 ? $ac : $3);
				}
				$i=$j;
			}
		}

		my $ref_first = substr($ref,0,1);
		my $alt_first = substr($alt,0,1);
		my $fr="";
		if($ref_first eq '-' || $alt_first eq '-'){
			$fr=substr($title_seq{$chr},$posi-2,1);
			$posi-=1;
		}
		$ref = ($ref_first eq '-' ? $fr : $fr.$ref);
		$alt = ($alt_first eq '-' ? $fr : $fr.$alt);
		
		print "$chr\t$posi\t$id\t$ref\t$alt\t60\tPASS\tAF=$af;DP=$dp;AC=$ac\n";
	}else{
		my ($chr,$posi,$id,$ref,$alt)=($variants_sorted[$i+1][0],$variants_sorted[$i+1][1],$variants_sorted[$i+1][2],$variants_sorted[$i+1][3],$variants_sorted[$i+1][4]);
		my($af,$dp,$ac)=();
		if($variants_sorted[$i+1][7]=~/AF=(\S+);DP=(\d+);AC=(\d+)/){
			$af=$1;$dp=$2;$ac=$3;
		}
		my $ref_first = substr($ref,0,1);
		my $alt_first = substr($alt,0,1);
		my $fr="";
		if($ref_first eq '-' || $alt_first eq '-'){
			$fr=substr($title_seq{$chr},$posi-2,1);
			$posi-=1;
		}

		$ref = ($ref_first eq '-' ? $ref : $fr.$ref);
		$alt = ($alt_first eq '-' ? $alt : $fr.$alt);
		print "$chr\t$posi\t$id\t$ref\t$alt\t60\tPASS\tAF=$af;DP=$dp;AC=$ac\n";
	
	}
}

############################################################

sub LoadFa(){
# load the reference fasta
	open(IN,"<$ARGV[1]")|| die "Cannot open $ARGV[1] fasta file: $!\n";
	my $title;
	while(<IN>){
		chomp;
		if($_=~/^>(\S+)/){
			$title=$1;
		}else{
			$title_seq{$title}.=$_;
		}
	}
	close IN;
}
