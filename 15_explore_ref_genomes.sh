#!/bin/bash
# Laura Dean
# 17/9/26

# script to make some teloexplorer plots and genome comparison plots
# of the different Fusarium venenatum genome assemblies

# setup env
srun --partition defq --cpus-per-task 4 --mem 20g --time 08:00:00 --pty bash
source $HOME/.bash_profile
cd /gpfs01/home/mbzlld/data/paul_dyer/exploring_references

ref1=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_900007375.1_ASM90000737v1_genomic.fna
ref2=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic.fna

genomes=( $ref1 $ref2 )

########################################
# run the telomere explorer for all the references
mkdir -p teloexplorer
conda activate quartet
for genome in ${genomes[@]}
do
python ~/software_bin/quarTeT/quartet.py TeloExplorer \
	-i $genome \
	-c other \
	-p teloexplorer/$(basename ${genome%.*})_teloexplorer
done
rm -r tmp
conda deactivate
########################################


########################################
# prep files to plot assemblies against each other with syri
mkdir -p plotsr
# assign the ragtag scaffolded version of ref2
ref2scaf=/gpfs01/home/mbzlld/data/paul_dyer/reference_genomes/GCF_020744135.1_Fusven1_genomic_ragtag/ragtag.scaffold.fasta
# identify contig names
grep ">" $ref1
grep ">" $ref2scaf

# copy refs to dir with only contigs that occur in both and fix names
# for ref1
cp $ref1 plotsr/
conda activate seqkit
# retain only the four contigs that map between the assemblies with ragtag
seqkit grep -r -p "NC_038012.1|NC_038013.1|NC_038014.1|NC_038015.1" plotsr/$(basename $ref1) > plotsr/tmp
mv plotsr/tmp plotsr/$(basename $ref1)
# remove the first space and everything after it from every fasta header
sed -i '/^>/ s/ .*$//' plotsr/$(basename $ref1)
# for ref2
cp $ref2scaf plotsr/
# retain only the four contigs that map between the assemblies with ragtag
seqkit grep -r -p "NC_038012.1|NC_038013.1|NC_038014.1|NC_038015.1" plotsr/$(basename $ref2scaf) > plotsr/tmp
mv plotsr/tmp plotsr/$(basename $ref2scaf)
# remove the first underscore and everything after it from every fasta header
sed -i '/^>/ s/^\([^_]*_[^_]*\)_.*/\1/' plotsr/$(basename $ref2scaf)

# sort refs by name order
seqkit sort -n plotsr/$(basename $ref1) > plotsr/tmp && mv plotsr/tmp plotsr/$(basename $ref1)
seqkit sort -n plotsr/$(basename $ref2scaf) > plotsr/tmp && mv plotsr/tmp plotsr/$(basename $ref2scaf)
conda deactivate
########################################


########################################
# plot assemblies against eachother with syri

# align the assemblies
conda activate minimap2
minimap2 -ax asm5 --eqx --secondary=no -t 16 plotsr/$(basename $ref1) plotsr/$(basename $ref2scaf) | samtools sort -o plotsr/syri.bam
samtools index plotsr/syri.bam
conda deactivate

# Run syri to find structural rearrangements between your assemblies
conda activate syri_new
syri \
-c plotsr/syri.bam \
-r plotsr/$(basename $ref1) \
-q plotsr/$(basename $ref2scaf) \
-F B \
--nc 4 \
--dir plotsr \
--prefix ASM90000737v1_Fusven1
conda deactivate

# write the names of the assemblies to a file for use by plotsr
echo -e ""$(realpath "plotsr/$(basename "$ref1")")"\tASM90000737v1
"$(realpath "plotsr/$(basename "$ref2scaf")")"\tFusven1" > plotsr/plotsr_assemblies_list.txt

# create plotsr plot
conda activate plotsr1.1.0
plotsr \
--sr plotsr/ASM90000737v1_Fusven1syri.out \
--genomes plotsr/plotsr_assemblies_list.txt \
-o plotsr/plotsr_plot.png \
--lf plotsr/plotsr.log \
-s 100  #  minimum size of a SR to be plotted (default: 10000)
conda deactivate

# customise the plot for the paper
plotsr \
       -o plotsr_plot_MS.png \
       --sr asm1_asm2_syri.out \
       --genomes plotsr_assemblies_list.txt \
       -H 23 \
       -W 20 \
       -f 14 \
       --cfg base.cfg

########################################
