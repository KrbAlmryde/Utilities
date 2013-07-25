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


function setup() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Setup the project directory. All required directories and data
    #           are constructed.
    #
    #------------------------------------------------------------------------

    mkdir -p {$BASE,$MASK,$SSUB}/Etc

} # End of setup




# File naming conventions:
# co ==> coefficient dataset
# tt ==> t-statitic dataset
# nn ==> no negative actication
#
# If a file has more than one subbrick, it is labeled stats, in addition
# to whatever type of subbrick the dataset contains (ie co-tt)

# 1) Extract tstat and coef subbricks
    if $condition == "sent"
        coefSB=12
        tstatSB=13
    else
        coefSB=9
        tstatSB=10

    3dbucket \
        -prefix "${SSTATS}/${scan}_${subj}_${task}_${condition}_co-tt_stats.nii.gz" \
                "${scan}_${subj}_tshift_volreg_despike_mni_7mm_164tr_0sec_${task}.nii.gz[${coefSB},${tstatSB}]"
# 2) Remove negative activation from coef and tstats, rebucket them
    3dmerge \
        -1noneg \
        -prefix "${SUBSTATS}/NoNeg/${scan}_${subj}_${task}_${condition}_co_nn.nii.gz"
                "${SUBSTATS}/NoNeg/${scan}_${subj}_${task}_${condition}_co-tt_stats.nii.gz[0]"

    3dmerge \
        -1noneg \
        -prefix "${SUBSTATS}/NoNeg/${scan}_${subj}_${condition}_tt_nn.nii.gz"
                "${SUBSTATS}/Combo/${scan}_${subj}_${task}_${condition}_co-tt_stats.nii.gz[1]"


    3dbucket \
        -fbuc \
        -prefix "${STATS}/NoNeg/${scan}_${subj}_${task}_${condition}_co-tt_nn_stats.nii.gz" \
                "${SUBSTATS}/NoNeg/Etc/${scan}_${subj}_${condition}_co_nn.nii.gz"
                "${SUBSTATS}/NoNeg/Etc/${scan}_${subj}_${condition}_tt_nn.nii.gz"


# 3) Run 3dTtest++ on the extracted nn datasets, specifically just the co datafiles
    3dttest++ \
        -setA "${SUBSTATS}/NoNeg/${scan}_sub*_${task}_${condition}_co_nn.nii.gz"
        -prefix "${STATS}/NoNeg/${scan}_${task}_${condition}_nn_ttest.nii.gz"


function main () {
    for subj in ${subjList[*]}; do
        for scan ${scanList[*]}; do
            for task in ${taskList[*]}; do
                for condition ${condList[*]}; do

                    if $condition == "sent"
                        coefSB=12
                        tstatSB=13
                    else
                        coefSB=9
                        tstatSB=10

}


#================================================================================
#                                START OF MAIN
#================================================================================

condition=$1            # This is a command-line supplied variable which determines
                        # which experimental condition should be run. This value is
                        # important in that it determines which group of subjects should
                        # be run. If this variable is not supplied the program will
                        # exit with an error and provide the user with instructions
                        # for proper input and execution.

operation=$2    # This command-line supplied variable is optional. If it is left


RUN=( Run1 Run2 Run3 )


case $condition in
    "learn"|"learnable"     )
                              condition="learnable"
                              subj_list=( sub013 sub016 sub019 sub021 \
                                          sub023 sub027 sub028 sub033 \
                                          sub035 sub039 sub046 sub050 \
                                          sub057 sub067 sub069 sub073 )
                              ;;

    "unlearn"|"unlearnable" )
                              condition="unlearnable"
                              subj_list=( sub009 sub011 sub012 sub018 \
                                          sub022 sub030 sub031 sub032 \
                                          sub038 sub045 sub047 sub048 \
                                          sub049 sub051 sub059 sub060 )
                              ;;

    "debug"|"test"          )
                              condition="debugging"
                              subj_list=( sub009 sub013 )
                              ;;

    *                       )
                              HelpMessage
                              ;;
esac




MAIN


#================================================================================
#                              END OF MAIN
#================================================================================

exit

BASE="/Exps/Analysis/HuanpingWB1"
MASK="$BASE/Masks"
SSUB="$BASE/SingleSubjects"  # This contains the raw sub
SSNONEG="$SSUB/NoNeg" #
SSTATS="$SSUB/Stats"  # This contains the combined tstat and coef datasets for each subject
SSTATSNONEG="$SSTATS/NoNeg"  # This is the combined tstat and coef datasets that contain no negative actiavtion
SOURCE=/Volumes/Data/WordBoundary1/GLM/${subj}/Glm/${scan}/Stats


taskList=(learnable unlearnable)
condList=(sent tone)
scanList=(run{1..3})
subjList=()



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