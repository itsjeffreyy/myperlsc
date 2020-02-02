#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2015.03.11
#

use strict;
use Data::Dumper;
use Getopt::Long;

my @in=();

GetOptions(
	"in=s{,}" => \@in,
);

# load all of the genemark output
my $i=1;
foreach my $in (@in){
	open(IN,"<$in")|| die "open $in: $!\n";
	my $title="";
	while(<IN>){
		chomp;
		if($_=~/^# nucleotide sequence of predicted genes/){last;}	
		if($_=~/^FASTA defline\: (>dna.fa_\d+)/){
			$title=$1;
		}
	}

	while(<IN>){
		if($_=~/^\n/){next;}
		if($_=~/^# end nucleotide sequence/){last;}

		chomp;

		# print title
		if($_=~/^>(\S+)/){
			if($i==1){
				print "$title\_$1\n";
			}else{
				print "\n$title\_$1\n";
			}
			$i++;
		
		# print sequence 
		}else{
			print "$_";
		}
	}
	close IN;
}

