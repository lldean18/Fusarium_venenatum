#!/bin/bash
# 11/9/26

# script to generate a circos plot for Fusarium veneneatum

# move to working dir
cd /gpfs01/home/mbzlld/data/paul_dyer
mkdir -p circos
cd circos

# setup env
source $HOME/.bash_profile
conda activate circos

#####################
### PREP ASSEMBLY ###
#####################

# convert assembly to the right format
assembly=../reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
awk '{print "chr - " $1 " " $1 " 0 " $2 " chr1"}' ${assembly}.fai > karyotype.txt


##############################
### PREP GENOME ANNOTATION ###
##############################

# convert annotation to circos format
awk '$3=="CDS"' ../reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes.txt

# make separate annotation files for genes on fwd and rev strands (strand info is 7th column)
# fwd strand
awk '$3=="CDS" && $7=="+"' ../reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes_fwd_strand.txt
# rev strand
awk '$3=="CDS" && $7=="-"' ../reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes_rev_strand.txt

#######################
### PREP GC CONTENT ###
#######################

# calculate GC content across genome
bedtools nuc -fi $assembly -bed ../snp_density/windows_20kb.bed > gc_content_20kb.txt
# extract the relavent columns for circos
awk 'NR>1 {print $1, $2, $3, $5}' gc_content_20kb.txt > gc_track.txt
# calculate mean GC content
awk '{sum+=$4; n++} END {print sum/n}' gc_track.txt
# 0.476912 = mean GC content
# make a track with GC content centered around the mean
awk -v mean=0.476912 '{print $1,$2,$3,$4-mean}' gc_track.txt > gc_dev.txt





