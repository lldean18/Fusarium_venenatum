#!/bin/bash



# Paul and Alex's sequencing data was uploaded using Rsync from their hard drive using e.g.:
#rsync -rvha --progress /Volumes/LaCie2/Fusarium_venenatum_genomes/Novogene_Fusarium_venenatum_final_4strains_114-5_114-10_114-12_114-24/Fvenx4genomesFullseqsResult/01.CleanData ada:/gpfs01/home/mbzlld/data/paul_dyer/

# the fastqs were then all moved into a single directory /gpfs01/home/mbzlld/data/paul_dyer/fastqs using:
cd /gpfs01/home/mbzlld/data/paul_dyer
find 01.CleanData -type f -name "*.fq.gz" -exec cp {} fastqs/ \;
find 01.CleanData_1 -type f -name "*.fq.gz" -exec cp {} fastqs/ \;

# then the odd hidden files were removed with:
find fastqs -maxdepth 1 -name ".*" -delete

# then multiple runs per individual were conatenated with:
cat 114-19_HFL22DSX2_L2_1.clean.fq.gz 114-19_HGHF2DSX2_L4_1.clean.fq.gz > 114-19_1.clean.fq.gz
rm 114-19_HFL22DSX2_L2_1.clean.fq.gz 114-19_HGHF2DSX2_L4_1.clean.fq.gz

cat 114-19_HFL22DSX2_L2_2.clean.fq.gz 114-19_HGHF2DSX2_L4_2.clean.fq.gz > 114-19_2.clean.fq.gz
rm 114-19_HFL22DSX2_L2_2.clean.fq.gz 114-19_HGHF2DSX2_L4_2.clean.fq.gz

cat D11422_HFL22DSX2_L2_1.clean.fq.gz D11422_HGHF2DSX2_L4_1.clean.fq.gz > D11422_1.clean.fq.gz
rm D11422_HFL22DSX2_L2_1.clean.fq.gz D11422_HGHF2DSX2_L4_1.clean.fq.gz

cat D11422_HFL22DSX2_L2_2.clean.fq.gz D11422_HGHF2DSX2_L4_2.clean.fq.gz > D11422_2.clean.fq.gz
rm D11422_HFL22DSX2_L2_2.clean.fq.gz D11422_HGHF2DSX2_L4_2.clean.fq.gz

cat D11423_HFL22DSX2_L2_1.clean.fq.gz D11423_HGHF2DSX2_L4_1.clean.fq.gz > D11423_1.clean.fq.gz
rm D11423_HFL22DSX2_L2_1.clean.fq.gz D11423_HGHF2DSX2_L4_1.clean.fq.gz

cat D11423_HFL22DSX2_L2_2.clean.fq.gz D11423_HGHF2DSX2_L4_2.clean.fq.gz > D11423_2.clean.fq.gz
rm D11423_HFL22DSX2_L2_2.clean.fq.gz D11423_HGHF2DSX2_L4_2.clean.fq.gz

cat D1144_HFL22DSX2_L2_1.clean.fq.gz D1144_HGHF2DSX2_L4_1.clean.fq.gz > D1144_1.clean.fq.gz
rm D1144_HFL22DSX2_L2_1.clean.fq.gz D1144_HGHF2DSX2_L4_1.clean.fq.gz

cat D1144_HFL22DSX2_L2_2.clean.fq.gz D1144_HGHF2DSX2_L4_2.clean.fq.gz > D1144_2.clean.fq.gz
rm D1144_HFL22DSX2_L2_2.clean.fq.gz D1144_HGHF2DSX2_L4_2.clean.fq.gz

cat D1146_HFL22DSX2_L2_1.clean.fq.gz D1146_HGHF2DSX2_L4_1.clean.fq.gz > D1146_1.clean.fq.gz
rm D1146_HFL22DSX2_L2_1.clean.fq.gz D1146_HGHF2DSX2_L4_1.clean.fq.gz

cat D1146_HFL22DSX2_L2_2.clean.fq.gz D1146_HGHF2DSX2_L4_2.clean.fq.gz > D1146_2.clean.fq.gz
rm D1146_HFL22DSX2_L2_2.clean.fq.gz D1146_HGHF2DSX2_L4_2.clean.fq.gz

cat D1148_HWFCWDSXY_L1_1.clean.fq.gz D1148_HGHF2DSX2_L4_1.clean.fq.gz > D1148_1.clean.fq.gz
rm D1148_HWFCWDSXY_L1_1.clean.fq.gz D1148_HGHF2DSX2_L4_1.clean.fq.gz

cat D1148_HWFCWDSXY_L1_2.clean.fq.gz D1148_HGHF2DSX2_L4_2.clean.fq.gz > D1148_2.clean.fq.gz
rm D1148_HWFCWDSXY_L1_2.clean.fq.gz D1148_HGHF2DSX2_L4_2.clean.fq.gz


# the reference genome was downloded from NCBI using:
cd /gpfs01/home/mbzlld/data/paul_dyer/reference_genomes
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.gff.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/900/007/375/GCF_900007375.1_ASM90000737v1/GCF_900007375.1_ASM90000737v1_genomic.gtf.gz

# and extracted with:
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.fna.gz
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.gtf.gz
gunzip -k GCF_900007375.1_ASM90000737v1_genomic.gff.gz






