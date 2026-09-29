#!/bin/bash
# Laura Dean
# 29/9/26

# script to detect structural variants from illumina short read data with gridss

#SBATCH --job-name=gridss
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=40g
#SBATCH --time=12:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
mkdir -p ~/data/paul_dyer/variants/SVs
cd ~/data/paul_dyer/variants/SVs

# set variables
reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
genome_identifier=ASM90000737v1
##reference=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic.fna
##genome_identifier=Fusven1
suffix=
#suffix=_venenatum_only


# run structural variant detection
/gpfs01/home/mbzlld/software_bin/gridss/gridss \
--jar /gpfs01/home/mbzlld/software_bin/gridss/gridss-2.13.2-gridss-jar-with-dependencies.jar \
--reference $reference \
--output Fusven_SVs$suffix \
--threads 16 \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-1.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-2.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-3.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-4.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-5.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-6.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-7.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-8.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-9.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-12.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-13.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-14.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-15.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-16.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-17.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-18.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-20.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-21.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-22.bam \
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-25.bam




