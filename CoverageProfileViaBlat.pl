#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: CoverageProfileViaBlat.pl .psl

use strict;
use Data::Dumper;
use List::Util qw(max);
use List::MoreUtils qw(uniq);

#cc: contig coverage
my %cc=();
my %cl=();
my %blat=();
my $mmmax=10;
my $qafrmin=0.8;


open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";
$_=<IN>;

if($_=~/^psLayout/) {
    <IN>; <IN>; <IN>; <IN>;
} else {
    seek(IN,-length($_),1);
}


while(<IN>) {
    chomp $_; my @a=split("\t",$_);
# [match, mismatch, rep. match, N's, Q gap count, Q gap bases, T gap count, T gap bases, strand, Qname, Qsize, Qstart, Qend, Tname, Tsize, Tstart, Tend, block count, blockSizes, qStarts, tStarts]
# # [0    , 1       , 2         , 3  , 4          , 5          , 6          , 7          , 8     , 9    , 10   , 11    , 12  , 13   , 14   , 15    , 16  , 17         , 18        , 19     , 20    ]
#
    my ($m,$mm,$qgb,$tgb,$qid,$qsl,$qas,$qae,$tid,$tsl,$bs,$ts)=@a[0,1,5,7,9,10,11,12,13,14,18,20];

    if(($mm+$qgb+$tgb)<=$m && $mm<=$mmmax && ($qae-$qas)/$qsl>=$qafrmin) {
        $qas++;
	
	push(@{$blat{$tid}},$_);
	
	my @alignsize=split(',',$bs);
	my @alignstart=split(',',$ts);
	while(@alignsize){
		my $length=shift(@alignsize);
		my $start=shift(@alignstart)+1;
		my $end=$start+$length-1;
		for(my $i=$start;$i<=$end;$i++){
			@{$cc{$tid}}[$i]++;
		}
	}
    }
}
close IN;

my $coveragefile="";
my $blatfile="";
if($ARGV[0]=~/(\S+)\.psl/){
	$coveragefile="$1\.cp";
	$blatfile="$1\.cpbr";
}

open(CPOUT,">$coveragefile");
open(CPBROUT,">$blatfile");
foreach my $id (keys %cc){
	print CPOUT "$id\n";
	print CPBROUT "$id\n";

	foreach(1.."$#{$cc{$id}}"){
		if(defined ${$cc{$id}}[$_]){
			print CPOUT $_;print CPOUT "\t${$cc{$id}}[$_]\n";#${$cc{$id}}[$_]\n";
		}else{
			print CPOUT $_;print CPOUT "\t0\n";
		}
	}
	print CPOUT "\n";

	for(0..$#{$blat{$id}}){
		print CPBROUT "${$blat{$id}}[$_]\n";
	}
	print CPBROUT "\n";
}
close CPOUT;
close CPBROUT;
