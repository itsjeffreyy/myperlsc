#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my $bigest=0;
my %id_t=();
my %id_seq=();
my %id_seqleng=();
my %id_qua=();
open(IN,"<$ARGV[0]")|| die "ERR\n";
while(<IN>){
	my $l1=$_; chomp $l1;
	my $l2=<IN>; chomp $l2;
	my $l3=<IN>; chomp $l3;
	my $l4=<IN>; chomp $l4;
	my $leng=length($l2);
	my ($t)=$l1=~/^@(\S+)/;
	$id_t{$t}=$l1;
	$id_seq{$t}=$l2;
	$id_seqleng{$t}=$leng;
	$id_qua{$t}=$l4;
}
close IN;


my $i =0;
foreach my $t (sort {$id_seqleng{$b} <=> $id_seqleng{$a}} (keys %id_seqleng)){
	if($i >= 5){last;}
	#print "$id_seqleng{$t}\n";
	if($ARGV[1] ==1){
		#print "$id_t{$t}\n";
		print "$id_t{$t}\_$id_seqleng{$t}\n$id_seq{$t}\n\+\n$id_qua{$t}\n";
	}
	$i++;
}
