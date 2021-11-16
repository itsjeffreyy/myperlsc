#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $out_name="raw_read";
GetOptions(
	"o|out=s" => \$out_name,
);

$out_name.=".fastq";

# open a output fastq file
open(OUT,">$out_name")|| die "Cannot write to $out_name!\n";

# load multiple fastq or fastq.gz
my @fqfs=@ARGV;

foreach my $fqf (@fqfs){
	# check comprassion stat
	if($fqf=~/\.fastq$|\.fq$/){	

		# check the fastq format
		open(IN,"<$fqf")||die "open file $fqf:$!\n";
		my $l1=<IN>; chomp $l1; <IN>;
		my $l3=<IN>; chomp $l3; <IN>;
		close IN;
		if ($l1=~/^@/ && $l3=~/^\+/){
			my $fq_content=`cat $fqf`;
			print OUT "$fq_content";
		}else{
			print "ERR: $fqf is not fastq format.\n"; exit;
		}
	}elsif($fqf=~/\.fastq\.gz$|\.fq\.gz$/){
		my @fq_c=`zcat $fqf`; chomp @fq_c;
		my $l1 = $fq_c[0]; chomp $l1;
		my $l3 = $fq_c[2]; chomp $l3;
		if ($l1=~/^@/ && $l3=~/^\+/){
			print OUT join("\n",@fq_c)."\n";
		}else{
			print "ERR: $fqf is not fastq format.\n";
		}
	}
}
close OUT;
