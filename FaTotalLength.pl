#!/usr/bin/perl -w
# usage : FaTotalLength.pl seqence.fa
# writer: Jeffreyy Yu
my $len=0;

if($ARGV[0] eq "mute"){
open(IN,"<$ARGV[1]")||die "open file $ARGV[1]:$!\n";
}else{
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
}

while(<IN>){
	if ($_!~/^>/){
	 	my $seq=$_; chomp $seq;
		$len+=length($seq);
	}
}

#my $id="";
#my %sq=();
#while(<IN>){
#	chomp $_;
#	if($_=~/^>(.+)/){
#		$id=$1;
#	}else{
#		$sq{$id}.=$_;
#	}
#}
close IN;
#foreach (keys %sq){
#	$len+=length($sq{$_});
#}
if($ARGV[0] eq "mute"){
	print "$len";
}else{
	print "$ARGV[0] Fasta Total= $len\n";
}
