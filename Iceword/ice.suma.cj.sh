#!/bin/bash
#================================================================================
#	Program Name: ice.suma.sh
#		  Author: Kyle Reese Almryde
#			Date: 6/25/2013
#
#	 Description: This program
#
#
#
#	Deficiencies:
#
#
#
#
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


function setup () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Sets up the project directory by creating the necessary folders
    #			and grabbing copies of the data
    #
    #    Input: None
    #
    #   Output: None -- Side effects
    #
    #------------------------------------------------------------------------

    echo -e "building direcotry structure\n"
    mkdir -p ${FIGURE}/{Components,Threshold,Mask}

    echo -e "Copying data to directory\n"
    for ic in `ls ${ATLAS}/IC*_s*.nii.gz`; do
        echo "${ic}"

        if [[ -e ${COMPS}/`basename ${ic}` ]]; then
            echo "${ic} already exists"
        else
            3dcopy $ic ${COMPS}/
        fi
    done


} # End of setup

function threshold () {
    #------------------------------------------------------------------------
    #
    #  Purpose:
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    run=$1
    for (( i = 0; i < ${#comp[*]}; i++ )); do
        local input=IC${comp[i]}_${run}
        local output=IC${comp[i]}_${run}_${tstat}
        3dmerge \
            -1noneg \
            -dxyz=1 \
            -1clust 1 ${clust} \
            -1tindex 0 \
            -1thresh ${tstat} \
            -prefix ${THRESH}/${output}.nii \
            ${COMPS}/${input}.nii.gz
        3drefit -space MNI ${THRESH}/${output}.nii
        echo ${THRESH}/${output}.nii
    done

} # End of threshold


function display () {
    #------------------------------------------------------------------------
    #
    #  Purpose:
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    run=$1

    3dcalc \
        -a "${THRESH}/IC${comp[0]}_${run}_${tstat}.nii" \
        -b "${THRESH}/IC${comp[1]}_${run}_${tstat}.nii" \
        -c "${THRESH}/IC${comp[2]}_${run}_${tstat}.nii" \
        -d "${THRESH}/IC${comp[3]}_${run}_${tstat}.nii" \
        -expr 'step(a)*1.01 + step(b)*1.02 + step(c)*1.03 + step(d)*1.04' \
        -prefix ${MASK}/IC${comp[0]}_${run}_${tstat}_Figure.nii

} # End of display




function MAIN () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Main function. Performs the steps necessary to generate cool
    #			display models of the independant components.
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    ICE='/Exps/Analysis/Ice'
    FIGURE="${ICE}/Figure"
    MASK="${FIGURE}/Mask"
    COMPS="${FIGURE}/Components"
    THRESH="${FIGURE}/Threshold"
    ATLAS="${ICE}/GiftAnalysis/AtlasAnalysis"

    comp=(4 11 12 18)
    tstat=2.6503
    clust=274

    setup  # Create our directory structure amd copy the required files

    for run in s1 s2 s3 s4; do
        threshold $run
        display $run
    done

    #--------------------#
    # Initiate functions #
    #--------------------#


} # End of MAIN

#================================================================================
#                                START OF MAIN
#================================================================================

MAIN

<<-DETAILS
Threshold t-value for p=0.01 according to SPM tool:
This is based on the spm tool Srinivas

recommended (one-tailed--I think):

 (13 is df, since we have 14 subjects…14-1)

Do the following in matlab:

t_thresh=spm_u(0.01, [1,13],'T')


t=2.6503

=====================
Cluster size threshold estimated from afni for Iceword data: 274 voxels
=====================
t-values for each IC component of interest for each of the 4 sessions (s1,s2,s3,s4) are here:
You should copy these off into a separate directory to make sure I don't overwrite your stuff.

/Exps/Analysis/Ice/GiftAnalysis/AtlasAnalysis:
IC2_s1.nii.gz
IC2_s2.nii.gz
IC2_s3.nii.gz
IC2_s4.nii.gz
IC4_s1.nii.gz
IC4_s2.nii.gz
IC4_s3.nii.gz
IC4_s4.nii.gz
IC11_s1.nii.gz
IC11_s2.nii.gz
IC11_s3.nii.gz
IC11_s4.nii.gz
IC12_s1.nii.gz
IC12_s2.nii.gz
IC12_s3.nii.gz
IC12_s4.nii.gz
IC18_s1.nii.gz
IC18_s2.nii.gz
IC18_s3.nii.gz
IC18_s4.nii.gz

 -Dianne
DETAILS

