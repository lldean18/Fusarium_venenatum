#!/bin/bash
# 10/9/26

# script to filter raw variants

#setup env
srun --partition defq --cpus-per-task 4 --mem 20g --time 06:00:00 --pty bash
module load bcftools-uoneasy/1.19-GCC-13.2.0
module load singularity/3.8.5
#cd ~/software_bin/singularity
#singularity build gatk.sif docker://broadinstitute/gatk:latest
WKDIR=/gpfs01/home/mbzlld/data/paul_dyer/variants
cd /gpfs01/home/mbzlld/data/paul_dyer/variants


####################################################
# apply gatk best practice site level hard filters #
####################################################

# first mark the reads that pass the filters with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen.raw.snps.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
--output FusVen.raw.snps.SFmarked.vcf.gz

# then retain only reads with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen.raw.snps.SFmarked.vcf.gz \
--exclude-filtered true \
--output FusVen.raw.snps.SF.vcf.gz

# first mark the reads that pass the filters with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen.raw.indels.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "FS > 200.0" --filter-name "FS200" \
-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
--output FusVen.raw.indels.marked.vcf.gz

# then retain only reads with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen.raw.indels.marked.vcf.gz \
--exclude-filtered true \
--output FusVen.raw.indels.filtered.vcf.gz



# check how many variants were removed by site-level filtering in the vcf
bcftools view -H FusVen.raw.snps.vcf.gz | wc -l # 2,255,743 (haploid called) 2,274,351 (diploid called)
bcftools view -H FusVen.raw.snps.SF.vcf.gz | wc -l # 2,214,790 (haploid called) 2,227,569 (diploid called)

# then check how many indels were removed by filtering
bcftools view -H FusVen.raw.indels.vcf.gz | wc -l # 234,474 (haploid called) 238,651 (diploid called)
bcftools view -H FusVen.raw.indels.filtered.vcf.gz | wc -l # 234,296 (haploid called) 237,897 (diploid called)



##############################################
# Apply genotype-level filters with bcftools #
##############################################

# first check the annotations I want to use are present in the vcf
bcftools view -h FusVen.raw.snps.SF.vcf.gz | grep -E 'ID=(QD|MQ|FS|SOR|MQRankSum|ReadPosRankSum|ExcessHet)'

# set genotypes to missing if they have a depth (DP) <10 or a genotype quality (GQ) <20
bcftools +setGT \
    FusVen.raw.snps.SF.vcf.gz \
    -Oz \
    -o FusVen.raw.snps.SF.GFset.vcf.gz \
    -- \
    -t q \
    -n . \
    -i 'FMT/DP<10 || FMT/GQ<20'
bcftools index -t FusVen.raw.snps.SF.GFset.vcf.gz

# reset the missingness tags
bcftools +fill-tags \
    FusVen.raw.snps.SF.GFset.vcf.gz \
    -Oz \
    -o FusVen.raw.snps.SF.GFset.miss.vcf.gz \
    -- -t F_MISSING,MAF,AF,AC,AN
bcftools index -t FusVen.raw.snps.SF.GFset.miss.vcf.gz

# now filter for missingness
bcftools view \
    -i 'INFO/F_MISSING<=0.20' \
    FusVen.raw.snps.SF.GFset.miss.vcf.gz \
    -Oz \
    -o FusVen.snps.filtered.vcf.gz
bcftools index -t FusVen.snps.filtered.vcf.gz

# check how many variants were filtered out by genotype-filtering
bcftools view -H FusVen.raw.snps.SF.vcf.gz | wc -l # 2,214,790 (for the haploid called) 2,227,569 (diploid called)
bcftools view -H FusVen.snps.filtered.vcf.gz | wc -l # 387,583 (for the haploid called) 1,709,395 (diploid called)


