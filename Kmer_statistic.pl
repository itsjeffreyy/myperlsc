#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $list=10;
my $kmer=5;
my $rc_option="";
my $help="";

GetOptions(
	"rc" => \$rc_option,
	"list|l=i" => \$list,
	"kmer|k=i" => \$kmer,
	"help|h" => \$help,
	#"fa=s" => \$fa,
);

if($help){&Help;}

if(! -e $ARGV[0]){
	print "ERR: Input $ARGV[0] not exist!\n\n";
	&Help;
}

# load sequence fasta file
my %id_seq=();
my $id="";
open(IN,"<$ARGV[0]")|| die "Cannnot open $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	if($_=~/^>(\S+)/){
		$id=$1;
	}else{
		$id_seq{$id}.=$_;
	}
}
close IN;

# scan kmer that kmer nucleotide
my %seq_kmer_num=();
foreach my $id (keys %id_seq){
	
	my $total_kmer=0;
	my $seq="";

	if($rc_option){
		$seq=$id_seq{$id};
	}else{
		$seq=&RC($id_seq{$id});
	}

	# collect kmer
	for (my $i=0;$i < ((length $seq)-$kmer-1);$i++){
		my $kmer=substr($seq,$i,$kmer);
		$seq_kmer_num{$kmer}++;
		$total_kmer++;
	}

	my $j=1;
	print ">$id\n";
	foreach my $m (sort {$seq_kmer_num{$b}<=>$seq_kmer_num{$a}} (keys %seq_kmer_num)){
		my $freq=sprintf("%.2f",$seq_kmer_num{$m}/$total_kmer*100);
		print "$m\t$seq_kmer_num{$m}\t$freq\%\n";
		if($j==$list){last;}
		$j++;
	}
}


############################################################
sub RC(){
	my $seq=shift @_;
	my $r_seq=reverse($seq);
	$r_seq=~tr/ATCGatcg/TAGCtagc/;
	return $r_seq;
}

sub Help(){
	print <<EOF;
Usage: 
	Kmer_statistic.pl [options] seq.fasta
Options:
	rc    : Reverse complete seqence
	list|l: list kmer number (default: 10)
	kmer|k: k number (defaulf: 5)
EOF
	exit;
}
