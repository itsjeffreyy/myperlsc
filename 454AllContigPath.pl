#!/usr/bin/perl -w
# usage : 454AllContigPath.pl [option] 454ContigGraph.txt contig1 contig2
# ex    : 454AllContigPath.pl -plmax 1000 -pcnmax 10 454ContigGraph.txt 273- 145+

use strict;
use Getopt::Long;


# set parameters

my $plmax=100000;
my $pcnmax=30;

GetOptions(
	   "plmax=i" => \$plmax,
	   "pcnmax=i" => \$pcnmax
	   );


# load 454 contig graph
# csns  : contig strand number strand (number is the abbreviation of contig)
# nscs  : number strand contig strand
# cslen : contig strand length
# cs3cs : contig strand 3' end contig strand
# csslq : contig strand self-loop Q

my %csns=();
my %nscs=();
my %cslen=();
my %cs3cs=();
my %csloop=();
my %cslooplen=();

Load454ContigGraph($ARGV[0]);


# depth first search

# connect contigs according to their aligned position on optical map
# path         : path (i.e., contigs on the path)
# pathlen      : path length (i.e., total length of contigs on the path) 
# pathcontig   : path contig (i.e., total number of contigs on the path)
# csonpathq    : contig strand on path Q
# looppath     : loop path
# foundpath    : path found

my @path=();
my %csonpathq=();
my $pl=0;
my $pcn=0;
my @allpath=();
my %pathlen=();

my $lcs = ($ARGV[1]=~/contig/) ? $ARGV[1] : $nscs{$ARGV[1]};
my $rcs = ($ARGV[2]=~/contig/) ? $ARGV[2] : $nscs{$ARGV[2]};

$plmax+=($cslen{$lcs}+$cslen{$rcs});

DepthFirstSearch($lcs,$rcs,$pcnmax,$plmax);


# insert loop path to match the desired path len

if(@allpath) {
    foreach my $p (@allpath) {
	$pathlen{$p}-=($cslen{$lcs}+$cslen{$rcs});
	print "path: $p\t$pathlen{$p}\n";

	my $lendiff=$plmax-$pathlen{$p};
	my @cs=split(":",$p);
	for(my $i=0;$i<@cs;$i++) {
	    if($csloop{$cs[$i]}) {
		my $n=int($lendiff/$cslooplen{$cs[$i]}+0.5);
		if($n>0) {
		    my $lp=join(":",@cs[0..$i]);
		    $lp.=":".join(":",map($csloop{$cs[$i]},(1..$n)));
		    if($i<$#cs) {
			$lp.=":".join(":",@cs[($i+1)..$#cs]);
		    }
		    my $lpl=$pathlen{$p}+$n*$cslooplen{$cs[$i]};
		    print "looppath: $lp\t$lpl\n";
		}
	    }
	}
    }
}



################################################################################


sub RC {
    $_[0]=~tr/+-/-+/;
    return $_[0];
}


sub Load454ContigGraph {
    my $fn=shift(@_);
    open(IN,"<$fn") || die "open $fn: $!\n";
    
    # load contig info
    while(<IN>) {
        if($_=~/^C/) {
            seek(IN,-length($_),1);
            last;
        }
        my @a=split("\t",$_); chomp $a[-1];

        $csns{"$a[1]+"}="$a[0]+";
        $csns{"$a[1]-"}="$a[0]-";
        $nscs{"$a[0]+"}="$a[1]+";
        $nscs{"$a[0]-"}="$a[1]-";
        $cslen{"$a[1]+"}=$a[2];
        $cslen{"$a[1]-"}=$a[2];
    }

    # load contig connections
    while(<IN>) {
        if($_!~/^C/) { last; }
        my @a=split("\t",$_); chomp $a[-1];

        my $lns = ($a[2]=~/3/) ? "$a[1]+" : "$a[1]-";
        my $rns = ($a[4]=~/5/) ? "$a[3]+" : "$a[3]-";
        my $lcs=$nscs{$lns};
        my $rcs=$nscs{$rns};
        push(@{$cs3cs{$lcs}},$rcs);
    
        my $tns=$lns;
        $lns=RC($rns);
        $rns=RC($tns);
        $lcs=$nscs{$lns};
        $rcs=$nscs{$rns};
        push(@{$cs3cs{$lcs}},$rcs);
    }
    close IN;

    # record and remove self-loop
    foreach my $cs (keys %cs3cs) {
        my @tmp=grep($_ eq $cs,@{$cs3cs{$cs}});
        if(@tmp) {
	    $csloop{$cs}=$cs;
	    $cslooplen{$cs}=$cslen{$cs};
            @{$cs3cs{$cs}}=grep($_ ne $cs,@{$cs3cs{$cs}});
        }
    }
}


# node : contig + strand
# path : an array of nodes on the path including the current node

sub DepthFirstSearch {
    my $scs=shift(@_);
    my $ecs=shift(@_);
    my $pcnmax=shift(@_);
    my $plmax=shift(@_);
    
    # push the current node into path
    push(@path,$scs);
    $csonpathq{$scs}=1;
    $pcn++;
    $pl+=$cslen{$scs};

    # if the path length and path contig number do not exceed their maximums
    if($pcn<=$pcnmax && $pl<=$plmax) {

	# if the starting node is the end node, record the path 
	if($scs eq $ecs) {
	    my $p=join(":",@path);
	    push(@allpath,$p);
	    $pathlen{$p}=$pl;
	    
	# if the currnt node is not the end node, and it has child node(s)
	} elsif($cs3cs{$scs}) {
	    
	    # explore all the child nodes
	    foreach my $cs (@{$cs3cs{$scs}}) {
		
		# if the child node forms a loop, i.e., the child node is on the path 
		if($csonpathq{$cs}) {
		    my $i=ArrayIndex(@path,$cs);
		    my @loopcs=(@path[($i+1)..$#path],$cs);
		    $csloop{$cs}=join(":",@loopcs);
		    $cslooplen{$cs}=Total(map($cslen{$_},@loopcs));
		    next;
		
		# if the child node is not on the path, recursively DFS from the child node
		} else {
		    DepthFirstSearch($cs,$ecs,$pcnmax,$plmax);
		}
	    }
	}
    }

    # pop the current node from path
    pop(@path);
    delete $csonpathq{$scs};
    $pcn--;
    $pl-=$cslen{$scs};
}


sub ArrayIndex {
    my @a=@_;
    my $e=pop(@a);
    for(my $i=0;$i<@a;$i++) {
        if($a[$i] eq $e) {
            return $i;
        }
    }
    return -1;
}


sub Total {
    my $sum=0;
    foreach my $n (@_) {
	$sum+=$n;
    }
    return $sum;
}
