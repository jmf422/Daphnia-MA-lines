#$ -S /bin/bash
#$ -q regular.q
#$ -j y
#$ -N get_ni,nj
#$ -cwd

# qsub run_get_ni,nj.sh

#date
d1=$(date +%s)
echo $HOSTNAME
echo $1

/programs/bin/labutils/mount_server cbsufsrv5 /data1 ## Mount data server

mkdir -p /workdir/$USER/$JOB_ID

cd /workdir/$USER/$JOB_ID

cp /fs/cbsufsrv5/data1/jmf422/DaphniaKmer/kseek_Results/C01.seqprep.all.fastq.rep .

cp $HOME/extract.py .
cp $HOME/common.kmer.names39.txt .

# read in file of the common kmers line by line, and execute on each of them

# this is your output file
qsub="C01.total.reads.txt"

input="common.kmer.names39.txt"
while read -r kmer
do
	python extract.py $kmer C01.seqprep.all.fastq.rep -o C01.$kmer.reads.fasta
	less C01.$kmer.reads.fasta | grep '^>' | cut -f 5,6,7 -d ":" | awk 'OFS="\t" {print $1, $2}' > C01.$kmer.readnames.txt
	less C01.$kmer.readnames.txt | sort -n -k1 | cut -f 1 | uniq -c | wc -l >> $qsub
done < "$input"

mv C01.total.reads.txt $HOME 
mv C01.A.reads.fasta $HOME
mv C01.A.readnames.txt $HOME


cd ..
rm -r ./$JOB_ID

#date
d2=$(date +%s)
sec=$(( ( $d2 - $d1 ) ))
hour=$(echo - | awk '{ print '$sec'/3600}')
echo Runtime: $hour hours \($sec\s\)
