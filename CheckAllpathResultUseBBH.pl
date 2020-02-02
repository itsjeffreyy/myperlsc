#!/usr/bin/perl -w
#writer: Jeffreyy Yu
#usage: CheckAllpathResultUseBBH.pl [option] .bbh 454ContigGraph.txt .psl > result
#

use strict;
use Data::Dumper;
use Getopt::Long;
my %allpath=();
my $totalcontig=0;
my $goodcontig=0;
my $badcontig=0;
my $blat=0;
# upb:unaling part bases
my $upb=10;

GetOptions(
	"blat|b"=>\$blat,
);


# load the blat result with BlatBestHists.pl
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	if($_=~/^(contig_\d+)/ || $_=~/^(scaffold_\d+)/){
		my $contig=$1;
		$totalcontig++;
		while(<IN>){
			if($_ eq "\n"){
				last;
			}else{
				my @blat=split(' ',$_);	
				push(@{$allpath{$contig}},\@blat);
			}
		}
	}
}
close IN;

# load the newbler contig graph and transfer the direction 5'3' to +-
my %cs5cs=();
my %cs3cs=();
open(CGIN,"<$ARGV[1]")||die "open file $ARGV[1]:$!\n";
#open (CGOUT,">contiggraph");
while(<CGIN>){
	#C       145     5'      177     5'      31
	if($_=~/^C\s+(\d+)\s+(\d)'\s+(\d+)\s+(\d)'\s+\d+/){
		my $c1=$1;
		my $c2=$3;
		my @id1=();
		my @id2=();
		while(length($c1) < 5){
			@id1=split('',$c1);
			unshift(@id1,0);
			$c1=join('',@id1);
		}
		while(length($c2) < 5){
			@id2=split('',$c2);
			unshift(@id2,0);
			$c2=join('',@id2);
		}
		$c1="contig$c1";$c2="contig$c2";
		my $d1=$2;
		my $d2=$4;
#		print "$c1\t$d1\t$c2\t$d2\n";
		if($d1 eq 5){
			push(@{$cs5cs{$c1}},[$c2,$d2]);
		}
		if($d2 eq 5){
			push(@{$cs5cs{$c2}},[$c1,$d1]);
		}
		if($d1 eq 3){
			push(@{$cs3cs{$c1}},[$c2,$d2]);
		}
		if($d2 eq 3){
			push(@{$cs3cs{$c2}},[$c1,$d1]);
		}
	}
}
close CGIN;
#close CGOUT;
#print Dumper %cs5cs;
# allpath{$contig}[
# [match, mismatch, rep. match, N's, Q gap count, Q gap bases, T gap count, T gap bases, strand, Qname, Qsize, Qstart, Qend, Tname, Tsize, Tstart, Tend, block count, blockSizes, qStarts, tStats]
# [0    , 1       , 2         , 3  , 4          , 5          , 6          , 7          , 8     , 9    , 10   , 11    , 12  , 13   , 14   , 15    , 16  , 17         , 18        , 19     , 20    ]
# []....
# ]
#man function
my $filegc="";
my $filepc="";
if($ARGV[0]=~/(.+)\.bbh/){
	$filegc=$1;
	$filepc=$1;
}
if($blat eq 1 ){
	$filepc.="\-blast";
}
open(BADOUT,">check_$filepc.pc");
open(GOODOUT,">check_$filegc.gc");

# find out the problem contig rangs
foreach my $id (keys %allpath){

	# find out the newbler contigs element of allapth contig.
	my @element=();

	for (0..$#{ $allpath{$id} }){
		push(@element,"${$allpath{$id}}[$_][9]${$allpath{$id}}[$_][8]");
	}

	# find out the problem rang from elements.	
	# pr: problem range
	# pl: problem length
	# pp: problem position
	# pg: problem graph
	# tcbr: two contigs blat result
	my @pr=();
	my @pl=();
	my @pp=();
	my @pg=();
	my @tcbr=();
	for (my $j=1;$j<=$#{ $allpath{$id} };$j++){
		# fc: forward contig
		# bc: backward contig
		# fcd: forward contig direction
		# bcd: backward contig direction
		# fcep: forward contig end position
		# bcsp: backward contig start position
		# disttwocontig: distance between two contigs
		# fqs: forward query size
		# bqs: backward query size
		my $fc=${ $allpath{$id} }[$j-1][9];
		my $bc=${ $allpath{$id} }[$j][9];
		my $fcd=${ $allpath{$id} }[$j-1][8];
		my $bcd=${ $allpath{$id} }[$j][8];
		my $fcep=${ $allpath{$id} }[$j-1][16];
		my $bcsp=${ $allpath{$id} }[$j][15];
		my $disttwocontig=$bcsp-$fcep;
		my $fql=${ $allpath{$id} }[$j-1][10];
		my $fqs=${ $allpath{$id} }[$j-1][11];
		my $fqe=${ $allpath{$id} }[$j-1][12];
		my $bql=${ $allpath{$id} }[$j][10];
		my $bqs=${ $allpath{$id} }[$j][11];
		my $bqe=${ $allpath{$id} }[$j][12];

		my $uap=Unalignpart($fcd,$bcd,$fql,$fqs,$fqe,$bql,$bqs,$bqe);
		if($uap eq 1){
			# record two contigs information
			push (@pr,"$fc$fcd\_$bc$bcd");
			push (@pl,$disttwocontig);
			push (@pp,"$fcep\_$bcsp");

			# record two contigs blat information
			my @forward=();
			my @backward=();
			my $blats="";
			for(0..17){
				push(@forward,${$allpath{$id}}[$j-1][$_]);
				push(@backward,${$allpath{$id}}[$j][$_]);
			}
			$blats=join("\t",@forward)."\n".join("\t",@backward);
			push(@tcbr,$blats);	

			# check the contig graph
			my $ccg=CCG($fc,$bc,$fcd,$bcd);
			push(@pg,$ccg);
			

		# gap
		}elsif($disttwocontig > 10){
			# record two contigs information
			push (@pr,"$fc$fcd\_$bc$bcd");
			push (@pl,$disttwocontig);
			push (@pp,"$fcep\_$bcsp");

			# record two contigs blat information
			my @forward=();
			my @backward=();
			my $blats="";
			for(0..17){
				push(@forward,${$allpath{$id}}[$j-1][$_]);
				push(@backward,${$allpath{$id}}[$j][$_]);
			}
			$blats=join("\t",@forward)."\n".join("\t",@backward);
			push(@tcbr,$blats);	

			# check the contig graph
			my $ccg=CCG($fc,$bc,$fcd,$bcd);
			push(@pg,$ccg);

			#overlap
		}elsif($disttwocontig< -10){
			# record two contigs information
			push (@pr,"$fc$fcd\_$bc$bcd");
			push (@pl,$disttwocontig);
			push (@pp,"$fcep\_$bcsp");

			# record two contigs blat information
			my @forward=();
			my @backward=();
			my $blats="";
			for(0..17){
				push(@forward,${$allpath{$id}}[$j-1][$_]);
				push(@backward,${$allpath{$id}}[$j][$_]);
			}
			$blats=join("\t",@forward)."\n".join("\t",@backward);
			push(@tcbr,$blats);	

			# check the contig graph
			my $ccg=CCG($fc,$bc,$fcd,$bcd);
			push(@pg,$ccg);

		}
	}

	# print
	if($#pr >= 0){
		$badcontig++;
		print BADOUT "$id\t".join(',',@element)."\n";
		if($blat == 1){
			print BADOUT "\n";
		}
		for(0..$#pr){
			print BADOUT "$pr[$_]\t$pl[$_]\t$pp[$_]\t$pg[$_]\n";
			if($blat == 1){
				print BADOUT "$tcbr[$_]\n";
			}

		}
		print BADOUT "\n\n";
	}else{
		$goodcontig++;
		print GOODOUT "$id\t".join(',',@element)."\n";
	}
}
close GOODOUT;
close BADOUT;
print "total contigs $totalcontig\ngood contig $goodcontig\nbad contig $badcontig\n";

######################################################################

sub Unalignpart{
	my $fcd=shift(@_);
	my $bcd=shift(@_);
	my $fql=shift(@_);
	my $fqs=shift(@_);
	my $fqe=shift(@_);
	my $bql=shift(@_);
	my $bqs=shift(@_);
	my $bqe=shift(@_);
	my @q=();
	if($fcd eq '+'){
		my $q=($upb >= $fql-$fqe+1 ? 0 : 1);
		push(@q,$q);
	}elsif($fcd eq '-'){
		my $q=($upb >= $fqs ? 0 : 1);
		push(@q,$q);
	}

	if($bcd eq '+'){
		my $q=($upb >= $bqs ? 0 : 1);
		push(@q,$q);
	}elsif($bcd eq '-'){
		my $q=($upb >= $bql-$bqe+1 ? 0 : 1);
		push(@q,$q);
	}
	foreach(@q){
		if($_ eq 1){
			return 1;
			last;
		}
	}
}

sub CCG {
	my $fc  = shift(@_);
	my $bc  = shift(@_);
	my $fcd = shift(@_);# +-
	my $bcd = shift(@_);
	#ccp: contig connection possible
	my @fccp=();
	my @bccp=();
	my @ccr=();
	my @ccr123=();
	# ccr: contig connection result

	# find the next contig from forward
	if($fcd eq '+'){
		if($#{$cs3cs{$fc}}>=0){
			for(my $i=0;$i<=$#{ $cs3cs{$fc} };$i++){
				my $c=${ $cs3cs{$fc} }[$i][0];
				my $d=(${ $cs3cs{$fc} }[$i][1] eq 5 ? '+':'-'); # 5,3
				push(@fccp,"$c$d");
			}
		}

	}elsif($fcd eq '-'){
		if($#{$cs5cs{$fc}}>=0){
			for(my $i=0;$i<=$#{ $cs5cs{$fc} };$i++){
				my $c=${ $cs5cs{$fc} }[$i][0];
				my $d=(${ $cs5cs{$fc} }[$i][1] eq 5 ? '+': '-'); #5,3
				push(@fccp,"$c$d");
			}
		}
	}

	# find the next contig from backward
	if($bcd eq '+'){
		if($#{$cs5cs{$bc}}>=0){
			for(0..$#{ $cs5cs{$bc} }){
				my $c=${ $cs5cs{$bc} }[$_][0];
				my $d=(${ $cs5cs{$bc} }[$_][1] eq 3 ? '+' : '-');
				push(@bccp,"$c$d");
			}
		}

	}elsif($bcd eq '-'){
		if($#{$cs3cs{$bc}}>=0){
			for(0..$#{ $cs3cs{$bc} }){
				my $c=${ $cs3cs{$bc} }[$_][0];
				my $d=(${ $cs3cs{$bc} }[$_][1] eq 3 ? '+': '-');
				push(@bccp,"$c$d");
			}
		}
	}
	if(@fccp && @bccp){
		foreach my $b (@bccp){
			foreach my $f (@fccp){
				if($f eq $b){
					push(@ccr123,$f);
				}
			}
		}
	}
	
	my $result="";
	if(@fccp){
		foreach my $f (@fccp){
			if(@ccr123){
				foreach my $c2 (@ccr123){
					if($f ne "$bc$bcd" && $f ne $c2){
						push(@ccr,"$fc$fcd:$f:");
					}
				}
			}elsif($f ne "$bc$bcd"){
				push(@ccr,"$fc$fcd:$f:");
				
			}
		}
	}else{
		push(@ccr,"$fc$fcd:");
	}

	
	if(@fccp){
		foreach my $f (@fccp){
			if($f eq "$bc$bcd"){
				push(@ccr," $fc$fcd:$bc$bcd ");
			}
		}
	}

	foreach(@ccr123){
		push(@ccr," $fc$fcd:$_:$bc$bcd ");
	}

	if(@bccp){
		foreach my $b (@bccp){
			if(@ccr123){
				foreach my $c2 (@ccr123){
					if($b ne "$fc$fcd" && $b ne $c2){
						push(@ccr,":$b:$bc$bcd");
					}
				}
			}elsif($b ne "$fc$fcd"){
				push(@ccr,":$b:$bc$bcd");
			}
		}
	}else{
		push(@ccr,":$bc$bcd");
	}

	$result=join('|',@ccr);
	return $result;
}
