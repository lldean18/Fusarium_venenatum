#!/bin/bash
# 8/9/26

# script to filter mapped reads

#SBATCH --job-name=FilterReads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=100g
#SBATCH --time=24:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-27

# move to working directory
cd ~/data/paul_dyer

# set the config file (script make_array_configs.sh gives instructions on making the config)
CONFIG=~/code_and_scripts/config_files/fusarium_config.txt


# extract the sample name for this array step from the config file
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)
echo "filtering mapped reads for sample $SAMPLE"

# load software
source $HOME/.bash_profile
conda activate samtools1.24

# make a dir for the mapped bams and one for info
mkdir -p filtered_bams
mkdir -p filtered_bams/bam_info


#######################
# FILTER MAPPED READS #
#######################

# Remove unmapped reads and do quality filtering
# -q mapping quality greater than or equal to 40
# -f include reads mapped in a propper pair
# -F 2308 Only include reads which are not read unmapped or mate unmapped and not secondary or supplementary alignments
samtools view \
--threads 16 \
-q 40 \
-f 2 \
-F 2308 \
-b bams/$SAMPLE.bam |
# Mark and remove duplicate reads (again)
samtools markdup \
-r \
--threads 16 \
- filtered_bams/$SAMPLE.bam

# index the final bam file
samtools index --threads 16 filtered_bams/$SAMPLE.bam

# Generate info about how well the reads mapped
echo "the filtered reads were mapped with the following success:" > filtered_bams/bam_info/${SAMPLE}_filtered_mapping_info.txt
samtools flagstat --threads 16 filtered_bams/$SAMPLE.bam >> filtered_bams/bam_info/${SAMPLE}_filtered_mapping_info.txt

# deactivate software
conda deactivate

