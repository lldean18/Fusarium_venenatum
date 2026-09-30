#!/bin/bash
# 8/9/26

# merge the per site depth calculations to give overall depth per individual

##########################################
# for the mean genome-wide depth per ind #
##########################################

# move to the working directory
#genome_identifier=Fusven1
genome_identifier=ASM90000737v1
cd ~/data/paul_dyer/$genome_identifier

# copy all the depth statistics to a single file
cat filtered_bams/bam_info/*_mapping_cov_depth.txt > filtered_bams/bam_info/per_ind_coverage_depth.txt

# and get rid of the file extension and path leaving just the individual name and the mean depth
sed -i 's/\.bam//' filtered_bams/bam_info/per_ind_coverage_depth.txt
sed -i 's@.*/@@' filtered_bams/bam_info/per_ind_coverage_depth.txt

####################################
# for the site-level depth per ind #
####################################

cd /gpfs01/home/mbzlld/data/paul_dyer/$genome_identifier/filtered_bams/bam_info
#genome_identifier=Fusven1
genome_identifier=ASM90000737v1
suffix=_venenatum_only

# set list of inds to work across
inds=(114-1 114-2 114-3 114-4 114-5 114-6 114-7 114-8 114-9 114-12 114-13 114-14 114-15 114-16 114-17 114-18 114-20 114-21 114-22 114-25)

# create initial file of chr and site from first ind
awk '{ print $1"\t"$2 }' 114-1_site-level_mapping_cov_depth.txt > site-level_depth${suffix}.txt

# loop over individuals and paste their depth as a new column in the file
for ind in "${inds[@]}"
do
#  paste -d '\t' ${ind}_site-level_mapping_cov_depth.txt <(awk '{print $NF}' ${ind}_site-level_mapping_cov_depth.txt) >> site-level_depth$suffix.txt
    paste site-level_depth${suffix}.txt \
          <(awk '{print $NF}' ${ind}_site-level_mapping_cov_depth.txt) \
          > tmp.txt
    mv tmp.txt site-level_depth${suffix}.txt
done

# calculate the total depth at each site (if 0 the site is uncallable)
awk '{
    sum=0
    for (i=3; i<=NF; i++)
        sum += $i
    print $1 "\t" $2 - 1 "\t"  $2 "\t" sum
}' site-level_depth${suffix}.txt > summed_site-level_depth${suffix}.bed

# finally check how may sites are uncallable:
awk '$4 == 0' summed_site-level_depth$suffix.bed | wc -l
# 1,064,842 for ASM90000737v1 _venenatum_only

# and finally finally, remove the uncallable sites from the bed file
awk '$4 > 0 {print $1"\t"$2"\t"$3"\t"$4}' summed_site-level_depth$suffix.bed > callable_sites_with_summed_site-level_depth$suffix.bed


