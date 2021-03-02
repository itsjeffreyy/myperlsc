#!/usr/bin/perl -w
# writer: Jeffreyy, Chunhui Yu
use strict;
use Data::Dumper;
use Getopt::Long;

# variables
my $min_leng=0;
my $max_leng=0;
my $fq="";
my $help;

# get options
GetOptions(
	"max|max_length=i" => \$max_leng,
	"min|min_length=i" => \$min_leng,
	"fq|fastq=s" => \$fq,
	"help|h" => \$help,
);

# help activate
if($help){
	&Help();
}

# check fastq file
if(! -e $fq){
	print "ERR: Fastq $fq not exsit.\n";
	&Help;
}

# open fastq file
open(IN,"<$fq")|| die "open $fq: $!\n";

# make output fastq filename
my $fn=`basename $fq`; chomp $fn;
my ($basename)=$fn=~/(.+)\.(?:fastq|fq)/;
my $outn=$basename."\_$min_leng\-$max_leng.fastq";

# open output file
open(OUT,">$outn");
while(<IN>){
	chomp;
	my ($id,$seq,$l3,$qua)=();
	if($_=~/^@.+/){
		$id=$_;
	}else{
		print "ERR: Not Fastq format.\n";
		exit;
	}
	$seq=<IN>; chomp $seq;
	$l3=<IN>; chomp $l3;
	$qua=<IN>; chomp $qua;
	my $read_leng=length($seq);
	if($min_leng < $read_leng && $read_leng <= $max_leng){
		print OUT "$id\n$seq\n$l3\n$qua\n";
	}
}
close IN;
close OUT;

######################################################
sub Help{
print <<EOF;
Usage: 
   ExtractFqbyLength.pl -fq read.fq -min min_length -max max_length

Option:
    "max|max_length": maxmum read length
    "min|min_length": minum read length
    "fq|fastq": imput fastq file
    "help|h": show help message
		
EOF

exit;
}
