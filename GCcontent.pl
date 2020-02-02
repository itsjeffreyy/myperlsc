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
		$cs{$id}.=$_;
	}
}
close IN;

# cgc :contigs GC count
# gcc : GC content
# gcp : GC content percentage
my %cgc=();
my $totalgcc=0;
my $totalgcp=0;
my $totalleng=0;

#my @scid=sort {$a<=>$b}(keys %cs);
my @scid=sort (keys %cs);
foreach my $c (@scid){	
	$totalleng+=length($cs{$c});
	my $gcc=GC($cs{$c});
	$totalgcc+=$gcc;
	my $gcp=($gcc/length($cs{$c}))*100;
	print "$c\t";
	printf ("%.1f\n",$gcp);
}
$totalgcp=$totalgcc/$totalleng*100;
print "total GC\t";
printf ("%.1f\n",$totalgcp);

# print time
my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
print "\n",scalar localtime,"\n";
####################################################################################################

sub GC{
	#s  : sequence
	#tl : total length
	#nc : nucleotide count
	my $s=uc(shift(@_));
	my @s=split("",$s);
	my %nc=();
	map($nc{$_}++,@s);
	if(!$nc{G}){$nc{G}=0;}
	if(!$nc{C}){$nc{C}=0;}
#	return ($nc{G}+$nc{C})/length($s);
	return ($nc{G}+$nc{C});
}
