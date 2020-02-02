#!/usr/bin/perl -w
# usage: PeakMemoryUsage.pl delay PID

use strict;


# set parameters

my $d=shift(@ARGV);
my @pid=@ARGV;
$|=1;


# check peak memory usage of all processes every d seconds if one of them is still running

my $peakmem=0;

my $runq=ProcessRunningQ(@pid);
my @m=();

while($runq==1) {
    my @m=();
    foreach my $p (@pid) {
	my $s=`grep Peak /proc/$p/status`;
	$s=~/VmPeak:\s+(\d+) kB/;
	push(@m,$1);
    }
    
    my $mem=Sum(@m);
    if($mem>$peakmem) { $peakmem=$mem; }
    print "current memory usage: $mem kB\n";

    sleep($d);
    $runq=ProcessRunningQ(@pid);
}

print "peak memory usage: $peakmem kB\n";



######################################################################


sub ProcessRunningQ {
    my @pid=@_;
    
    my $q=0;
    foreach my $p (@pid) {
	if(`ps -a | grep $p`) {
	    $q++;
	}
    }
    if($q>0) { $q=1; }
    
    return $q;
}


sub Sum {
    my $s=0;
    foreach my $e (@_) {
	$s+=$e;
    }
    return $s;
}
