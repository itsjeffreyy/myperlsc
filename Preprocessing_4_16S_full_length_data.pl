#!/usr/bin/perl -w
use strict;
use Data::Dumper;
use Getopt::Long;

# The directory structure is as below
# 20220318_1132_X2_FAS01788_eb5cf166/
#└── fastq
#    ├── fastq_fail
#    │   ├── barcode01
#    │   ├── barcode02
#    │   ├── barcode03
#    │   ├── barcode04
#    │   ├── barcode05
#    │   ├── barcode07
#    │   ├── barcode08
#    │   ├── barcode10
#    │   ├── barcode11
#    │   ├── barcode12
#    │   └── unclassified
#    └── fastq_pass
#        ├── barcode01
#        ├── barcode02
#        ├── barcode03
#        ├── barcode04
#        ├── barcode05
#        ├── barcode06
#        ├── barcode07
#        ├── barcode09
#        ├── barcode11
#        └── unclassified

my $dir="";
my $barcode_list="";
my @barcode=();
my $thread=4;
my $my_script="conda_activate_execution.sh";
my $act_script="nanoplot_act.sh";
my $help;

GetOptions(
	"d|dir=s" => \$dir,
	"bl|barcode_list=s" => \$barcode_list,
	"b|barcode=s{,}" => \@barcode,
	"t|thread=i" => \$thread,
	"h|help" => \$help,
);

# help option function
if($help){
	&Help;
}

# check the input options and directory.
if(! -e $dir){
	print STDERR "ERR: Directory $dir not exist!\n";
	print STDERR "Abort!!\n";
	&Help;
}

if(! -e "$dir/fastq"){
	print STDERR "ERR: Directory $dir/fastq not exist!\n";
	print STDERR "Abort!!\n";
	&Help;
}

if($barcode_list){
	open(IN,"<$barcode_list")|| die "Cannot open $barcode_list: $!\n";
	@barcode=<IN>; chomp @barcode;
	close IN;
}

if(!@barcode){
	print STDERR "ERR: No input barcode list\n\n";
	print STDERR "Abort!!\n";
	&Help;
}

my @dir_bc=`ls $dir/fastq/fastq_pass/`; chomp @dir_bc;
my %dir_bc=();
foreach(@dir_bc){
	$dir_bc{$_}=1;
}

foreach (@barcode){
	if(!$dir_bc{$_}){
		print STDERR "$_ not in the sequencing case.\n";
		print STDERR "Abort!!\n";
		&Help;
	}
} 

# conda environment activate
&Create_conda_activate;
&Create_info_sc($dir);

# NanoPlot QC
# raw data
if(! -e "$dir/NanoPlot_QC"){
	print STDOUT "[MSG] Create directory $dir/NanoPlot_QC...\n";
	system("mkdir -p $dir/NanoPlot_QC");
}


open(OUTact,">$act_script")|| die "Cannot create $act_script: $!\n";
foreach my $b (@barcode){
	#print STDOUT "[MSG] NanoPlot QC for $b...\n";
	print OUTact "echo \"[MSG] NanoPlot QC for $b...\"\n";

	#system("/home/hgt/miniconda3/envs/nanoplot/bin/NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw");
	#system("/home/hgt/miniconda3/envs/nanoplot/bin/NanoPlot -t $thread --fastq $dir/fastq/fastq_pass/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_pass");
	#system("NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw");
	#system("NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw");
	print OUTact "NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw\n";
	print OUTact "NanoPlot -t $thread --fastq $dir/fastq/fastq_pass/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_pass\n";
}
close OUTact;

system("cat $act_script >> $my_script");
system("bash $my_script");

# Merge pass part fastq 
foreach my $b (@barcode){
	print "[MSG] Merge PASS part barcode $b fastq into one fastq file...\n";
	my $out_name="$dir/fastq/$b\_pass.fastq";
	
	# list the fastq files for merged
	my @fqfs=`ls $dir/fastq/fastq_pass/$b/`; chomp @fqfs;
	for (my $i=0; $i< scalar @fqfs; $i++){
		$fqfs[$i]="$dir/fastq/fastq_pass/$b/$fqfs[$i]";
	}

	# open a output fastq file
	open(OUT,">$out_name")|| die "Cannot write to $out_name!\n";
	
	# load multiple fastq or fastq.gz
	
	foreach my $fqf (@fqfs){
		if(! -e $fqf){
			print STDERR "[ERR] $fqf not exist.\n";
			&Help;
		}
	
		# check comprassion stat
		if($fqf=~/\.fastq$|\.fq$/){	
	
			# check the fastq format
			open(IN,"<$fqf")||die "open file $fqf:$!\n";
			my $l1=<IN>; chomp $l1; <IN>;
			my $l3=<IN>; chomp $l3; <IN>;
			close IN;
			if ($l1=~/^@/ && $l3=~/^\+/){
				my $fq_content=`cat $fqf`;
				print OUT "$fq_content";
			}else{
				print STDERR "ERR: $fqf is not fastq format.\n"; exit;
			}
		}elsif($fqf=~/\.fastq\.gz$|\.fq\.gz$/){
			my @fq_c=`zcat $fqf`; chomp @fq_c;
			my $l1 = $fq_c[0]; chomp $l1;
			my $l3 = $fq_c[2]; chomp $l3;
			if ($l1=~/^@/ && $l3=~/^\+/){
				print OUT join("\n",@fq_c)."\n";
			}else{
				print STDERR "ERR: $fqf is not fastq format.\n";
			}
		}
	}
	close OUT;
}
# remove the seperate fastq in the fastq_pass and fastq_fail directory
#print "[MSG] Remove the raw fastq_pass and fastq_fail folder...\n";
#system("rm -r $dir/fastq/fastq_*");

system("bash $dir/info.sh");

print STDOUT "[MSG] Finish processing\n\n";
system("rm $my_script $act_script");
############################################################
sub Help{
print <<EOF;

Command: 
	Preprocessing_4_16S_full_length_data.pl -dir dir -barcode barcode01 barcode02 ...
Options:
	-d|-dir          : The directory of 16S full length product case. 
                           `fastq` directory must be included in the case directory.
	-bl|-barcode_list: The barcode you wanted in a list file.
	-b|-barcode      : The list barcode in this product case.
	-t|-thread       : execution CPU number
	-h|-help         : Show this help information.

EOF
exit;
}

sub Create_conda_activate{
open (OUT,">$my_script")|| die "Cannot write the file $my_script\n";

print OUT <<EOF;
#!/bin/sh

#-----------------------------------------------------------------------------------
# FileName: $my_script
#-----------------------------------------------------------------------------------

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="\$('/home/hgt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ \$? -eq 0 ]; then
	eval "\$__conda_setup"
else
	if [ -f "/home/hgt/miniconda3/etc/profile.d/conda.sh" ]; then
		. "/home/hgt/miniconda3/etc/profile.d/conda.sh"
	else
		export PATH="/home/hgt/miniconda3/bin:\$PATH"
	fi
fi
unset __conda_setup
# <<< conda initialize <<<
echo "[MSG] Activate conda noanoplot environment..."
conda activate nanoplot

EOF


close OUT;
}

sub Create_info_sc(){
my $out='info.sh';
my $dir=shift @_;
open (OUT,">$dir/$out" )|| die "Cannot create $dir/$out: $!\n";

print OUT <<EOF;
#!/bin/sh
source ~/miniconda3/bin/activate base
cd $dir
ls fastq/barcode* | awk -F '/' '{print \$2}' | awk -F '.' '{print \$1}'  > tmp_list.txt
while read i; do
	echo \$i
	nanoq -i fastq/\${i}.fastq --min-qual 10 --min-len 1300 --max-len 1950 -o fastq/\${i}_filter.fastq
done < tmp_list.txt

source ~/miniconda3/bin/activate nanoplot
while read i; do
	NanoPlot --fastq fastq/\${i}_filter.fastq --plots dot --N50 -o NanoPlot_QC/\${i}_filter
done < tmp_list.txt

rm tmp_list.txt
rm QC_info.tsv

echo -e "Barcode\\tTotalBases_Raw\\tNumberOfReads_Raw\\tMeanReadLength_Raw\\tReadLengthN50_Raw\\tTotalBases_Pass\\tNumberOfReads_Pass\\tMeanReadLength_Pass\\tReadLengthN50_Pass\\tTotalBases_QC\\tNumberOfReads_QC\\tMeanReadLength_QC\\tReadLengthN50_QC\\tLossRate1(Raw2QC)\\tLossRate2(Pass2QC)" > QC_info.tsv

ls NanoPlot_QC | awk -F '_' '{print \$1}' | sort | uniq > tmp.list

while read i; do

	echo -e "\${i}\\t\\c" >> QC_info.tsv

	less NanoPlot_QC/\${i}_raw/NanoStats.txt | grep "Total bases" > tmp_\${i}_raw.txt
	sed -i 's/ //g' tmp_\${i}_raw.txt
	sed -i 's/Totalbases://g' tmp_\${i}_raw.txt
	cat tmp_\${i}_raw.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_raw/NanoStats.txt | grep "Number of reads" > tmp_\${i}_raw_num.txt
	sed -i 's/ //g' tmp_\${i}_raw_num.txt
	sed -i 's/Numberofreads://g' tmp_\${i}_raw_num.txt
	cat tmp_\${i}_raw_num.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_raw/NanoStats.txt | grep "Mean read length" > tmp_\${i}_raw.txt
	sed -i 's/ //g' tmp_\${i}_raw.txt
	sed -i 's/Meanreadlength://g' tmp_\${i}_raw.txt
	cat tmp_\${i}_raw.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_raw/NanoStats.txt | grep "Read length N50" > tmp_\${i}_raw.txt
	sed -i 's/ //g' tmp_\${i}_raw.txt
	sed -i 's/ReadlengthN50://g' tmp_\${i}_raw.txt
	cat tmp_\${i}_raw.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass/NanoStats.txt | grep "Total bases" > tmp_\${i}_pass.txt
	sed -i 's/ //g' tmp_\${i}_pass.txt
	sed -i 's/Totalbases://g' tmp_\${i}_pass.txt
	cat tmp_\${i}_pass.txt | tr '\\n' '\\t' >> QC_info.tsv

        less NanoPlot_QC/\${i}_pass/NanoStats.txt | grep "Number of reads" > tmp_\${i}_pass_num.txt
	sed -i 's/ //g' tmp_\${i}_pass_num.txt
	sed -i 's/Numberofreads://g' tmp_\${i}_pass_num.txt
	cat tmp_\${i}_pass_num.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass/NanoStats.txt | grep "Mean read length" > tmp_\${i}_pass.txt
	sed -i 's/ //g' tmp_\${i}_pass.txt
	sed -i 's/Meanreadlength://g' tmp_\${i}_pass.txt
	cat tmp_\${i}_pass.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass/NanoStats.txt | grep "Read length N50" > tmp_\${i}_pass.txt
	sed -i 's/ //g' tmp_\${i}_pass.txt
	sed -i 's/ReadlengthN50://g' tmp_\${i}_pass.txt
	cat tmp_\${i}_pass.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass_filter/NanoStats.txt | grep "Total bases" > tmp_\${i}_pass_filter.txt
	sed -i 's/ //g' tmp_\${i}_pass_filter.txt
	sed -i 's/Totalbases://g' tmp_\${i}_pass_filter.txt
	cat tmp_\${i}_pass_filter.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass_filter/NanoStats.txt | grep "Number of reads" > tmp_\${i}_pass_filter_num.txt
	sed -i 's/ //g' tmp_\${i}_pass_filter_num.txt
	sed -i 's/Numberofreads://g' tmp_\${i}_pass_filter_num.txt
	cat tmp_\${i}_pass_filter_num.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass_filter/NanoStats.txt | grep "Mean read length" > tmp_\${i}_pass_filter.txt
	sed -i 's/ //g' tmp_\${i}_pass_filter.txt
	sed -i 's/Meanreadlength://g' tmp_\${i}_pass_filter.txt
	cat tmp_\${i}_pass_filter.txt | tr '\\n' '\\t' >> QC_info.tsv

	less NanoPlot_QC/\${i}_pass_filter/NanoStats.txt | grep "Read length N50" > tmp_\${i}_pass_filter.txt
	sed -i 's/ //g' tmp_\${i}_pass_filter.txt
	sed -i 's/ReadlengthN50://g' tmp_\${i}_pass_filter.txt
	cat tmp_\${i}_pass_filter.txt | tr '\\n' '\\t' >> QC_info.tsv

	sed -i 's/,//g' tmp_\${i}_raw_num.txt
	sed -i 's/,//g' tmp_\${i}_pass_num.txt
	sed -i 's/,//g' tmp_\${i}_pass_filter_num.txt
	raw_num=\$(<tmp_\${i}_raw_num.txt)
	pass_num=\$(<tmp_\${i}_pass_num.txt)
	pass_filter_num=\$(<tmp_\${i}_pass_filter_num.txt)
	echo -e "0\\c" >> QC_info.tsv
	echo "scale=2; 1-\$pass_filter_num/\$raw_num" | bc | cat | tr '\\n' '\\t' >> QC_info.tsv
	echo -e "0\\c" >> QC_info.tsv
	echo "scale=2; 1-\$pass_filter_num/\$pass_num" | bc >> QC_info.tsv

done < tmp.list

rm tmp*

EOF


close OUT;
}






