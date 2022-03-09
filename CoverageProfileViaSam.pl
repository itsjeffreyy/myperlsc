#!/usr/bin/perl -w
# writer : Jeffreyy Yu
# usage : CoverageProfileViaSam.pl [-sf] -ref reference.fa [-bam file.bam] -sam file.sam
# note : 
#	separate file| sf: separate the output file according chromosome.
#	reference |ref: give the specis reference file (fasta formate).
#	bamfile| bam: give bam files, the script will automatically  transfer to SAM.
#	samfile| sam: give sam files, if you have the sam file.


use strict;
use Data::Dumper;
use Getopt::Long;

my $separatefile=0;
my @samfile=();
my @bamfile=();
my $ref="";
my $help="";

GetOptions(
		"separate-file|sf" => \$separatefile,
		"samfile|sam=s{,}" => \@samfile,
		"bamfile|bam=s{,}" => \@bamfile,
		"reference|ref=s"=> \$ref,
		"help|h" => \$help,
		);

if($help){
print <<EOF;

usage: CoverageProfileViaSam.pl [-sf] -ref reference.fa [-bam file.bam] -sam file.sam
note : 
	separate file| sf: separate the output file according chromosome.
	reference |ref   : give the specis reference file (fasta formate).
	bamfile| bam     : give bam files, the script will automatically  transfer to SAM.
	samfile| sam     : give sam files, if you have the sam file.

EOF
exit 0;
}

# check bam tranfer to sam
my %ridalign=();

if (@bamfile){
	foreach my $bam (@bamfile){
	 -e $bam or die "file $bam is not exist!\n";
	}
	foreach my $bam (@bamfile){
		my ($fh)=$bam=~/(\S+)\.bam/;
		$fh.="\.sam";
		-e $fh or `samtools view $bam > $fh`;
		push (@samfile,$fh);
	}
}

# load sam file
	foreach my $sam (@samfile){
	 -e $sam or die "file $sam is not exist!\n";
	}
foreach my $sam (@samfile){
	open(IN,"<$sam")||die"open file $sam:$!\n";
	while(<IN>){
		if($_=~/^@/){next;}
		chomp;
		my @a=split("\t",$_);
# rid :read id
# ref :reference
# sp  :start position
# var :variation
		my ($rid,$ref,$sp,$var)=@a[0,2,3,5];
		push(@{$ridalign{$rid}},[$ref,$sp,$var]);
	}
	close IN;
}

# load reference length
my %idleng=();
open(IN,"<$ref")||die"open file $ref:$!\n";
my $id="";
while(<IN>){
	chomp;
	if($_=~/^>(\S+)/){
		$id=$1;
		$idleng{$id}=0;
		next;
	}
	$idleng{$id}+=length($_);
}
close IN;


# record the counts of a read alignment.
my %readcount=();
foreach my $rid (keys %ridalign){
	$readcount{$rid}=scalar @{$ridalign{$rid}};
}


my %cidcov=();
foreach my $rid (keys %ridalign){
	for (my $align=0;$align<=$#{$ridalign{$rid}};$align++){
# cid : contig id
# sp  : start position
# var : variation
		my $cid=$ridalign{$rid}[$align][0];
		my $sp =$ridalign{$rid}[$align][1];
		my $var=$ridalign{$rid}[$align][2];

		while(length($var)>0){

# hard linking
			if ($var=~/^(\d+)H/){
				my $le=length($1)+1;
				$var=substr($var,$le);

# soft linking
			}elsif ($var=~/^(\d+)S/){
				my $le=length($1)+1;
				$var=substr($var,$le);
# match
			}elsif ($var=~/^(\d+)M/){
				my $m=$1;
				for(my $i=$sp;$i<=($sp+$m)-1;$i++){
					$cidcov{$cid}[$i]+=(1/$readcount{$rid});
				}

				my $le=length($m)+1;
				$var=substr($var,$le);

				if($var=~/(\d+)N(\d+)M/){
					my $resp=$sp+$1-1;
					my $rem=$2;
					for(my $i=$resp;$i<=($resp+$rem)-1;$i++){
						$cidcov{$cid}[$i]+=(1/$readcount{$rid});
					}
				}
				last;
			}
		}
	}
}

if($separatefile == 0){
	my ($fn)=$ref=~/(\S+)\.fa/;
	$fn.="\.cp";
	open(OUT,">./$fn");
	foreach my $cid (keys %cidcov){
		print OUT "$cid\t$idleng{$cid}\n";
		for (my $posi=1; $posi <= $idleng{$cid}; $posi++){
			if(! $cidcov{$cid}[$posi]){
				$cidcov{$cid}[$posi]=0;
			}
			print OUT "$posi\t";
			printf OUT "%.2f\n",$cidcov{$cid}[$posi];
#			printf OUT "%.2f\n",join("\t",@{$cidcov{$cid}});
#			print OUT "\n";
		}
	}
	close OUT;
}else{
	foreach my $cid (keys %cidcov){
		my $fn="$cid\_$idleng{$cid}\.cp";
		open(OUT,">./$fn"); 
		for (my $posi=1; $posi <= $idleng{$cid}; $posi++){
			if(! $cidcov{$cid}[$posi]){
				$cidcov{$cid}[$posi]=0;
			}
			print OUT "$posi\t";
			printf OUT "%.2f\n",$cidcov{$cid}[$posi];
		}
		close OUT;
	}
}
