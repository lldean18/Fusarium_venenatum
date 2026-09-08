#!/bin/bash
# Laura Dean
# 16/3/26

# script to calculate depth of coverage from BAM files

#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --tasks-per-node=1
#SBATCH --mem=4g
#SBATCH --time=5:00:00
#SBATCH --job-name=coverage_calcs
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-27

# move to working dir
cd ~/data/paul_dyer

# set the config file (script make_array_configs.sh gives instructions on making the config)
CONFIG=~/code_and_scripts/config_files/fusarium_config.txt

# extract the sample name for this array step from the config file
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)

# load software
source $HOME/.bash_profile
conda activate samtools1.24


############################################
# CALCULATE COVERAGE DEPTH FOR EACH SAMPLE #
############################################

# calculate depth for all bams
samtools depth \
-a \
-J \
-H \
filtered_bams/$SAMPLE.bam |
awk -F '\t' '(NR==1) {split($0,header);N=0.0;next;} {N++;for(i=3;i<=NF;i++) a[i]+=int($i);} END { for(x in a) print header[x], a[x]/N;}' > filtered_bams/bam_info/${SAMPLE}_mapping_cov_depth.txt


# unload software
conda deactivate

