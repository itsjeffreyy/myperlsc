#!/usr/bin/perl -w
use strict;
my @a=Unique(@ARGV);
foreach (@a){
	print "$_\n";
}


##################################
sub Unique{
    my %seen=();
    return grep (!$seen{$_}++,@_);
}
