#!/usr/bin/perl -w
#writer: Jeffreyy Yu
#usage: GCcontent.pl .fasta

use strict;
use Data::Dumper;

open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
# cs : contig sequence
my %cs=();
my $id ="";
while(<IN>){
	chomp $_;
#	if($_=~/^>contig(\d+)/){
	if($_=~/^>(\S+)/){
		$id =$1;
	}else{
		$cs{$id}.=uc($_);
	}
}
close IN;

# cnc :contigs nucleotide count
# nc : nucleotide content
my %cnc=();
my %nc=();

my $totalleng=0;

foreach my $c (sort (keys %cs)){	
	$totalleng+=length($cs{$c});
	
	my @s=split("",$cs{$c});
	map($cnc{$c}{$_}++,@s);
	map($nc{$_}++,@s);
	
	my $ap=sprintf("%.2f",($cnc{$c}{'A'}/length($cs{$c}))*100);
	my $cp=sprintf("%.2f",($cnc{$c}{'C'}/length($cs{$c}))*100);
	my $gp=sprintf("%.2f",($cnc{$c}{'G'}/length($cs{$c}))*100);
	my $tp=sprintf("%.2f",($cnc{$c}{'T'}/length($cs{$c}))*100);
	print "$c\tA:$cnc{$c}{'A'}\t$ap\%\tC:$cnc{$c}{'C'}\t$cp\%\tG:$cnc{$c}{'G'}\t$gp\%\tT:$cnc{$c}{'T'}\t$tp\%\n";
}

my $total_ap=sprintf("%.2f",($nc{'A'}/$totalleng)*100);
my $total_cp=sprintf("%.2f",($nc{'C'}/$totalleng)*100);
my $total_gp=sprintf("%.2f",($nc{'G'}/$totalleng)*100);
my $total_tp=sprintf("%.2f",($nc{'T'}/$totalleng)*100);
print "Total\tA:$nc{'A'}\t$total_ap\%\tC:$nc{'C'}\t$total_cp\%\tG:$nc{'G'}\t$total_gp\%\tT:$nc{'T'}\t$total_tp\%\n";

# print time
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
print "\n",scalar localtime,"\n";
####################################################################################################
