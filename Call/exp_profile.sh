################################################################################
					########### START OF MAIN ############
#================================================================================
# This is the exp_profile.sh. It is designed to define general path variables that
# can be called by my scripts and sourced by my experiment profiles
echo ----------------------- exp_profile.sh has been sourced! -----------------------
#================================================================================
# Experiment global Path variables
#================================================================================

ATTNMEM=/Volumes/Data/ATTNMEM
BEHAV=/Volumes/Data/BEHAV
STROOP=/Volumes/Data/STROOP
TAP=/Volumes/Data/TAP
RAT=/Volumes/Data/RAT
WORDBOUNDARY=/Volumes/Data/WordBoundary1
#===============================================================================
# Script Location Variables
#===============================================================================

UTL=/usr/local/utilities
DRIVR=$UTL/DRIVR
PROFILE=$UTL/PROFILE
LST=$UTL/LST
BLK=$UTL/BLK
PROG=$UTL/PROG
STIM=$UTL/STIM
#===============================================================================
# Define general experiment variables, specifically subject, run, and conditions
#===============================================================================

SUBJECTS=$LST/lst_subj_${1}.txt
RUNS=$LST/lst_run_${1}.txt
CONDITIONS=$LST/lst_cond_${1}.txt
#===============================================================================
# Define imaging specific variables, specifically brik#, Hemodynamic Response Model type, and
# efiles.
#===============================================================================

BRIKS=$LST/lst_brik_${1}.txt
EFILES=$LST/lst_efile_${1}.txt
CLUST=$LST/lst_clust_${1}.txt
#===============================================================================
#
#===============================================================================

case $context in
    "attnmem" )
            study_dir=$ATTNMEM
            ;;

    "behav" )
            study_dir=$BEHAV
            ;;

    "stroop" )
            study_dir=$STROOP
            ;;

    "tap" )
            study_dir=$TAP
            ;;

    "dich" )
            study_dir=$DICHOTIC
            ;;

    "rat" )
            study_dir=$RAT
            ;;

    "sld" )
            study_dir=$STROOPLD
            ;;

    "wb1" )
            study_dir=$WORDBOUNDARY
            ;;
esac

#===============================================================================
								########### Functions ############
#===============================================================================
# Source useful functions that can be used in my scripts. These functions are meant to make semi-
# regular processes easier to use and access
#===============================================================================
# This function reads an outlier file looking for the lowest integer then prints the NUMBER line
# - 5 to account for time shifting and AFNI's penchant for starting timeseries with 0 (which is
# annoying), then exits, which causes awk to print only 1 value. This allows us to acquire a base
# value to register our data to.

function base_reg ()
{
 cat -n ${prep_dir}/${subrun}.outliers.txt 		\
 	| sort -k2,2n							 	\
 	| head -1 									\
 	| awk '{print $1-5}'
}




#===============================================================================
# This function uses the fsl toolbox and "bc" to calculate the Jaccard Index and distance
# statistics for two binary masks. The Jaccard Index measures the similarity between two binary
# masks, and the Jaccard Distance calculates the dissimilarity between those two images.
# Note: The scale=6 variable sets the number of decimal places to use.
# See the link below for more information about Jaccard Index
# http://en.wikipedia.org/wiki/Jaccard_index
# Based on a dice_kappa calculation script written by Matt Petoe 11/2/2011
# Original script ritten by Dianne Patterson 11/9/2011
# Modified by Kyle Almryde 1/18/2012

function jaccard_index ()
{
	roi1=$1;	roi2=$2

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
	echo "${roi1} ${roi2} ${jaccard_index} ${jaccard_distance}" >>${subrun}.jaccard.txt
}
#===============================================================================
# This string prints the contents of the file (cat), removes columns 10-73 (colrm 10 73: This makes
# it so only the Volume, Mean, Sem, Max Int, X, Y, and Z are printed) then removes any rows that
# begin with "#" from the output (sed '/^#/d') ((Note:^ represents the start of the line, the 'd'
# means delete)) the "." Following that, it replaces any combination of spaces within the text with
# a single space (tr -s '[:space:]'), which it is itself replaced with a tab (awk -v OFS='\t'
# '$1=$1') before limiting only the first 2 rows of the text (head -2)

function whereami_strip ()
{
	cat $1.txt | colrm 10 73 | sed '/^#/d' | tr -s '[:space:]' | awk -v OFS='\t' '$1=$1' \
		| head -2 > $1.strip.txt

	whereami -tab -atlas TT_Daemon -coord_file $1.strip.txt'[4,5,6]' | sed -n '/TT_Daemon/p' | \
		awk -v OFS='\t' '$1=$1 {print $2,$4,$5,$6}'| head -4 > $1.whereami.txt
}


#===============================================================================
# This function renames efiles specific to the fse anatomical scan

function rename_fse ()
{

efile=$1
j=1

echo "rename fse e-files"
echo "This script assumes files with the form e12345s2i*"
echo ""

while [ $j -le 99 ]
do
	fname="${efile}2i${j}"
	if ! test -f $fname; then
		break
	fi

	echo "renaming image $j"

	if [ $j -le 9 ]; then
		mv $fname "${efile}2i00${j}"
	else
		mv $fname "${efile}2i0${j}"
	fi

	j=`expr $j + 1`
done
}

#===============================================================================
#
# This function renames efiles specific to the spgr anatomical scan

function rename_spgr ()
{
echo "rename spgr e-files"

efile=e[0-9][0-9][0-9][0-9]s[789]i
j=1

while [ $j -le 99 ]
do
	fname="${efile}${j}"
	if ! test -f $fname; then
		break
	fi

	echo "renaming image $j"

	if [ $j -le 9 ]; then
		mv $fname "${efile}7i00${j}"
	else
		mv $fname "${efile}7i0${j}"
	fi

	j=`expr $j + 1`
done
}
#===============================================================================
