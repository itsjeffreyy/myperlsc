#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# uasage: CutTwoContig.pl -fc -bc [option] .fa
# r : Reverse complement

use strict;
use Getopt::Long;
use Data::Dumper;

# fc: forward contig
# bc: backward contig
# fcr: forward contig reverse complement
# bcr: backward contig reverse complement
my $fc="";
my $bc="";
my $fcr=0;
my $bcr=0;
GetOptions(
	   "fc=s" => \$fc,
	   "bc=s" => \$bc,
	   "fcr"  => \$fcr,
	   "bcr"  => \$bcr,
	  );

my $id1="";
my $seq1="";
my $id2="";
my $seq2="";

open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^>(.*$fc.*)/){
		$id1=$1;
		while(<IN>){
			chomp $_;
			if($_!~/^>/){
				$seq1.=$_;
			}else{
				seek(IN,-length($_),1);
				last;	
			}
		}
	}
}

open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_=~/^>(.*$bc.*)/){
		$id2=$1;
		while(<IN>){
			chomp $_;
			if($_!~/^>/){
				$seq2.=$_;
			}else{
				seek(IN,-length($_),1);
				last;	
			}
		}
	}
}
close IN;

my $leng=length($seq1.$seq2);
if($fcr eq 0 && $bcr eq 0){
	print ">$id1+_$id2+_TotalLength $leng\n$seq1$seq2\n";
}elsif($fcr eq 1 && $bcr eq 0){
	my $s1=RC($seq1);
	print ">$id1-_$id2+_TotalLength $leng\n$s1$seq2\n";
}elsif($fcr eq 0 && $bcr eq 1){
	my $s2=RC($seq2);
	print ">$id1+_$id2-_TotalLength $leng\n$seq1$s2\n";
}elsif($fcr eq 1 && $bcr eq 1){
	my $s1=RC($seq1);
	my $s2=RC($seq2);
	print ">$id1-_$id2-_TotalLength $leng\n$s1$s2\n";

}
#################################################################
sub RC{
        my $read=shift(@_);
#                $read = reverse uc($read);
                $read = reverse $read;
                        $read=~tr/ATCGatcg/TAGCtagc/;
                                return $read;
                                }
