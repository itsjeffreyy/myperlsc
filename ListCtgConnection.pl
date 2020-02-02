#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# Usage: ListCtgConnection.pl [-s|-soft] contiggraph.file > contigconnection.file
# 	 -soft|-s  the software name. newbler or velvet.

use strict;
use Data::Dumper;
use Getopt::Long;

my $soft="";
GetOptions(
	"soft|s=s" => \$soft,
	);


open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";

my %c3c=();
my %c5c=();
my %nclen=();
# $1 is a contig, $2 is the side of $1 contig (5' or 3').
# $3 is a contig, $4 is the side if $3 contig (5' or 3').
# the $1 contig $2 side connect to $3 contig $4 side, and the $5 is the support of the this connect.
if($soft eq 'newbler'){
	while(<IN>){
		if($_!~/^\d/) {
			seek(IN,-length($_),1);
			last;
		}
		my @a=split("\t",$_); chomp $a[-1];
		$nclen{"$a[0]+"}=$a[2];
		$nclen{"$a[0]-"}=$a[2];
	}
	
	while(<IN>) {
		my $lc="";
		my $rc="";
		if($_=~/^C\s+(\d+)\s+(\d)'\s+(\d+)+\s+(\d)'\s+(\d+)/){
			$lc=($2 eq "3" ? "$1+": "$1-");
			$rc=($4 eq "5" ? "$3+": "$3-");
			push(@{$c3c{$lc}},$rc);
			push(@{$c5c{$rc}},$lc);
			my $tc=$lc;
			$lc=RC($rc);
			$rc=RC($tc);
			push(@{$c3c{$lc}},$rc);
			push(@{$c5c{$rc}},$lc);
		}
	}
	close IN;
}elsif($soft eq 'velvet'){
	while(<IN>){
		if($_=~/^ARC/) {
			seek(IN,-length($_),1);
			last;
		}elsif($_=~/^NODE\t(\d+)\t(\d+)/){
			$nclen{"$1+"}=$2;
			$nclen{"$1-"}=$2;
		}
	}

	while(<IN>) {
		my $lc ="";
		my $rc ="";
		if($_=~/^ARC/){
			my @a=split("\t",$_);chomp $a[-1];
			$lc = ($a[1] =~ /^-(\d+)/ ? "$1\-": "$a[1]\+");
			$rc = ($a[2] =~ /^-(\d+)/ ? "$1\-": "$a[2]\+");
			push(@{$c3c{$lc}},$rc);
			push(@{$c5c{$rc}},$lc);
			my $tc=$lc;
			$lc=RC($rc);
			$rc=RC($tc);
			push(@{$c3c{$lc}},$rc);
			push(@{$c5c{$rc}},$lc);
		}
	}
	close IN;
}else{
	print "Please enter the software name. [velvet or newbler]\n";
	die;
}

foreach my $c (keys %nclen) {
    if(!$c3c{$c}) { @{$c3c{$c}}=(); }
    if(!$c5c{$c}) { @{$c5c{$c}}=(); }
}
# cc: connect contig
# fivec: 5' contigs
# threec: 3' contigs
# fives: 5' contig support
# threes: 3' contigsupport
# fivel: 5' contig length
# threel: 3' contig length

my @ac = sort (keys %nclen);
foreach my $c(@ac){
	if(@{$c5c{$c}} || @{$c3c{$c}}){
		print join(',',@{$c5c{$c}})." : $c : ".join(',',@{$c3c{$c}})."\n";
	}
}

##################################################################################################################################

sub RC {
    my $cs=shift(@_);
    $cs=~tr/+-/-+/;
    return $cs;
}

sub Uniq{
    my %seen=();
    return grep (!$seen{$_}++,@_);
}
