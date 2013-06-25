#!/bin/bash
#================================================================================
#   Program Name: wb1.hp.sh
#         Author: Kyle Reese Almryde
#           Date: 6/25/2013
#
#    Description: This program is part of a collaboration with Dr. Huanping
#                 Dai. filters group generated ROI binary masks through the single-subject 3D t-value and 4D data post-processing
#                 data.
#
#
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================



#================================================================================
#                                START OF MAIN
#================================================================================

<<-NOTES
    1) Create a HuanpingWB1 directory under /Exps/Analysis

    2) Create binary masks identifying each cluster at the group level.
        -These should have some informative & consistent names
        -(This will take a long time, I'm sure)

    3) Apply each binary mask to the 3D volume containing the t-values for that
        subject run.
        -Thus, we get a 3d volume of the t-values in the mask for each of the runs.

        e.g. if the binary mask is smg_l, then we'd end up with something like this
        for a subject:
        sub013_run1_smg_l_t.nii.gz
        sub013_run2_smg_l_t.nii.gz
        sub013_run3_smg_l_t.nii.gz

    ===========

    4) Apply each binary mask to the 4D data from the final result of preprocessing.
        E.g.,  /Exps/Data/WordBoundary1/sub013/Func/Run1/
               run1_sub013_tshift_volreg_despike_mni_7mm_164tr.nii

        Multiply subject image by the regional mask and labeled in some consistent
        way.

        E.g., we'd end up with something like these:
        sub013_run1_smg_l_4d.nii.gz
        sub013_run2_smg_l_4d.nii.gz
        sub013_run3_smg_l_4d.nii.gz
NOTES