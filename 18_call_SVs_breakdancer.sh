#!/bin/bash
# Laura Dean
# 29/9/26

# script to detect structural variants from illumina short read data with gridss

#SBATCH --job-name=gridss
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=30g
#SBATCH --time=12:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate breakdancer

# set variables
genome_identifier=ASM90000737v1
##genome_identifier=Fusven1


mkdir -p ~/data/paul_dyer/$genome_identifier/variants/SVs
cd ~/data/paul_dyer/$genome_identifier/variants/SVs

#suffix=

# for venenatum only
suffix=_venenatum_only
#list of bams
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-1.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-2.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-3.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-4.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-5.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-6.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-7.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-8.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-9.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-12.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-13.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-14.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-15.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-16.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-17.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-18.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-20.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-21.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-22.bam \
# /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-25.bam



# prepare config file from bams for running breakdancer
bam2cfg.pl \
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
/gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/bams/114-25.bam > breakdancer${suffix}.config

# run structural variant detection
breakdancer-max breakdancer${suffix}.config > breakdancer_SVs$suffix.out

# cleanup env
conda deactivate


