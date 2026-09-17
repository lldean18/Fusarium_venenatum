#!/bin/bash
# 11/9/26

# script to generate a circos plot for Fusarium veneneatum

# setup env
srun --partition defq --cpus-per-task 4 --mem 20g --time 08:00:00 --pty bash
source $HOME/.bash_profile
conda activate circos

# move to working dir
#reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
#genome_identifier=ASM90000737v1
reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic.fna
genome_identifier=Fusven1
mkdir -p /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/circos
cd /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/circos


#####################
### PREP ASSEMBLY ###
#####################

# convert assembly to the right format
# without naming the chrs with their chr names
awk '{print "chr - " $1 " " $1 " 0 " $2 " chr1"}' ${reference}.fai > karyotype.txt

# for the ASM90000737v1 assembly, extract chromosome names for plotting
awk 'NR==FNR {map[$1]=$2; next}
     {print "chr - " $1 " " map[$1] " 0 " $2 " chr1"}' chr_names_mapping_info.txt ${reference}.fai > karyotype.txt


##############################
### PREP GENOME ANNOTATION ###
##############################

# convert annotation to circos format
awk '$3=="CDS"' ${reference%.*}.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes.txt

# make separate annotation files for genes on fwd and rev strands (strand info is 7th column)
# fwd strand
awk '$3=="CDS" && $7=="+"' ${reference%.*}.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes_fwd_strand.txt
# rev strand
awk '$3=="CDS" && $7=="-"' ${reference%.*}.gff |
awk '{print $1, $4, $5}' OFS="\t" > genes_rev_strand.txt

#######################
### PREP GC CONTENT ###
#######################

# calculate GC content across genome
bedtools nuc -fi $reference -bed ../snp_density/windows_20kb.bed > gc_content_20kb.txt
# extract the relavent columns for circos
awk 'NR>1 {print $1, $2, $3, $5}' gc_content_20kb.txt > gc_track.txt
# calculate mean GC content
awk '{sum+=$4; n++} END {print sum/n}' gc_track.txt
# 0.476912 = mean GC content of 1st ref
# 0.476331 = mean GC content of FusVen1
# make a track with GC content centered around the mean
awk -v mean=$(awk '{sum+=$4; n++} END {print sum/n}' gc_track.txt) '{print $1,$2,$3,$4-mean}' gc_track.txt > gc_dev.txt


#####################
### TO RUN CIRCOS ###
#####################
# make the circos.conf file stipulating how you want the plot to be then
# in the dir with the circos.conf file run:
conda activate circos
circos

