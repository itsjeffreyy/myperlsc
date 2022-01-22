#!/usr/bin/perl
my $file1 = $ARGV[0];#coverage
my $file2 = $ARGV[1];#step1
my $file3 = $ARGV[2];#genome fa
my $depth = $ARGV[3];#depth threshold
my $ratio = 0.2;
my $chr = "";
my %TO = ();
my %MUTANT = ();
my $SEQ = "";
open(IN,$file3);
while(<IN>)
{
        chomp;
	if(substr($_,0,1) ne ">")
        {
                $SEQ .= uc($_);
        }
}
close(IN);

open(IN,$file1);
while(<IN>)
{
	chomp;
	my @tmp = split("\t",$_);
	$TO{$tmp[0]} = $tmp[1];
}
close(IN);
open(IN,$file2);
while(<IN>)
{
	chomp;
	my @tmp = split("\t",$_);
	$chr = $tmp[1];
	my @MU = split("&",$tmp[2]);
	my $musize = @MU;
	my %blist = ();
	my $dlist = "";
	for(my $i=0;$i<$musize;$i++)
	{
		my @B = split("@",$MU[$i]);
		my @C = split(";",$B[1]);
		my $csize = @C;
		if($csize>1)
		{
			my $list = "";
			my $mark = 0;
			for(my $j=0;$j<$csize;$j++)
			{
				my @D = split("x",$C[$j]);
				$list .= $D[1];
				$mark = 1;
			}
			if($mark==0)
			{
			}
			else
			{
				$MUTANT{$B[0]} .= "-x".$list.";";
			}
		}
		else
		{
			my @DC = split("x",$B[1]);
			if($DC[1] eq "-")
			{
				$dlist .= $DC[0].",".$B[0].";";
                                $blist{$B[0]} = 1;
			}
			else
			{
				$MUTANT{$B[0]} .= $B[1].";";
			}
		}
	}
	my @Ablist = split(";",$dlist);
        my $absize = @Ablist;
       	my @LOC = ();
       	my @MUS = ();
       	my @LRK = ();
       	for(my $k=0;$k<$absize;$k++)
        {
        	my @BCD = split(",",$Ablist[$k]);
               	$LOC[$k] = $BCD[1];
               	$MUS[$k] = $BCD[0];
                $LRK[$k] = 0;
       	}
        for(my $k=0;$k<$absize;$k++)
       	{
        	for(my $g=$k+1;$g<$absize;$g++)
                {
                	if($LOC[$k]>$LOC[$g])
                        {
                        	my $T1 = $LOC[$k];
                                my $T2 = $MUS[$k];
                                $LOC[$k] = $LOC[$g];
                                $MUS[$k] = $MUS[$g];
                                $LOC[$g] = $T1;
                                $MUS[$g] = $T2;
                        }
                }
        }
	my $NODP = "";
	my $MSS = "";
	for(my $k=0;$k<$absize;$k++)
        {
        	if($LRK[$k]==0)
                {
                	$NODP = $LOC[$k];
                        $MSS = $MUS[$k];
                        my $CNP = $LOC[$k];
                        for(my $g=$k+1;$g<$absize;$g++)
                        {
                        	if($LRK[$g]==0)
                                {
                                	if($LOC[$g]-$CNP==1)
                                        {
                                        	$MSS .= $MUS[$g];
                                                $CNP = $LOC[$g];
                                                $LRK[$g] = 1;
                                        }
                                        else
                                        {
                                        	$MUTANT{$NODP} .= $MSS."x-;";
                                                $NODP = $LOC[$g];
                                                $MSS = $MUS[$g];
                                                $CNP = $LOC[$g];
                                                last;
                                        }
                               	}
                        }
                	$LRK[$k] = 1;
               }
	}
	if($NODP ne "")
	{
		$MUTANT{$NODP} .= $MSS."x-;";
	}
}
close(IN);

foreach my $key(keys%MUTANT)
{
	my @pattern = split(";",$MUTANT{$key});
	my $psize = @pattern;
	my %hash = ();
	for(my $i=0;$i<$psize;$i++)
	{
		$hash{$pattern[$i]}++;
	}
	if($TO{$key}>=$depth)
	{
		my $Tmp = "$chr";
		foreach my $key1(keys%hash)
		{
			my @ABC = split("x",$key1);
			my $var = "";
			my $ori = substr($SEQ,$key-1,1);
			my $loc = $key;
			if($ABC[1] eq "-" || $ABC[0] eq "-")
			{
				if($ABC[0] eq "-")
				{
					$ori = substr($SEQ,$key-2,1);
					$var = $ori.$ABC[1];
					$loc = $key-1;
					
				}
				if($ABC[1] eq "-")
				{
					$ori = substr($SEQ,$key-2,1).$ABC[0];
					$var = substr($SEQ,$key-2,1);
					$loc = $key-1;	
					#$ori = $ABC[0];
				}	
			}
			else
			{
				$var = $ABC[1];
			}
			if(($hash{$key1}/$TO{$key})>=$ratio && $var ne "")
			{
				print $Tmp."\t".$loc."\t".$ori."\t".$var."\t".$TO{$key}."\t".$hash{$key1}."\n";
			}
			#$Total[$ti] = $Tmp."\t".$ori."\t".$var."\t".$hash{$key1};
			#$loc[$ti] = $key;
			#$ti++;
		}
	}
}
