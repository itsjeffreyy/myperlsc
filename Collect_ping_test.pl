#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

my $url = "www.google.com";
#my $url = "mirror.oxfordnanoportal.com";
my $count = 30;
my $time=0;
my $sleep=10;

GetOptions(
	"url|u=s" => \$url,
	"count|c=i" => \$count,
	"time|t=i" => \$time,
	"sleep|s=i" => \$sleep,
);

my $out_name="Ping_test_$url\_c$count\_t$time\_s$sleep\_".&Timestamp.".log";
open(OUT,">$out_name")|| die "Cannot write $out_name: $!\n";

# print title
#print "ping_ip\tTotal_packets\treceived\tpacket_gain\tpacket_loss\ttime\tmin\tavg\tmax\tmdev\ttimestamp\n";
print OUT "Timestamp\tPing_ip\tTotal_packets\tReceived\tPacket_loss\tTime\tMin\tAvg\tMax\tMdev\n";

my $t=0;
while ($time ==0 || $t < $time ){
	my $ping_r = `ping -c $count $url 2>&1`; 
	my @ping_r = split("\n",$ping_r); chomp @ping_r;
	#print Dumper @ping_r;
	#exit;
	
	if($ping_r =~ /^ping/){
		$ping_r[0]=~s/ /_/g;
		print OUT &Timestamp."\tERR:$ping_r[0]!!\n";
	
	}elsif($ping_r[0] =~ /^PING/){
		#print "MSG: $ping_r[0]\n";
		my $info=&Timestamp;
		$ping_r[0]=~s/ /_/g;
		$info .= "\t$ping_r[0]\t";
		
		#$ping_r[-3]
	
		#$ping_r[-2]
		my ($total,$recieved,$loss,$time)=(0,0,0,0);
		if( $ping_r[-2] =~ /(\d+) packets transmitted, (\d+) received, (\d+%) packet loss, time (\d+ms)/){
			($total,$recieved,$loss,$time)=($1,$2,$3,$4);
		}
		#my $perc= sprintf("%.2f",($recieved/$total*100));
		#print "$total\t$recieved\t$perc\%\t$loss\t$time\t";
		$info .= "$total\t$recieved\t$loss\t$time\t";
	
		#$ping_r[-1]
		my ($min,$avg,$max,$mdev)=(0,0,0,0);
		if($ping_r[-1] =~/rtt min\/avg\/max\/mdev = (\S+)\/(\S+)\/(\S+)\/(\S+) ms/){
			($min,$avg,$max,$mdev)=($1,$2,$3,$4);
		}
		$info .= "$min\t$avg\t$max\t$mdev";
		print OUT "$info\n";
	
	}else{
		print OUT &Timestamp."\tERR: Wrong!!\n";
	}
	sleep $sleep;

	if($time == 0){
		$t=0;
	}else{
		$t++;
	}
}

close OUT;

#########################################################
sub Timestamp{
        #my $datetimestamp = localtime(time);
        #return $datetimestamp;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();
	# time
	my $time = sprintf("%04d-%02d-%02d_%02d:%02d:%02d",$year+1900, $mon+1, $mday,$hour,$min,$sec);
	return $time;
}

