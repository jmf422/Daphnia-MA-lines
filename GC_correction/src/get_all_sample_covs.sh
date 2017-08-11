#!/usr/bin/env bash

CHROM_SIZES=$1
REMOVE_POS_FILES=$2
RES_FOLDER=$3
SRC=$4
SAMPLEBAM=$5

SAMPLENAME=`basename ${SAMPLEBAM%.*}`

samtools index $SAMPLEBAM
samtools view -b $SAMPLEBAM `cut -f 1 $CHROM_SIZES` \
    | bedtools bamtobed -i stdin \
    | bedtools genomecov -i stdin -g $CHROM_SIZES -d \
    | awk 'NR==FNR{a[$1,$3]=$4;next} ($1,$2) in a{print $0, a[$1,$2]}' \
    mappable_positions.bed /dev/stdin > $SAMPLENAME\_positions.txt

python $SRC/20161201_gcbias_table.py \
    $SAMPLENAME\_positions.txt \
    > $SAMPLENAME\_gc.txt

if $REMOVE_POS_FILES
then
    rm $SAMPLENAME\_positions.txt
else
    mv $SAMPLENAME\_positions.txt $RES_FOLDER
fi

mkdir -p $RES_FOLDER
mv $SAMPLENAME\_gc.txt $RES_FOLDER

echo "Done getting the table for $SAMPLENAME!"
