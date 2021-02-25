#!/usr/bin/perl -w 
use strict;
use Data::Dumper;
use Getopt::Long;

if($ARGV[-1] eq '-h' || $ARGV[-1] eq '--help'){
	print <<EOF;

Usage:
	Guppy_barcoder_statistic.pl path/to/guppy_barcoder/output_dir
Option:
	-h|--help: Show this message.


EOF
	exit;
}

# check path
my $barcoder_path=$ARGV[-1];
if(! -e $barcoder_path){
	print"ERR: directory not exist!\n"; exit;
}

# get barcode directory list
#opendir DIR,"$barcoder_path" || die "Cannot open $barcoder_path: $!\n";
#my @barcode_dir=grep{$_=~/^barcode/} readdir DIR;
#closedir DIR;
my @list=`ls $barcoder_path`; chomp @list;
my @barcode_dir = grep {$_=~/^barcode/} @list;

# check unclassified folder
if(-e "$barcoder_path/unclassified"){
	push(@barcode_dir,'unclassified');
}
#print Dumper @barcode_dir;

# calculate the total base and read number for every barcode
my %barcode_readnum=();
my %barcode_basenum=();
my ($total_readnum,$total_basenum)=(0,0);

foreach my $dir_n (@barcode_dir){
	opendir (DIR,"$barcoder_path/$dir_n") || die "Cannot open $barcoder_path/$dir_n: $!\n";
	my @fq_fs=grep {$_=~/\.fastq$|\.fq$/} readdir DIR;
	closedir DIR;

	foreach my $fq (@fq_fs){
		my($readnum,$basenum)=&SingleFq("$barcoder_path/$dir_n/$fq");
		$barcode_readnum{$dir_n}+=$readnum;
		$barcode_basenum{$dir_n}+=$basenum;
	}
	$total_readnum+=$barcode_readnum{$dir_n};
	$total_basenum+=$barcode_basenum{$dir_n};
}

# calcuate the percentage of every barcode
print "barcode\tRead number\tTotal base(bp)\n";
foreach my $barcode (@barcode_dir){
	my $readnum_per=sprintf("%2.2f",$barcode_readnum{$barcode}/$total_readnum*100);
	my $basenum_per=sprintf("%2.2f",$barcode_basenum{$barcode}/$total_basenum*100);
	print "$barcode:\t".&commify($barcode_readnum{$barcode})." ($readnum_per\%):\t".&commify($barcode_basenum{$barcode})." ($basenum_per\%)\n";
}
print "Total:\t".&commify($total_readnum).":\t".&commify($total_basenum)."\n";

############################################################
sub SingleFq(){

	my ($readnum,$basenum)=(0,0);
	my $fq_f=shift(@_);
	open(IN,"<$fq_f")|| die "ERR: Cannot open $fq_f: $!\n";
	while(<IN>){
		my $title=$_; chomp $title;
		my $seq=<IN>; chomp $seq;
		my $l3=<IN>; chomp $l3;
		my $qua=<IN>; chomp $qua;

		# check format
		if($title!~/^\@/ || $l3!~/^\+/ || length($seq) != length($qua)){
			print "ERR: $fq_f NOT fastq format!\n";
			exit;
		}
		$readnum++;
		$basenum+=length($seq);
	}
	close IN;
	return($readnum,$basenum);
}

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
