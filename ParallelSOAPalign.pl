#!/usr/bin/perl -w
# usage : ParallelSOAPalign.pl [option] ref fasta/q

use strict;
use Getopt::Long;


# set parameters

my $cpu=2;
my $l=40;
my $v=5;

GetOptions(
	   "cpu=i" => \$cpu,
	   "l=i" => \$l,
	   "v=i" => \$v
	   );

my $ref=$ARGV[0];
my $refp=BaseName($ref);

my $read=$ARGV[1];
my $readp=BaseName($read);


# split reads

open(IN,"<$read") || die "open $read: $!\n";

my @ofh=();
for(my $i=1;$i<=$cpu;$i++) {
    open($ofh[$i-1],">$readp\_$i.fa") || die "open $readp\_$i.fa: $!\n";
}

if($read=~/q$/) {
    while(<IN>) {
	my $id=substr($_,1);
        print {$ofh[0]} ">$id";
        $_=<IN>;
        print {$ofh[0]} $_;
        <IN>;
        <IN>;
        for(my $ofi=2;$ofi<=$cpu;$ofi++) {
            if($_=<IN>) {
		my $id=substr($_,1);
                print {$ofh[$ofi-1]} ">$id";
                $_=<IN>;
                print {$ofh[$ofi-1]} $_; 
                <IN>;
                <IN>;
            } else {
                last;
            }
        }
    }
} else {
    while(<IN>) {
        print {$ofh[0]} $_;
        $_=<IN>;
        print {$ofh[0]} $_;
        for(my $ofi=2;$ofi<=$cpu;$ofi++) {
            if($_=<IN>) {
                print {$ofh[$ofi-1]} $_;
                $_=<IN>;
                print {$ofh[$ofi-1]} $_;
            } else {
                last;
            }
        }
    }
}


# align reads to reference

`mkdir $refp\_$readp\_aligned`;
`mkdir $refp\_$readp\_unmapped`;

`2bwt-builder $ref`;

my @child=();
for(my $i=1;$i<=$cpu;$i++) {
    my $pid=fork();
    if($pid) {
        push(@child,$pid);

    } elsif($pid==0) {
        `soap -a $readp\_$i.fa -D $ref.index -l $l -v $v -r 2 -o $refp\_$readp\_aligned/$refp\_$readp\_$i.aligned -u $refp\_$readp\_unmapped/$refp\_$readp\_$i.unmapped 2> /dev/null`;
        exit 0;

    } else {
        print "fork: $!\n";
    }
}

# wait until all child processes are done 

foreach (@child) {
    waitpid($_,0);
}


# remove intermediate files

`rm $ref.index.*`;
for(my $i=1;$i<=$cpu;$i++) {
    `rm $readp\_$i.fa`;
}



######################################################################


sub BaseName {
    my $fn=shift(@_);
    my $dir="";
    if($fn=~/\//) { 
	$dir=`dirname $fn`; chomp $dir;
	$dir.="/";
    }
    my ($bn)=$fn=~/$dir(.+)\./;
    return $bn;
}
