#!/bin/bash
# 8/9/26

# script to perform joint genotyping on individual level g.vcf.gz files with GATK4

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=60g
#SBATCH --time=60:00:00
#SBATCH --job-name=joint_genotype
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
module load singularity/3.8.5
#cd ~/software_bin/singularity
#singularity build gatk.sif docker://broadinstitute/gatk:latest
cd ~/data/paul_dyer
WKDIR=/gpfs01/home/mbzlld/data/paul_dyer


# consolidate gvcfs into a database
echo "MAKING THE DATABASE"
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk GenomicsDBImport \
--genomicsdb-workspace-path variants/FusariumDB \
--variant variants/114-1.g.vcf.gz \
--variant variants/114-2.g.vcf.gz \
--variant variants/114-3.g.vcf.gz \
--variant variants/114-4.g.vcf.gz \
--variant variants/114-5.g.vcf.gz \
--variant variants/114-6.g.vcf.gz \
--variant variants/114-7.g.vcf.gz \
--variant variants/114-8.g.vcf.gz \
--variant variants/114-9.g.vcf.gz \
--variant variants/114-10.g.vcf.gz \
--variant variants/114-11.g.vcf.gz \
--variant variants/114-12.g.vcf.gz \
--variant variants/114-13.g.vcf.gz \
--variant variants/114-14.g.vcf.gz \
--variant variants/114-15.g.vcf.gz \
--variant variants/114-16.g.vcf.gz \
--variant variants/114-17.g.vcf.gz \
--variant variants/114-18.g.vcf.gz \
--variant variants/114-19.g.vcf.gz \
--variant variants/114-20.g.vcf.gz \
--variant variants/114-21.g.vcf.gz \
--variant variants/114-22.g.vcf.gz \
--variant variants/114-23.g.vcf.gz \
--variant variants/114-24.g.vcf.gz \
--variant variants/114-25.g.vcf.gz \
--reference reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna \
--intervals NC_038015.1 \
--intervals NC_038016.1 \
--intervals NC_038012.1 \
--intervals NC_038013.1 \
--intervals NC_038014.1 \
--intervals NW_020311997.1 \
--reader-threads 8
echo "FINISHED MAKING THE DATABASE"
#119-01.g.vcf.gz
#120-01.g.vcf.gz


# perform joint genotype calling
echo "PERFORMING JOINT GENOTYPE CALLING"
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk GenotypeGVCFs \
--output variants/FusVen.raw.vcf.gz \
--reference reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna \
--variant gendb://variants/FusariumDB \
--annotation-group StandardAnnotation \
--annotation-group StandardHCAnnotation \
--call-genotypes true
echo "FINIHSED JOINT GENOTYPE CALLING"


#singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants --help

# split snps and indels
singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant variants/FusVen.raw.vcf.gz \
--select-type-to-include SNP \
--output variants/FusVen.raw.snps.vcf.gz

singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk SelectVariants \
--variant variants/FusVen.raw.vcf.gz \
--select-type-to-include INDEL \
--output variants/FusVen.raw.indels.vcf.gz





