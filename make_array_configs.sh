#/bin/bash
# 7/9/26

# record of code used to make Fusarium array config files

####################################
### for the mapping array config ###
####################################

# set the config file name
CONFIG=~/code_and_scripts/config_files/fusarium_config.txt

# move to the directory with the fastq files
cd /gpfs01/home/mbzlld/data/paul_dyer/fastqs

# save the file names to the config file (only escaping the ls bc I have an alias, no one else would need the escape)
\ls > $CONFIG

# remove file endings to leave run IDs
sed -i 's/_[^_]*$//' $CONFIG

# remove duplicate IDs
sort $CONFIG | uniq > ~/tmp && mv ~/tmp $CONFIG

# add numbers to the start of each line
awk '{print NR,$0}' $CONFIG > ~/tmp && mv ~/tmp $CONFIG

# count the lines to know how many array steps we will need to set in our array script
cat $CONFIG | wc -l

# I then added the proper individual names manually in the 3rd column

