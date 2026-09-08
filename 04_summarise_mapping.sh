#!/bin/bash
# 8/9/26

# script to summarise mapping success

cd ~/data/paul_dyer/bams/bam_info

{
printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "Sample" "Total" "Primary" "Secondary" "Mapped" "Mapped_%" \
    "Primary_mapped" "Primary_mapped_%" "Properly_paired" \
    "Properly_paired_%" "Singletons" "Singletons_%" \
    "Mate_diff_chr" "Mate_diff_chr_MAPQ5"

    for file in *_mapping_info.txt; do
        sample=${file%_mapping_info.txt}
        awk -v sample="$sample" '
        /in total/ {
            total = $1
        }
        / primary$/ {
            primary = $1
        }
        / secondary$/ {
            secondary = $1
        }
        / mapped \(/ && !/primary mapped/ {
            mapped = $1
            mapped_pct = $5
            gsub(/[()%]/, "", mapped_pct)
        }
        / primary mapped \(/ {
            primary_mapped = $1
            primary_mapped_pct = $6
            gsub(/[()%]/, "", primary_mapped_pct)
        }
        / properly paired \(/ {
            properly_paired = $1
            properly_paired_pct = $6
            gsub(/[()%]/, "", properly_paired_pct)
        }
        / singletons \(/ {
            singletons = $1
            singletons_pct = $5
            gsub(/[()%]/, "", singletons_pct)
        }
        / with mate mapped to a different chr$/ {
            mate_diff_chr = $1
        }
        / with mate mapped to a different chr \(mapQ>=5\)$/ {
            mate_diff_chr_mapq5 = $1
        }
        END {
            print sample "\t" \
                  total "\t" \
                  primary "\t" \
                  secondary "\t" \
                  mapped "\t" mapped_pct "\t" \
                  primary_mapped "\t" primary_mapped_pct "\t" \
                  properly_paired "\t" properly_paired_pct "\t" \
                  singletons "\t" singletons_pct "\t" \
                  mate_diff_chr "\t" \
                  mate_diff_chr_mapq5
        }
        ' "$file"
    done
} > mapping_summary.tsv

