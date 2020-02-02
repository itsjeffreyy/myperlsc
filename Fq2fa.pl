#!/usr/bin/perl -w
# usage: Fq2fa.pl sequence.fq prefix
# writer: Jeffreyy Yu
use strict;
use Data::Dumper;
my $prefix="";

if(defined $ARGV[1]){
	$prefix=$ARGV[1];
}else{
	if($ARGV[0]=~/(\S+)\.["fastq","fq"]/){
		$prefix=$1;
	}
}

open(FaOUT,">$prefix\.fa");
open(FqIN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<FqIN>){
	if ($_=~/^\@(.+)/){
		chomp $1;
		my $id=$1;
		print FaOUT "\>$id\n";
	}
	my $seq=<FqIN>; chomp $seq;
	print FaOUT "$seq\n";
	<FqIN>;<FqIN>;
}
close FqIN;
close FaOUT;
