#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

#INPUT_DIR="[YOUR_INPUT_FOLDER]"        # e.g. /home/user1/input (absolute path needed)
#OUTPUT_DIR="[YOUR_OUTPUT_FOLDER]"      # e.g. /home/user1/output (absolute path needed)
#THREADS="[MAXIMUM_THREADS]"            # e.g. 8
#MODEL_NAME="[YOUR_MODEL_NAME]"         # e.g. r941_prom_hac_g360+g422



my $input_dir  ="./";         # e.g. /home/user1/input (absolute path needed)
my $output_dir ="./clair3_output";         # e.g. /home/user1/output (absolute path needed)
my $threads    ="2";         # e.g. 8
my $model_name ="r941_prom_hac_g360+g422";         # e.g. r941_prom_hac_g360+g422
my $bam="";
my $sam="";
my $ref="";
my $fq="";
my $out_prefix="ref_fq";
my $help;

GetOptions(
	"input_dir|in=s" =>\$input_dir ,
	"output_dir|out=s" =>\$output_dir ,
	"thread|t=i" => \$threads,
	"model|m=s" => \$model_name,
	"bam=s" => \$bam,
	"sam=s" => \$sam,
	"ref=s" => \$ref,
	"fastq|fq=s" => \$fq,
	"prefix|p=s" => \$out_prefix,
	"help|h" => \$help,
);


if($help){
	&Help;
}

unless($bam || $sam){
	if(!$ref || !$fq){
		print "ERR: No $bam, $ref or $fq!\n"; 
		&Help;
	}
}

#absolute the path
$input_dir=`readlink -f $input_dir`; chomp $input_dir;
$output_dir=`readlink -f $output_dir`; chomp $output_dir;


# docker 
#my $docker_cmd="docker run -it   -v $input_dir:$input_dir   -v $output_dir:$output_dir hkubal/clair3:latest  ";
#my $docker_cmd="docker run  --rm  -v $input_dir:$input_dir   -v $output_dir:$output_dir minimap2_clair3:20231121  ";
my $docker_cmd="docker run  --rm  -v $input_dir:$input_dir    itsjeffreyy/minimap2_clair3:20231121  ";

# minimap2 alignment
my $mm2_cmd="minimap2 -t $threads -ax map-ont $input_dir/$ref $input_dir/$fq -o $input_dir/$out_prefix.sam";
my $samtools_cmd1="samtools sort $input_dir/$out_prefix.sam -o $input_dir/$out_prefix\_sort.bam";
my $samtools_cmd2="samtools index $input_dir/$out_prefix\_sort.bam";

if(!$bam && !$sam){
	print ("[CMD] $docker_cmd  $mm2_cmd\n");
	system("$docker_cmd  $mm2_cmd");
	print "\n";
	print ("[CMD] $docker_cmd  $samtools_cmd1\n");
	system("$docker_cmd  $samtools_cmd1");
	print "\n";
	print ("[CMD] $docker_cmd  $samtools_cmd2\n");
	system("$docker_cmd  $samtools_cmd2");
	print "\n\n";
	$bam="$out_prefix\_sort.bam";
}elsif(!$bam && -e $sam){
	my ($pre)=$sam=~/(\S+).sam/;
	$samtools_cmd1="samtools sort $sam -o $pre\_sort.bam";
	$samtools_cmd2="samtools index pre\_sort.bam";
	print ("[CMD] $docker_cmd  $samtools_cmd1\n");
	system("$docker_cmd  $samtools_cmd1");
	print "\n";
	print ("[CMD] $docker_cmd  $samtools_cmd2\n");
	system("$docker_cmd  $samtools_cmd2");
	print "\n\n";
	$bam="$pre\_sort.bam";
	
}


# Clair3 variant calling
my $clair3_cmd = "/opt/bin/run_clair3.sh --include_all_ctgs --bam_fn=$input_dir/$bam --ref_fn=$input_dir/$ref  --threads=$threads --platform=\"ont\"  --model_path=\"/opt/models/$model_name\" --output=$output_dir  --enable_phasing";
#my $clair3_cmd = "/opt/bin/run_clair3.sh --include_all_ctgs --bam_fn=$input_dir/$out_prefix\_sort.bam --ref_fn=$input_dir/$ref  --threads=$threads --platform=\"ont\"  --model_path=\"/opt/models/$model_name\" --output=$output_dir";

print ("[CMD] $docker_cmd  $clair3_cmd\n");
system("$docker_cmd  $clair3_cmd");


# filter the variant


######################################################################

sub Help(){

	print <<EOF;

	Usage:
	Run_clair3_variant.pl -ref ref.fa -fq read.fastq -m r941_prom_sup_g5014 -in ./ -out ./ -prefix input

	Options:     
	input_dir|in  : input directory. (default: ./) 
	output_dir|out: output directory (default: ./clair3_output) 
	thread|t      : caculate core number. (default: 2)
	model|m       : variant calling model. (default: r941_prom_hac_g360+g422, r1041_e82_400bps_sup_v420)
	bam           : alignment result after sort and index.
	sam           : alignment result.
	ref           : reference fasta file or minimap2 index file.
	fastq|fq      : ONT sequencing fastq file.
	prefix|p      : the prefix of output file. (default: ref_fq)
	help|h        : show the help message.

	
EOF
	exit;
}
