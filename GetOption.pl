#!/usr/bin/perl -w
# usage : GetOption.pl [option] file

use strict;
use Getopt::Long;
use Data::Dumper;

my $v="";
my $min=10;
my $max=100;
my $s='';
my @f=();

GetOptions(
           "verbose" => \$v,
           "min=i" => \$min,
	   "max|x=f" => \$max,
           "string=s" => \$s,
	   "file=s{,}" => \@f,
           );

my $a=$ARGV[0];

print "v: $v\n";
print "min: $min\n";
print "max: $max\n";
print "s: $s\n";
print "f: @f\n";
print Dumper @f;
