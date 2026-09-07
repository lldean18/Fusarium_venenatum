#!/bin/bash
# 7/9/26

# script to map reads to a reference genome

#SBATCH --job-name=MapReads
#SBATCH --partition=defq
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem=120g
#SBATCH --time=6:00:00
#SBATCH --output=/gpfs01/home/mbzlld/code_and_scripts/slurm_out_scripts/slurm-%x-%j.out
#SBATCH --array=1-27


# move to working directory
cd /gpfs01/home/mbzlld/data/paul_dyer

# set the config file (script make_array_configs.sh gives instructions on making the config)
CONFIG=~/code_and_scripts/config_files/fusarium_config.txt

# extract the information for this array step from the config file
ARRAY_STEP=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $1}' $CONFIG)
IDENTIFIER=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $2}' $CONFIG)
SAMPLE=$(awk -v ArrayTaskID=$SLURM_ARRAY_TASK_ID '$1==ArrayTaskID {print $3}' $CONFIG)
echo "mapping reads for array step $ARRAY_STEP for the sample $SAMPLE with the files ${IDENTIFIER}_1.fq.gz and ${IDENTIFIER}_2.fq.gz"

# name the forward and reverse reads for this array step using the sample info
fwd_reads=${IDENTIFIER}_1.clean.fq.gz
rev_reads=${IDENTIFIER}_2.clean.fq.gz

# set the reference genome that we will map the reads to
# the reference must be indexed with the bwa index command once before running this script
ref=reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna.gz

# load software
source $HOME/.bash_profile
conda activate samtools1.24
module load bwa-uoneasy/0.7.17-GCCcore-12.3.0
module load picard-uoneasy/3.0.0-Java-17

# make a dir for the mapped bams and one for info
mkdir -p bams
mkdir -p bams/bam_info


#####################################
# MAP READS TO THE REFERENCE GENOME #
#####################################

###### Align the reads to the reference genome using bwa mem ######
# BWA MEM command explanation:
# -M = Mark shorter split hits as secondary (for Picard compatibility)
# -R = Specify info to go in read group header line
bwa mem \
-t 19 \
-M \
-R "@RG\tID:"$SAMPLE"\tSM:"$SAMPLE"\tPL:ILLUMINA\tLB:"$SAMPLE"\tPU:"$SAMPLE"" \
$ref \
fastqs/$fwd_reads \
fastqs/$rev_reads |
# add mate score tags then
# sort and index the bam files
samtools fixmate --threads 19 -m -O BAM - - |
samtools sort --threads 19 -o bams/${SAMPLE}_tmp.bam
samtools index bams/${SAMPLE}_tmp.bam

# remove pcr duplicaltes with picard
java -Xmx1g -jar $EBROOTPICARD/picard.jar \
MarkDuplicates \
REMOVE_DUPLICATES=true \
ASSUME_SORTED=true \
VALIDATION_STRINGENCY=SILENT \
MAX_FILE_HANDLES_FOR_READ_ENDS_MAP=1000 \
INPUT=bams/${SAMPLE}_tmp.bam \
OUTPUT=bams/${SAMPLE}.bam \
METRICS_FILE=bams/bam_info/${SAMPLE}.rmd.bam.metrics

# index the final bam file
samtools index bams/${SAMPLE}.bam

# remove the temp file with duplicates not removed
rm bams/${SAMPLE}_tmp.bam*



# Generate info about how well the reads mapped
echo "the reads mapped with the following success:" > bams/bam_info/${SAMPLE}_mapping_info.txt
samtools flagstat --threads 19 bams/$SAMPLE.bam >> bams/bam_info/${SAMPLE}_mapping_info.txt

# deactivate software
conda deactivate
module unload bwa-uoneasy/0.7.17-GCCcore-12.3.0
module unload picard-uoneasy/3.0.0-Java-17

