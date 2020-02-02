#! /usr/bin/perl -w
# usage :FastqRC.pl MPfastq > RCfastq
# writer:Jeffreyy Yu
use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	my $id=$_; chomp $id;
	my $seq=<IN>; chomp $seq;
	$seq = RC($seq);
	my $quaid=<IN>; chomp $quaid;
	my $qua=<IN>; chomp $qua;
	$qua= reverse $qua;

	print "$id\n$seq\n$quaid\n$qua\n";
}

#################################################################
sub RC{
	my $read=shift(@_);
	$read = reverse uc($read);
	$read=~tr/ATCG/TAGC/;
	return $read;
}
