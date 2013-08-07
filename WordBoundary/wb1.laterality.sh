#!/bin/bash
#================================================================================
#    Program Name: wb1.laterality.sh
#          Author: Kyle Reese Almryde
#            Date: Monday 8/5/13 @ 1:16 PM
#
#     Description: This program will determine the laterality metric of each
#                  individual subject from the Word Boundary study. Regions of
#                  interest include the pre-frontal cortex and the temporal lobe
#
#    Deficiencies: None, this program meets specifications
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================



function getLaterality() {
    local input3D=$1
    local outfile=$2
    local outname=`basename $input3D`
    local mask="/Volumes/Data/StructuralImage/laterality_mask.nii.gz"
    local numROIs=`3dmaskave -mask $mask -max $mask`  # output looks like this: 10 [10419 voxels]

    means=( `3dROIstats -quiet -mask $mask $input3D` )
    echo $outname   ${means[*]}
    printf "\n$outname\t" >> ${outfile}
    printf "%s\t" ${means[*]} >> ${outfile}

} # End of main


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
    scan=run$1
    RUN=Run$1
    cond=$2
    task=$3


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

    HP="/Exps/Analysis/HuanpingWB1"
    BASE="/Exps/Data/WordBoundary1"
    TEMPLATE="Subject\tLeft Prefontal\tLeft Temporal\tRight Prefrontal\tRight Temporal"
    # printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_4D.txt
    printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_CO.txt
    printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_TT.txt

    for subj in ${subjList[*]}; do

        runsub=${scan}_${subj}
        SDATA="${HP}/${condition}/${RUN}/${subj}/Stats"
        NDATA="${HP}/${condition}/${RUN}/${subj}/NoNeg"
        RDATA="${BASE}/${subj}/Func/${RUN}"

        # -----------------
        # Execute Functions
        # -----------------
        # getLaterality "${RDATA}/${runsub}_tshift_volreg_despike_mni_7mm_164tr.nii" Laterality_Report_${RUN}_${condition}_4D.txt
        getLaterality "${SDATA}/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[0]" Laterality_Report_${RUN}_${task}_${condition}_CO.txt
        getLaterality "${SDATA}/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[1]" Laterality_Report_${RUN}_${task}_${condition}_TT.txt
        getLaterality "${NDATA}/${runsub}_${task}_${condition}_co_nn.nii.gz" Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt
        getLaterality "${NDATA}/${runsub}_${task}_${condition}_tt_nn.nii.gz" Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt
        #+++++++++++++++++++++++++++++++++++++++++++++++

        echo -e "++++++++++++++++++++++++\nMain has been called! ${runsub} $condition $task\n========================\n"
    done
    cat Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt >> Laterality_Report_${RUN}_${task}_${condition}_CO.txt
    cat Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt >> Laterality_Report_${RUN}_${task}_${condition}_TT.txt
    rm Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt
    rm Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt

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

for r in {1..3}; do
    Main $r $cond $task
done

#================================================================================
#                              END OF MAIN
#================================================================================

exit