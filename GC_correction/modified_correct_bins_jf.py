import os
import argparse
import numpy as np
import pandas as pd
from collections import OrderedDict as odict

def get_args():
    parser = argparse.ArgumentParser(description='Correct by binned GC counts')
    parser.add_argument('compilefile', help='Path to kcompile file')
    parser.add_argument('biasfolder',
    help='Path to folder containing bias tables (gc.txt files)')
    parser.add_argument('--minreads', 
            help='Minimum number of overlapping reads to consider for correction. Default is 0, and all GC regions are used.',
            type=int, default=0)
    return parser.parse_args()

def get_kmer_counts(compilefile):
    raw_counts = pd.read_table(compilefile, index_col=0)
    raw_counts = raw_counts.drop('total_bp', axis=1)
    try:
        raw_counts = raw_counts.drop('N/N', axis=1)
    except ValueError:
        pass
    def cleanup_line_names(df):
        split_names = df.index.str.split('.')
        new_index = []
        for sn in split_names:
            new_index.append(sn[0])
        df.index = new_index
    def cleanup_kmer_names(df):
        kmer_names = df.columns.str.split('/')
        new_names = []
        for n in kmer_names:
            new_names.append(n[0])
        df.columns = new_names
    cleanup_line_names(raw_counts)
    cleanup_kmer_names(raw_counts)
    raw_counts = raw_counts.reindex_axis(sorted(raw_counts.columns, key=get_gc_content), axis=1)
    return raw_counts

def get_gc_content(dna):
    return (dna.count('C') + dna.count('G'))/len(dna)

def get_bias_tables(biasfolder, min_reads):
    tables = odict()
    for biasfile in os.listdir(biasfolder):
        sample_name = biasfile.split('.')[0]
        df = pd.read_table(biasfolder + biasfile, index_col=0)
        df = df.loc[df['Overlapping Reads'] > min_reads]
        tables[sample_name] = df
    return tables

def get_avg_cov(df):
    return (df.sum()['Overlapping Reads'])/(df.sum()['Num. Positions'])

def write_avg_covs(bias_tables):
    with open('avg_covs.txt', 'w') as outfile:
        outfile.write('%10s\t%6s\n' % ('sample', 'avg. cov'))
        for sample in bias_tables:
            outfile.write('%10s\t%2.3f\n'% (sample, get_avg_cov(bias_tables[sample])))

def get_bins():
    bins = [0, 0.25, 0.30, 0.35, 0.40, 0.45, 0.50, 0.55, 0.60, 0.75, 1.0]
    return bins

def get_binned_tables(bias_tables):
    samples_binned = odict()
    bins = get_bins()
    for samplename in bias_tables:
        sample = bias_tables[samplename]
        grouped = sample.groupby(pd.cut(sample.index, bins, include_lowest=True))
        binned = grouped.mean()['Avg. Coverage']
        binned = binned.replace(np.nan, get_avg_cov(sample))
        samples_binned[samplename] = binned
    return samples_binned

def correct_counts(kmer_counts, correction_tables):
    kmers = kmer_counts.columns
    samples = kmer_counts.index
    corrected_counts = pd.DataFrame(index = samples, columns=kmers)
    for kmer in kmers:
        gc = get_gc_content(kmer)
        for sample in samples:
            sample_table = correction_tables[sample]
            corr = match_binned_avg(gc, sample_table)
            corrected_counts.loc[sample, kmer] = kmer_counts.loc[sample, kmer]/corr
    return corrected_counts.applymap(lambda x: int(round(x)))

def match_binned_avg(gc, correction_table):
    cats = correction_table.index
    if gc == 0:
        cat = cats[0]
    for c in cats:
        c_min = float(c.split(',')[0][1:])
        c_max = float(c.split(',')[1][:-1])
        if (gc > c_min) & (gc <= c_max):
            cat = c
            break
    return correction_table.loc[cat]



if __name__ == '__main__':
    args = get_args()
    clean_counts = get_kmer_counts(args.compilefile)
    bias_tables = get_bias_tables(args.biasfolder, args.minreads)
    write_avg_covs(bias_tables)
    binned_tables = get_binned_tables(bias_tables)
    corrected = correct_counts(clean_counts, binned_tables)
    corrected.to_csv('corrected.csv')