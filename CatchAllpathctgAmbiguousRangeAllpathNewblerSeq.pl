#!/usr/bin/perl -w
#writer : jeffreyy Yu
#usage :CatchAllpathctgAmbiguousRangeAllpathNewblerSeq.pl .bbh allpath_contig.fa newbler_contig.fa allpathctg_ambiguous.lst

use strict;
use Data::Dumper;

# load the bbh 
open(IN,"<$ARGV[0]")||die "open file $ARGV[0]:$!\n";
while(<IN>){
	if($_=~/target/){<IN>;last;}
}

my %acpncp=();
my %aclen=();
while(<IN>){
	my ($ac)=$_=~/^contig_(\d+)/;
	while(<IN>) {
		if($_ eq "\n") { last; }

		my @a=split("\t",$_); chomp $a[-1];
		# newbler contig
		my ($nc)=$a[9]=~/contig0+(\d+)/;
		$nc.=$a[8];
		# allpath contig length
		$aclen{$ac}=$a[14];
		# block length
		my @blen=split(",",$a[18]);

		# allpath contig information
		my @as=split(",",$a[20]);
		# allpath contig start
		my @astart=map($_+1,@as);
		# allpath contig end
		my @aend=();

		#newbler contig information
		my @ns=split(",",$a[19]);
		# newbler contig start
		my @nstart=map($_+1,@ns);
		# newbler contig end
		my @nend=();
		# store allpath contig block end and newbler contig block end
		for (my $i=0;$i< @blen;$i++){
			my $ae=$as[$i]+$blen[$i];
			push(@aend,$ae);

			my $ne=$ns[$i]+$blen[$i];
			push(@nend,$ne);
		}

		# record the position correlation in the block between allpath contig and newbler contig
		for (my $i=0;$i< @blen;$i++){
			my $aposi=$astart[$i];
			my $nposi=$nstart[$i];

			while($aposi <= $aend[$i] ){
				@{$acpncp{$ac}{$aposi}}=($nc,$nposi);
				$aposi++; $nposi++;
			}

		}

		# record the position correlation out of the block between allpath contig and newbler contig
		for (my $i=0;$i< $#blen;$i++){
			my $agaps=$astart[$i+1]-$aend[$i]-1;
			my $ngaps=$nstart[$i+1]-$nend[$i]-1;
		
			if($agaps != 0){
				my $aposi=$aend[$i]+1;
				my $nposi="$nend[$i]\>\<$nstart[$i+1]";
				while($aposi<$astart[$i+1]){
					@{$acpncp{$ac}{$aposi}}=($nc,$nposi);
					$aposi++;
				}
			}
		}

	}
}
close IN;

# load allpath contig sequence
open(IN,"<$ARGV[1]")||die "open file $ARGV[1]:$!\n";
my $acid="";
my %acseq=();
while(<IN>){
	chomp;
	if($_=~/^>contig_(\d+)/){
		$acid=$1; next;
	}
	$acseq{$acid}.=$_;
}
close IN;


# load newbler contig sequence
open(IN,"<$ARGV[2]")||die "open file $ARGV[2]:$!\n";
my $ncid="";
my %ncseq=();
while(<IN>){
	chomp;
	if($_=~/^>contig0+(\d+)/){
		$ncid="$1+"; next;
	}
	$ncseq{$ncid}.=$_;
}
close IN;

foreach my $ncid (keys %ncseq){
	my $seq=reverse $ncseq{$ncid};
	$seq=~tr/ATCGatcg/TAGCtagc/;
	$ncid=~tr/+-/-+/;
	$ncseq{$ncid}=$seq;
}

# load the allpath contig ambiguous list and output
open(IN,"<$ARGV[3]")||die"open file $ARGV[3]:$!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	my ($acid)=$a[0]=~/ac_(\d+)/;
	my @arange=split("><",$a[1]);
	my @option=();
	for my $i (2..$#a){
		push(@option,$a[$i]);
	}
	my $aseq=uc(substr($acseq{$acid},$arange[0],$arange[1]-$arange[0]-1));
	if(!$aseq){$aseq=".";}
	my @ncid=();
	my @nrange=();
	my $nseq="";

	# if the allpath contig not align to newbler contig
	if(!$acpncp{$acid}{$arange[0]}[0] && !$acpncp{$acid}{$arange[1]}[0]){
		 @ncid=("-","-"); @nrange=("-","-"); $nseq="-";

	# if the newbler contig have a gap
	}elsif($acpncp{$acid}{$arange[0]}[1]=~/\>\</ || $acpncp{$acid}{$arange[1]}[1]=~/\>\</){
		@ncid=($acpncp{$acid}{$arange[0]}[0],$acpncp{$acid}{$arange[1]}[0]);
		
		for($arange[0]+1..$arange[1]-1){
			if($acpncp{$acid}{$_}[1]=~/></){
				$nseq.=".";
			}else{
				$nseq.=uc(substr($ncseq{ $acpncp{$acid}{$_}[0] },$acpncp{$acid}{$_}[1],1));
			}
		}
		my $start=""; my $end="";
		if($acpncp{$acid}{$arange[0]}[1]=~/(\d+)\>\</){$start=$1;}else{$start=$acpncp{$acid}{$arange[0]}[1];}
		if($acpncp{$acid}{$arange[1]}[1]=~/\>\<(\d+)/){$end=$1;}else{$end=$acpncp{$acid}{$arange[1]}[1];}
		@nrange=("$start","$end");

	# the allpath contig align to newbler contig
	}else{
		@ncid=($acpncp{$acid}{$arange[0]}[0],$acpncp{$acid}{$arange[1]}[0]);
		@nrange=("$acpncp{$acid}{$arange[0]}[1]","$acpncp{$acid}{$arange[1]}[1]");

		for($arange[0]+1..$arange[1]-1){
			if(!$acpncp{$acid}{$_}[0]){
				$nseq.=".";
			}elsif($acpncp{$acid}{$_}[1]=~/\>\</){
				$nseq.=".";
			}else{
				$nseq.=uc(substr($ncseq{ $acpncp{$acid}{$_}[0] },$acpncp{$acid}{$_}[1]-1,1));
			}
		}
	}
	if(!$nseq){$nseq=".";}
#	print "ac_$acid\t$arange[0],$arange[1]\t$aseq\tnc_$ncid\t$nrange[0],$nrange[1]\t$nseq\t".join(",",@option)."\n";
	print "ac_$acid\t$arange[0]><$arange[1]\t$aseq\t\|".join(",",@option)."\|\tnc_$ncid[0]\#$nrange[0]><nc_$ncid[1]\#$nrange[1]\t$nseq\n";
}
close IN;

# print time
# my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst)=localtime;
# print "\nfile product time\n",scalar localtime,"\n";
