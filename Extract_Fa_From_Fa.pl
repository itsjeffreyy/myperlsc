#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# uasage: ExtractContig.pl [option] .fa contig
# r : Reverse complement

use strict;
use Getopt::Long;
use Data::Dumper;

my $rc=0;
my $list_f="";
my $id="";

GetOptions(
	"rc|r" => \$rc,
	"list|l=s" => \$list_f,
	"id|i=s" => \$id,
);

my @ids=();
if($list_f &&  $id){
	print "ERR: Option -list and -id cannot exist same time.\n"; exit;
}elsif($list_f && -e $list_f){
	open(IN,"<$list_f")|| die "Cannot open $list_f: $!\n";
	while(<IN>){
		chomp;
		push(@ids,$_);
	}
	close IN;

}else{
	push(@ids,$id);
}

#print Dumper @ids; exit;
my $sequence="";
open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	if($_!~/^>/){next;}
	foreach my $id_search (@ids){
		if($_=~/^>$id_search/){
			print "$_\n";
			$sequence="";
			while(<IN>){
				chomp $_;
				if($_!~/^>/){
					$sequence.=$_;
				}else{
					seek(IN,-length($_)-1,1);
					last;
				}
			}
			if($rc eq 0){
				print "$sequence\n";
			}elsif($rc eq 1){
				my $s=RC($sequence);
				print "$s\n";
			}
			last;
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
