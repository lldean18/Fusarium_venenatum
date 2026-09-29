#!/bin/bash
# 10/9/26

# script to count SNPs in windows for plotting as a heatmap

# setup env
module load bcftools-uoneasy/1.19-GCC-13.2.0
reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
genome_identifier=ASM90000737v1
#reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic.fna
#genome_identifier=Fusven1
cd /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier
mkdir -p snp_density
#suffix=
suffix=_venenatum_only

# generate windows
bedtools makewindows -g $reference.fai -w 100000 > snp_density/windows_100kb.bed
bedtools makewindows -g $reference.fai -w 50000 > snp_density/windows_50kb.bed
bedtools makewindows -g $reference.fai -w 20000 > snp_density/windows_20kb.bed




##############################################
# count n snps / n callable bases in windows #
##############################################


# extract snp positions only
bcftools query -f '%CHROM\t%POS\t%REF\t%ALT\n' variants/FusVen$suffix.raw.vcf.gz |
awk 'length($3)==1 && length($4)==1 && $4 !~ /,/ {
    print $1"\t"$2-1"\t"$2
}' |
sort -k1,1 -k2,2n > snp_density/snps$suffix.bed

# Count SNPs in each window
bedtools intersect \
-a snp_density/windows_20kb.bed \
-b snp_density/snps$suffix.bed \
-c > snp_density/snp_counts_20kb$suffix.txt

bcftools query -f '%CHROM\t%POS\n' variants/FusVen$suffix.raw.vcf.gz |
awk '{print $1"\t"$2-1"\t"$2}' |
sort -k1,1 -k2,2n > snp_density/callable$suffix.bed

bedtools intersect \
-a snp_density/windows_20kb.bed \
-b snp_density/callable$suffix.bed \
-c > snp_density/callable_counts_20kb$suffix.txt

paste \
    snp_density/snp_counts_20kb$suffix.txt \
    snp_density/callable_counts_20kb$suffix.txt |
awk 'BEGIN {
    OFS="\t";
    print "chrom","start","end","n_snps","callable_bases","snp_density"
}
{
    callable=$7;
    snps=$4;
    if (callable > 0)
        density=snps/callable;
    else
        density="NA";
    print $1,$2,$3,snps,callable,density;
}' > snp_density/snp_density_20kb$suffix.txt

# correct format for circos
sed '1d' snp_density/snp_density_20kb$suffix.txt | cut -f1,2,3,6 > snp_density/for_circos_snp_density_20kb$suffix.txt

#######################
# count snps in windows
#######################

bedtools coverage \
-a snp_density/windows_100kb.bed \
-b variants/FusVen$suffix.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_100kb_winds$suffix.txt

bedtools coverage \
-a snp_density/windows_50kb.bed \
-b variants/FusVen$suffix.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_50kb_winds$suffix.txt

bedtools coverage \
-a snp_density/windows_20kb.bed \
-b variants/FusVen$suffix.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_20kb_winds$suffix.txt

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




