#!/usr/bin/perl 
use strict;
use Data::Dumper;
use Getopt::Long;

my ($freq_filter,$deepth_filter,$coverage_filter);
$freq_filter=30;
$deepth_filter=5;
$coverage_filter=1;
GetOptions(
	"f|freq=f" => \$freq_filter,
	"d|deep=i" => \$deepth_filter,
	"c|coverage=i" => \$coverage_filter,
);

# load deepth for every position
my %posi_deepth=();
open(IN1,"<$ARGV[1]")|| die "Cannot open $ARGV[1]: $!\n";
while(<IN1>){
	chomp;
	my @a=split("\t",$_);
	$posi_deepth{$a[0]}=$a[1];
}
close IN1;

# variant per read
my %chr_variant=();
open(IN,"<$ARGV[0]")|| die "Cannot open $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my @b=split("&",$a[2]);
	#print Dumper @b;
	foreach (@b){
		$chr_variant{$a[1]."_".$_}++;
	}
}
close IN;

#print Dumper %chr_variant;

# VCF format
# CHROM POS ID REF ALT QUAL FILTER INFO
# INFO: DP AF AC
my @output=();
foreach my $v (sort (keys %chr_variant)){
	my ($chr,$posi,$mut)=();
	if($v=~/(\S+)_(\d+)\@(.+)/){
		$chr=$1; $posi=$2; $mut=$3;
	}
	my @muts=split(";",$mut);

	my ($ref,$alt)=();
	#print Dumper @muts;
	foreach my $m (@muts){
		my @aa=split("x",$m);
		$ref.=$aa[0];
		$alt.=$aa[1];
	}

	#if(!$posi_deepth{$posi}){print "$chr_variant{$v}\t$posi_deepth{$posi}\n"; exit;}
	my $freq;
	if(!$posi_deepth{$posi}){
		$freq = 0;
	}else{
		$freq = sprintf("%.2f",$chr_variant{$v}/$posi_deepth{$posi}*100);
	}
	if($freq_filter && $freq < $freq_filter){next;}
	if($deepth_filter && $chr_variant{$v} < $deepth_filter){next;}
	if($coverage_filter && $posi_deepth{$posi} < $coverage_filter){next;}

	push(@output,"$chr\t$posi\t\.\t$ref\t$alt\t60\tPASS\tAF=$freq;DP=$chr_variant{$v};AC=$posi_deepth{$posi}\n");
}

# output result
print "#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\n";
print join("",@output);
