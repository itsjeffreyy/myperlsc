#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my @notmove=();
my $notmoveline=();
GetOptions(
	"notmove|n=i" => \$notmoveline,
);

my @line=();
open (IN,"$ARGV[0]")|| die "open $ARGV[0]:$!\n";
while(<IN>){
	chomp;
	push(@line,$_);
}
close IN;

if($notmoveline){
	for(my $i=0;$i<$notmoveline;$i++){
		push(@notmove,shift(@line));
	}
}

@line=reverse @line;
if(@notmove){
	print join("\n",@notmove)."\n";
}
print join("\n",@line)."\n";
