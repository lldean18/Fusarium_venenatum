#!/bin/bash
# Laura Dean
# 16/9/26



#SBATCH --job-name=ragtag_scaffold
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=30g
#SBATCH --time=12:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out

# setup env
source $HOME/.bash_profile
conda activate ragtag
cd /gpfs01/home/mbzlld/data/paul_dyer/reference_genomes
assembly=GCF_020744135.1_Fusven1_genomic.fna
reference=GCF_900007375.1_ASM90000737v1_genomic.fna


# scaffold assembly
ragtag.py scaffold -t 16 -o ${assembly%.*}_ragtag $reference $assembly

# get rid of the ragtag suffixes
sed -i 's/_RagTag//' ${assembly%.*}_ragtag/ragtag.scaffold.fasta


# cleanup env
conda deactivate


