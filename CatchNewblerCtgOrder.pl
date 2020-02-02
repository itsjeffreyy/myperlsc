#!/usr/bin/perl -w
# usage : .pl bbh

use strict;
use Getopt::Long;

my $process="contig";

GetOptions(
		"process|p=s" => \$process,
		);

my %acnc=();
open(IN,"<$ARGV[0]")||die;
while(<IN>){
	if($_=~/^target/){<IN>;last;}
}
while(<IN>){
	my $ac;
	$process=($_=~/^contig/?"contig" : "scaffold");
	if($process eq "contig"){
		($ac)=$_=~/^contig_(\d+)/;
	}elsif($process eq "scaffold"){
		($ac)=$_=~/^scaffold_(\d+)/;
	}
	while(<IN>) {
		if($_ eq "\n") { last; }
		my @a=split("\t",$_); chomp $a[-1];
		my $id;
		if($process eq "contig"){
			($id)=$a[9]=~/contig0+(\d+)/;
		}elsif($process eq "scaffold"){
			($id)=$a[9]=~/contig_(\d+)/;
		}
		push(@{$acnc{$ac}},"$id$a[8]");
	}

}
close IN;

#my %confirm=();
#open(IN2,"<$ARGV[1]")||die;
#while(<IN2>){
#	my @a=split("\t",$_);
#	chomp $a[-1];
#	$confirm{$a[0]}=$a[1];
#}

my @ac= sort {$a<=>$b} (keys %acnc);
foreach my $ac (@ac){
	if($process eq "contig"){
		print "contig_$ac\t".join(":",@{$acnc{$ac}})."\n";
#		print "$ac\t".join(":",@{$acnc{$ac}})."\t$confirm{$ac}\n";
	}elsif($process eq "scaffold"){
		print "scaffold_$ac\t".join(":",@{$acnc{$ac}})."\n";
	}
}
