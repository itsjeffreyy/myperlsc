#!/usr/bin/perl -w
# writer : Jeffreyy Yu
# usage : DFS.pl graph start end
use strict;
use Data::Dumper;

# load graph and contigs length
my $s=$ARGV[1];
my $e=$ARGV[2];
my %nc=();
open(IN,"<$ARGV[0]")|| die "open file $ARGV[0]:$!\n";
while(<IN>){
	chomp;
	my @a=split("\t",$_);
	push (@{$nc{ $a[0] }},$a[1]);
}
close IN;

my @allpath=();
my @path=();
DFS($s,$e);
print join("\n",@allpath)."\n";

############################################################

sub DFS{
	my $s=shift(@_);
	my $e=shift(@_);

	if(OnPath($s)==1){
		return;
	}
	push(@path,$s);
	
	if($s eq $e){
		push(@allpath,join(":",@path));
		pop(@path);
		return;
	}

	foreach my $c (@{ $nc{$s} }){
		DFS($c,$e);
	}
	pop(@path);
}


sub OnPath{
	$s=shift(@_);
	foreach (@path){
		if($_ eq $s){
			return 1;
		}
	}
	return 0;
}
