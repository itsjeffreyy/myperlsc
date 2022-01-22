#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $Fastq = $ARGV[0];#QC fastq
my $ref = $ARGV[2]; 
my $output_name = $ARGV[1];#output_name
my $thread=8;
my $anno;

GetOptions(
	"fq|fastq=s" => \$Fastq,
	"prefix|pre=s" => \$output_name,
	"ref|r=s" => \$ref,
	"anno_filter" => \$anno,	
);


# ref: chr4
system("minimap2 -t $thread -ax map-ont $ref $Fastq \> $output_name.sam");
system("samtools sort $output_name.sam  --output-fmt BAM -o $output_name\_sort.bam");
system("samtools index $output_name\_sort.bam");
system("medaka_variant -i $output_name\_sort.bam -f $ref -s r941_min_high_g360 -m r941_min_high_g360 -t $thread -o $output_name-medaka");
system("medaka tools annotate $output_name-medaka/round_1.vcf $ref $output_name\_sort.bam $output_name-medaka/annotated.vcf");
if($anno ){
	system("perl /home/hgt/Projects/fjuProject/parse_medaka_annotatevcf_new.pl $output_name\-medaka/annotated.vcf 30 40 >$output_name-medaka/filtered.txt");
}
#system("perl /home/hgt/Projects/fjuProject/parse_medaka_annotatevcf.pl $output_name\-medaka/annotated.vcf 30 40 >$output_name-medaka/filtered.txt");
