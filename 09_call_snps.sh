#!/bin/bash
# 8/9/26

# script to call snps with GATK4

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=60g
#SBATCH --time=40:00:00
#SBATCH --job-name=call_snps
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-27


# set the config file (script make_array_configs.sh gives instructions on making the config)
CONFIG=~/code_and_scripts/config_files/fusarium_config.txt
# extract the sample name for this array step from the config file
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)
echo "filtering mapped reads for sample $SAMPLE"


# setup env
module load singularity/3.8.5
#cd ~/software_bin/singularity
#singularity build gatk.sif docker://broadinstitute/gatk:latest
mkdir -p ~/data/paul_dyer/variants
cd ~/data/paul_dyer
WKDIR=/gpfs01/home/mbzlld/data/paul_dyer


# index the reference
#singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk CreateSequenceDictionary -R reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna


singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk HaplotypeCaller \
--input filtered_bams/$SAMPLE.bam \
--output variants/$SAMPLE.g.vcf.gz \
--reference reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna \
--emit-ref-confidence GVCF \
--native-pair-hmm-threads 16


#singularity exec -B ${WKDIR}:${WKDIR} ~/software_bin/singularity/gatk.sif gatk HaplotypeCaller --help





