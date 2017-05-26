
#!/usr/bin/env bash
#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N gcbias_run_dec7
#$ -cwd
#$ -l h_vmem=54G
#$ -M jmf422@cornell.edu
#$ -m be
#$ -pe bscb 4


# ask for multiple processors

#qsub gcbias_run_dec7.sh

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1

##############################################################################
## This script implements a modified version of the GC bias correction method of
## Benjamini & Speed (Nucleic Acids Research, 2012).  The difference is that the
## original paper looked at bias measured by how many reads start at each uniquely
## mappable single base-pair position, producing a correction metric that was
## "rate of read production" per uniquely mappable base pair. This script looks at
## how many reads overlap instead of start at a given position, producing a
## correction metric that's more akin to "average coverage at each uniquely
## mappable base pair (of a given GC content). This makes more sense for our
## purposes.
## 
## Input:
## 1) Reference genome in FASTA format.
## 2) Information on chromosome length for the reference genome.
## 3) Sorted BAM files of read alignment for the samples you wish to correct.
## 
## Output:
## A file ending with _gc.txt that looks like this:
## GC        Num. Positions  Overlapping Reads  Avg. Coverage
## 0.000000  1320            5369               4.067424242424242
## 0.003333  669             3728               5.5724962630792225
## 0.006667  562             11933              21.23309608540925
## 0.010000  609             20295              33.32512315270936
## 0.013333  450             18856              41.90222222222222
## 0.016667  546             18875              34.56959706959707
## 0.020000  438             28650              65.41095890410959
## 0.023333  920             90774              98.66739130434783
## 0.026667  645             67426              104.53643410852713
## The columns mean, in order:
## GC                - percent of GC content in question;
## Num. Positions    -  number of uniquely mappable sites in the reference 
##                      genome with that GC content;
## Overlapping Reads - How many reads overlap all of those positions;
## Avg. Coverage     - Total overlapping reads/number of positions.
## 
## The _gc.txt file can be read by any program that manipulates tab-delimited
## files, and the data can be used for GC bias correction downstream.
## 
## USAGE:
## After setting all the relevant variables below, just run this script
## with bash or sh.
## 
###########################################################################

###############
## VARIABLES ##
###############

# Customize your analysis by changing the values of the following variables:

# What is the length of a read?
# This is used in discovering what positions in the genome are uniquely
# mappable. A single location in the genome (1bp) is considered uniquely
# mappable if the x-mer that starts from it does not repeat elsewhere in the
# genome, where x is the read length.
READLEN=100

# What is the fragment length?
# This is used in calculating GC content. The model states that the number of
# reads that align (start) at a single 1bp position in the genome depends on
# the GC content of the y-mer that starts from it. Benjamini & Speed advocate
# the best y is the length of a fragment.
FRAGLEN=250

# Where is your reference genome?
# We need it in FASTA format.
GENOME=/fs/cbsufsrv5/data1/jmf422/DaphniaKmer/Daphnia_pulex.Dappu1.21.dna_sm.genome.rDNA.fa

# We need a file with chromsome lengths, separated by Tabs (not spaces).
# These are just the lengths in the reference. You can get them in the header
# of SAM files, by running bowtie2-inspect, or any equivalent method.
# Example:
# chr2L	23513712
# chr2R	25286936
# chr3L	28110227
# chr3R	32079331
# chr4	1348131
# chrM	19524
# chrX	23542271
# chrY	3667352
#
# Where is it?
CHROM_SIZES=$HOME/scaffold_sizes.txt
# Please note that this script makes no provisions for mismatches between
# chromosome names in this file (which is used to generate the downstream BEDs)
# and the BAM alignments. 
# ALSO: if you want to exclude entire chromosomes/regions from all downstream
# analyses, just do not include them in this file.

# Where are your BAM files of aligned reads for the samples?
# They do need to be sorted.
# Right now, we're grabbing every file with a .bam termination in a single
# folder. Grabbing BAMs from multiple folders is possible but slightly
# trickier.
BAMFOLDER=/fs/cbsufsrv5/data1/jmf422/DaphniaKmer/Bamfiles
#BAMFOLDER=/fs/cbsufsrv5/data1/jmf422/DaphniaKmer/testBam

# An optional part of this script's output are files ending with
# _positions.txt. They look like this:
# chr2L	5952	0.290000	0
# chr2L	5953	0.286667	0
# chr2L	5954	0.290000	0
# chr2L	5955	0.290000	0
# chr2L	5956	0.293333	0
# chr2L	5957	0.293333	0
# chr2L	5958	0.293333	0
# chr2L	5959	0.290000	0
# chr2L	5960	0.290000	0
# chr2L	5961	0.290000	0
# chr2L	5962	0.290000	0
# chr2L	5963	0.286667	0
# chr2L	5964	0.286667	0
# The first two columns describe a 1bp uniquely mappable position in the genome
# (1-based coordinates), the third is that position's GC content (according to
# FRAGLEN) and the last is how many reads start at this position.  This is a huge
# multi-GB file usually, so we delete it by default. However, if you want very
# fine information about what positions in the genome have what GC and where
# exactly are you finding a high or low number of aligned reads, you can keep 
# these files by changing the following variable to false:
REMOVE_POS_FILES=false

# This is just a wrapper script that calls other helper scripts.
# Where are they?
SRC=$HOME/gcbias_src

# Which folder should I write the output to?
RES_FOLDER=$HOME/gcbias_res_Dec7
# note, moved to fileserver 5

# How many parallel processors to use?
PARALLEL=4




#####################
## ANALYSIS BEGINS ##
#####################

# This part runs only once for the reference genome:

source $SRC/get_uniq_map_regions.sh \
    $READLEN $GENOME $CHROM_SIZES
echo 'Done getting mappable regions and their GC!'

# (!) At this point, you've got a file called mappable_positions.bed. It
# includes all the uniquely mappable 1bp positions in your reference genome in
# BED format. If you want to exclude specific positions from downstream
# analysis, just remove them from this file. Since it's a BED, this can be
# easily done with bedtools and the like.


# This part will loop through samples and run many times:

SAMPLEFILES=$BAMFOLDER/*.bam
echo $SAMPLEFILES | xargs -n 1 -P $PARALLEL \
    bash $SRC/get_all_sample_covs.sh \
    $CHROM_SIZES $REMOVE_POS_FILES $RES_FOLDER $SRC
rm mappable_positions.bed



#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)



#### And we're done. ####
