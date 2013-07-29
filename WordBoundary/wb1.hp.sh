#!/bin/bash
#================================================================================
#   Program Name: wb1.hp.sh
#         Author: Kyle Reese Almryde
#           Date: 6/25/2013
#
#    Description: This program is part of a collaboration with Dr. Huanping
#                 Dai. filters group generated ROI binary masks through the
#                 single-subject 3D t-value and 4D data post-processing data.
#
#                 File naming conventions:
#                 co ==> coefficient dataset
#                 tt ==> t-statitic dataset
#                 nn ==> no negative actication
#
#                 If a file has more than one subbrick, it is labeled stats, in addition
#                 to whatever type of subbrick the dataset contains (ie co-tt)
#
#          Notes: This script is intended to be run Three times!
#                 1st) To process each individual subject, extracting subbrick
#                       info and remove negative activation
#                 2nd) Run the group ttest
#                 3rd) Filter the newly created masks through each subject
#
#           To run every subject and every condition, copy and paste the following
#           into the command-line:
#           for i in wb1.hp.sh{' 'un,' '}learn{' 'sent,' 'tone}; do bash $i; done
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

    mkdir -p {$BASE,$SUB/Filtered,$SUBNEG,$SUBSTATS,$SUBSTATSNEG,$MASK,$TTEST}

} # End of setup


# 1) Extract tstat and coef subbricks

function getStatImages() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Extract tstat and coef sub bricks from individual subjects
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local input3D=$1

    if [[ $task == "sent" ]]; then
        coef=12
        tstat=13
    else
        coef=9
        tstat=10
    fi

    3dbucket \
        -fbuc \
        -prefix "${SUBSTATS}/${output3D}_co-tt_stats.nii.gz" \
                "${SDATA}/${input3D}.nii.gz[${coef},${tstat}]"

    echo -e "\t++++++++++++++++++++++++"
    echo -e "\tgetStatImages has been called! ${runsub} "
    echo -e "\tInput: ${SDATA}/${input3D}.nii.gz[${coef},${tstat}]"
    echo -e "\tOutput: ${SUBSTATS}/${output3D}_co-tt_stats.nii.gz"
    echo -e "\t========================\n"
} # End of getStatImage



function noNegImages() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Remove negative activation from coef and tstats, rebucket them.
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local input3D=$1
    local output3D=${runsub}_${task}_${condition}

    3dmerge \
        -1noneg \
        -prefix "${SUBNEG}/${output3D}_co_nn.nii.gz" \
                "${SUBSTATS}/${input3D}.nii.gz[0]"

    3dmerge \
        -1noneg \
        -prefix "${SUBNEG}/${output3D}_tt_nn.nii.gz" \
                "${SUBSTATS}/${input3D}.nii.gz[1]"

    echo -e "\t++++++++++++++++++++++++\n\tnoNegImages has been called! ${runsub}"
    echo -e "\tInput: ${SUBSTATS}/${input3D}.nii.gz[0]"
    echo -e "\tOutput: ${SUBNEG}/${output3D}_co_nn.nii.gz"
    echo -e "\tInput: ${SUBSTATS}/${output3D}_tt_nn.nii.gz"
    echo -e "\tOutput: ${SUBNEG}/${input3D}.nii.gz[1]"
    echo -e "\t========================\n"
} # End of noNegImages


function tTestImages() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Run 3dTtest++ on the extracted nn datasets, specifically just
    #           the co datafiles
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local output3D=${scan}_${task}_${condition}
    local STRUCT="/Volumes/Data/StructuralImage"

    if [[ -e ${TTEST}/${output3D}_nn_ttest.nii.gz ]]; then
        echo
    else
        3dttest++ \
            -mask ${STRUCT}/MNI_2mm_mask.nii \
            -setA "${BASE}/${subjList[0]}/NoNeg/${scan}_${subjList[0]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[1]}/NoNeg/${scan}_${subjList[1]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[2]}/NoNeg/${scan}_${subjList[2]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[3]}/NoNeg/${scan}_${subjList[3]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[4]}/NoNeg/${scan}_${subjList[4]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[5]}/NoNeg/${scan}_${subjList[5]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[6]}/NoNeg/${scan}_${subjList[6]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[7]}/NoNeg/${scan}_${subjList[7]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[8]}/NoNeg/${scan}_${subjList[8]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[9]}/NoNeg/${scan}_${subjList[9]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[10]}/NoNeg/${scan}_${subjList[10]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[11]}/NoNeg/${scan}_${subjList[11]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[12]}/NoNeg/${scan}_${subjList[12]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[13]}/NoNeg/${scan}_${subjList[13]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[14]}/NoNeg/${scan}_${subjList[14]}_${task}_${condition}_co_nn.nii.gz" \
                  "${BASE}/${subjList[15]}/NoNeg/${scan}_${subjList[15]}_${task}_${condition}_co_nn.nii.gz" \
            -prefix "${TTEST}/${output3D}_nn_ttest.nii.gz"
    fi

    echo -e "\t++++++++++++++++++++++++\n\ttTestImages has been called! ${runsub}"
    echo -e "\tInput: ${SUBSTATS}/NoNeg/${input3D}.nii.gz[0]"
    echo -e "\tOutput: ${TTEST}/${scan}_${task}_${condition}_nn_ttest.nii.gz"
    echo -e "\t========================\n"


} # End of tTestImages



function filterSubjectImages() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Filter single subject data through roi masks (once created)
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local input3D=$1
    local maskList=(`ls ${MASK}/*.nii.gz`)
    local output3D

} # End of filterSubjectImages




function HelpMessage ()
{
   echo "-----------------------------------------------------------------------"
   echo "+                 +++ No arguments provided! +++                      +"
   echo "+                                                                     +"
   echo "+             This program requires at least 2 arguments.             +"
   echo "+                                                                     +"
   echo "+       NOTE: [words] in square brackets represent possible input.    +"
   echo "+             See below for available options.                        +"
   echo "+                                                                     +"
   echo "-----------------------------------------------------------------------"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                   Experimental condition                    +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                                                             +"
   echo "   +  [learn]   or  [learnable]    For the Learnable Condtion    +"
   echo "   +  [unlearn] or  [unlearnable]  For the Unlearnable Condtion  +"
   echo "   +  [debug]   or  [test]         For testing purposes only     +"
   echo "   +                                                             +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                      Experimental task                      +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                                                             +"
   echo "   +  [sent]    For the Sentences focused task                   +"
   echo "   +  [tone]    For the Tone focused task                        +"
   echo "   +                                                             +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "-----------------------------------------------------------------------"
   echo "+                Example command-line execution:                      +"
   echo "+                                                                     +"
   echo "+                    bash wb1.hp.sh learn sent                        +"
   echo "+                                                                     +"
   echo "+                  +++ Please try again +++                           +"
   echo "-----------------------------------------------------------------------"

   exit 1
}


function Main() {
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
    subj=$1
    scan=run$2
    condition=$3
    task=$4
    operation=$5

    RUN=Run$2
    runsub=${scan}_${subj}
    output3D=${runsub}_${task}_${condition}

    SDATA="/Volumes/Data/WordBoundary1/GLM/${subj}/Glm/${RUN}/Stats"
    BASE="/Exps/Analysis/HuanpingWB1/${condition}/${RUN}"
    SUB="${BASE}/${subj}"   # This contains the raw sub
    SUBNEG="${SUB}/NoNeg"  #
    SUBSTATS="${SUB}/Stats"  #
    SUBFILTER="${SUB}/Filtered"  # once we have masks to filter the subject data, they will go here
    MASK="${BASE}/Masks"
    TTEST="${BASE}/Ttest"

    # -----------------
    # Execute Functions
    # -----------------
    case $operation in
        "group" )
            tTestImages
            ;;

        "filter" )
            echo "theres is nothing here!"
            # filterSubjectImages
            ;;

        * )
            setup  ${runsub}_tshift_volreg_despike_mni_7mm_164tr_0sec_${condition}.stats  # Build the directory
            getStatImages ${runsub}_tshift_volreg_despike_mni_7mm_164tr_0sec_${condition}.stats  # Get the stat images
            noNegImages ${runsub}_${task}_${condition}_co-tt_stats   # Remove the negative activation
            ;;
    esac

    #+++++++++++++++++++++++++++++++++++++++++++++++

    echo -e "++++++++++++++++++++++++\nMain has been called! ${runsub} $condition $task\n========================\n"

} # End of Main


#================================================================================
#                                START OF MAIN
#================================================================================

cond=$1     # This is a command-line supplied variable which determines
            # which experimental condition should be run. This value is
            # important in that it determines which group of subjects should
            # be run. If this variable is not supplied the program will
            # exit with an error and provide the user with instructions
            # for proper input and execution.

task=$2    # This command-line supplied variable distinguishes the task from sentences
           # or tones. If this is not provided, it will default to "sent" for sentences

oper=$3    # This determines whether we should be processing the individual subjects,
           # the group tTest, or filter masks through single subject data.



case $cond in
    "learn"|"learnable" )
        condition="learnable"
        subjList=( sub013 sub016 sub019 sub021 \
                   sub023 sub027 sub028 sub033 \
                   sub035 sub039 sub046 sub050 \
                   sub057 sub067 sub069 sub073 )
        ;;

    "unlearn"|"unlearnable" )
        condition="unlearnable"
        subjList=( sub009 sub011 sub012 sub018 \
                   sub022 sub030 sub031 sub032 \
                   sub038 sub045 sub047 sub048 \
                   sub049 sub051 sub059 sub060 )
        ;;

    * )
        HelpMessage
        ;;
esac


for r in {1..3}; do
    for subj in ${subjList[*]}; do
        Main $subj $r $condition $task $oper
    done
done

#================================================================================
#                              END OF MAIN
#================================================================================

exit





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
========================================================================================

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
        -prefix "${SSTATS}/${runsub}_${task}_${condition}_co-tt_stats.nii.gz" \
                "/Volumes/Data/WordBoundary1/GLM/sub009/Glm/Run1/Stats/${runsub}_tshift_volreg_despike_mni_7mm_164tr_0sec_${task}.nii.gz[${coefSB},${tstatSB}]"
# 2) Remove negative activation from coef and tstats, rebucket them
    3dmerge \
        -1noneg \
        -prefix "${SUBSTATS}/NoNeg/${runsub}_${task}_${condition}_co_nn.nii.gz"
                "${SUBSTATS}/NoNeg/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[0]"

    3dmerge \
        -1noneg \
        -prefix "${SUBSTATS}/NoNeg/${runsub}_${condition}_tt_nn.nii.gz"
                "${SUBSTATS}/Combo/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[1]"


    3dbucket \
        -fbuc \
        -prefix "${STATS}/NoNeg/${runsub}_${task}_${condition}_co-tt_nn_stats.nii.gz" \
                "${SUBSTATS}/NoNeg/Etc/${runsub}_${condition}_co_nn.nii.gz"
                "${SUBSTATS}/NoNeg/Etc/${runsub}_${condition}_tt_nn.nii.gz"


# 3) Run 3dTtest++ on the extracted nn datasets, specifically just the co datafiles
    3dttest++ \
        -setA "${SUBSTATS}/NoNeg/${scan}_sub*_${task}_${condition}_co_nn.nii.gz"
        -prefix "${STATS}/NoNeg/${scan}_${task}_${condition}_nn_ttest.nii.gz"

NOTES




function bucketStatImages() {
    # THIS FUNCTION IS DEPRECIATED!!!
    #------------------------------------------------------------------------
    #
    #  Purpose: Bucket two datasets to form one Stat image
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    # local input3D=$1
    # local output3D=${runsub}_${task}_${condition}

    # # 3dbucket \
    # #     -fbuc \
    # #     -prefix "${SUBSTATSNEG}/${output3D}_co-tt_nn_stats.nii.gz" \
    # #             "${SUBNEG}/${input3D}_co_nn.nii.gz"
    # #             "${SUBNEG}/${input3D}_tt_nn.nii.gz"

    # echo -e "\t++++++++++++++++++++++++\n\tbucketStatImages has been called! ${runsub}"
    # echo -e "\tInput: ${SUBNEG}/${input3D}_co_nn.nii.gz"
    # echo -e "\t       ${SUBNEG}/${input3D}_tt_nn.nii.gz"
    # echo -e "\tOutput: ${SUBSTATSNEG}/${output3D}_co-tt_nn_stats.nii.gz"
    # echo -e "\t========================\n"
} # End of bucketStatImages
