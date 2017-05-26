#!/usr/bin/env python
"""This script will generate the F variable from Benjamini & Speed 2012 from
our BED-like tables.
"""

import argparse
import csv
import sys

def get_args():
    """Get command-line arguments."""
    parser = argparse.ArgumentParser(description="""This script will generate
            the F variable from Benjamini & Speed 2012 from
            our BED-like tables.
            """
            )
    parser.add_argument('file',
                        help='positions.txt file.')
    return parser.parse_args()

class Record:
    def __init__(self, n=1, cov=0):
        self.n_sites = n
        self.reads_covered = cov

    def get_n(self):
        return self.n_sites

    def get_cov(self):
        return self.reads_covered

    def increment_n(self, num=1):
        self.n_sites += num

    def increment_cov(self, num=1):
        self.reads_covered += num


def read_table(infile):
    """Reads input table and returns equivalent dictionary."""
    dict_gc = {}
    with open(infile, 'r') as table:
        for line in table:
            words = line.split()
            gc_content = words[3]
            reads_covered = int(words[2])
            if gc_content in dict_gc:
                dict_gc[gc_content].increment_n(1)
                dict_gc[gc_content].increment_cov(reads_covered)
            else:
                dict_gc[gc_content] = Record(n=1, cov=reads_covered)
    return dict_gc

def write_output(table, output):
    """Writes table to output strem."""
    writer = csv.writer(output, delimiter='\t')
    writer.writerow(['GC', 'Num. Positions', 'Overlapping Reads', 'Avg. Coverage'])
    for gc_content in sorted(table.keys()):
        this_gc = table[gc_content]
        n_sites = this_gc.get_n()
        reads_covered = this_gc.get_cov()
        avg_cov = this_gc.get_cov()/float(this_gc.get_n())
        writer.writerow([gc_content, n_sites, reads_covered, avg_cov])

if __name__ == '__main__':
    args = get_args()
    cov_gc = read_table(args.file)
    write_output(cov_gc, sys.stdout)
