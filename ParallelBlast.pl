#!/usr/bin/perl -w
# date:
# writer: Jeffreyy Yu
# usage: ParallelBlast.pl [option] ref read
# note : parallel the blast alingment tool. The parameters some are same with blastall. the blast version is 2.25. So this script need install blast 2.25 first.

use strict;
use Data::Dumper;
use Getopt::Long;

my $cpu=2;
my $seqtype="prot";
my $seqpara="T";
my $m="8";
my $p="blastp";
my $e="10.0";

GetOptions(
		"cpu=i" => \$cpu,
		"seqtype|seq=s" => \$seqtype,
		"m=i" => \$m,
		"p=s" => \$p,
		"e=f" => \$e,
		);

if(!$ARGV[0] || !$ARGV[1]){print"error!!!\n"; &Help;}

if($seqtype ne "nucl" && $seqtype ne "prot"){
	print "\nThe sequence type must be \"nucl\" or \"prot\"!!\n\n";
	&Help;
}

if($p ne "blastn" && $p ne "blastp" && $p ne "blastx" && $p ne "tblastn" && $p ne "tblastx"){
	print "\nThe p option must be \"blastp\", \"blastn\", \"blastx\", \"tblastn\" or \"tblastx\" !!\n\n";
	&Help;
}

if($seqtype eq "nucl"){
	$seqpara="F";
}


my $ref=$ARGV[0];
my $refname=`basename $ref`; chomp $refname;
my $refdir=`dirname $ref`; chomp $refdir; $refdir.="\/";
my ($refbasename)=$refname=~/(.+)\./;

my $read=$ARGV[1];
my $readname=`basename $read`; chomp $readname;
my $readdir=`dirname $read`; chomp $readdir; $readdir.="\/";
my ($readbasename)=$readname=~/(.+)\./;


# split read file
# open the output file
my @ofh=();
for(my $i=1;$i<=$cpu;$i++){
	open($ofh[$i-1],">$readbasename\_$i.fa")|| die "output $readbasename\_$i.fa:$!\n";
}

# check the file type
open (IN,"<$read")|| die "open file $read :$!\n";
my $ftype="";
$_=<IN>;
if($_=~/^@/){
	$ftype="fq";
}elsif($_=~/^>/){
	$ftype="fa";
}
close IN;

# split read file
if($ftype eq "fq"){
	&FqSplit;
}elsif($ftype eq "fa"){
	&FaSplit;
}

for(my $i=1;$i<=$cpu;$i++){
	close $ofh[$i-1];
}

# align read to reference 

`mkdir $refbasename\_$readbasename\_$m\_aligned`;

# do the index
my $check=$ref;
$check.=".phr";
-e "$check" || `formatdb -i $ref -p $seqpara`;

my @child=();
for (my $i=1;$i<=$cpu;$i++){
	my $pid=fork();
	if($pid){
		push(@child,$pid);

	}elsif($pid==0){
		`blastall -p $p -d $ref -i $readbasename\_$i.fa -o $refbasename\_$readbasename\_$m\_aligned\/$refbasename\_$readbasename\_$m\_$i.$p -m $m -e $e`;
		exit 0 ;
	}else{
		print "fork: $!\n";
	}
} 

# wait until all child processes are done

foreach (@child){
	waitpid($_,0);
}

# remove intermediate file
`rm $ref.p*`;
for(my $i=1;$i<=$cpu;$i++){
	`rm $readbasename\_$i.fa`;
}

if(-e "$refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m.$p"){
	`rm $refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m.$p`;
	for (my $i=1;$i<=$cpu;$i++){
		`less $refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m\_$i.$p >> $refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m.$p`;
	}
}else{
	for (my $i=1;$i<=$cpu;$i++){
		`less $refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m\_$i.$p >> $refbasename\_$readbasename\_aligned\/$refbasename\_$readbasename\_$m.$p`;
	}
}
############################################################
sub FqSplit{
	open (IN,"<$read")|| die "open file $read :$!\n";
	while(<IN>){
		seek(IN,-length($_),1);
		for(my $j=0;$j<$cpu;$j++){
			while(<IN>){
				my $id=substr($_,1);
				print {$ofh[$j]} ">$id";
				$_=<IN>;
				print {$ofh[$j]} "$_";
				<IN>;<IN>;
				
			}
		}
	}
	close IN;
}

sub FaSplit{
	open (IN,"<$read")|| die "open file $read :$!\n";
	while(<IN>){
		seek(IN,-length($_),1);
		for(my $j=0;$j<$cpu;$j++){
			while(<IN>){
				print {$ofh[$j]} "$_";
				while(<IN>){
					if($_!~/^>/){
						print {$ofh[$j]} "$_";
					}else{
						seek(IN,-length($_),1); last;
					}
				}
				last;
			}
		}
	}
	close IN;
}


sub Help{
	print <<EOF;

Usage:
ParallelBlast.pl [option] reference read
option:
	-seqtype|-seq: reference sequence type
	prot: protein
	nucl: nucleotide
		default: prot

	-cpu: use how many cpu to excute the program
		default: 2

	-p: aligment program
	blastp: Search protein database using a protein query
	blastn: Search a nucleotide database using a nucleotide query
	blastx: Search protein database using a translated nucleotide query
	tblastn: Search translated nucleotide database using a protein query
	tblastx: Search translated nucleotide database using a translated nucleotide query
		default: blastp

	-m: alignment view options:
	0 = pairwise,
	1 = query-anchored showing identities,
	2 = query-anchored no identities,
	3 = flat query-anchored, show identities,
	4 = flat query-anchored, no identities,
	5 = query-anchored no identities and blunt ends,
	6 = flat query-anchored, no identities and blunt ends,
	7 = XML Blast output, 
	8 = tabular,
	9 tabular with comment lines
	10 ASN, text
	11 ASN, binary [Integer]
	    default = 8

	-e: Expectation value (E) [Real]
    	default = 10.0

EOF
exit;
}
