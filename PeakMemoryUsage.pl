#!/usr/bin/perl -w
# usage: PeakMemoryUsage.pl process

use strict;


# set parameters and output
# d : delay
# p : process (command and arguments)

sleep(1);

my $d=2;
my $p=join(" ",@ARGV);

my $f=join("_",@ARGV).".mem";
open(OUT,">$f") || die "open $f: $!\n";
my $ofh=select(OUT);
$|=1;
select($ofh);


# check peak memory usage of all processes every d seconds if one of them is still running

my $peakmem=0;
my $pid=ProcessID($p);
while($pid) {
    my $s=`grep Peak /proc/$pid/status`;
    $s=~/VmPeak:\s+(\d+) kB/;
    my $mem=$1;

    if($mem>$peakmem) { $peakmem=$mem; }
    my $date=`date`; chomp $date;
    print OUT "$date memory usage : $mem kB\n";

    sleep($d);
    $pid=ProcessID($p);
}

print OUT "peak memory usage: $peakmem kB\n";
close OUT;



######################################################################


sub ProcessID {
    my $p=shift(@_);
    my $id="";

    my @run=split("\n",`ps aux`);
    foreach my $r (@run) {
	if($r=~/$p/) {
	    $id=(split(/\s+/,$r))[1];
	}
    }

    return $id;
}
