#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my %id_seq=();
my %id_qua=();
my %id_leng=();
my $total_leng=0;
my $id="";
my $n_level="50";
my $fq="";
my $allow_print_fq="";
my $help="";

GetOptions(
	"n|n_level=i"  => \$n_level,
	"fq|fastq=s" => \$fq,
	"print|p" => \$allow_print_fq,
	"h|help" => \$help,
);

if($help){&Help;}

# load fastq
open(IN,"<$fq") || die "Open Fastq $fq: $!\n";
while(<IN>){
	chomp;
	if($_=~/^@(.+)/){
		$id=$1;
	}
	my $seq=<IN>; chomp $seq;
	$id_seq{$id}.=$seq;
	$id_leng{$id}+=length($seq);
	$total_leng+=length($seq);

	my $l3=<IN>; chomp $l3;
	my $qua=<IN>; chomp $qua;
	$id_qua{$id}.=$qua;

}
close IN;

my $out_n="";
if($fq=~/(.+)\.(?=fastq|fq)/){
	$out_n=$1;
}
$out_n.="_N$n_level\.fastq";


my $accu_leng=0;
my $n_level_leng=$total_leng*$n_level/100;
my $l_value=0;
my $new_total=0;
if($allow_print_fq){open(OUT,">$out_n")|| die "Can not write to $out_n\n";}

foreach my $id (sort {$id_leng{$b} <=> $id_leng{$a}} (keys %id_leng)){
	if($allow_print_fq){
		print OUT "\@$id\n$id_seq{$id}\n\+\n$id_qua{$id}\n";
	}
	$accu_leng+=$id_leng{$id};
	$l_value+=1;
	$new_total+=$id_leng{$id};
	if($accu_leng > $n_level_leng ){
		print "N$n_level: $id_leng{$id}\n";
		print "L$n_level: $l_value\n";
		print "Total: $total_leng\n";
		print "New Total: $new_total\n";
		last;
	}
}
if($allow_print_fq){close OUT;}

############################################################
sub Help(){
	print <<EOF;
Usage: Extract_ONT_fq_longest_2_N_level.pl -fq fq_file -n 50
Option:	
	"n|n_level"  => the level user wanted (defalt: 50)
	"fq|fastq" => input fastq file
	"print|p" => allow output fastq (default: not output fastq)
	"h|help" : Show help message
EOF
exit;
}
