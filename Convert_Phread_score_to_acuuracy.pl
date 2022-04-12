#!/usr/bin/perl -w
use strict;
use Data::Dumper;

# input q score to convert to accuracy
my $q_score=$ARGV[0];

my $error_p=(10**((-$q_score)/10))*100;
my $accuracy=100-$error_p;

print "Error rate: $error_p%\n";
print "correct rate: $accuracy%\n";
