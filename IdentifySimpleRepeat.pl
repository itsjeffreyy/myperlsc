#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# Usage: IdentifySimpleRepeat.pl 454ContigGraph.txt > 454.sr
use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";

my %connect=();
my %leng=();
while(<IN>){
	if ($_=~/(\d+)\s+contig\d+\s+(\d+)\s+/){
		$leng{$1}=$2;
	}
	# $1 is a contig, $2 is the side of $1 contig (5' or 3').
	# $3 is a contig, $4 is the side if $3 contig (5' or 3').
	# the $1 contig $2 side connect to $3 contig $4 side, and the $5 is the support of the this connect.
	if($_=~/^C\s+(\d+)\s+(\d)'\s+(\d+)+\s+(\d)'\s+(\d+)/){
		push(@{$connect{$1}{$2}},[$3,$4,$5]);
		push(@{$connect{$3}{$4}},[$1,$2,$5]);
	}
}
close IN;

# cc: connect contig
# fivec: 5' contigs
# threec: 3' contigs
# fives: 5' contig support
# threes: 3' contigsupport
# fivel: 5' contig length
# threel: 3' contig length

foreach my $c (keys %connect){
	my $cc="";
	my $cci="";
	my @fivec=();
	my @threec=();
	my @fives=();
	my @threes=();	
	my @fivel=();
	my @threel=();	

	if(defined @{ $connect{$c}{5} }){
		for ($cc=0;$cc<=$#{$connect{$c}{5}};$cc++){
	
			my $ccid=${$connect{$c}{5}}[$cc][0];
			my $ccside=${$connect{$c}{5}}[$cc][1];
			my $ccsupport=${$connect{$c}{5}}[$cc][2];			

			if($ccid eq $c){
				push(@fivec,"$ccid-$ccside");
				push(@fives,$ccsupport);
				push(@fivel,$leng{$ccid});
			

			}elsif($#{$connect{$ccid}{$ccside}} < 1 && ${$connect{$ccid}{$ccside}}[0][0] eq $c){
				push(@fivec,"$ccid-$ccside");
				push(@fives,$ccsupport);
				push(@fivel,$leng{$ccid});
			}
		}
	}

	if(defined @{ $connect{$c}{3} }){
		for ($cc=0;$cc<=$#{$connect{$c}{3}};$cc++){
	
			my $ccid=${$connect{$c}{3}}[$cc][0];
			my $ccside=${$connect{$c}{3}}[$cc][1];
			my $ccsupport=${$connect{$c}{3}}[$cc][2];			

			if($ccid eq $c){
				push(@threec,"$ccid-$ccside");
				push(@threes,$ccsupport);
				push(@threel,$leng{$ccid});
			
			
			}elsif($#{$connect{$ccid}{$ccside}} < 1 && ${$connect{$ccid}{$ccside}}[0][0] eq $c){
				push(@threec,"$ccid-$ccside");
				push(@threes,$ccsupport);
				push(@threel,$leng{$ccid});
			}
		}
	}

	if(@fivec && @threec){
		print join(',',@fivec)."| $c |".join(',',@threec)."\t".join(',',@fives)."||".join(',',@threes)."\t".join(',',@fivel)."| $leng{$c} |".join(',',@threel)."\n";
	}
}
