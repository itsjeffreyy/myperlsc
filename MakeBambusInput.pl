#!/usr/bin/perl -w 
#usage: MakeBambusInput.pl .lib prefix
#The libSize file have the format:
#lib1_name R1 R2 Insert_size_min Insert_size_max
#Writer: Jeffreyy Yu

use strict;
use Data::Dumper;

# count the number of library
my $num_lib="";
$num_lib=`wc -l $ARGV[0]`;
if($num_lib=~/(\d+)\s\S+/){$num_lib=$1;}

# record the library information include read1 read2 file name, and the insert size max. & min.
open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
my @lib=();
while(<IN>){
	push(@lib,[split(/\s+/,$_)]);
}
close IN;

# opne read1 and read2 file and create sequence and mates file for every library
my $prefix="";
if (defined $ARGV[1]){
	$prefix=$ARGV[1];
}else{
	$prefix="genome";
}

open(MateOUT,">$prefix.mates");
open(SeqOUT,">$prefix.fq");
foreach my $libdata (0..$num_lib-1){
	print MateOUT "library\t$lib[$libdata][0]\t$lib[$libdata][3]\t$lib[$libdata][4]\n";
	open(Read1IN,"<$lib[$libdata][1]")||die "open file $lib[$libdata][1]:$!\n";
	open(Read2IN,"<$lib[$libdata][2]")||die "open file $lib[$libdata][2]:$!\n";
	while(<Read1IN>){
		my $r1id=$_; chomp $r1id;
		if($r1id=~/^\@(\S+)1$/){
			print MateOUT "$1"."1\t";
			print SeqOUT "$r1id\n";
			my $r1seq=<Read1IN>;chomp $r1seq;
			print SeqOUT "$r1seq\n";
			<Read1IN>;
			print SeqOUT "+\n";
			my $r1qua=<Read1IN>;chomp $r1qua;
			print SeqOUT "$r1qua\n";
		}
		my $r2id=<Read2IN>; chomp $r2id;
		if($r2id=~/^\@(\S+)2$/){
			print MateOUT "$1"."2\t$lib[$libdata][0]\n";
			print SeqOUT "$r2id\n";
			my $r2seq=<Read2IN>;chomp $r2seq;
			print SeqOUT "$r2seq\n";
			<Read2IN>;
			print SeqOUT "+\n";
			my $r2qua=<Read2IN>;chomp $r2qua;
			print SeqOUT "$r2qua\n";
		}
		
	}	
	close Read1IN;
	close Read2IN;
}
close MateOUT;
close SeqOUT;
