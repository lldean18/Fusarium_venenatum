#!/bin/bash
# 10/9/26

# script to filter raw variants
# I didn't use the output of this one in the end because it was throwing away most of the snps







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
# first because we kept invariant sites in the original vcf remove the * entries #
###################################################################################

bcftools view -e 'ALT="*"' FusVen$suffix.raw.vcf.gz -Oz -o tmp.vcf.gz
mv tmp.vcf.gz FusVen$suffix.raw.vcf.gz
bcftools index -t FusVen$suffix.raw.vcf.gz

################################################################################
# retain only sites where all samples have non-missing genotypes and depth >=3 #
################################################################################

bcftools view -i 'N_PASS(GT!="mis" && FMT/DP>=3)=N_SAMPLES' FusVen$suffix.raw.vcf.gz -Oz -o FusVen$suffix.callable.vcf.gz
bcftools index -t FusVen$suffix.callable.vcf.gz
# FusVen$suffix.callable.vcf.gz contains my total number of callable bases

####################################################
# extract only SNPs / indels for further filtering #
####################################################

singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.callable.vcf.gz \
--select-type-to-include SNP \
--output FusVen$suffix.callable.snps.vcf.gz


singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.callable.vcf.gz \
--select-type-to-include INDEL \
--output FusVen$suffix.callable.indels.vcf.gz

#######################################################################
# apply gatk best practice site level hard filters to snps and indels #
#######################################################################

# first mark the sites that pass the filters with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen$suffix.callable.snps.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "SOR > 3.0" --filter-name "SOR3" \
-filter "FS > 60.0" --filter-name "FS60" \
-filter "MQ < 40.0" --filter-name "MQ40" \
-filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
-filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
--output FusVen$suffix.callable.snps.SFmarked.vcf.gz

# then retain only reads with PASS for the snps
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.callable.snps.SFmarked.vcf.gz \
--exclude-filtered true \
--output FusVen$suffix.callable.snps.SF.vcf.gz
# FusVen$suffix.callable.snps.SF.vcf.gz is my file of callable snps


# first mark the reads that pass the filters with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk VariantFiltration \
--variant FusVen$suffix.callable.indels.vcf.gz \
-filter "QD < 2.0" --filter-name "QD2" \
-filter "QUAL < 30.0" --filter-name "QUAL30" \
-filter "FS > 200.0" --filter-name "FS200" \
-filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
--output FusVen$suffix.callable.indels.marked.vcf.gz

# then retain only reads with PASS for the indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant FusVen$suffix.callable.indels.marked.vcf.gz \
--exclude-filtered true \
--output FusVen$suffix.callable.indels.filtered.vcf.gz
# FusVen$suffix.callable.indels.filtered.vcf.gz is my file of callable indels

##################
# check how many variants were removed by filtering

# in the original file (with * sites removed) = 38,634,000
bcftools view -H FusVen$suffix.raw.vcf.gz | wc -l

# in the file with all callable bases = 36,740,223
bcftools view -H FusVen$suffix.callable.vcf.gz | wc -l 

# in the file with callable SNPs before SNP specific filtering = 125,703
bcftools view -H FusVen$suffix.callable.snps.vcf.gz | wc -l
# in the file with all callable SNPs = 122,846
bcftools view -H FusVen$suffix.callable.snps.SF.vcf.gz | wc -l

# in the file with all callable indels = 8,243
bcftools view -H FusVen$suffix.callable.indels.filtered.vcf.gz | wc -l





##############################################
##############################################


# check how many variants were filtered out by genotype-filtering
bcftools view -H FusVen$suffix.raw.snps.SF.vcf.gz | wc -l # 2,214,790 (for the haploid called) 2,227,569 (diploid called)
# for the fusven1 assembly: 2,211,601
# for _ven_only: 133,326
bcftools view -H FusVen$suffix.snps.filtered.vcf.gz | wc -l # 2,018,836 (for the haploid called) 1,709,395 (diploid called)
# for the fusven1 assembly: 2,132,397
# for _ven_only: 103,374


