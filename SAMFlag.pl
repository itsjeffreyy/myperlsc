#!/usr/bin/perl -w
use strict;
use Data::Dumper;
# usage: SAMFlag.pl flag_number

my %samtools_explan= (
1 => 'template having multiple segments in sequencing',
2 => 'each segment properly aligned according to the aligner',
4 => 'segment unmapped',
8 => 'next segment in the template unmapped',
16 => 'SEQ being reverse complementedSEQ being reverse complemented',
32 => 'SEQ of the next segment in the template being reverse complemented',
64 => 'the first segment in the template',
128 => 'the last segment in the template',
256 => 'secondary alignment',
512 =>  'not passing filters, such as platform/vendor quality controls',
1024 => 'PCR or optical duplicate',
2048 => 'supplementary alignment'
);

my %picard_explan= (
1 => 'read paired',
2 => 'read mapped in proper pair',
4 => 'read unmapped',
8 => 'mate unmapped',
16 => 'read reverse strand',
32 => 'mate reverse strand',
64 => 'first in pair',
128 => 'second in pair',
256 => 'not primary alignment',
512 => 'read fails platform/vendor quality checks',
1024 => 'read is PCR or optical duplicate',
2048 => 'supplementary alignment'
);


my $flag=$ARGV[0];

my @bits=split('\+',&flag_assembly($flag));
print "$flag\t".join(", ",@bits)."\n";
foreach (@bits){
	if(!$picard_explan{$_}){next;}
	print "$_\t$picard_explan{$_}\n";
}
# paired
my $paired_flag=&flag_pair($flag);
print "\npaired: $paired_flag\n";
my @pair_bits=split('\+',&flag_assembly(&flag_pair($flag)));
print "$paired_flag\t".join(", ",@pair_bits)."\n";
foreach (@pair_bits){
	if(!$picard_explan{$_}){next;}
	print "$_\t$picard_explan{$_}\n";
}


############################################################
sub flag_assembly(){
	# a*2^0 + b*2^1 + c*2^2 + d*2^3 + e*2^4 + f*2^5 + g*2^6 + h*2^7 + i*2^8 + j*2^9 + k*2^10 + l*2^11
	my $n=12;
	my @a=();
	my @b=();
	map {push(@a,0)} (1..$n);
	map {push(@b,2**($_-1))} (1..$n);
	my $biggest=0;
	map {$biggest+=($b[$_-1])} (1..$n);
	
	#input flag number 
	my $flag=shift(@_);
	
	# check flag number 
	if ($flag > $biggest){
		print STDERR "ERR: wrong flag number. Biggest is $biggest\n";
		exit 1;
	}
	
	# find the assembly
	my $limit=0;
	while($flag > 0){
		for(my $i=1; $i < $#b+1; $i++){
			if($flag < $b[$i-1]){
				last;
			}
			$limit=$i;
		}
		$a[$limit-1]=1;
		$flag-=$b[$limit-1];
	}
	
	
	#return assembly 
	my @ab=();
	for(my $i=0; $i <= $#a;$i++){
		if($a[$i]==1){
			push(@ab,$b[$i]);
		}
	}
	return join("+",@ab);
}

sub flag_pair(){
	# (99, 147), (163, 83) are properly mapped read pairs within a defined insert size
	my $flag=shift(@_);
	my @bits=split('\+',&flag_assembly($flag));
	if($bits[0] != 1){
		exit;
	}
	
	my $pair_flag=0;
	foreach my $b (@bits){
		if($b == 4){
			$pair_flag+=8;
		}elsif($b == 8){
			$pair_flag+=4;
		}elsif($b == 16){
			$pair_flag+=32;
		}elsif($b == 32){
			$pair_flag+=16;
		}elsif($b == 64){
			$pair_flag+=128;
		}elsif($b == 128){
			$pair_flag+=64;
		}else{
			$pair_flag+=$b;
		}
	}
	return $pair_flag;
}
