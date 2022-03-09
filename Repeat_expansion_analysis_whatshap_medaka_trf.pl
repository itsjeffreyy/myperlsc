#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;
# medaka+trf
# Requirment:
# LRA, Medaka (medaka_consensus, medaka_variant), samtools, ExtractReadfromSAMwithbed_Cover_target.pl, SeperateFq4Medaka_consensus.pl, Fq2fa.pl, Seperate_HP_fq_from_Medaka_variant_sam.pl, SeperateFq4Medaka_consensus.pl

my $ref_f="/home/hgt/Projects/RD_cas9/code/chr8.fa";
my $bed_f="/home/hgt/Projects/RD_cas9/code/SAMD12_region.bed";
my $sam_f="";
my $fq_f="";
my $prefix="Repeat_expansion_out"; #crRNAmix-Amber_cover_SAMD12
my $range=100;
my $thread=4;
my $help;

GetOptions(
	"ref=s" => \$ref_f,
	"bed=s" => \$bed_f,
	"sam=s" => \$sam_f,
	"fq=s" => \$fq_f,
	"p|prefix=s" => \$prefix,
	"r|range=i" => \$range,
	"t|thread=i" => \$thread,
	"help|h" => \$help,
);


if(! $sam_f || ! -e $sam_f){
	my $ref_name=`basename $ref_f`; chomp $ref_name;
	my ($ref_head)=$ref_name=~/(.+).fa*/;
	my $fq_name=`basename $fq_f`; chomp $fq_name;
	my $fq_head="";
	if($fq_name=~/(.+)\.fq/ || $fq_name=~/(.+)\.fastq/){
		$fq_head=$1;
	}

	my $ref_index1=$ref_f.".gli";
	my $ref_index2=$ref_f.".mmi";
	if(! -e $ref_index1 || ! -e $ref_index2){
		`lra index $ref_f`;
		#`lra index $ref_f`;
	}

	my $sam_f="$prefix\_$ref_head\_$fq_head\.sam";
	
	print "\n[MSG] No SAM file $sam_f. Do LRA aign $fq_f to $ref_f.\n";
	print "[CMD] lra align -ONT -t $thread $ref_f $fq_f -p s > $sam_f\n\n";
	`lra align -ONT -t $thread $ref_f $fq_f -p s > $sam_f`;
	#print "[CMD] minimap2 -ax map-ont -t $thread $ref_f $fq_f -o $sam_f\n\n";
	#`minimap2 -ax map-ont -t $thread $ref_f $fq_f -o $sam_f`;
}

# extract the read almost cover target region
print "\n[MSG] Extract the reads almost cover target region\n\n";
`ExtractReadfromSAMwithbed_Cover_target.pl $bed_f $sam_f $fq_f $prefix $range`;

# get target region fastq name
my $target_fq_fn="";
open(IN,"<$bed_f")|| die "ERR: Cannot open $bed_f: $!\n";
my $a=<IN>; chomp $a;
my @a=split("\t",$a);
$target_fq_fn="$prefix\_$a[3]\_covered.fastq";
close IN;

print "\n[MSG] Convert $target_fq_fn FASTQ format to FASTA format\n\n";
`Fq2fa.pl $target_fq_fn`;

# phasing the read into 2 phases
print "\n[MSG] Do covered reads phasing\n\n";
if(! -e "$prefix\_$a[3]\_phase"){`mkdir -p $prefix\_$a[3]\_phase`;}
#cd phase
#minimap2 -ax map-ont -t 4 ~/Projects/RD_cas9/code/chr8.fa ../crRNAmix-Amber_cover_SAMD12_SAMD12_aligned.fastq -o chr8_cover_SAMD12.sam
#samtools view -h chr8_cover_SAMD12.sam -o chr8_cover_SAMD12.bam
#samtools sort chr8_cover_SAMD12.bam -o chr8_cer_SAMD12_sorted.bam
#samtools index chr8_cover_SAMD12_sorted.bam
#samtools phase -b Amber_SAMD12 --output-fmt SAM --reference ~/Projects/RD_cas9/code/chr8.fa chr8_cover_SAMD12_sorted.bam

`minimap2 -ax map-ont -t $thread $ref_f $target_fq_fn -o $prefix\_$a[3]\_phase/ref_cover_$a[3].sam`;
#`samtools view -Shb phase/chr8_cover_SAMD12.sam -o phase/chr8_cover_SAMD12.bam`;
#`samtools sort phase/chr8_cover_SAMD12.bam -o phase/chr8_cover_SAMD12_sorted.bam`;
`samtools sort $prefix\_$a[3]\_phase/ref_cover_$a[3].sam --output-fmt BAM -o $prefix\_$a[3]\_phase/ref_cover_$a[3]_sorted.bam`;
`samtools index $prefix\_$a[3]\_phase/ref_cover_$a[3]_sorted.bam`;
`medaka_variant -i $prefix\_$a[3]\_phase/ref_cover_$a[3]_sorted.bam -f $ref_f -o $prefix\_$a[3]\_medaka_variant -t $thread`;
`Seperate_HP_fq_from_Medaka_variant_sam.pl -p $prefix\_$a[3] $prefix\_$a[3]\_medaka_variant/round_0_hap_mixed_phased.bam $target_fq_fn`;

# get the reads of two phases
my $phase1_fq="$prefix\_$a[3]_phase1.fastq";
my $phase2_fq="$prefix\_$a[3]_phase2.fastq";

my $p1_wc=`wc -l $phase1_fq`; my @a1=split(" ",$p1_wc); my $phase1_fq_reads_number=$a1[0]/4;
my $p2_wc=`wc -l $phase2_fq`; my @a2=split(" ",$p2_wc); my $phase2_fq_reads_number=$a2[0]/4;
if($phase1_fq_reads_number==0 || $phase2_fq_reads_number==0){
	print "MSG: Abort the workflow!\n";
	print "     The phase 1 read number=$phase1_fq_reads_number\n";
	print "     The phase 2 read number=$phase2_fq_reads_number\n";
	print "Can not do the repeat finding\n";
	exit;
}

#./ExtractReadFqFromSam.pl Amber_SAMD12.0.sam ../crRNAmix-Amber_cover_SAMD12_SAMD12_aligned.fastq > Amber_SAMD12.0.fastq
#./ExtractReadFqFromSam.pl Amber_SAMD12.1.sam ../crRNAmix-Amber_cover_SAMD12_SAMD12_aligned.fastq > Amber_SAMD12.1.fastq
#./ExtractReadFaFromSam4medaka_consensus.pl Amber_SAMD12.0.sam ../crRNAmix-Amber_cover_SAMD12_SAMD12_aligned.fastq
#./ExtractReadFaFromSam4medaka_consensus.pl Amber_SAMD12.1.sam ../crRNAmix-Amber_cover_SAMD12_SAMD12_aligned.fastq
#`ExtractReadFaFromSam4medaka_consensus.pl $phase1_sam $target_fq_fn`;
#`ExtractReadFaFromSam4medaka_consensus.pl $phase2_sam $target_fq_fn`;
`SeperateFq4Medaka_consensus.pl $phase1_fq`;
`SeperateFq4Medaka_consensus.pl $phase2_fq`;

print "\n[MSG] Do Medaka consensus\n\n";
# consensus for two phases
my $phase1_center_fa="$prefix\_$a[3]_phase1_center.fasta";
my $phase1_polish_fa="$prefix\_$a[3]_phase1_polish.fasta";
my $phase2_center_fa="$prefix\_$a[3]_phase2_center.fasta";
my $phase2_polish_fa="$prefix\_$a[3]_phase2_polish.fasta";
#medaka_consensus -f -i Amber_SAMD12.0_polish.fasta -d Amber_SAMD12.0_center.fasta -t 10 -o medaka-phase1
#medaka_consensus -f -i Amber_SAMD12.1_polish.fasta -d Amber_SAMD12.1_center.fasta -t 10 -o medaka-phase2
`medaka_consensus -f -i $phase1_polish_fa -d $phase1_center_fa -t $thread -o $prefix\_$a[3]\_phase/medaka-phase1`;
`medaka_consensus -f -i $phase2_polish_fa -d $phase2_center_fa -t $thread -o $prefix\_$a[3]\_phase/medaka-phase2`;

print "MSG: Do Tandem Repeat Finder\n";
# trf for two phase consensus sequeces
`mkdir -p $prefix\_$a[3]\_phase/trf-phase1 $prefix\_$a[3]\_phase/trf-phase2`;
`cd $prefix\_$a[3]\_phase/trf-phase1; /home/hgt/Programs/trf/trf409.linux64 ../medaka-phase1/consensus.fasta 2 7 7 80 10 50 2000; cd ../..`;
`cd $prefix\_$a[3]\_phase/trf-phase2; /home/hgt/Programs/trf/trf409.linux64 ../medaka-phase2/consensus.fasta 2 7 7 80 10 50 2000; cd ../..`;

############################################################

sub Help{
	print <<EOF;
	ref      : The reference fasta file (default: "/home/hgt/Projects/RD_cas9/code/chr8.fa")
	bed      : The bed file of target gene region (default: "/home/hgt/Projects/RD_cas9/code/SAMD12_region.bed")
	fq       : The read after quality filter (Required)
	sam      : The alignment result of aligned fq to ref.
	p|prefix : The output file prefix (default: Repeat_expansion_out)
	r|range  : The allowed distance from the both ends of taget region (default: 100)
	t|thread : The execution thread (default: 4)
	h|help   : Show this message
EOF
exit;
}
