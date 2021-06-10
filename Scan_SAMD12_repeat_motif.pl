#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my @motif=("TTTTA","TTTCA","AAATA","AAATG");
my $rc_option="";
my $help="";
#my $fa="";

GetOptions(
	"rc" => \$rc_option,
	"motif|m=s{,}" => \@motif,
	"help|h" =>  \$help,
	#"fa=s" => \$fa,
);

if($help){&Help;}

if(! -e $ARGV[0]){
        print "ERR: Input $ARGV[0] not exist!\n\n";
        &Help;
}

# load sequence fasta file
my %id_seq=();
my $id="";
open(IN,"<$ARGV[0]")|| die "Cannnot open $ARGV[0]: $!\n";
while(<IN>){
	chomp;
	if($_=~/^>(\S+)/){
		$id=$1;
	}else{
		$id_seq{$id}.=$_;
	}
}
close IN;

my %motifs=();
foreach (@motif){
	$motifs{$_}=1;
}

# scan motift 
my %seq_motif_num=();
foreach my $id (keys %id_seq){
	
	my $seq="";
	if($rc_option){
		$seq=$id_seq{$id};
	}else{
		$seq=&RC($id_seq{$id});
	}

	for (my $i=0;$i < ((length $seq)-4);$i++){
		my $motif=substr($seq,$i,5);
		if($motifs{$motif} && $motifs{substr($seq,$i+5,5)}){
			#print "$motif\n";
			for (my $ia=$i;$ia < ((length $seq)-4);$ia+=5){
				my $part_motif=substr($seq,$ia,5);
				$seq_motif_num{$part_motif}++;
				if(!$motifs{$part_motif} || !$motifs{substr($seq,$ia+5,5)}){$i=$ia+5; last;}
			}			
		}
	}
}

print "# motif\tcopy_number\n";
foreach my $m (sort {$seq_motif_num{$b}<=>$seq_motif_num{$a}} (keys %seq_motif_num)){
	print "$m\t$seq_motif_num{$m}\n";
}

############################################################
sub RC(){
	my $seq=shift @_;
	my $r_seq=reverse($seq);
	$r_seq=~tr/ATCGatcg/TAGCtagc/;
	return $r_seq;
}
sub Help(){
	print <<EOF;
Usage:
	Scan_SAMD12_repeat_motif.pl [options] SAMD12_target.fasta
Options:
	rc     : Reverse complete seqence
	motif|m: the motifs want to scan (default: TTTTA TTTCA AAATA AAATG)

EOF
	exit;
}
