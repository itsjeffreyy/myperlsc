#!/usr/bin/perl -w
# usage : PEDistanceViaSoap.pl [option] ref pe1 pe2
# note  : This obtains PE distance distrubtion given a reference sequence
#       : and paired-end data. It maps PE reads to reference using soap.
#       : It requires ShuffleSplitFastq2Fasta.pl and SoapAlignmentPEDistance.pl.
#       : It assumes a constant read length.
# date  : 2012.01.23

use strict;
use Getopt::Long;


# set parameters

my $cpu=2;
my $neg=0;

GetOptions(
	   'c=i' => \$cpu,
	   'neg' => \$neg
	   );

my $ref=shift(@ARGV);
my ($pe1,$pe2)=@ARGV;

my $tmp=`head -2 $pe1 | tail -1`;
my ($r)=$tmp=~/(.+)/;
my $rl=length($r);
my $v=int($rl/20);


# split fastq into n file for parallel computing

`ShuffleSplitFastq2Fasta.pl $pe1,$pe2 $cpu petmp`;


# map PE reads to reference

`2bwt-builder $ref`;

my @child=();
for(my $i=1;$i<=$cpu;$i++) {
    my $pid=fork();
        
    if($pid) {
	push(@child,$pid);

    } elsif($pid==0) {
	`soap -a petmp_$i.fa -D $ref.index -l 40 -v $v -r 2 -o $ref\_petmp_$i.aligned 2> /dev/null`;
	`SoapAlignmentPEDistance.pl $ref\_petmp_$i.aligned > $ref\_petmp_$i.ped`;
	exit 0;

    } else {
	print "fork: $!\n";
    }
}

# wait until all child processes are done 
foreach (@child) {
    waitpid($_,0);
}


# combine PE distances

my %pedc=();

for(my $i=1;$i<=$cpu;$i++) {
    open(IN,"<$ref\_petmp_$i.ped") || die "open $ref\_petmp_$i.ped: $!\n";
    while(<IN>) {
	my @a=split("\t",$_); chomp $a[-1];
	if($neg) {
	    $pedc{$a[0]}+=$a[1];
	} elsif($a[0]>0) {
	    $pedc{$a[0]}+=$a[1];
	}
    }
    close IN;
}


# output PE distance distribution

foreach my $ped (sort{$a<=>$b}(keys %pedc)) {
    print "$ped\t$pedc{$ped}\n";
}


# remove intermediate files

`rm petmp_*.fa`;
`rm $ref.index.*`;
`rm $ref\_petmp_*.aligned`;
`rm $ref\_petmp_*.ped`;
