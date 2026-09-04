#!/bin/bash



# Paul and Alex's sequencing data was uploaded using Rsync from their hard drive using e.g.:
#rsync -rvha --progress /Volumes/LaCie2/Fusarium_venenatum_genomes/Novogene_Fusarium_venenatum_final_4strains_114-5_114-10_114-12_114-24/Fvenx4genomesFullseqsResult/01.CleanData ada:/gpfs01/home/mbzlld/data/paul_dyer/

# the fastqs were then all moved into a single directory /gpfs01/home/mbzlld/data/paul_dyer/fastqs using:
cd /gpfs01/home/mbzlld/data/paul_dyer
find 01.CleanData -type f -name "*.fq.gz" -exec cp {} fastqs/ \;
find 01.CleanData_1 -type f -name "*.fq.gz" -exec cp {} fastqs/ \;

# then the odd hidden files were removed with:
find fastqs -maxdepth 1 -name ".*" -delete




# the reference genome was downloded from NCBI using:
cd /gpfs01/home/mbzlld/data/paul_dyer/reference_genomes
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.gff.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.gtf.gz

# and extracted with:
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.fna.gz
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.gtf.gz
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.gff.gz






