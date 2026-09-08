#!/bin/bash
# 8/9/26

# merge the per site depth calculations to give overall depth per individual

# move to the working directory
cd ~/data/paul_dyer

# copy all the depth statistics to a single file
cat filtered_bams/bam_info/*_mapping_cov_depth.txt > filtered_bams/bam_info/per_ind_coverage_depth.txt

# and get rid of the file extension and path leaving just the individual name and the mean depth
sed -i 's/\.bam//' filtered_bams/bam_info/per_ind_coverage_depth.txt
sed -i 's@.*/@@' filtered_bams/bam_info/per_ind_coverage_depth.txt

