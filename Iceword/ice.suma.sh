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


function setup() {
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
        if [[ -e ${ic} ]]; then
            echo "${ic} already exists"
        else
            3dcopy $ic ${COMPS}/
        fi
    done


} # End of setup


function thresh_components () {
    #------------------------------------------------------------------------
    #
    #   Description: thresh_components
    #
    #       Purpose: Threshold components of interest at the provided p-lvl
    #                 as well as remove any negative activation from the
    #                 image.
    #
    #         Input: cond => THe present condition, availale options are
    #                        learn or unlearn
    #                comp => The component number of interest
    #                run => The current scan, options incude run1-4
    #
    #        Output: Produces a positive actiavtion only statistical map
    #                 thresholded to the desired p-lvl.
    #
    #------------------------------------------------------------------------
    cond=$1; comp=$2; run=$3

    if [[ ${cond} == 'unlearn' ]]; then
        local input4d=${cond}_${run}_IC${comp}
    else
        local input4d=${cond}_IC${comp}_${run}
    fi

    local output4=${cond}_IC${comp}_${run}_${tstat}

    echo -e "\n========================================================="
    echo -e "Thresholding Components @ ${tstat}"

    # Merge clusters exlcuding Negative activations
    3dmerge \
        -1noneg \
        -dxyz=1 \
        -1clust 1 ${clust} \
        -1thresh ${tstat} \
        -prefix ${Merged}/Etc/${output4}.nii \
        ${EXPERT}/${input4d}.nii.gz

    3drefit -space MNI ${Merged}/Etc/"${output4}.nii"


    echo -e "========================================================\n"
}



function MAIN() {
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

    #--------------------#
    # Initiate functions #
    #--------------------#
    setup   # Create our directory structure amd copy the required files


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

