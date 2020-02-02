#!/usr/bin/perl -w
# writer: Jeffreyy Yu
# usage: SD.pl file.LenDis
#Standard Deviation

use strict;
use Data::Dumper;
use Getopt::Long;
# bn: bin numbers
my %la=();
my $bn=50;

GetOptions(
	"histogram|h=i" => \$bn,
	);

my $numbers=$ARGV[0];
my @numbers=split(",",$numbers);

# count mean
my $all=0;
my $account=@numbers;
my $mean=0;
foreach (@numbers){
	$all+=$_;
}
$mean=$all/$account;

# count standard deviation
my $var=0;
foreach(@numbers){
	$var+=($_-$mean)**2;
}

my $sd=0;
$sd=($var/$account)**0.5;
printf ("Account:%d\nMean:%.2f\nSD:%.2f\n",$account,$mean,$sd);

#histogram
@numbers=sort{$a<=>$b}@numbers;

#bin counts
my $min=$numbers[0];
my $max=$numbers[-1];
my $bs=($max-$min)/$bn;
my %in=();
map($in{int(($_-$min)/$bs)}++,@numbers);

my %histogram=();
print "$min\n";
for(my $i=0;$i<=$bn;$i++) {
	my $n=sprintf("%.2f",$min+($i+0.5)*$bs);
	if(!$in{$i}) { $in{$i}=0; }
	$histogram{$n}=$in{$i};
	print "$n\t$in{$i}\n";
}
print "$max\n";
my %peak=();
foreach my $key (sort{$histogram{$b}<=>$histogram{$a}} keys %histogram){
	$peak{$key}=$histogram{$key};
}
