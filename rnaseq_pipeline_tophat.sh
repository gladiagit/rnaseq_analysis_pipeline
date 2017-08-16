###########################################################################
###	a program to run the tophat/	RNASeq pipeline automatically		###
###########################################################################
### assumptions:														###
###		- each filename is in the format : text_L00N_RM_00X.fastq.gz	###
###			where:														###
###				- N is the LANE number (1-4)							###
###				- M is the RUN number  (1-2)							###
###				- X is the re-run number ? but there is only one for each##
###					lane/run combination in the folder					###
###########################################################################
#!/usr/bin/env bash -x

OUT=$1				# the output folder
REF=$2				# the indexed reference genome
FNAME=$3			# the filename template for files to analyse , including full path
NCORE=$4			# the number of cores to use, default value is 1
CPARAM=$5			# the cufflinks parameters file, tab separated with first column containing the parameter and the second containign the value/(in progress 08/15/17)	
LIB=$6 				# library type information


#checking the existance of tophat in the path 
cmd="tophat"
cmd2="samtools"
cmd3="cufflinks"
cmd4="cuffmerge"
cmd5="cuffdiff"

if [ -z "$NCORE" ]
then
	NCORE=1
fi

echo "we are going to use $NCORE cores"
#type -P "$cmd" && echo "found $cmd in path" || { echo "$cmd not in path"; exit 1}
if ! type -P "$cmd" 
then
	echo "$cmd not in path, exiting"
	exit 1
fi

if ! type -P "$cmd2" 
then
	echo "$cmd2 not in path, exiting"
	exit 1
fi
if ! type -P "$cmd3" 
then
	echo "$cmd3 not in path, exiting"
	exit 1
fi


SFNAME=$(echo $FNAME | rev | cut -f 1 -d "/" | rev)


for i in `seq 1 4`;	# consider giving the total number of lanes as parameter (08/14/17 JA)
do
	#making assumptions of the filename in the folder based on the lane and run number 
	file1=($FNAME"_L00"$i"_R1_001.fastq.gz")
	file2=($FNAME"_L00"$i"_R2_001.fastq.gz")
	
	echo $i 
	#checking for the existance of expected files 
	if [ ! -e $file1 ]
	then
		echo "file $file1 NOT found"
		file1=`ls $FNAME"_L00"$i"_R1"*`
		echo "file $file1 found instead"
	fi
	
	if [ ! -e $file2 ]
	then
		echo "file $file2 NOT found"
		file2=`ls $FNAME"_L00"$i"_R2"*`
		echo "file $file2 found instead"
	fi
	NOUT=($OUT"/tophat_out_L00"$i)
	NOUT2=($OUT"/cufflinks_out_L00"$i)
	`ls $NOUT` || `mkdir $NOUT`
	`ls $NOUT2` || `mkdir $NOUT2`
	NNAME=($SFNAME"_L00"$i".bam")
	NNAME2=($SFNAME"_L00"$i".gtf")
	echo "$cmd  -p$NCORE -o $NOUT $REF $file1 $file2 "
#	`$cmd -p $NCORE -o $NOUT $REF  $file1 $file2`
#	`$cmd2 index $NOUT/accepted_hits.bam`
#	`$cmd3 --library-type $LIB -o $NOUT2/$NNAME $NOUT/accepted_hits.bam `
	`mv $NOUT2/$NNAME/transcripts.gtf $NOUT2/$NNAME/$NNAME2`
	`cp $NOUT/accepted_hits.bam $OUT/$NNAME`
	echo "$cmd3 --library-type $LIB -o $NOUT2/$NNAME $NOUT/accepted_hits.bam"
	`echo $NOUT2/$NNAME/$NNAME2 >> $OUT/assemblies.txt`
done;

	`cuffmerge -s $REF $OUT/assemblies.txt`
	`cuffdiff -p $NCORE --library-type $LIB -o $OUT/diff_out -b $REF -L $SFNAME"_L001",$SFNAME"_L002",$SFNAME"_L003",$SFNAME"_L004" -u merged_asm/merged.gtf $OUT/$SFNAME"_L001.bam" $OUT/$SFNAME"_L002.bam" $OUT/$SFNAME"_L003.bam" $OUT/$SFNAME"_L004.bam"`
	 echo "cuffdiff --library-type fr-firststrand -o $OUT/diff_out -b $REF -L $SFNAME_L001,$SFNAME_L002,$SFNAME_L003,$SFNAME_L004 -u merged_asm/merged.gtf $OUT/$SFNAME_L001.bam $OUT/$SFNAME_L002.bam $OUT/$SFNAME_L003.bam $OUT/$SFNAME_L004.bam"rfe