#!/bin/bash
#================================================================================
#    Program Name: ice.ss-gift.sh
#          Author: Kyle Reese Almryde
#            Date: 9/03/13 @ 11:30 AM
#
#     Description:
#
#
#
#    Deficiencies:
#
#
#
#
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================




#================================================================================
#                                START OF MAIN
#================================================================================

# "/Exps/Analysis/Ice/GiftAnalysis/ice_scaling_components_files/${subj}_component_ica_${scan}/${subj}_component_ica_${scan}_.nii"

function main() {
    for i in {1..14}-{1..4}; do

        #-----------------------------------#
        # Define variable names for program #
        #-----------------------------------#
        run=run${i#*-}
        sub=`printf "sub%03d" ${i%-*}`
        runsub=${run}_${sub}

        components=(4 11 12 18)
        components=(3 10 11 17)  # Thses are for the dataset index, since they are 0-based


        #-------------------------------------#
        # Define pointers for Functional data #
        #-------------------------------------#
        MASKS="/Exps/Analysis/Ice/Figure/Mask"
        STRUCTURALS="/Volumes/Data/ETC/StructuralImages"   # The location for standard anatomical images
        SUBIC="/Exps/Analysis/Ice/GiftAnalysis/ice_scaling_components_files/${subj}_component_ica_${scan}"

    done
}