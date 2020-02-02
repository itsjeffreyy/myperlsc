#!/usr/bin/perl -w
# usage : GetSRAByRun.pl SRR# (or DRR or ERR) ...
# note  : This also takes as input a file containing many SRR#'s.

use strict;


# get run numbers

my @srrn=();

if(-e $ARGV[0]) {
    open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";
    @srrn=<IN>;
    chomp @srrn;
} else {
    @srrn=@ARGV;
}


# download runs

foreach my $srrn (@srrn) {
    my $srr=substr($srrn,0,3);
    my $n=substr($srrn,3);
    my $n3=substr($n,0,3);
    
    my $command='ascp -i /home/jeffreyy/program/aspera/asperaweb_id_dsa.openssh -k 1 -QTr -l 100m ';
    $command.='anonftp@ftp-private.ncbi.nlm.nih.gov:/sra/sra-instant/reads/ByRun/sra/';
    $command.="$srr/$srr$n3/$srrn/$srrn.sra .";
    `$command`;
}
