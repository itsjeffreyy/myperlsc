#!/usr/bin/perl -w
# writer : Jeffreyy Yu
# usage : CorrespondPoistion4AllpathctgNewblerctgViaBlat.pl .bbh > txt
# Note : bbh file is BlatBestHit.pl output.

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

# print data
foreach my $acid(keys %acpncp){
	my @acseqposi= sort {$a<=>$b}(keys %{$acpncp{$acid}});
	my $ncid="";
	my $j=1;
	while(! $ncid){
		$ncid=$acpncp{$acid}{$j}[0];
		$j++;
	}
	print ">ac_$acid\t$aclen{$acid}\tnc_$ncid\n";
	for(my $i=0;$i<@acseqposi;$i++){
		if($acpncp{$acid}{$acseqposi[$i]}[0]=~/\S+/){$ncid=$acpncp{$acid}{$acseqposi[$i]}[0];}
		if($i>0 && $ncid && $ncid ne $acpncp{$acid}{$acseqposi[$i-1]}[0]){print ">ac_$acid\t$aclen{$acid}\tnc_$ncid\n";}
		print "$acseqposi[$i]\t$acpncp{$acid}{$acseqposi[$i]}[1]\n";
	}
}
