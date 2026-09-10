#!/bin/bash
#8/9/26

# script to investigate reads that do not map to the reference genome

# setup env
srun --partition defq --cpus-per-task 8 --mem 20g --time 03:00:00 --pty bash
source $HOME/.bash_profile
conda activate samtools1.24
cd /gpfs01/home/mbzlld/data/paul_dyer/bams


# extract the unmapped reads and convert back to fastqs
for bam in *.bam
do
samtools sort -n -@ 8 $bam |
samtools fastq -n -f 4 \
    -1 ../unmapped_reads/${bam%.*}_unmapped_R1.fastq \
    -2 ../unmapped_reads/${bam%.*}_unmapped_R2.fastq \
    -0 /dev/null \
    -s ../unmapped_reads/${bam%.*}_unmapped_singletons.fastq \
    -
done

# compress the fastq files
cd ../unmapped_reads
gzip *.fastq


