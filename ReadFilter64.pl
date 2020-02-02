#!/usr/bin/perl -w
# usage : ReadFilter.pl read1.fq read2.fq outputfilename
# writer: Jeffreyy Yu
use strict;
use Data::Dumper;
my $asciib=64;
my $quacut=30;
my $fn1="$ARGV[2]\_1\.fq";
my $fn2="$ARGV[2]\_2\.fq";
my $fn1n="$ARGV[2]\_1\_N\.fq";
my $fn2n="$ARGV[2]\_2\_N\.fq";
my $fn1lc="$ARGV[2]\_1\_lc\.fq";
my $fn2lc="$ARGV[2]\_2\_lc\.fq";
my $fn1quacut="$ARGV[2]\_1\_Q$quacut\.fq";
my $fn2quacut="$ARGV[2]\_2\_Q$quacut\.fq";

open(OUT1,">$fn1");
open(OUT2,">$fn2");
open(OUT1N,">$fn1n");
open(OUT2N,">$fn2n");
open(OUT1LC,">$fn1lc");
open(OUT2LC,">$fn2lc");
open(OUT1quacut,">$fn1quacut");
open(OUT2quacut,">$fn2quacut");

open(R1IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
open(R2IN,"<$ARGV[1]")||die"open file $ARGV[1]:$!\n";
while(<R1IN>){
	#load read1
	my $r1id=$_; chomp $r1id;
	if($r1id=~/^@(.+)/){$r1id=$1;}
	my $r1seq=<R1IN>; chomp $r1seq;
	<R1IN>;
	my $r1qua=<R1IN>; chomp $r1qua;

	#load read2
	my $r2id=<R2IN>; chomp $r2id;
	if($r2id=~/^@(.+)/){$r2id=$1;}
	my $r2seq=<R2IN>; chomp $r2seq;
	<R2IN>;
	my $r2qua=<R2IN>; chomp $r2qua;

	#discade if seq contian N's
	if(QuaCut($r1qua)>0 || QuaCut($r2qua)>0){
		print OUT1quacut "\@$r1id\n$r1seq\n\+\n$r1qua\n";
		print OUT2quacut "\@$r2id\n$r2seq\n\+\n$r2qua\n";

	}elsif($r1seq=~/N/ || $r2seq=~/N/){
		print OUT1N "\@$r1id\n$r1seq\n\+\n$r1qua\n";
		print OUT2N "\@$r2id\n$r2seq\n\+\n$r2qua\n";

	}elsif(LowComplexity($r1seq)==1 || LowComplexity($r2seq)==1){
		print OUT1LC "\@$r1id\n$r1seq\n\+\n$r1qua\n";
		print OUT2LC "\@$r2id\n$r2seq\n\+\n$r2qua\n";

	}else{
		print OUT1 "\@$r1id\n$r1seq\n\+\n$r1qua\n";
		print OUT2 "\@$r2id\n$r2seq\n\+\n$r2qua\n";
	}
}

close OUT1;
close OUT2;
close OUT1N;
close OUT2N;
close OUT1LC;
close OUT2LC;
close OUT1quacut;
close OUT2quacut;
close R1IN;
close R2IN;
#######################################################################
sub LowComplexity{
        my @seq=split("",shift(@_));
        my $totalseq=scalar @seq;
        my %bn=();
        foreach(@seq){
                $bn{$_}++;
        }
        my @count = sort {$bn{$b}<=>$bn{$a}} keys %bn;
        my $q=$bn{$count[0]}/$totalseq >= 0.95 ? 1 : 0 ;
        return $q;
}


sub QuaCut{
	my @qua=map (ord($_)-$asciib,split("",shift(@_)));
	foreach(@qua){
		my $q = 0;
		if($_ < $quacut){
			$q += 1; 
			return $q;
			last;
		}
	}
}
