
import argparse

def rev_comp(kmer):
    '''Returns reverse complement of k-mer.'''
    result = ''
    nucleotides = ['A', 'C', 'T', 'G']
    for char in kmer[::-1]:
        result += nucleotides[(nucleotides.index(char)+2)%len(nucleotides)]
    return result

def get_rotations(kmer):
    '''Returns all rotated versions of k-mer.'''
    return [(kmer*2)[i:len(kmer)+i] for i in range(0, len(kmer))]

def get_reverse_complements(rotations):
    '''Returns reverse complements of a k-mer's rotations.'''
    return [rev_comp(kmer) for kmer in rotations]

def is_same_kmer(rotations, reverse_complements, query):
    '''Returns True if query is either a rotated version of the target
    k-mer or the reverse complement of one of these rotations.'''
    if (query in rotations) or (query in reverse_complements):
        return True
    else:
        return False

def get_arguments():
    parser = argparse.ArgumentParser(description = '''
    Parses the .rep output of kseek looking for a specific k-mer.
    Returns all reads found for that k-mer in a FASTA file.
    This program will not only look for the k-mer, but also for its
    rotations and for their reverse complements. For instance, if the
    k-mer you're looking for is AACCTG, the program will return reads
    with the k-mers:
    AACCTG  CAGGTT
    ACCTGA  TCAGGT
    CCTGAA  TTCAGG
    CTGAAC  GTTCAG
    TGAACC  GGTTCA
    GAACCT  AGGTTC
    
    Example usage:

    python extract.py AACCTG kseek_results.rep -o extracted_reads.fasta
    ''', formatter_class = argparse.RawTextHelpFormatter)
    parser.add_argument("kmer", help='k-mer you want to search for.')
    parser.add_argument("repfile", help='.rep file, output of kseek.')
    parser.add_argument("--output", '-o', help='name of output file.\
 Default is extracted_reads.fasta.', default='extracted_reads.fasta')
    return parser.parse_args()

def parse_reads(kmer, infile, outfile):
    out = open(outfile, 'w')
    round = 0
    rotations = get_rotations(kmer)
    reverse_complements = get_reverse_complements(rotations)
    with open(infile, 'r') as f:
        while True:
            if round%100000 == 0:
                print(round)
            read_name = f.readline()[1:]
            if read_name == '':
                # EOF, break out of loop, end program
                break
            read_content = f.readline()
            # skip 2 lines:
            f.readline()
            f.readline()
            repeat_found = f.readline().split('=')[0]
            if is_same_kmer(rotations, reverse_complements, repeat_found):
                out.write('>' + read_name)
                out.write(read_content + '\n')
            round += 1
    out.close()

args = get_arguments()
parse_reads(args.kmer, args.repfile, args.output)
