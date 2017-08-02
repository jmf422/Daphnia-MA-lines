#!/usr/bin/env bash

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
GENOME=<path-to-file.fasta>

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
CHROM_SIZES=<path-to-file.txt>
# Please note that this script makes no provisions for mismatches between
# chromosome names in this file (which is used to generate the downstream BEDs)
# and the BAM alignments. 
# ALSO: if you want to exclude entire chromosomes/regions from all downstream
# analyses, just do not include them in this file.

# Where are your BAM files of aligned reads for the samples?
# They do need to be sorted.
# This script will take all bam files in the given folder
BAMFOLDER=<path-to-folder/>


# An optional part of this script's output are files ending with
# _positions.txt. They look like this:
# chr2L	5011	39 0.396667
# chr2L	5012	38 0.400000
# chr2L	5013	38 0.400000
# chr2L	5014	37 0.403333
# chr2L	5015	37 0.400000
# chr2L	5016	37 0.403333
# chr2L	5017	37 0.400000
# chr2L	5018	37 0.403333
# chr2L	5019	36 0.403333
# chr2L	5020	36 0.406667
# chr2L	5021	35 0.410000
# The first two columns describe a 1bp uniquely mappable position in the genome
# (the first base in the chromosome is number 1), the third is how many reads
# overlap this position, and the last is the position's GC content according to
# FRAGLEN.  This is a huge multi-GB file usually, so we delete it by default.
# However, if you want very fine information about what positions in the genome
# have what GC and where exactly are you finding a high or low number of
# aligned reads, you can keep these files by changing the following variable to
# false:
REMOVE_POS_FILES=false

# This is just a wrapper script that calls other helper scripts.
# Where are they?
SRC=<path-to-src-files/>

# Which folder should I write the output to?
RES_FOLDER=<path-to-results-folder>

# How many parallel processors to use?
PARALLEL=<integer>


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




