#!/usr/bin/perl -w 
#$d3=5;
#print "enter str\n";
#$str=<STDIN>;
print "enter number\n";
$num=<STDIN>;
chomp $num;
$a = ($num=~/^-(\d+)/ ? "$1\-": "$num\+");
print "$a\n";


#if($str eq YES && $d3 eq ($bcd eq '+' ?5:3)){
#	print "YES\t$d3\t$bcd\n";
#}else{
#	print "NOT\t$d3\t$bcd\n";
#}
