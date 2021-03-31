#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $leng_between_primer_min="";
my $leng_between_primer_max="";
my $scan_leng=50;
my $mismatch_cut=5;
my $help;

GetOptions(
	"maxlength|maxl=i" => \$leng_between_primer_max,
	"minlength|minl=i" => \$leng_between_primer_min,
	"scan|s=i" => \$scan_leng,
	"mismatch|mm=i" => \$mismatch_cut,
	"help|h" => \$help,
);

if($help){&Help;}

my $primer_f=$ARGV[0];
my $fq_f=$ARGV[1];

if(!$ARGV[0] || !$ARGV[1]){&Help;}

my ($F1,$F2)=();
# load primer
open(IN,"<$primer_f")|| die "Can not open $primer_f: $!\n";
($F1,$F2)=<IN>; chomp ($F1,$F2);
close IN;

my %IUPAC = ();
$F2 =~ tr/ATCG/TAGC/;
$F2 = reverse($F2);
$IUPAC{"N"} = "A,C,G,T";
$IUPAC{"H"} = "A,G,T";
$IUPAC{"V"} = "T,C,G";
$IUPAC{"W"} = "A,T";

# load Fastq
open(IN,"<$fq_f") || die "Cannot open $fq_f: $!\n";
while(<IN>){
	my $l1=$_;   chomp $l1;
	my $l2=<IN>; chomp $l2;
	my $l3=<IN>; chomp $l3;
	my $l4=<IN>; chomp $l4;
	my ($F1_i,$F2_i)=();

	my $rev_seq=$l2;
	$rev_seq=~ tr/ATCG/TAGC/;
	$rev_seq=reverse($rev_seq);

	my ($id)=$l1=~/^@(\S+)/;

	my $seq_leng=length($l2);
	my $primers_leng=length($F1)+length($F2);
	if($seq_leng <= $primers_leng ){next;}
	if($seq_leng <= $scan_leng*2){next;}
	#print "$l1\n";
	#print "p1: $F1\np2: $F2\n";
	#print "seq \t$l2\n";
	($F1_i,$F2_i)=&Scan_primer($l2);
	if(! $F1_i || ! $F2_i){
		($F1_i,$F2_i)=&Scan_primer($rev_seq);
	}

	#exit;
	if(! $F1_i ||! $F2_i){next;}
	my $amplicon_leng=($F2_i+length($F2)-1)-($F1_i-length($F1)+1)+1;
	if($amplicon_leng < $primers_leng){next;}
	if($leng_between_primer_min || $leng_between_primer_max){
		if($leng_between_primer_min && $leng_between_primer_max){
			if($leng_between_primer_min <= $amplicon_leng && $amplicon_leng <= $leng_between_primer_max){print "\@$id\n$l2\n$l3\n$l4\n";}
		}elsif($leng_between_primer_min && !$leng_between_primer_max){
			if($leng_between_primer_min <= $amplicon_leng){print "\@$id\n$l2\n$l3\n$l4\n";}
		}elsif( !$leng_between_primer_min && $leng_between_primer_max){
			if($amplicon_leng <= $leng_between_primer_max){print "\@$id\n$l2\n$l3\n$l4\n";}
		}
	}else{
		print "\@$id\n$l2\n$l3\n$l4\n";
	}
}
close IN;



############################################################

sub Scan_primer{
	my $seq=shift @_;

	# scan f1
	my $F1_i="";
	my %F1_posi_mm=();
	# segement
	for (my $i=0; $i<=$scan_leng-length($F1);$i++){
		my @F1nul=split("",$F1);
		my $ss_pos=$i+1;
		my @ss=split("",substr($seq,$ss_pos-1,length($F1)));
		my $mm=0; # mm: mistmatch
		# position
		for (my $j=0;$j < length($F1);$j++){
			# find mismatch
			if($F1nul[$j] ne $ss[$j]){
				$mm++;
			}
		}
		#print "p1\tF\t: $F1\n";
		#print "ss\t$ss_pos\t: ".join("",@ss)."\n";
		#print "mm: $mm\n";
		#check mismatch
		if($mm <= $mismatch_cut){
			#print "p1\tF\t: $F1\n";
			#print "ss\t$ss_pos\t: ".join("",@ss)."\n";
			#print "mm: $mm\n";
			$F1_i=$ss_pos+length($F1)-1;
			$F1_posi_mm{$F1_i}=$mm;
		}
	}

	# scan f2
	my $F2_i="";
	my %F2_posi_mm=();
	#segement
	for (my $i=0; $i<=$scan_leng-length($F2);$i++){
		my @F2nul=split("",$F2);
		my $se_pos=length($seq)-length($F2)-$i+1;
		my @se=split("",substr($seq,$se_pos-1,length($F2)));
		my $mm=0; # mm: mistmatch
		# position
		for (my $j=0;$j < length($F2);$j++){
			# find mismatch
			if($F2nul[$j] ne $se[$j]){
				$mm++;
			}
		}
		# check mismatch 
		#print "p2\tR\t: $F2\n";
		#print "se\t$se_pos\t: ".join("",@se)."\n";
		#print "mm: $mm\n";
		if($mm <= $mismatch_cut){
			#print "p2\tR\t: $F2\n";
			#print "se\t$se_pos\t: ".join("",@se)."\n";
			#print "mm: $mm\n";
			$F2_i=$se_pos;
			$F2_posi_mm{$F2_i}=$mm;
		}
	}

	# find the best one for each primer
	my ($F1_least_mm,$F2_least_mm)=();
	# F1
	foreach my $posi (sort {$F1_posi_mm{$a} <=> $F1_posi_mm{$b}} (keys %F1_posi_mm)){
		$F1_least_mm=$F1_posi_mm{$posi};last;
	}
	my @F1_posi=();
	foreach my $p (keys %F1_posi_mm){
		if($F1_posi_mm{$p} == $F1_least_mm){
			push(@F1_posi,$p);
		}
	}
	if(@F1_posi){@F1_posi = sort {$a <=> $b} (@F1_posi);}

	# F2
	foreach my $posi (sort {$F2_posi_mm{$a} <=> $F2_posi_mm{$b}} (keys %F2_posi_mm)){
		$F2_least_mm=$F2_posi_mm{$posi};last
	}
	my @F2_posi=();
	foreach my $p (keys %F2_posi_mm){
		if($F2_posi_mm{$p} == $F2_least_mm){
			push(@F2_posi,$p);
		}
	}
	if(@F2_posi){@F2_posi = sort {$a <=> $b} (@F2_posi);}

	my ($best_F1_i,$best_F2_i);
	if(@F1_posi && @F2_posi){
		($best_F1_i,$best_F2_i)=($F1_posi[0],$F2_posi[0]);
	}

	# return
	#print ">>1$best_F1_i \t $best_F2_i\n";
	if($best_F1_i && $best_F2_i){
		return ($best_F1_i,$best_F2_i);
	}
}

sub Help{
	print <<EOF;
	Usage: 
		Scan_Primers_in_Fq.pl.pl [options] primer_seq file.fastq

	Options:
		maxlength|maxl: the maximum length of fragment between two primers (default: deactivate)
		minlength|minl: the minimum length of fragment between two primers (default: deactivate)
		scan|s        : scan length from two ends of a read (default: 50)
		mismatch|mm   : alow mismatch (default: 5)
		help|h        : Show this help messsage

	Note: Primer_seq file format as below

	ACTCACATAGCTTTGCATCC
	CCACTGGAGTTCCTTAAAGT
	
	user's primer sequence as below
	Forward: ACTCACATAGCTTTGCATCC
	Reverse: CCACTGGAGTTCCTTAAAGT

EOF
exit;
}
