#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# date: 2015.03.17

use strict;
use Data::Dumper;
use Getopt::Long;

my $ctg="";
my $gtf="";

GetOptions(
	"ctg=s" => \$ctg,
	"gtf=s" => \$gtf,
);

if(!$ctg || !$gtf){
	&Help;
	exit;
}


# load the contig seq
my %ctgseq=(); 
my $id="";
open(IN,"<$ctg")|| die "open $ctg: $!\n";
while(<IN>){
	chomp;
	if($_=~/^>(.+)/){
		$id=$1;
	}else{
		$ctgseq{$id}.=$_;
	}
}
close IN;

# load the gtf file and cut the exon seq.
open (IN,"<$gtf")|| die "open $gtf: $!\n";
my $ogeneid=0;
my ($octgid,$oorien)="";
my $seq="";
my ($ctgid,$cate,$start,$end,$orien,$note)="";
while(<IN>){
	my @a=split("\t",$_); chomp $a[-1];
	($ctgid,$cate,$start,$end,$orien,$note)=@a[0,2,3,4,6,8];
	if ($cate ne "exon"){next;}
	
	my $leng=$end-$start+1;
	my ($geneid)=$note=~/gene_id \"(\S+)\"\; transcript_id/;
	

	if($ogeneid eq $geneid || $ogeneid eq "0"){
		$seq.=substr($ctgseq{$ctgid},$start-1,$leng);

	}elsif($ogeneid ne $geneid ){
		my $exonseq="";
		if($oorien eq "-"){
			$exonseq=RC($seq);

		}else{
			$exonseq=$seq;
		}
		
		my $seqleng=length ($exonseq);
		print ">$ogeneid\_$octgid$oorien\_$seqleng\_bp\n$exonseq\n";
		$seq=substr($ctgseq{$ctgid},$start-1,$leng);
	}
	
	$ogeneid=$geneid;
	$octgid=$ctgid;
	$oorien=$orien;
}
close IN;


my $exonseq="";
if($orien eq "-"){
	$exonseq=RC($seq);

}else{
	$exonseq=$seq;
}

my $seqleng=length ($exonseq);
print ">$ogeneid\_$octgid$oorien\_$seqleng\_bp\n$exonseq\n";


############################################################
sub Help{
print "Please enter the gtf and ctg options!\n";
print <<EOF

usage:
	Gtf2fa.pl -ctg ctg.fa -gtf gtf > output.fa
	-ctg: contig fasta file
	-gtf: gtf file

EOF
}

sub RC{
	my $seq=shift @_;
	$seq=~tr/ATCGatcg/TAGCtagc/;
	$seq= reverse $seq;
	return $seq;
}
