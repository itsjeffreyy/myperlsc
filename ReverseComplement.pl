#! /usr/bin/perl -w
# usage :ReverseComplement.pl sequence > RCsequence
# writer:Jeffreyy Yu
use strict;
use Data::Dumper;
use Getopt::Long;

my $fa;
GetOptions(
	"fa=s" => \$fa,
);

if (! $fa){
	my $seq=$ARGV[0];
	my $rcseq= &RC($seq);
	print "$rcseq\n";
}elsif ($fa){
	my $check = &CheckFaFormat($fa);
	if($check == 0){
		print "ERR: Probably not Fasta format!\n";
		exit;
	}elsif($check == 1){
		my %title_seq=();
		my @title=();
		open(FaIN,"<$fa")|| die "open $fa: $!\n";
		while(<FaIN>){
			chomp;
			if($_=~/^>(.+)/){
				push(@title,$1);
			}else{
				$title_seq{$title[-1]}.=$_;
			}
		}
		close FaIN;
		
		# fasta file
		my ($rc_fa_fn,$ext)=$fa=~/(.+)((?:.fasta|.fa|.fna))/;
		$rc_fa_fn.="_rc".$ext;
		print "MSG: Generate RC fasta file $rc_fa_fn\n";

		open(FaOUT, "> $rc_fa_fn") || die "ERR: Can not write $rc_fa_fn\n";
		foreach my $t (@title){
			print FaOUT ">$t\n";
			print FaOUT &RC($title_seq{$t})."\n";
		}
		close FaOUT;
	}
}

#################################################################
sub RC{
	my $read=shift(@_);
#	$read = reverse uc($read);
	$read = reverse $read;
	$read=~tr/ATCGatcg/TAGCtagc/;
	return $read;
}

sub CheckFaFormat{
	my $faf=shift @_;
	open(FaIN,"<$faf") || die "open $fa: $!\n";
	my $line=<FaIN>;
	close FaIN;
	if($line=~/^>/){
		return 1;
	}else{
		return 0;
	}
}
