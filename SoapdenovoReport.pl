#!/usr/bin/perl -w
use strict;
my $k="";
my $c_n50=();
my $c_total=();
my $contigs=();
my $s_n50=();
my $s_total=();
my $scaffolds=();
my $prefix=$ARGV[0];

print "            contig     contig    contig    scaffold   scaffold   scaffold\n";
print "kmer         N50       total     numbers      N50       total     numbers\n";
for ($k=$ARGV[1];$k<=$ARGV[2];$k=$k+2){
	my $contig_filename="$prefix"."_k"."$k".".contig";
	my $scaffold_filename="$prefix"."_gapclsoer"."_k"."$k";
#	my $contig_filename="k"."$k".".contig";
#	my $scaffold_filename="gi1"."k"."$k";

	$c_n50=`N50.pl ./$contig_filename`; chomp $c_n50;
	$c_total=`FaTotalLength.pl mute ./$contig_filename`;
	my $contigs=`grep -c \\> $contig_filename`;chomp $contigs;

	my$s_n50=`N50.pl ./$scaffold_filename`; chomp $s_n50;
	$s_total=`FaTotalLength.pl mute ./$scaffold_filename`;
	my $scaffolds=`grep -c \\> $scaffold_filename`;chomp $scaffolds;
	
	printf "%4.0f  %10.0f  %10.0f  %10.0f  %10.0f  %10.0f  %10.0f\n",$k,$c_n50,$c_total,$contigs,$s_n50,$s_total,$scaffolds;
}
