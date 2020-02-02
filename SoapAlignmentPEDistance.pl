#!/usr/bin/perl -w
# usage : SoapAlignmentPEDistance.pl aligned > ped
# note  : Given PE alignments by soap, this gives the distribution of  
#       : PE distances.
# date  : 2012.01.23

use strict;


# load paired end distances (including read length) and output the distribution
# pei : paired-end index
# pedc: paired-end distance count

my %pedc=();

open(IN,"<$ARGV[0]") || die "cannot open file $ARGV[0]!\n";

while(<IN>) {
    my @a1=split("\t",$_); chomp $a1[-1];
    my ($pei,$pe12)=$a1[0]=~/^(\d+)\/([12])/;

    # if a read starts as a pe1
    if(1==$pe12) {
	$_=<IN>; if(!$_) { last; }

	# if the next read is the pe2
	if($_=~/^$pei\/2/) {
	    my @a2=split("\t",$_); chomp $a2[-1];

	    # if the pe2 is uniquely mapped
	    if($a2[3]==1) {

		# if soap11r, get paired-end distance count
		if($a1[7] eq $a2[7]) {
		    if($a1[6] ne $a2[6]) {
			my $ped = ($a1[6] eq "+") ? ($a2[8]+$a2[5]-$a1[8]) : ($a1[8]+$a1[5]-$a2[8]);
			$pedc{$ped}++;
		    }
		}

	    # if the pe2 is not uniquely mapped, skip the rest pe2 records
	    } else {
		for (2..$a2[3]) { <IN>; }
		next;
	    }
	    
	# if the next read is not the pe2, put it back and start over 
	} else {
	    seek(IN,-length($_),1);
	    next;
	}

    # if the read starts as a pe2, skip the rest pe2 records
    } else {
	for(2..$a1[3]) { <IN>; }
    }
}
close IN;


# output paired-end distance count

my @ped=sort{$a<=>$b}(keys %pedc);
foreach my $d (@ped) {
    print "$d\t$pedc{$d}\n";
}
