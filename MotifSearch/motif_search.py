#!/usr/bin/env python

import re

def get_rotations(kmer):
    '''Returns all rotated versions of k-mer.'''
    return [(kmer*2)[i:len(kmer)+i] for i in range(0, len(kmer))]
    
def rev_comp(kmer):
    '''Returns reverse complement of k-mer.'''
    result = ''
    nucleotides = ['A', 'C', 'T', 'G']
    for char in kmer[::-1]:
        if char in nucleotides:
            result += nucleotides[(nucleotides.index(char)+2)%len(nucleotides)]
        else:
            result += char
    return result

def get_reverse_complements(rotations):
    '''Returns reverse complements of a k-mer's rotations.'''
    return [rev_comp(kmer) for kmer in rotations]

# import in list of kmers
# for each kmer, get its rotations and reverse complements of its rotations

# search for motifs

def motif_search(kmer_list):
	main = kmer_list[0]
	for i in kmer_list:
		if re.search("AAC", i):
			print '%s AAC' % (main)
		if re.search("AAG", i):
			print '%s AAG' % (main)
		if re.search("AAAA", i):
			print '%s AAAA' % (main)
		if re.search("TAGG", i):
			print '%s TAGG' % (main)
		if re.search("AGG", i):
			print '%s AGG' % (main)
		if re.search("AGC", i):
			print '%s AGC' % (main)
		if re.search("GCCAG", i):
			print '%s GCCAG' % (main)
		if re.search("AATGG", i):
			print '%s AATGG' % (main)
		if re.search("AGGAG", i):
			print '%s AGGAG' % (main)
		if re.search("ACGC", i):
			print '%s ACGC' % (main)
		if re.search("AACCT", i):
			print '%s AACCT' % (main)
		if re.search("AACCT", i):
			print '%s AACCT' % (main)
		if re.search("ACGG", i):
			print '%s ACGG' % (main)
		if re.search("ACCGA", i):
			print '%s ACCGA' % (main)
		if re.search("TCCAG", i):
			print '%s TCCAG' % (main)



#with open('../common.kmer.names39.txt', 'r') as f:
#with open ('dpul-final-all-legitkmers.txt', 'r') as f:
#with open ('New-unrelated-kmers.txt', 'r') as f:
#with open('dmel.commonkmers.txt', 'r') as f:
	for line in f:
		rots = get_rotations(line.strip())
		revcomps = 	get_reverse_complements(rots)
		all_kmers = rots + revcomps
		motif_search(all_kmers)
		
		




			
			
			
	