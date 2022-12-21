#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

#my $char= $ARGV[0]; chomp $char;
#my $score = &Convert_char2ord($char)-33;
#my $perc = &phred_Q2P($score);
#print "$char\t $score\t$perc\n";
#exit 1;
#######
my $fq_f="";
my $fqs; # filter quality score
GetOptions(
	"fq|fastq=s" => \$fq_f,
	"fqs|filter_quality_score=i" => \$fqs,
);

if(! -e $fq_f){
	print "ERR: No fastq file.\n";
	exit 1;
}

open(FQIN,"<$fq_f") || die "open $fq_f: $!\n";
while(<FQIN>){
	chomp;
	my $line1=$_;
	my $seq=<FQIN>; chomp $seq;
	my $line3=<FQIN>; chomp $line3;
	my $qual=<FQIN>; chomp $qual;

	# check fq format
	if($line1 !~ /^\@/ || $line3 !~ /^\+/){
		print "ERR: $fq_f not fastq format.\n";
		exit 1;
	}

	# get read id 
	my ($id) = $line1 =~ /^@(\S+)/;
	# get read length
	my $seq_leng = length($seq);
	# get average quality score
	my @quals=split( //,$qual);
	my $total_prob=0;
	# get probability summary for one read
	foreach my $char (@quals){
		my $score = &Convert_char2ord($char)-33;
		#print "$score||".&phred_Q2P($score)."||".sprintf('%f',&phred_Q2P($score))."\n";
		$total_prob += sprintf('%.6f',&phred_Q2P($score));
	}
	my $average_prob=$total_prob/$seq_leng;
	my $average_score=&phred_P2Q($average_prob);
	
	if($fqs){
		#if($average_score < $fqs){next;}
		if($average_score >= $fqs){next;}
		print "$id\t".sprintf('%.3f',$average_prob*100)."%\t".sprintf('%.6f',$average_score)."\n";
		#print "$id\t".sprintf('%.3f',$average_prob*100)."%\t".$average_score."\n";
	}else{
		print "$id\t".sprintf('%.3f',$average_prob*100)."%\t".sprintf('%.6f',$average_score)."\n";
	}
}
close FQIN;

############################################################

sub Convert_char2ord(){
	my $char = shift @_;
	my $num = ord($char);
	return $num;
}

sub Convert_ord2char(){
	my $num = shift @_;
	my $char = chr($num);
	return $char;
}

# Convert quality score to probability via phred quality score
sub phred_Q2P(){
	my $qual=shift @_;
	my $prob=10**(-1*$qual/10);
	return $prob;
}

# Convert probability to quality score via phred quality score
sub phred_P2Q(){
	my $prob=shift @_;
	my $qual=-1*10*log($prob);
	return $qual;
}
