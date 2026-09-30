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

# count snps in each window
bedtools coverage \
-a snp_density/windows_20kb.bed \
-b variants/FusVen$suffix.snps.filtered.vcf.gz \
-counts > snp_density/snp_counts_20kb_winds$suffix.txt

# count callable bases in each window
bedtools map \
-a snp_density/windows_20kb.bed \
-b filtered_bams/bam_info/callable_sites_with_summed_site-level_depth$suffix.bed \
-c 4 \
-o count \
> snp_density/callable_sites${suffix}_20kb.bed

# divide snps by callable bases to get true snp density
awk 'NR==FNR { callable[$1 FS $2 FS $3]=$4; next }
     { key=$1 FS $2 FS $3;
       if (callable[key] > 0)
           printf "%s\t%s\t%s\t%.10f\n",$1,$2,$3,$4/callable[key];
       else
           print $1,$2,$3,"NaN" }' \
    OFS="\t" snp_density/callable_sites${suffix}_20kb.bed \
    snp_density/snp_counts_20kb_winds$suffix.txt \
    > snp_density/snp_DENSITY_20kb_winds$suffix.txt

# delete lines containing NA (i.e. where no bases could be called)
sed -i '/NaN/d' snp_density/snp_DENSITY_20kb_winds$suffix.txt

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


################3###############################
# count n indels / n callable bases in windows #
################################################

# count snps in each window
bedtools coverage \
-a snp_density/windows_20kb.bed \
-b variants/FusVen$suffix.raw.indels.filtered.vcf.gz \
-counts > snp_density/indel_counts_20kb_winds$suffix.txt

# divide indels by callable bases to get true indel density
awk 'NR==FNR { callable[$1 FS $2 FS $3]=$4; next }
     { key=$1 FS $2 FS $3;
       if (callable[key] > 0)
           printf "%s\t%s\t%s\t%.10f\n",$1,$2,$3,$4/callable[key];
       else
           print $1,$2,$3,"NaN" }' \
    OFS="\t" snp_density/callable_sites${suffix}_20kb.bed \
    snp_density/indel_counts_20kb_winds$suffix.txt \
    > snp_density/indel_DENSITY_20kb_winds$suffix.txt

# delete lines containing NA (i.e. where no bases could be called)
sed -i '/NaN/d' snp_density/indel_DENSITY_20kb_winds$suffix.txt



