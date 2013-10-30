#!/bin/bash
#================================================================================
#    Program Name: .sh
#          Author: Kyle Reese Almryde
#            Date:
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

TTEST="/Volumes/Data/Iceword/ANALYSIS/TTEST"

imagesLSN-CTR=($(ls ${TTEST}/tTest_run*_Lsn-Ctr_0sec.nii.gz))
imagesRSP-LSN=($(ls ${TTEST}/tTest_run*_Rsp-Lsn_0sec.nii.gz))


for (( i = 0; i < ${#imagesLSN[*]}; i++ )); do
    fwhm`3dfwhmx -automask -combine -input ${imagesLSN[i]}`
done













