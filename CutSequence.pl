#!/usr/bin/perl -w 
#writer: Jeffreyy Yu
#Usage: CatSequence.pl [option] .fa contig start end
#       there are three difined method
#       if start<0 and no end, it will take the tail sequence
#       if no end and start>0, it will take the position to the end sequence
#       it usually take the suquence of the position start to end.
use strict;
use Data::Dumper;
use Getopt::Long;

my $rc=0;
my $id=$ARGV[1];
my $printid="";
my $start="";
my $end="";
my $len="";
my $sequence="";
my $printseq="";
my $Tlength="";
GetOptions(
	"rc|r" => \$rc,
	"start|s=i" => \$start,
	"end|e=i" => \$end,
	"len|l=i" => \$len,
	  );

print "get ctg id $id....\n";
print "open $ARGV[0]...\n";
open(IN,"<$ARGV[0]")||die"open file $ARGV[0]:$!\n";
while(<IN>){
	chomp $_;
	$sequence="";
#	if($_ eq ">$id"){
	if($_ =~ ">$id"){
		chomp $_; $printid=$_;
		$sequence="";
		while(<IN>){
			chomp $_;
			if($_=~/^>/){
				seek(IN,-length($_),1);
				last;
			}else{
				$sequence.=$_;
			}
		}

		$Tlength=length($sequence);
		if($sequence && $Tlength > $start){
			my $range="";
			$printseq="";
			if($start>0 && $end eq "" && !$len){
				$printseq=substr($sequence,$start-1);
				$range="$start~$Tlength";
			}elsif($start<0 && $end eq "" && !$len){
				$printseq=substr($sequence,$start);
				my $a=$Tlength+$start;
				$range="$a~$Tlength";
			}elsif($start>0 &&  $end){
				$printseq=substr($sequence,$start-1,$end-$start+1);
				$range="$start~$end";
			}elsif($start>0 && $len){
				$printseq=substr($sequence,$start-1,$len);
				my $e=$start+$len;
				$range="$start~$e";
			}


			if($printseq){
				my $psl=length($printseq);		
				if($rc eq 0){
					my $s=uc($printseq);
					print "$printid\t$Tlength\t$range\t";
					print "\+\t$psl\n$s\n";
				}elsif($rc eq 1){
					my $s=uc(RC($printseq));
					print "$printid\t$Tlength\t$range\t";
					print "\-\t$psl\n$s\n";
				}
			}
		}else{
			print "Error!: The start site is larger than sequence length!\n";
			exit;
		}
	}
}

#################################################################
sub RC{
	my $read=shift(@_);
#                $read = reverse uc($read);
	my $rcread = reverse $read;
	$rcread=~tr/ATCGatcg/TAGCtagc/;
	return $rcread;
}
