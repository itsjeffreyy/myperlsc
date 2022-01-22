#!/usr/bin/perl 

my $file= $ARGV[0];
my @DATA = ();
my $di = 0;
open(IN,$file);
while(<IN>)
{
	chomp;
	if(substr($_,0,1) ne "@")
	{
		my @A = split("\t",$_);
		if($A[2] ne "*")
		{
			$DATA[$di] = $_;
			$di++;
		}
	}
}
close(IN);

# load reference fasta file
my $file1= $ARGV[1];
my %SEQ = ();
my $Aname = "";
open(IN,$file1);
while(<IN>)
{
        chomp;
        if(substr($_,0,1) eq ">")
        {
                $Aname = substr($_,1);
        }
        else
        {
                $SEQ{$Aname} .= $_;
        }
}
close(IN);
#my $A = "CCCACGTGTGCCGCCTGCTGGGCATCTGCCTCACCTCCACCGTGCAGCTCATCACGCAGCTCATGCCCTTCGGCTGCCTCCTGGACTATGTCCGGGAACACAAAGACAATATTGGCTCCCAGTACCTGCTCAACTGGTGTGTGC";
#my $B = "CTCACCTCCACCGTGCAACTCATCACGCCGCCTCACCTCCACCGTGCAACTCATCACGCAGCTCATGCCCTTCGGCTGCCTCCTGGACTATGTCCGGGAACACAAAGGCAATATTGGCTCCCAGTACCTGCTCAACTGGTGTGTGC";
#my $AD = "13M2D10M4I119M";
my %sscount = ();
for(my $i=0;$i<$di;$i++)
{
	my @S1 = split("\t",$DATA[$i]);
       	my $len = length($S1[9]);
        my $POS1 = $S1[3];
        my $ref = $SEQ{$S1[2]};
	#print $S1[0]."\n";
        my @mark1 = split("\n",seq_rematch($ref,$S1[9],$S1[5],$POS1,$S1[10]));
       	my $msize1 = @mark1;
	my %HASH1 = ();
        my $nop = 0;
        my $var = "";
        my $pd = "";
        for(my $i=0;$i<$msize1;$i++)
        {
        	my @AB = split(",",$mark1[$i]);
               	if($AB[0]!=$nop)
                {
                	if($nop>0)
                       	{
                        	$HASH1{$nop} = $var."\t".$pd;
                        }
			#if((ord($AB[3])-$patscore)>=$threshold)
			#{
                        	$nop = $AB[0];
                                $var = $AB[1]."x".$AB[2];
                                $pd = $AB[3];
				#}
                }
                else
                {
			#if((ord($AB[3])-$patscore)>=$threshold)
			#{
                        	$var .= ";".$AB[1]."x".$AB[2];
                                $pd .= ";".$AB[3];
				#}
                }
          }
          if($nop>0)
          {
          	$HASH1{$nop} = $var."\t".$pd;
          }
	my $show_list = "";
               foreach my $key(keys%HASH1)
                {
                	my @PS = split("\t",$HASH1{$key});
                        $show_list .= $key."@".$PS[0]."&";
                }
		if(length($show_list)>1)
                {
			print $S1[0]."\t".$S1[2]."\t".$show_list."\n";
                }
}

open(OUT,">".$ARGV[2]);
foreach my $key(keys%sscount)
{
	print OUT $key."\t".$sscount{$key}."\n";
}
close(OUT);

############################################################

#seq_rematch($A,$B,$AD,"16723","CCCCCFFFCFFFGGGGGGGGGGHHHHGGGGGGGGCGFHHHHHHGGEFGGHHHGHHHHGHGGGHHHHHHHHHHHHGGGGGHHHHHHHFGHHHHHHHGGGGGGHHHGGHHHEFHHHHHHGHHGGHHHGHHHHFHHHFHHHGGHHGHHH");
sub seq_rematch
{
	my $SEQ1 = $_[0];
	my $SEQ2 = $_[1];
	my $ALN = $_[2];
	my $POS = $_[3];
	my $PRED = $_[4];
	my $New1 = "";
	my $New2 = "";
	my $NewPD = "";
	my $np1 = $POS-1;
	my $np2 = 0;
	while($ALN =~ /([0-9]+)([MSIDNHP]+)(.*)/)
        {
                if($2 eq "M")
                {
			$New1 .= substr($SEQ1,$np1,$1);
			$New2 .= substr($SEQ2,$np2,$1);
			$NewPD .= substr($PRED,$np2,$1);
			$np1 += $1;
			$np2 += $1;
			#print $2."\t".$1."\n".substr($SEQ1,$np1,$1)."\n".substr($SEQ2,$np2,$1)."\n";
                }
                if($2 eq "D")
                {
			for(my $i=0;$i<$1;$i++)
			{
				$New2 .= "-";
				$NewPD .= "I";
			}
			#print $2."\t".$1."\n".substr($SEQ1,$np1,$1)."\-----\n";
			$New1 .= substr($SEQ1,$np1,$1);
			$np1 += $1;
                }
		if($2 eq "I")
		{
			for(my $i=0;$i<$1;$i++)
                        {
                                $New1 .= "-";
                        }
                        $New2 .= substr($SEQ2,$np2,$1);
			#print $2."\t".$1."\n-----\n".substr($SEQ2,$np2,$1)."\n";
                        $np2 += $1;
		}
		if($2 eq "S")
		{
			#for(my $i=0;$i<$1;$i++)
			#{
			#        $New2 .= "-";
			#        $NewPD .= "I";
			#}
			$np2 += $1;
			#my $cac = substr($SEQ2,$np2,1);
			#my $st = $np1;
			#my $AS = "";
			#while(1)
			#{
			#	my $cat = substr($SEQ1,$st,1);
				#print $st."\t".$cat."\n";
				#	if($cat eq $cac)
				#	{
				#		$AS = $st;
				#		last;
				#}
				#$st++;
				#}
				#$np1 = $st;
			#print $np2."\t$cac\t".$np1."\tyyyy\n";

		}
                $ALN = $3;
        }
	my $alen = length($New1);
	my $nowp = 0;
	my $mark = "";
	my $end = $POS-1;
	#print $POS."\n".$New1."\n".$New2."\n";
	my $bound = 80;
	my $LGT = length($New1);
	for(my $i=0;$i<$LGT;$i=$i+$bound)
	{
		#print substr($New1,$i,$bound)."\n".substr($New2,$i,$bound)."\n******************\n";

	}



	for(my $i=0;$i<$alen;$i++)
	{
		my $cha = substr($New1,$i,1);
		my $chb = substr($New2,$i,1);
		my $NpD=0;
		$NpD = $nowp+$POS;
		if($cha ne $chb)
		{
			#print $nowp."\n";
                        $mark .= $NpD.",".$cha.",".$chb.",".substr($NewPD,$i,1)."\n";   
			if($cha ne "-" && $chb ne "-")
			{
				#if($NpD eq "0")
				#{
				#	print "1\t".$POS."\n";
				#}
				$sscount{$NpD}++;
				$nowp++;
				$end++;		
			}
			else
			{
				if($chb eq "-")
				{
					$nowp++;
					$end++;
				}
				else
				{

					$sscount{$NpD}++;
					#if($NpD eq "0")
					#{
					#	print "2\t".$POS."\n";
					#}
				}
			}
		}	
		else
		{
			if($cha ne "-")
			{
				$sscount{$NpD}++;
				#if($NpD eq "0")
				#{
				#	print "3\t".$POS."\n";
				#}
			}
			$end++;
			$nowp++;
		}		
	}
	return $mark;
	
}
