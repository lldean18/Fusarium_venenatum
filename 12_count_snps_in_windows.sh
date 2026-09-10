#!/bin/bash
# 10/9/26

# script to count SNPs in windows for plotting as a heatmap

# setup env
cd /gpfs01/home/mbzlld/data/paul_dyer
mkdir -p snp_density

# generate windows
bedtools makewindows -g reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna.fai -w 100000 > snp_density/windows_100kb.bed
bedtools makewindows -g reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna.fai -w 50000 > snp_density/windows_50kb.bed
bedtools makewindows -g reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna.fai -w 20000 > snp_density/windows_20kb.bed

# count snps in windows
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

