#!/bin/bash
# Laura Dean
# 13/11/26

# script to generate a consensus sequence from a reference and vcf 

#SBATCH --job-name=consensus
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=30g
#SBATCH --time=48:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out


# setup env
source $HOME/.bash_profile
conda activate samtools1.24
module load bcftools-uoneasy/1.19-GCC-13.2.0
mkdir -p /gpfs01/home/mbzlld/data/paul_dyer/ASM90000737v1/consensus_sequences
cd /gpfs01/home/mbzlld/data/paul_dyer/ASM90000737v1/consensus_sequences


# setup variables
REFERENCE=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
VCF=/gpfs01/home/mbzlld/data/paul_dyer/ASM90000737v1/variants/FusVen.snps.filtered.vcf.gz
INDIVIDUALS=(114-5 114-10 114-12 114-24)


## index the reference and vcf files in case they're not already indexed
#samtools faidx $REFERENCE
#bcftools index $VCF

# generate consensus sequences for each individual
for INDIVIDUAL in ${INDIVIDUALS[@]}
do
bcftools consensus \
  --fasta-ref $REFERENCE \
  --samples $INDIVIDUAL \
  $VCF > ${INDIVIDUAL}_consensus.fa
done

# cleanup env
conda deactivate
module unload bcftools-uoneasy/1.19-GCC-13.2.0


