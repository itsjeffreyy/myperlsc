#!/usr/bin/perl -w
# usage : 

use strict;


# load bbh
# acnc : allpath contig newbler contig

my %acnc=();
#my %acncr=();

open(IN,"<$ARGV[0]") || die "open $ARGV[0]: $!\n";

while(<IN>) {
    if($_=~/^tar/) { <IN>; last; }
}

while(<IN>) {
    my ($ac)=$_=~/^(contig_\d+)/;
    while(<IN>) {
	if($_ eq "\n") { last; }
	my @a=split("\t",$_); chomp $a[-1];
	push(@{$acnc{$ac}},"$a[9]$a[8]");
    }
}
close IN;


# load contig graph
# nnc : number newbler contig
# nc3nc : newbler contig 3' end newbler contig
# lc    : left contig
# rc    : right contig

my %nnc=();
my %nclen=();
my %nccov=();
my %nc3nc=();
my %nc5nc=();
my %ncuq=();

open(IN,"<$ARGV[1]") || die "open $ARGV[1]: $!\n";

while(<IN>) {
    if($_!~/^\d/) {
	seek(IN,-length($_),1);
	last;
    }
    my @a=split("\t",$_); chomp $a[-1];
    $nnc{$a[0]}=$a[1];
    $nclen{"$a[1]+"}=$a[2];
    $nclen{"$a[1]-"}=$a[2];
    $nccov{"$a[1]+"}=$a[3];
    $nccov{"$a[1]-"}=$a[3];
}

while(<IN>) {
    if($_!~/^C/) { last; }
    my @a=split("\t",$_); chomp $a[-1];
    my $lc = ($a[2] eq "3'") ? "$nnc{$a[1]}+" : "$nnc{$a[1]}-";
    my $rc = ($a[4] eq "5'") ? "$nnc{$a[3]}+" : "$nnc{$a[3]}-";
    push(@{$nc3nc{$lc}},$rc);
    push(@{$nc5nc{$rc}},$lc);
    my $tc=$lc;
    $lc=RC($rc);
    $rc=RC($tc);
    push(@{$nc3nc{$lc}},$rc);
    push(@{$nc5nc{$rc}},$lc);
}
close IN;

foreach my $nc (keys %nclen) {
    if(!$nc3nc{$nc}) { @{$nc3nc{$nc}}=(); }
    if(!$nc5nc{$nc}) { @{$nc5nc{$nc}}=(); }
}

foreach my $nc (keys %nclen) {
    if($nclen{$nc}>6000 || $nccov{$nc}<30) {
	$ncuq{$nc}=1;
    } elsif(@{$nc3nc{$nc}}==1 && @{$nc5nc{$nc}}==1) {
	$ncuq{$nc}=1;
    } else {
	$ncuq{$nc}=0;
    }
}


# load paired-end bridges

my %pebs=();
my %penc3nc=();
my %penc5nc=();

open(IN,"<$ARGV[2]") || die "open $ARGV[2]: $!\n";

while(<IN>) {
    my @a=split("\t",$_); chomp $a[-1];
    $pebs{$a[0]}=$a[1];
    $pebs{RCB($a[0])}=$a[1];
    my ($lc,$rc)=split(":",$a[0]);
    push(@{$penc3nc{$lc}},$rc);
    push(@{$penc5nc{$rc}},$lc);
    my $tc=$lc;
    $lc=RC($rc);
    $rc=RC($tc);
    push(@{$penc3nc{$lc}},$rc);
    push(@{$penc5nc{$rc}},$lc);
}
close IN;

foreach my $nc (keys %nclen) {
    if(!$penc3nc{$nc}) {
	@{$penc3nc{$nc}}=();
    } else {
	@{$penc3nc{$nc}}=Unique(@{$penc3nc{$nc}});
    }
    if(!$penc5nc{$nc}) {
	@{$penc5nc{$nc}}=();
    } else {
	@{$penc5nc{$nc}}=Unique(@{$penc5nc{$nc}});
    }
}


# load mate-pair bridges

my %mpbs=();
my %mpnc3nc=();
my %mpnc5nc=();

open(IN,"<$ARGV[3]") || die "open $ARGV[3]: $!\n";

while(<IN>) {
    my @a=split("\t",$_); chomp $a[-1];
    if($a[1]<10) {
	next;
    }
    $mpbs{$a[0]}=$a[1];
    $mpbs{RCB($a[0])}=$a[1];
    my ($lc,$rc)=split(":",$a[0]);
    push(@{$mpnc3nc{$lc}},$rc);
    push(@{$mpnc5nc{$rc}},$lc);
    my $tc=$lc;
    $lc=RC($rc);
    $rc=RC($tc);
    push(@{$mpnc3nc{$lc}},$rc);
    push(@{$mpnc5nc{$rc}},$lc);
}
close IN;

foreach my $nc (keys %nclen) {
    if(!$mpnc3nc{$nc}) {
	@{$mpnc3nc{$nc}}=();
    } else {
	@{$mpnc3nc{$nc}}=Unique(@{$mpnc3nc{$nc}});
    }
    if(!$mpnc5nc{$nc}) {
	@{$mpnc5nc{$nc}}=();
    } else {
	@{$mpnc5nc{$nc}}=Unique(@{$mpnc5nc{$nc}});
    }
}


# check allpath contig
# acerrjunc : allpath contig error junction

my %acerrjunc=();

foreach my $ac (keys %acnc) {
    @{$acerrjunc{$ac}}=();
    
    # if there is only one contig, then it is OK
    my @nc=@{$acnc{$ac}};
    if(@nc==1) {
	next;
    }

    # if there are two or more contigs, check the connection of the first two contigs
    # if the first two contigs are not connected in 454 contig graph, check PE
    if(ElementQ(@{$nc3nc{$nc[0]}},$nc[1])==0) {
	
	# if PE does not support the connection, output error
	if(ElementQ(@{$penc3nc{$nc[0]}},$nc[1])==0) {	
	    push(@{$acerrjunc{$ac}},"$nc[0]:$nc[1]");
	}
    }
    
    # from the second contig, check the connection to the next contig
    for(my $i=1;$i<(@nc-1);$i++) {
	    
	# if there is contig at the 3' end
	if(@{$nc3nc{$nc[$i]}}>0) {
	   
	    # if the next contig is not at the 3' end, output error
	    if(ElementQ(@{$nc3nc{$nc[$i]}},$nc[$i+1])==0) {
		push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		next;
	    }
	    
	    # if the next contig is not unique at the 3' end, check MP
	    if(@{$nc3nc{$nc[$i]}}>1) {
		
		# first find the unique contig before
		my $lunc="";
		if($nclen{$nc[$i]}>10000) {
		    $lunc=$nc[$i];
		} else {
		    for(my $j=$i-1;$j>=0;$j--) {
			if($ncuq{$nc[$j]}==1) { $lunc=$nc[$j]; last; }
		    }
		}
		
		# if there is no unique contig before and after, output error
		if(!$lunc) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# get the contigs at the 3' end is supported by MP
		my @nc3=();
		foreach my $nc3 (@{$nc3nc{$nc[$i]}}) {
		    if(ElementQ(@{$mpnc3nc{$lunc}},$nc3)==1) {
			push(@nc3,$nc3);
		    }
		}

		# if no contig at the 3' end is supported by MP, output error
		if(@nc3==0) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# if only one contig at the 3' end is supported by MP, but not the next one, output error
		if(@nc3==1 && $nc3[0] ne $nc[$i+1]) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# if more than one contig at the 3' end is supported by MP, check MP support
		# if the support of the next contig is less than 10 fold of the second supported contig, output error
		if(@nc3>=2) {
		    @nc3=sort{$mpbs{"$lunc:$b"}<=>$mpbs{"$lunc:$a"}}@nc3;
		    my $mpbsr=$mpbs{"$lunc:$nc3[0]"}/$mpbs{"$lunc:$nc3[1]"};
		    if($mpbsr<10 || $nc3[0] ne $nc[$i+1]) {
			push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    }
		}
	    }

	# if there is no contig at 3' end
	} else {

#	    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
#	    next;

	    # if the next contig is not at the 3' end, output error
	    if(ElementQ(@{$penc3nc{$nc[$i]}},$nc[$i+1])==0) {
		push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		next;
	    }
	    
	    # if the next contig is not unique at the 3' end, check MP
	    if(@{$penc3nc{$nc[$i]}}>1) {
		
		# first find the unique contig before
		my $lunc="";
		if($nclen{$nc[$i]}>10000) {
		    $lunc=$nc[$i];
		} else {
		    for(my $j=$i-1;$j>=0;$j--) {
			if($ncuq{$nc[$j]}==1) { $lunc=$nc[$j]; last; }
		    }
		}
		
		# if there is no unique contig before and after, output error
		if(!$lunc) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# get the contigs at the 3' end is supported by MP
		my @nc3=();
		foreach my $nc3 (@{$penc3nc{$nc[$i]}}) {
		    if(ElementQ(@{$mpnc3nc{$lunc}},$nc3)==1) {
			push(@nc3,$nc3);
		    }
		}

		# if no contig at the 3' end is supported by MP, output error
		if(@nc3==0) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# if only one contig at the 3' end is supported by MP, but not the next one, output error
		if(@nc3==1 && $nc3[0] ne $nc[$i+1]) {
		    push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    next;
		}

		# if more than one contig at the 3' end is supported by MP, check MP support
		# if the support of the next contig is less than 10 fold of the second supported contig, output error
		if(@nc3>=2) {
		    @nc3=sort{$mpbs{"$lunc:$b"}<=>$mpbs{"$lunc:$a"}}@nc3;
		    my $mpbsr=$mpbs{"$lunc:$nc3[0]"}/$mpbs{"$lunc:$nc3[1]"};
		    if($mpbsr<10 || $nc3[0] ne $nc[$i+1]) {
			push(@{$acerrjunc{$ac}},"$nc[$i]:$nc[$i+1]");
		    }
		}
	    }
	}
    }
}


# output error allpath contigs

foreach my $ac (keys %acnc) {
    print "$ac\t".join(",",@{$acerrjunc{$ac}})."\n";
}




######################################################################


sub ElementQ {
    my $e=pop(@_);
    my @a=@_;
    my %eq=();
    $eq{$e}=0;
    map($eq{$_}=1,@a);
    return $eq{$e};
}


sub RC {
    my $cs=shift(@_);
    $cs=~tr/+-/-+/;
    return $cs;
}


sub RCB {
    my @c=split(":",$_[0]);
    my $b=RC($c[1]).":".RC($c[0]);
    return $b;
}


sub Unique {
    my %seen=();
    return grep(!$seen{$_}++,@_);
}
