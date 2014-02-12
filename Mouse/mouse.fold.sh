#!/bin/bash
#================================================================================
#    Program Name: mouse.fold.sh
#          Author: Kyle Reese Almryde
#            Date: 02/03/2014
#
#     Description: This script implements the folding average of the image
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

function MAIN() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Main function to run the script
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local subj=$1
    local run=$2
    local MOUSE=/Volumes/Data/MouseHunger
    local PREP=$MOUSE/$subj/PREP
    local image=$subj.$run.tshift.volreg

    for (( i = 0, j = 49 ; j < 700; i+=25, j+=25 )); do

        3dtstat -mean -prefix $PREP/__.${subj}.${i}-${j}.nii  "$PREP/$image.nii[${i}..${j}]"
        # 3dbucket -fbuc -aglueto $image.span+orig __.${subj}.${i}-${j}.nii[0]

        if [[ $i -eq 0 ]]; then
            3dtcat -relabel -prefix __.$image.span.tcat+orig __.${subj}.${i}-${j}.nii
            i=`echo $i - 1 | bc`
        else
            3dtcat -relabel -glueto __.$image.span.tcat+orig __.${subj}.${i}-${j}.nii
        fi
    done
    3dAFNItoNIFTI -prefix $image.span.tcat.nii __.$image.span.tcat+orig
    # rm __.${subj}.*

} # End of MAIN
#================================================================================
#                                START OF MAIN
#================================================================================

for sub in m006;do
    MAIN $sub treat
done