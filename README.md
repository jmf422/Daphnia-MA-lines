# Daphnia-MA-lines
The scripts for analysis from the paper "Selection constrains high rates of tandem repetitive DNA mutation in Daphnia pulex"
Jullien M. Flynn, Ian Caldas, Melania E. Cristescu, Andrew G. Clark


Any questions about these scripts should be directed to Jullien Flynn: jmf422@cornell.edu. If the question is pertaining to the GC correction, it should be directed to Ian Caldas: ivc2@cornell.edu.

The first steps in the analysis were to merge overlapping reads with Seqprep, combine files, and then run k-Seek on the fastqc files. K-Seek is available at https://github.com/weikevinhc/k-seek . Files must also be mapped to the reference genome in order to do the GC correction.

1. Scripts required for the gc correction are in the GC_correction folder. Please refer to the README file contained in that folder for specific details. 
 
    `gcbias_run_github.sh`
is the wrapper script that uses the source files and input file requirements that are described within the script.  

The next step of the GC correction is to use the
    `modified_correct_bins_jf.py` 
python script. This script takes as input files the output table generated from k-compile  as well as the gc.txt files output from the previous GC correction script.  

 
2. The R code used for the main analysis is in the Rmd file
    `FileS3.Rmd`
The main input into this file is the file produced from the output of the GC correction script. Please see the InputFiles folder for the required input files for this and other scripts.


Comparing the kmers between Drosophila melanogaster and also searching kmers for common motifs that were found amongst the most common kmers are in the MotifSearch folder.

3. The R code used for doing various quality control tests is in
       `FileS4.Rmd`.  

The input files required for Steps 2 and 3 are located in the InputFiles folder.

4. The scripts used to test for interspersion between the related kmers are found in the InterspersionAnalysis folder. For this analysis, k-Seek was run individually on each read of the mate pair (i.e. the files were not combined as they were for the main analysis). Files were named as: *\_1.rep and *\_2.rep. E.g. read\_1.rep, read\_2.rep. 

Run this command:  
    `pl rep_mate.pl read_1.rep`

It will output two files: read\_1.rep.mp and read\_2.rep.mp.  

Next, run this command:
    `pl mp.compile.updated.pl read_1.rep.mp read_2.rep.mp out`

The < out > can be anything you want the output to be named. You will get two output files: output\_base.rep.mpx and output\_base.unique.mpx.  These perl scripts were provided by K.H-C Wei.  

The .rep.mpx file will contain the (symmetrical) matrix you want where each cell is the number of reads where the respective repeats are found in the two mate pairs (i.e. how many times you see a AAGAG in both reads, and AAGAG with AACAC, etc).  

The R code for analyzing these matrices is in the script  
    FileS5.Rmd 
which includes the usage of the
     run_get_ni,nj.sh 
script, as well as the
    extract.py
script. 

