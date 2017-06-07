#!/usr/bin/env python

def get_rotations(kmer):
    '''Returns all rotated versions of k-mer.'''
    return [(kmer*2)[i:len(kmer)+i] for i in range(0, len(kmer))]
    
# read in drosophila data, make a list
dmelkmers=list()

with open('dmel.commonkmers.txt', 'r') as f:
	for line in f:
		dmelkmers.append(line.strip())

# function that returns the elements common to the two input lists given
def intersect(a,b):
	return list(set(a) & set(b))


# read in Daphnia data, get the rotations of each kmer and search the list

dpulkmers=list()
with open('../common.kmer.names39.txt', 'r') as f:
	for line in f:
		dpulkmers.append(line.strip())

for i in dpulkmers:
	print intersect(dmelkmers, get_rotations(i))

# good job, it works, but you got the same answer as using R. Oh well, you wrote something in python