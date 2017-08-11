GC bias correction script readme
Ian Caldas
ivc2@cornell.edu

This script implements a modified version of the GC bias correction method of
Benjamini & Speed (Nucleic Acids Research, 2012).  The difference is that the
original paper looked at bias measured by how many reads start at each uniquely
mappable single base-pair position, producing a correction metric that was
"rate of read production" per uniquely mappable base pair. 

This script looks at how many reads overlap instead of start at a given
position, producing a correction metric that's more akin to "average coverage"
at each uniquely mappable base pair (of a given GC content). This makes more
sense for the purposes of correcting k-mer counts, and is equivalent to a
weighted version of just correcting by the overall average coverage.

USAGE:
Open the main script (gcbias_run.sh) in a text editor and set the variables in
there to their relevant values. The descriptions of what you need to set and
how are in the script itself.
Then, just run the script with bash: 
> sh gcbias_run.sh

REQUIREMENTS:
The script uses standard bash utilities, as well as a Python script that should
run in any machine with any version of Python, preferrably 2.7 or 3+.

INPUT:
This is what you need to have on hand to make this work.
1) Reference genome in FASTA format.
2) Information on chromosome length for the reference genome.
3) Sorted BAM files of read alignment for the samples you wish to correct.

OUTPUT:
A tab-delimited file ending with _gc.txt that looks like this:
GC        Num. Positions  Overlapping Reads  Avg. Coverage
0.000000  1320            5369               4.067424242424242
0.003333  669             3728               5.5724962630792225
0.006667  562             11933              21.23309608540925
0.010000  609             20295              33.32512315270936
0.013333  450             18856              41.90222222222222
0.016667  546             18875              34.56959706959707
0.020000  438             28650              65.41095890410959
0.023333  920             90774              98.66739130434783
0.026667  645             67426              104.53643410852713
(...)

The columns mean, in order:
GC                - percent of GC content in question;
Num. Positions    - number of uniquely mappable sites in the reference 
                    genome with that GC content;
Overlapping Reads - How many reads overlap all of those positions, i.e. the sum
                    of overlapping reads for each single position;
Avg. Coverage     - Total overlapping reads/number of positions.

The _gc.txt file can be read by any program that manipulates tab-delimited
files, and the data can be used for GC bias correction downstream. See the
accompanying Jupyter notebook for an example.

Any questions, bugs, or suggestions, please e-mail ivc2@cornell.edu.
