#!/usr/bin/env bash

READLEN=$1
GENOME=$2
CHROM_SIZES=$3

bedtools makewindows -g $CHROM_SIZES -w $READLEN -s 1 \
    | bedtools nuc -bed - -fi $GENOME -seq \
    | LC_ALL=C sort --key 13,13 \
    | LC_ALL=C uniq -i -u -f 12 \
    | cut -f 1,2 \
    | sed '1d' \
    | LC_ALL=C sort -n --key 1,1d --key 2,2n \
    | awk "{printf \"%s\t%s\t%s\n\",\$1,\$2,\$2+$FRAGLEN}" \
    | bedtools nuc -bed - -fi $GENOME \
    | cut -f 1,2,5 \
    | awk 'NR>1 {printf "%s\t%s\t%s\t%s\n",$1,$2,$2+1,$3}' \
    > mappable_positions.bed
