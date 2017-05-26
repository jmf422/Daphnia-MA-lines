# Daphnia-MA-lines
The scripts for analysis of Daphnia MA lines for the publication:

1. Scripts required for the gc correction are in the `GC\_correction folder`. `gcbias\_run\_github.sh` is the wrapper script that uses the source files and input file requirements that are described within the script.  

The next step of the GC correction is to use the `modified_correct_bins_jf.py` python script. This script takes as input files the output table generated from k-compile (available from k-Seek's Github page at: https://github.com/weikevinhc/k-seek) as well as the gc.txt files output from the previous script.  

This is the main input file used for the main analysis.  

2. The R code used for the main analysis is in the Rmd file `Final_Main_Analysis.Rmd`. The main input into this file is the file produced from the previous python script.  

3. The R code used for doing various quality control tests is in `Final-Quality-control.Rmd`.  

4. The scripts used to test for interspersion between the related kmers are found in the `InterspersionAnalysis` folder. For this analysis, k-Seek was run individually on each read of the mate pair (i.e. the files were not combined as they were for the main analysis). Files were named as: *\_1.rep and *\_2.rep. E.g. read\_1.rep, read\_2.rep. 

Run this command:  
`pl rep\_mate.pl read\_1.rep`

It will output two files: read\_1.rep.mp and read\_2.rep.mp.  

Next, run this command:

`pl mp.compile.updated.pl read_1.rep.mp read_2.rep.mp out`

The out can be anything you want the output to be named. You will get two output files: output\_base.rep.mpx and output\_base.unique.mpx.  

The .rep.mpx file will contain the (symmetrical) matrix you want where each cell is the number of reads where the respective repeats are found in the two mate pairs (i.e. how many times you see a AAGAG in both reads, and AAGAG with AACAC, etc).  

The R code for analyzing these matrices is in the script ``Interspersion\_analysis\_final.Rmd`` 
 which includes the usage of the
 ``run_get_ni,nj.sh`` script. 
 
