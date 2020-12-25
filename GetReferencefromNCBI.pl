#!/usr/bin/perl -w 
# usage: GetReferencefromNCBI.pl -id [list or NCBI accession]  -combine combine.fasta
# writer: Jeffreyy Yu
# date: 2015.05.21

use strict;
use Data::Dumper;
use Getopt::Long;


my @id=();
my $type="fasta";
my $comname="";
# type can be gb (genebank), fasta
GetOptions(
		"id=s{,}" => \@id,
		"type|t=s"=> \$type,
		"combine|c=s"=> \$comname,
		);


if(!@id){
	print "Please enter id\n";
	exit 0;
}

my @acce=();
if(-e $id[0]){
    open(IN,"<$id[0]") || die "open $id[0]: $!\n";
    @acce=<IN>;
    chomp @acce;
} else {
    @acce=@id;
}

foreach my $acc (@acce){
	my $file="$acc\.$type";
	if(-e $file){next;}
	`wget -O $file "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=$acc&rettype=$type&retmode=text"`;
}

if($comname){
	my @ref=map{$_.".fasta"}@acce;
	my $command="cat @ref > $comname";
	`$command`;
}
