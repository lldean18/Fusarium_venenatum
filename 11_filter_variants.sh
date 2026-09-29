#!/bin/bash
# 10/9/26

# script to filter raw variants

#setup env
srun --partition defq --cpus-per-task 4 --mem 20g --time 06:00:00 --pty bash
source $HOME/.bash_profile
module load bcftools-uoneasy/1.19-GCC-13.2.0
module load singularity/3.8.5
#cd ~/software_bin/singularity
#singularity build gatk.sif docker://broadinstitute/gatk:latest
#genome_identifier=Fusven1
genome_identifier=ASM90000737v1
WKDIR=/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/variants
cd /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/variants
#suffix=
suffix=_venenatum_only


###################################################################################
# first if you have kept invariant sites in the original vcf remove the * entries #
###################################################################################

bcftools view -e 'ALT="*"' FusVen$suffix.raw.snps.vcf.gz -Oz -o tmp.vcf.gz
mv tmp.vcf.gz FusVen$suffix.raw.snps.vcf.gz
bcftools index -t FusVen$suffix.raw.snps.vcf.gz

####################################################
# apply gatk best practice site level hard filters #
####################################################

# first mark the reads that pass the filters with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen$suffix.raw.snps.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
--output FusVen$suffix.raw.snps.SFmarked.vcf.gz

# then retain only reads with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.raw.snps.SFmarked.vcf.gz \
--exclude-filtered true \
--output FusVen$suffix.raw.snps.SF.vcf.gz

# first mark the reads that pass the filters with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen$suffix.raw.indels.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "FS > 200.0" --filter-name "FS200" \
-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
--output FusVen$suffix.raw.indels.marked.vcf.gz

# then retain only reads with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.raw.indels.marked.vcf.gz \
--exclude-filtered true \
--output FusVen$suffix.raw.indels.filtered.vcf.gz



# check how many variants were removed by site-level filtering in the vcf
bcftools view -H FusVen$suffix.raw.snps.vcf.gz | wc -l # 2,252,872 # 139,025 _ven_only 
bcftools view -H FusVen$suffix.raw.snps.SF.vcf.gz | wc -l # 2,211,601 # 133,326 _ven_only

# then check how many indels were removed by filtering
bcftools view -H FusVen$suffix.raw.indels.vcf.gz | wc -l # 233,973 # 9653 _ven_only
bcftools view -H FusVen$suffix.raw.indels.filtered.vcf.gz | wc -l # 233,783 # 9618 _ven_only



##############################################
# Apply genotype-level filters with bcftools #
##############################################

# first check the annotations I want to use are present in the vcf
bcftools view -h FusVen$suffix.raw.snps.SF.vcf.gz | grep -E 'ID=(QD|MQ|FS|SOR|MQRankSum|ReadPosRankSum|ExcessHet)'

# set genotypes to missing if they have a depth (DP) <10 or a genotype quality (GQ) <20
bcftools +setGT \
    FusVen$suffix.raw.snps.SF.vcf.gz \
    -Oz \
    -o FusVen$suffix.raw.snps.SF.GF1set.vcf.gz \
    -- \
    -t q \
    -n . \
    -i 'FMT/DP<8'
bcftools index -t FusVen$suffix.raw.snps.SF.GF1set.vcf.gz

bcftools +setGT \
    FusVen$suffix.raw.snps.SF.GF1set.vcf.gz \
    -Oz \
    -o FusVen$suffix.raw.snps.SF.GFset.vcf.gz \
    -- \
    -t q \
    -n . \
    -i 'FMT/GQ<20'
bcftools index -t FusVen$suffix.raw.snps.SF.GFset.vcf.gz

# reset the missingness tags
bcftools +fill-tags \
    FusVen$suffix.raw.snps.SF.GFset.vcf.gz \
    -Oz \
    -o FusVen$suffix.raw.snps.SF.GFset.miss.vcf.gz \
    -- -t F_MISSING,MAF,AF,AC,AN,NS
bcftools index -t FusVen$suffix.raw.snps.SF.GFset.miss.vcf.gz



# now filter for missingness
bcftools view \
    -e 'INFO/F_MISSING>0.25' \
    FusVen$suffix.raw.snps.SF.GFset.miss.vcf.gz \
    -Oz \
    -o FusVen$suffix.snps.filtered.vcf.gz
bcftools index -t FusVen$suffix.snps.filtered.vcf.gz

# check how many variants were filtered out by genotype-filtering
bcftools view -H FusVen$suffix.raw.snps.SF.vcf.gz | wc -l # 2,214,790 (for the haploid called) 2,227,569 (diploid called)
# for the fusven1 assembly: 2,211,601
# for _ven_only: 133,326
bcftools view -H FusVen$suffix.snps.filtered.vcf.gz | wc -l # 2,018,836 (for the haploid called) 1,709,395 (diploid called)
# for the fusven1 assembly: 2,132,397
# for _ven_only: 103,374


