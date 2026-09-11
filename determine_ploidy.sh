#!/bin/bash
# 10/9/26

cd /gpfs01/home/mbzlld/data/paul_dyer/variants_diploid_assumed

# assess ploidy based on the vcf with snps called assuming diploid
bcftools query -i 'TYPE="snp" && QUAL>=30 && FORMAT/DP>=20' \
-f '%CHROM\t%POS\t%REF\t%ALT\t%QUAL\t[%GT\t%DP\t%AD{0}\t%AD{1}]\n' FusVen.snps.filtered.vcf.gz |
awk 'BEGIN {OFS="\t"} {if ($7 > 0) vaf=$9/$7; else vaf=0; print $0, vaf}' > vaf_distribution.txt

