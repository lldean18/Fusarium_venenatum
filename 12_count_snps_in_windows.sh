#!/bin/bash
# 10/9/26

# script to count SNPs in windows for plotting as a heatmap

# setup env
#reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
#genome_identifier=ASM90000737v1
reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic.fna
genome_identifier=Fusven1
cd /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier
mkdir -p snp_density

# generate windows
bedtools makewindows -g $reference.fai -w 100000 > snp_density/windows_100kb.bed
bedtools makewindows -g $reference.fai -w 50000 > snp_density/windows_50kb.bed
bedtools makewindows -g $reference.fai -w 20000 > snp_density/windows_20kb.bed

#######################
# count snps in windows
#######################

bedtools coverage \
-a snp_density/windows_100kb.bed \
-b variants/FusVen.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_100kb_winds.txt

bedtools coverage \
-a snp_density/windows_50kb.bed \
-b variants/FusVen.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_50kb_winds.txt

bedtools coverage \
-a snp_density/windows_20kb.bed \
-b variants/FusVen.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_20kb_winds.txt

########################
# coung genes in windows
########################

# filter the gff to retain only genes
awk -F'\t' '$3 == "gene"' ${reference%.*}.gff > ${reference%.*}_genes.gff

# count the genes across windows
bedtools coverage \
    -a snp_density/windows_20kb.bed \
    -b ${reference%.*}_genes.gff \
    -counts \
    > snp_density/gene_counts_20kb_winds.txt




