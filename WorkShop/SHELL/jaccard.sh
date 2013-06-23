#!/bin/bash

# usage: jaccard filename1 filename2
# this script uses the fsl toolbox and "bc" to calculate the Jaccard Index and distance statistics for two binary masks.
# http://en.wikipedia.org/wiki/Jaccard_index
# the scale=6 variable sets the number of decimal places to use.
# Written by Dianne Patterson 11/9/2011
# Based on a dice_kappa calculation script written by Matt Petoe 11/2/2011

#paths
source /usr/local/tools/REF/PROFILES/img_profile.sh

if [ $# -lt 2 ]
then
    echo "Usage: $0 <filename1> <filename2>"
    echo "Example $0 roi1 roi2"
    echo "The Jaccard index measures the similarity between 2 sample sets" 
    echo "The Jaccard distance measures the dissimilarity between 2 sample data sets"
    exit 1
fi

roi1=$1
roi2=$2

total_voxels1=`fslstats ${roi1} -V | awk '{printf $1 "\n"}'`
echo "total voxels ${roi1} is ${total_voxels1}" 

total_voxels2=`fslstats ${roi2} -V | awk '{printf $1 "\n"}'`
echo "total voxels ${roi2} is ${total_voxels2}" 

intersect_voxels=`fslstats ${roi1} -k ${roi2} -V | awk '{printf $1 "\n"}'`
echo "intersect voxels are ${intersect_voxels}"

fslmaths ${roi1} -add ${roi2} -bin union

union_voxels=`fslstats union -V | awk '{printf $1 "\n"}'`
echo "union voxels are ${union_voxels}" 

jaccard_index=`echo "scale=6; ${intersect_voxels}/${union_voxels}" | bc`
echo "Jaccard index is ${jaccard_index}"

jaccard_distance=`echo "scale=6; 1-(${intersect_voxels}/${union_voxels})" | bc`
echo "Jaccard distance is ${jaccard_distance}"

touch jaccard.txt
echo "${roi1} ${roi2} ${jaccard_index} ${jaccard_distance}" >>jaccard.txt

$mylog