#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: Z_score.pl

use strict;
use Data::Dumper;

# load file
open (IN,"<$ARGV[0]")|| die "open file $ARGV[0]:$!\n";
$_=<IN>;
print $_;

my %GeneExpression=();
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my $gene=shift @a;

	# descard total conditions nonexpression
	my $count=0;
	foreach my $exp (@a){
		if($exp==0){
			$count++;
		}
	}
	if($count==@a){next;}
	
	# others record
	push(@{$GeneExpression{$gene}},join("\t",@a));
}
close IN;



# calculate zscore
my $record="";
foreach my $gene (sort(keys %GeneExpression)){
	my $i=0;
	my $printgene="$gene";
	foreach my $exp (@{$GeneExpression{$gene}}){

		my $sum=0;
		my $count=0;
		my @a=split("\t",$exp);
		
		# calculate summary and mean
		for(my $i=0;$i<=$#a;$i++){
			$count++;
			$sum+=$a[$i];
		}
		my $mean=$sum/$count;
		
		# calculate standard deviation
		my $var=0;

		for(my $i=0;$i<=$#a;$i++){
			$var+=($a[$i]-$mean)**2;
		}
		my $sd=0;
		$sd=($var/$count)**0.5;
		
		# calculate Z score
		my @zvalue=();
		for(my $j=0;$j<=$#a;$j++){
			if($sd==0){
#				push(@zvalue,0);
				next;				
			}else{
				my $Zscore=sprintf("%.6f",($a[$j]-$mean)/$sd);
				push(@zvalue,$Zscore);
			}
		}
		
		if(@{$GeneExpression{$gene}}>1){
			$i++;
			$printgene="$gene\-$i";
		}
		# print result
		if($sd==0){next;}
		print "$printgene\t".join("\t",@zvalue)."\n";
	}
}
