#!/usr/bin/perl -w 
use strict;
use Data::Dumper;
use Getopt::Long;

my $help;
my ($show_bc_num);
my $dir_path="";

GetOptions(
	"help|h" => \$help,
	"show_bc|s=i" => \$show_bc_num,
	"dir|d=s" => \$dir_path,

);

if($help){
	print <<EOF;

Usage:
	Guppy_barcoder_statistic_rebasecalling.pl -d path/to/guppy_barcoder/output_dir
Option:
	-show_bc|-s : Show the number of barcodes [int. number]
	-help|-h    : Show this message.
	-dir|-d     : The directory of barcoder 


EOF
	exit;
}

# check path
my $barcoder_path;
if($dir_path){
	$barcoder_path=$dir_path;
}else{
	$barcoder_path=$ARGV[-1];
}

if(! -e $barcoder_path){
	print"ERR: $barcoder_path directory not exist!\n"; exit;
}

# setup the barcode number
my @bcs=();
if($show_bc_num){
	for (my $i=1;$i <= $show_bc_num;$i++){
		my $num=sprintf("%02d",$i);
		push(@bcs,"barcode$num");
	}
	push(@bcs,"unclassified");
}

# get barcode directory list
#opendir DIR,"$barcoder_path" || die "Cannot open $barcoder_path: $!\n";
#my @barcode_dir=grep{$_=~/^barcode/} readdir DIR;
#closedir DIR;
my @list_pass=`ls $barcoder_path/pass/`; chomp @list_pass;
my @list_fail=`ls $barcoder_path/fail/`; chomp @list_fail;
my %list=();
foreach (@list_pass){
	$list{$_}=1;
}
foreach (@list_fail){
	$list{$_}=1;
}
my @list=sort(keys %list);
my @barcode_dir = grep {$_=~/(?:^barcode|^BC)/} @list;

# check unclassified folder
if(-e "$barcoder_path/pass/unclassified" || -e "$barcoder_path/fail/unclassified"){
	push(@barcode_dir,'unclassified');
}
#print Dumper @barcode_dir;

# calculate the total base and read number for every barcode
my %barcode_readnum=();
my %barcode_basenum=();
my ($total_readnum,$total_basenum)=(0,0);

foreach my $dir_n (@barcode_dir){
	
	my @pass_fq_fs=();
	my @fail_fq_fs=();
	if(-e "$barcoder_path/pass/$dir_n"){
		opendir (DIR,"$barcoder_path/pass/$dir_n") || die "Cannot open $barcoder_path/pass/$dir_n: $!\n";
		@pass_fq_fs=grep {$_=~/\.fastq*|\.fq*/} readdir DIR;
		closedir DIR;
	}

	if(-e "$barcoder_path/fail/$dir_n"){
		opendir (DIR,"$barcoder_path/fail/$dir_n") || die "Cannot open $barcoder_path/fail/$dir_n: $!\n";
		@fail_fq_fs=grep {$_=~/\.fastq*|\.fq*/} readdir DIR;
		closedir DIR;
	}

	foreach my $fq (@pass_fq_fs){
		if(! -e "$barcoder_path/pass/$dir_n/$fq"){next;}
		my($readnum,$basenum)=&SingleFq("$barcoder_path/pass/$dir_n/$fq");
		$barcode_readnum{$dir_n}+=$readnum;
		$barcode_basenum{$dir_n}+=$basenum;
	}
	foreach my $fq (@fail_fq_fs){
		if(! -e "$barcoder_path/fail/$dir_n/$fq"){next;}
		my($readnum,$basenum)=&SingleFq("$barcoder_path/fail/$dir_n/$fq");
		$barcode_readnum{$dir_n}+=$readnum;
		$barcode_basenum{$dir_n}+=$basenum;
	}
	$total_readnum+=$barcode_readnum{$dir_n};
	$total_basenum+=$barcode_basenum{$dir_n};
}

my %bc_dir=();
foreach (@barcode_dir){
	$bc_dir{$_}=1;
}
# calcuate the percentage of every barcode
print "barcode;\tRead number;\t;\tTotal base(bp);\t\n";
if(!$show_bc_num){
	foreach my $barcode (@barcode_dir){
		if($bc_dir{$barcode}){
			my $readnum_per=sprintf("%2.2f",$barcode_readnum{$barcode}/$total_readnum*100);
			my $basenum_per=sprintf("%2.2f",$barcode_basenum{$barcode}/$total_basenum*100);
			print "$barcode;\t".&commify($barcode_readnum{$barcode})."; $readnum_per\%;\t".&commify($barcode_basenum{$barcode})."; $basenum_per\%\n";
		}elsif($show_bc_num && !$bc_dir{$barcode}){
			$barcode_readnum{$barcode}=0; 
			$barcode_basenum{$barcode}=0;
	
			my $readnum_per=sprintf("%2.2f",$barcode_readnum{$barcode}/$total_readnum*100);
			my $basenum_per=sprintf("%2.2f",$barcode_basenum{$barcode}/$total_basenum*100);
			print "$barcode;\t".&commify($barcode_readnum{$barcode})."; $readnum_per\%;\t".&commify($barcode_basenum{$barcode})."; $basenum_per\%\n";
		
		}
	}
}elsif($show_bc_num){
	foreach my $barcode (@bcs){
		if($bc_dir{$barcode}){
			my $readnum_per=sprintf("%2.2f",$barcode_readnum{$barcode}/$total_readnum*100);
			my $basenum_per=sprintf("%2.2f",$barcode_basenum{$barcode}/$total_basenum*100);
			print "$barcode;\t".&commify($barcode_readnum{$barcode})."; $readnum_per\%;\t".&commify($barcode_basenum{$barcode})."; $basenum_per\%\n";
		}elsif($show_bc_num && !$bc_dir{$barcode}){
			$barcode_readnum{$barcode}=0; 
			$barcode_basenum{$barcode}=0;
	
			my $readnum_per=sprintf("%2.2f",$barcode_readnum{$barcode}/$total_readnum*100);
			my $basenum_per=sprintf("%2.2f",$barcode_basenum{$barcode}/$total_basenum*100);
			print "$barcode;\t".&commify($barcode_readnum{$barcode})."; $readnum_per\%;\t".&commify($barcode_basenum{$barcode})."; $basenum_per\%\n";
		
		}
	}
}
print "Total;\t".&commify($total_readnum).";\t;\t".&commify($total_basenum).";\t\n";

############################################################
sub SingleFq(){

	my ($readnum,$basenum)=(0,0);
	my $fq_f=shift(@_);
	if($fq_f=~/\.fastq$|\.fq$/){
		open(IN,"<$fq_f")|| die "ERR: Cannot open $fq_f: $!\n";
		while(<IN>){
			my $title=$_; chomp $title;
			my $seq=<IN>; chomp $seq;
			my $l3=<IN>; chomp $l3;
			my $qua=<IN>; chomp $qua;

			# check format
			if($title!~/^\@/ || $l3!~/^\+/ || length($seq) != length($qua)){
				print "ERR: $fq_f NOT fastq format!\n";
				exit;
			}
			$readnum++;
			$basenum+=length($seq);
		}
		close IN;
	}elsif($fq_f=~/\.fastq\.gz$|\.fq\.gz$/){
		my @fq_c=`zcat $fq_f`; chomp @fq_c;
		while (@fq_c){
			my $title=shift(@fq_c); chomp $title;
			my $seq=shift(@fq_c); chomp $seq;
			my $l3=shift(@fq_c); chomp $l3;
			my $qua=shift(@fq_c); chomp $qua;

			# check format
			if($title!~/^\@/ || $l3!~/^\+/ || length($seq) != length($qua)){
				print "ERR: $fq_f NOT fastq.gz format!\n";
				exit;
			}
			$readnum++;
			$basenum+=length($seq);
		
		}
	}
	return($readnum,$basenum);
}

sub commify {
    my $text = reverse $_[0];
    $text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;
    return scalar reverse $text;
}
