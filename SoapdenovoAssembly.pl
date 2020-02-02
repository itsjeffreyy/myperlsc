#!/usr/bin/perl -w
# writer  :Jeffreyy Yu
# Usage   :SoapdenovoAssembly.pl
use strict;
use Data::Dumper;
use Getopt::Long;

# load parameters

my @pe=();
my @se=();
my $k="";
my $outprefix="";

GetOptions(
           "pe=s" => \@pe,
	   "se=s" => \@se,
	   "k=s" => \$k,
	   "outprefix=s" => \$outprefix
	   );
my $max_rd_len="";
my $avg_ins="";

# create soapdenovo config file
open (ConfOUT,">$conffile");
print ConfOUT <<EOF;
#maximal read length
max_rd_len=$max_rd_len
EOF


print ConfOUT <<EOF;
#[LIB]
##average insert size
avg_ins=$avg_ins 
#if sequence needs to be reversed 
reverse_seq=0
#in which part(s) the reads are used
asm_flags=3
#in which order the reads are used while scaffolding
rank=$rank
#fastq file for read 1 
q1=$f1
#fastq file for read 2 always follows fastq file for read 1
q2=$f2	
EOF

# load parameters

my @pe=();
my @se=();
my $k="";
my $outprefix="";

GetOptions(
           "pe=s" => \@pe,
	   "se=s" => \@se,
	   "k=s" => \$k,
	   "outprefix=s" => \$outprefix
	   );


# process input files

my @file=();
my %faq=();
my %fps=();

my $i=0;
foreach my $l (@pe) {
    $i++;
    my ($f1,$f2)=split(",",$l);
    my $f="tmplib$i\_pe.";
    if($f1=~/fastq$/ || $f1=~/fq$/) {
	$f.="fastq";
	$faq{$f}="fastq";
	`shuffleSequences_fastq.pl $f1 $f2 $f`;
    } else {
	$f.="fasta";
	$faq{$f}="fasta";
	`shuffleSequences_fasta.pl $f1 $f2 $f`;
    }
    $fps{$f}="shortPaired";
    push(@file,$f);
}

foreach my $f (@se) {
    $faq{$f} = ($f=~/fastq$/ || $f=~/fq$/) ? "fastq" : "fasta";
    $fps{$f}="short";
    push(@file,$f);
}


# construct velvet command and run velveth

my ($ks,$ke,$ki)=split(",",$k);
my $ken=$ke+$ki;

my $velveth="velveth $outprefix $ks,$ken,$ki -$fps{$file[0]} -$faq{$file[0]} $file[0]";
for(my $i=1;$i<@file;$i++) {
    my $i1=$i+1;
    $velveth.=" -$fps{$file[$i]}$i1 -$faq{$file[$i]} $file[$i]";
}
`$velveth`;


# run velvetg, record results, and remove worse results

my %kstat=();

`velvetg $outprefix\_$ks -exp_cov auto`;
ProcessOutput("$outprefix\_$ks",\%kstat);

my $bcn50k=$ks;
my $bsn50k=$ks;
my %kbq=($ks,2);

for(my $k=$ks+$ki;$k<=$ke;$k+=$ki) {
    `velvetg $outprefix\_$k -exp_cov auto`;
    ProcessOutput("$outprefix\_$k",\%kstat);

    my @dk=Unique($bcn50k,$bsn50k,$k);
    if($kstat{$k}{cn50}>=$kstat{$bcn50k}{cn50}) {
	$bcn50k=$k;
    }
    if($kstat{$k}{sn50}>=$kstat{$bsn50k}{sn50}) {
	$bsn50k=$k;
    }
    
    foreach my $dk (@dk) {
	if($dk!=$ks && $dk!=$bcn50k && $dk!=$bsn50k) {
	    `rm -r $outprefix\_$dk`;
	}
    }
}

if($ks!=$bcn50k && $ks!=$bsn50k) {
    `rm -r $outprefix\_$ks`;
}


# output statistics

open(OUT,">$outprefix.stat") || die "open $outprefix.stat: $!\n";

foreach my $k (sort{$a<=>$b}(keys %kstat)) {
    print OUT "$k\t$kstat{$k}{tcl}\t$kstat{$k}{cn}\t$kstat{$k}{cn50}";
    print OUT "\t$kstat{$k}{tsl}\t$kstat{$k}{sn}\t$kstat{$k}{sn50}\n";
}


# remove intermediate files

foreach my $f (@file) {
    if($fps{$f} eq "shortPaired") {
	`rm $f`;
    }
}



######################################################################


sub ProcessOutput {
    my ($d,$r)=@_;
    my ($k)=$d=~/(\d+)$/;

    `cp $d/contigs.fa $d/tmp.fa`;
    `RemoveShortFasta.pl $d/tmp.fa 100 > $d/scaffold.fa`;
    `Scaffold2Contig.pl $d/scaffold.fa > $d/tmp.fa`;
    `RemoveShortFasta.pl $d/tmp.fa 100 > $d/contig.fa`;
    `rm $d/tmp.fa`;
    
    $$r{$k}{tcl}=`TotalLength.pl $d/contig.fa`; chomp $$r{$k}{tcl};
    $$r{$k}{cn}=`grep -c \\> $d/contig.fa`; chomp $$r{$k}{cn};
    $$r{$k}{cn50}=`N50.pl $d/contig.fa`; chomp $$r{$k}{cn50};
    $$r{$k}{tsl}=`TotalLength.pl $d/scaffold.fa`; chomp $$r{$k}{tsl};
    $$r{$k}{sn}=`grep -c \\> $d/scaffold.fa`; chomp $$r{$k}{sn};
    $$r{$k}{sn50}=`N50.pl $d/scaffold.fa`; chomp $$r{$k}{sn50};
}


sub Unique {
    my %seen=();
    return grep(!$seen{$_}++,@_);
}
