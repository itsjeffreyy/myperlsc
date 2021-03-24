#!/usr/bin/perl -w
# writer: Jeffreyy, Chunhui Yu
use strict;
use Data::Dumper;
use Getopt::Long;

# variables
my $min_leng=0;
my $max_leng=0;
my $fq="";
my $out_n="";
my $help;

# get options
GetOptions(
	"max|max_length=s" => \$max_leng,
	"min|min_length=s" => \$min_leng,
	"fq|fastq=s" => \$fq,
	"o|outname=s" => \$out_n,
	"help|h" => \$help,
);

# help activate
if($help){
	&Help();
}

# make output fastq filename
my $fn=`basename $fq`; chomp $fn;
my ($basename)=$fn=~/(.+)\.(?:fastq|fq)/;
my $outn="";
if($out_n){
	$outn=$out_n;
}else{
	$outn=$basename."\_$min_leng\-$max_leng.fastq";
}
# number formatter
if($max_leng=~/\D+/){
	$max_leng=&Number_formatter($max_leng);
}
if($min_leng=~/\D+/){
	$min_leng=&Number_formatter($min_leng);
}

# check max and min
if($max_leng < $min_leng){
	print "ERR: Wrong with max length and min length!\n";
	print "Max: $max_leng\nMin: $min_leng\n";
	&Help;
}

# check fastq file
if(! -e $fq){
	print "ERR: Fastq $fq not exsit.\n";
	&Help;
}

# open fastq file
open(IN,"<$fq")|| die "open $fq: $!\n";

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
    "max|max_length": maxmum read length (k; M; G; T)
    "min|min_length": minum read length (k; M; G; T)
    "fq|fastq": imput fastq file
    "o|outname": output file name
    "help|h": show help message
		
EOF

exit;
}

sub Number_formatter(){
	my $num=shift @_;
	if($num=~/(\d+)(\w+)/){
		my ($p1,$p2)=($1,$2);
		# Check the character parts
		if( length($p2) > 1 ){
			print "ERR: Not a valid value!\n";
			&Help();
		}

		if($p2 =~/(?:k$|K$)/){
			my $numeric=$p1."000";
			return $numeric;
		}elsif($p2 =~/(?:m$|M$)/){
			my $numeric=$p1."000000";
			return $numeric;
		}elsif($p2 =~/(?:g$|G$)/){
			my $numeric=$p1."000000000";
			return $numeric;
		}elsif($p2 =~/(?:t$|T$)/){
			my $numeric=$p1."000000000000";
			return $numeric;
		}else{
			print "ERR: Not a valid value!\n";
			&Help();
		}
	}
}
