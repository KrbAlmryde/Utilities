#!/bin/bash
#================================================================================
#    Program Name: ice.elena.sh
#          Author: Kyle Reese Almryde
#            Date: 10/10/2013
#
#     Description: This script binarizes a list of images and converts
#                  them to nifti format
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


function binarizeToNifti() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Converts a functional image map to binary and converts the
    #           the image to nifti format
    #
    #
    #    Input: A single functional image
    #
    #   Output: A binary mask in nifti format
    #
    #------------------------------------------------------------------------

    local inputFile=$1
    local base=$(basename $inputFile)
    local outputFile=${BINARY}/${base%%mask*}mask2.nii
    echo "inputFile is: $inputFile"
    echo "outputFile is: $outputFile"
    3dcalc \
        -a $inputFile \
        -prefix $outputFile \
        -expr "step(a)"
} # End of binarizeToNifti



#================================================================================
#                                START OF MAIN
#================================================================================


MASKS="/Exps/Analysis/Ice/GiftAnalysis/AtlasAnalysis/Editable/EP_largeROIs/masks"
BINARY="/Exps/Analysis/Ice/GiftAnalysis/AtlasAnalysis/Editable/EP_largeROIs/masks/binary"
mkdir -p $BINARY

masklist=($(ls ${MASKS}/*mask+orig.HEAD))

for image in ${maskList[*]}; do
    binarizeToNifti $image
done