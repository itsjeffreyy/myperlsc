#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# load the output from variant_call_step2, transfer the format to vcf.
open(IN,"<$ARGV[0]")||die "Cannot open .variant2 file $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my $frac="";
	if(length($a[2])==1 && length($a[3])==1){
		$frac=sprintf("%.2f",$a[5]/$a[4]*100);
	}else{
		$frac=sprintf("%.2f",$a[4]/($a[4]+$a[5])*100);
	}
	print "$a[0]\t$a[1]\t\.\t$a[2]\t$a[3]\t60\tPASS\t.\tDP:AD:VAF\t$a[4]:$a[5]:$frac\n";
}
close(IN);
