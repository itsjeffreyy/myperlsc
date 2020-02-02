#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# uasage: ExtractContig.pl [option] .fa contig
# r : Reverse complement

use strict;
use Getopt::Long;
use Data::Dumper;

my $rc=0;

GetOptions(
	   "rc|r" => \$rc,
	  );

my $contig=$ARGV[1];
my $sequence="";
open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^(>.*$contig.*)/){
		print "$1\n";
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

#################################################################
sub RC{
        my $read=shift(@_);
#                $read = reverse uc($read);
                $read = reverse $read;
                        $read=~tr/ATCGatcg/TAGCtagc/;
                                return $read;
}
