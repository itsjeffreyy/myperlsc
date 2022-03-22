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
my @barcode=();
my $thread=4;
my $my_script="conda_activate_script.sh";
my $help;

GetOptions(
	"d|dir=s" => \$dir,
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
	print "ERR: Directory $dir not exist!\n";
	print "Abort!!\n";
	&Help;
}

if(! -e "$dir/fastq"){
	print "ERR: Directory $dir/fastq not exist!\n";
	print "Abort!!\n";
	&Help;
}

if(!@barcode){
	print "ERR: No input barcode list\n\n";
	print "Abort!!\n";
	&Help;
}

my @dir_bc=`ls $dir/fastq/fastq_pass/`; chomp @dir_bc;
my %dir_bc=();
foreach(@dir_bc){
	$dir_bc{$_}=1;
}

foreach (@barcode){
	if(!$dir_bc{$_}){
		print "$_ not in the sequencing case.\n";
		print "Abort!!\n";
		&Help;
	}
} 

# conda environment activate
&Create_conda_activate;
#system("bash -i ./conda_activate_script.sh");
#system("bash ./conda_activate.sh");
#`bash ./conda_activate.sh`;
#system("source /home/hgt/miniconda3/bin/activate nanoplot");
#system("conda activate nanoplot");
#&Activate_conda;
#system("bash","./act_conda.sh");


# NanoPlot QC
# raw data
if(! -e "$dir/NanoPlot_QC"){
	print "[MSG] Create directory $dir/NanoPlot_QC...\n";
	system("mkdir $dir/NanoPlot_QC");
}

open(OUT,">>$my_script")|| die "Cannot write $my_script\n";
foreach my $b (@barcode){
	print OUT "echo \"[MSG] NanoPlot QC for $b...\"\n";

	print OUT "NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw\n";
	print OUT "NanoPlot -t $thread --fastq $dir/fastq/fastq_pass/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_pass\n";
	#system("NanoPlot -t $thread --fastq $dir/fastq/fastq_*/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_raw");
	#system("NanoPlot -t $thread --fastq $dir/fastq/fastq_pass/$b/* --plots dot --N50 -o $dir/NanoPlot_QC/$b\_pass");
}
close OUT;
system("/bin/sh","$my_script");

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
			print "[ERR] $fqf not exist.\n";
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
				print "ERR: $fqf is not fastq format.\n"; exit;
			}
		}elsif($fqf=~/\.fastq\.gz$|\.fq\.gz$/){
			my @fq_c=`zcat $fqf`; chomp @fq_c;
			my $l1 = $fq_c[0]; chomp $l1;
			my $l3 = $fq_c[2]; chomp $l3;
			if ($l1=~/^@/ && $l3=~/^\+/){
				print OUT join("\n",@fq_c)."\n";
			}else{
				print "ERR: $fqf is not fastq format.\n";
			}
		}
	}
	close OUT;
}
# remove the seperate fastq in the fastq_pass and fastq_fail directory
print "[MSG] Remove the raw fastq_pass and fastq_fail folder...\n";
system("rm -r $dir/fastq/fastq_*");

print "[MSG] Finish processing\n\n";
system("rm $my_script");
############################################################
sub Help{
print <<EOF;

Command: 
	Preprocessing_4_16S_full_length_data.pl -dir dir -barcode barcode01 barcode02 ...
Options:
	-d|-dir    : The directory of 16S full length product case. 
                     `fastq` directory must be included in the case directory.
	-b|-barcode: The list barcode in this product case.
	-t|-thread : execution CPU number
	-h|-help   : Show this help information.

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
