#!/usr/bin/perl -w
use strict;
use Data::Dumper;

my %readid_iden=();
open(IN,"<$ARGV[0]") || die "Open PAF $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my $readid=$a[0];
	my $readleng=$a[1];
	my $matched=$a[9];
	push(@{$readid_iden{$readid}},sprintf("%.2f",$matched/$readleng*100));
}
close IN;

foreach my $key (keys %readid_iden){
	@{$readid_iden{$key}}=sort {$b <=> $a} @{$readid_iden{$key}};
}

#print Dumper %readid_iden;

#foreach my $key (keys %readid_iden){
#	if($readid_iden{$key}[0] > 50){
#		print "$key\t$readid_iden{$key}[0]\n";
#	}
#}

foreach my $key (keys %readid_iden){
	print "$key\t".join("\t",@{$readid_iden{$key}})."\n";
}
