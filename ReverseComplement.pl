#! /usr/bin/perl -w
# usage :ReverseComplement.pl sequence > RCsequence
# writer:Jeffreyy Yu
use strict;
use Data::Dumper;

my $seq=$ARGV[0];
my $rcseq=RC($seq);
print "$rcseq\n";

#################################################################
sub RC{
	my $read=shift(@_);
#	$read = reverse uc($read);
	$read = reverse $read;
	$read=~tr/ATCGatcg/TAGCtagc/;
	return $read;
}
