#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $out_name="raw_read";
my @fqfs=();
my $help="";
GetOptions(
	"o|out=s" => \$out_name,
	"fq|fastq=s{,}" => \@fqfs,
	"h|help" => \$help,
);

$out_name.=".fastq";

if($help){&help;}
if(scalar @fqfs ==0){
	print "[ERR] No input fastq files.\n";
	&help;
}
# open a output fastq file
open(OUT,">$out_name")|| die "Cannot write to $out_name!\n";

# load multiple fastq or fastq.gz

foreach my $fqf (@fqfs){
	if(! -e $fqf){
		print "[ERR] $fqf not exist.\n";
		&help;
	}

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

############################################################
sub help{
print <<EOF;
Usage: 
	Merge_ONT_barcode_fq.pl -fq fastq_pass/*.fastq fastq_fail/*.fastq... -o prefix_name
Options:
	-o | -out    : output file prefix name (default: raw_read. The output name: raw_read.fastq)
	-fq | -fastq : input multiple fastq files
	-h | -help   : show this help message

EOF
exit;
}
