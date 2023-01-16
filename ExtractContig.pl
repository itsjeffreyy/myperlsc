#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# uasage: ExtractContig.pl [option] .fa keyword
# r : Reverse complement
# default is match mode

use strict;
use Getopt::Long;
use Data::Dumper;

my $rc=0;
my $mode='match'; #match, simulate
my $fasta="";
my $keyword="";

GetOptions(
	   "rc|r" => \$rc,
	   "mode|m=s" => \$mode,
	   "fasta|fa=s" => \$fasta,
	   "keyword|kw=s" => \$keyword,
);

if(! $keyword){
	print "[ERR] No keyword. Enter the keyword with the option -kw.\n";
	exit;
}

if(! -e $fasta){
	print "[ERR] No Fasta file. Enter the fasta file with the option -fa.\n";
	exit;
}


my $sequence="";
open(IN,"<$fasta")||die"open file $fasta:$!\n";
while(<IN>){
	chomp;

	if($mode eq 'match'){
		if($_ eq ">$keyword"){
			print "$_\n";
			$sequence="";
			while(<IN>){
				chomp $_;
				if($_!~/^>/){
					$sequence.=$_;
				}else{
					seek(IN,-length($_),1);
					last;
				}
			}
			if($rc eq 0){
				print "$sequence\n";
			}elsif($rc eq 1){
				my $s=RC($sequence);
				print "$s\n";
			}
		}

	}elsif($mode eq 'simulate'){	
		if($_=~/^(>$keyword)/){
			print "$_\n";
			$sequence="";
			while(<IN>){
				chomp $_;
				if($_!~/^>/){
					$sequence.=$_;
				}else{
					seek(IN,-length($_),1);
					last;
				}
			}
			if($rc eq 0){
				print "$sequence\n";
			}elsif($rc eq 1){
				my $s=RC($sequence);
				print "$s\n";
			}
		}
	}
}

#################################################################
sub RC{
        my $read=shift(@_);
#                $read = reverse uc($read);
                $read = reverse $read;
                        $read=~tr/ATCGatcg/TAGCtagc/;
                                return $read;
}
