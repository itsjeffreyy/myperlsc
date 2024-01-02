#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;



#my $BASE="./";

my $in_dir ="";
my $out_dir="";
my $prefix="result";
my $ref;
my $bam;
my $thread=4;
my $sample_n="sample";

GetOptions(
	"in|in_dir=s"   => \$in_dir,
	"out|out_dir=s" => \$out_dir,
	"prefix|p=s" => \$prefix,
	"ref=s"   => \$ref,
	"bam=s"   => \$bam,
	"thread|t =i" => \$thread,
	"sample_name|sn=s" => \$sample_n,
);

# Set up input and output directory data
#INPUT_DIR ="$BASE/input/data"
#OUTPUT_DIR="$BASE/output"

my $INPUT_DIR =`readlink -f $in_dir`; chomp $INPUT_DIR;
my $OUTPUT_DIR=`readlink -f $out_dir`; chomp $OUTPUT_DIR;
$ref=`readlink -f $ref`; chomp $ref;
$bam=`readlink -f $bam`; chomp $bam;

## Create local directory structure
if(! -e $INPUT_DIR){`mkdir -p $INPUT_DIR`;}
if(! -e $OUTPUT_DIR){`mkdir -p $OUTPUT_DIR`;}


# Set up output variable
my $OUTPUT_VCF ="$prefix.vcf.gz";
my $OUTPUT_GVCF="$prefix.g.vcf.gz";
my $INTERMEDIATE_DIRECTORY="temp_dir";

`mkdir -p $OUTPUT_DIR/$INTERMEDIATE_DIRECTORY`;

my $cmd="docker run --rm  -v $INPUT_DIR:$INPUT_DIR -v $OUTPUT_DIR:$OUTPUT_DIR google/deepvariant:1.6.0  /opt/deepvariant/bin/run_deepvariant --model_type ONT_R104 --ref $ref --reads $bam --output_vcf $OUTPUT_DIR/$OUTPUT_VCF  --output_gvcf $OUTPUT_DIR/$OUTPUT_GVCF  --num_shards $thread --intermediate_results_dir $OUTPUT_DIR/$INTERMEDIATE_DIRECTORY --sample_name $sample_n";
print "[CMD] $cmd \n";
system("$cmd");
