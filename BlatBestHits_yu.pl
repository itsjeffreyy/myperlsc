#!/usr/bin/perl -w
# usage  : BlatBestHits.pl psl
# note   : Given the blat results of two sets of sequences, this finds the 
#        : best non-overlapping aligned regions on the query and target
#        : sequences in a heuristic manner. That is, if there are more than 
#        : one aligned region on a sequence, the longest alignment is first 
#        : selected. All other alignments overlapping the longest alignment 
#        : are then excluded. We iterate this procedure for the remaining 
#        : aligned regions. The final output are sets of non-overlapping 
#        : aligned regions on all the query and target sequences. In the 
#        : implementation, we actually allow a small overlap between two 
#        : aligned regions, but the overlap should not exceed a fraction of 
#        : the either region.
# author : Tsunglin Liu (2011.08.03)

use strict;
use List::Util qw(max);
use List::MoreUtils qw(uniq);


# set arguments and parameters
# olmax   : overlap maximum
# olfrmax : overlap fraction maximum
# mmmax   : mismatch maximum

my $olmax=400;
my $olfrmax=0.2;
my $mmratio=0.05;
my $qafrmin=0.20;


# load blat alignments
# first skip header if there is any

open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";
$_=<IN>;
if($_=~/^psLayout/) {
    <IN>; <IN>; <IN>; <IN>;
} else {
    seek(IN,-length($_),1);
}


# obtain non-overlapping best aligned regions for query contigs
# m      : match
# mm     : mismatch
# qs     : query sequence
# qsl    : query sequence length
# qsc    : query sequence coverage
# qgb    : query gap bases
# qas    : query alignment start
# gae    : query alignment end
# ts     : target sequence
# tsl    : target sequence length
# tas    : target alignment start
# tae    : target alignment end
# qar    : query aligned regions, i.e., ([s1,e1],[s2,e2],...)
# ara    : aligned region alignments, i.e., (alignment1, alignment2, ...)
# qnobr  : query non-overlapping best regions
# qnobrs : query non-overlapping best region size
#        : similar notation for target (variable names start with a t)

print "query contig\n\n";

my %tsa=();
while(<IN>) {
    my @a=split("\t",$_); chomp $a[-1];
    my ($m,$mm,$qgb,$tgb,$qs,$qsl,$qas,$qae,$ts,$tsl,$tas,$tae)=@a[0,1,5,7,9,10,11,12,13,14,15,16];

    my @qar=();
    my %ara=();

    # keep only the alignments whose total number of mis-match and gap bases is smaller than the number of matches
    if(($mm+$qgb+$tgb)<=$m && $mm/$qsl<=$mmratio && ($qsl < $tsl ? ($qae-$qas)/$qsl>=$qafrmin : ($tae-$tas)/$tsl>=$qafrmin)) {
	$qas++;
	push(@qar,"$qas~$qae");
	push(@{$ara{"$qas~$qae"}},$_);
	push(@{$tsa{$ts}},$_);
    }

    # load all the alignments involving the same query contig
    while(<IN>) {
	my @a=split("\t",$_); chomp $a[-1];
	
	if($a[9] eq $qs) {
	    ($m,$mm,$qgb,$tgb,$qs,$qsl,$qas,$qae,$ts,$tsl,$tas,$tae)=@a[0,1,5,7,9,10,11,12,13,14,15,16];
	    	    
	    # keep only the alignment whose total number of mis-match and gap bases is smaller than the number of matches
	    if(($mm+$qgb+$tgb)<=$m && $mm/$qsl<=$mmratio && ($qsl < $tsl ? ($qae-$qas)/$qsl>=$qafrmin : ($tae-$tas)/$tsl>=$qafrmin)) {
		$qas++;
		push(@qar,"$qas~$qae");
		push(@{$ara{"$qas~$qae"}},$_);
		push(@{$tsa{$ts}},$_);
	    }
	} else {
	    seek(IN,-length($_),1);
	    last;
	}
    }

    # obtain and output non-overlapping best regions
    if(@qar) {
	my @qnobr=NonOverlappingBestRegions(@qar);
	my $qnobrs=RegionSize(@qnobr);
	my $qsc=sprintf("%.1f",100*$qnobrs/$qsl);
	print "$qs\t$qsl\t$qnobrs\t$qsc\%\t@qar => @qnobr\n";

	foreach my $r (@qnobr) {
	    print join("",@{$ara{$r}});
	}
	print "\n";
    }
}
close IN;


# obtain non-overlapping best aligned regions for target contigs

print "target contig\n\n";

foreach my $ts (keys %tsa) {

    # keep only the the alignments whose total number of mis-matches and gaps is smaller than the number of matches
    my @tar=();
    my %ara=();
    my $tsl=0;
    foreach my $e (@{$tsa{$ts}}) {
	my @a=split("\t",$e); chomp $a[-1];
	my ($ts,$tas,$tae)=@a[13,15,16];
	$tsl=$a[14];
	$tas++;
	push(@tar,"$tas~$tae");
	push(@{$ara{"$tas~$tae"}},$e);
    }

    # obtain and output non-overlapping best ranges
    if(@tar) {
	my @tnobr=NonOverlappingBestRegions(@tar);
	my $tnobrs=RegionSize(@tnobr);
	my $tsc=sprintf("%.1f",100*$tnobrs/$tsl);
	print "$ts\t$tsl\t$tnobrs\t$tsc\%\t@tar => @tnobr\n";

	foreach my $r (@tnobr) {
	    print join("",@{$ara{$r}});
	}
	print "\n";
    }
}
close IN;



#######################################################


sub OverlapQ {
    my @r=sort{$a->[0]<=>$b->[0]}@_;
    my $q=0;
    
    my $ol=($r[0]->[1]-$r[1]->[0]+1);
    my $olfr1=$ol/($r[0]->[1]-$r[0]->[0]+1);
    my $olfr2=$ol/($r[1]->[1]-$r[1]->[0]+1);
    my $olfr=max($olfr1,$olfr2);
    if($ol>$olmax || $olfr>$olfrmax) {
	$q=1;
    }

    return $q;
}


sub NonOverlappingBestRegions {
    my @r=map([split("~",$_)],uniq(@_));

    # obtain region size and sort region by size
    my %rs=();
    map($rs{$_}=($_->[1]-$_->[0]+1),@r);
    @r=sort{$rs{$b}<=>$rs{$a}}@r;
    
    # get non-overlapping best regions
    my @nobr=(shift(@r));
    while(@r) {
	@r=grep(OverlapQ($nobr[-1],$_)==0,@r);
	if(@r) {
	    push(@nobr,shift(@r));
	}
    }
    @nobr=sort{$a->[0]<=>$b->[0]}@nobr;
    @nobr=map("$_->[0]~$_->[1]",@nobr);
    
    return @nobr;
}


sub RegionSize {
    my @r=map([split("~",$_)],@_);
    @r=sort{$a->[0]<=>$b->[0]}@r;
    
    # combine overlapping regions
    for(my $i=1;$i<@r;$i++) {
	if($r[$i-1]->[1] >= $r[$i]->[0]) {
	    $r[$i-1]->[1] = max($r[$i]->[1],$r[$i-1]->[1]);
	    splice(@r,$i,1);
	}
    }

    # calculate total size of non-overlapping regions
    my $s=0;
    foreach (@r) {
	$s+=($_->[1]-$_->[0]+1);
    }

    return $s;
}
