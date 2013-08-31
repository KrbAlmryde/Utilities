#!/bin/bash
#================================================================================
#    Program Name: ice.roi-comp.sh
#          Author: Kyle Reese Almryde
#            Date: 8/27/2013 @ 5:42pm
#
#     Description: This program filters through the supplied IC component mask
#
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

FIGURE="/Exps/Analysis/Ice/Figure"
MASKS="/Exps/Analysis/Ice/Figure/Mask"
THRESHOLD="/Exps/Analysis/Ice/Figure/Threshold"

for IC in IC{4,11,12,18}_s{1..4}; do
    comp=${IC%_*}
    scan=${IC#*_}
    for mask in {L,R}_mask; do
        mean=`3dROIstats -quiet -mask ${MASKS}/${mask}_${IC}_2.6503.nii ${THRESHOLD}/${IC}_2.6503.nii`
        printf "%s\t%s\t%s\t%f\n" $scan $comp $mask $mean >> ${FIGURE}/IceWord_Laterality_Report.txt
        # echo -e "$IC\t$mean">> ${FIGURE}/${mask}.txt
    done
done


DATA="/Exps/Analysis/Ice/GiftAnalysis/ice_group_stats_files/tmap_sub_${num}_component_ica_.zip Folder"
tmap_sub_${num}_component_ica_.nii
for num in {1..14}; do

# function split_masks() {
#     #------------------------------------------------------------------------
#     #
#     #  Purpose: Split component masks by hemisphere
#     #
#     #------------------------------------------------------------------------

#     for hemi in {L,R}; do
#         for mask in ${MASKS}/mask_IC*.nii; do
#             fname=`basename $mask`
#             3dcalc \
#                 -a $mask \
#                 -b ${STRUCT}/MNI_2mm_mask_${hemi}.nii \
#                 -expr 'a*b' \
#                 -prefix ${MASKS}/${hemi}_${fname}
#         done
#     done


# } # End of split_masks


# function _makeNoNeg() {
#     #------------------------------------------------------------------------
#     #
#     #  Purpose: Remove negative activation from single subject images
#     #
#     #------------------------------------------------------------------------

#     local input3D=$1
#     local output3D=${input3D}_NoNeg-Tstat
#     mkdir -p ${NNDATA}
#     3dmerge \
#         -1noneg \
#         -prefix ${NNDATA}/${output3D}.nii.gz \
#         ${DATA}/"${input3D}.nii.gz[1]"

# } # End of makeNoNeg


# function getLaterality() {
#     local input3D=$1
#     local input3DNN=${input3D}_NoNeg-Tstat

#     _makeNoNeg ${input3D}
#     for hemi in {L,R}; do
#         for mask in ${MASKS}/${hemi}_mask*; do

#             mean=`3dROIstats -quiet -mask $mask ${DATA}/${input3D}.nii.gz[1]`
#             meanNN=`3dROIstats -quiet -mask $mask ${NNDATA}/${input3DNN}.nii.gz`

#             echo $mean   $mask  $input3D
#             echo $meanNN  $mask   $input3DNN
#         done
#     done

#             # printf "\n$outname\t" >> ${outfile}
#             # printf "%s\t" ${means[*]} >> ${outfile}

# } # End of main





# function Main() {
#     #------------------------------------------------------------------------
#     #
#     #  Purpose:
#     #
#     #
#     #    Input:
#     #
#     #   Output:
#     #
#     #------------------------------------------------------------------------
#     scan=run$1
#     RUN=Run$1
#     cond=$2
#     task=$3

#     case $cond in
#         "learn"|"learnable" )
#             condition="learnable"
#             subjList=( sub013 sub016 sub019 sub021 \
#                        sub023 sub027 sub028 sub033 \
#                        sub035 sub039 sub046 sub050 \
#                        sub057 sub067 sub069 sub073 )
#             ;;

#         "unlearn"|"unlearnable" )
#             condition="unlearnable"
#             subjList=( sub009 sub011 sub012 sub018 \
#                        sub022 sub030 sub031 sub032 \
#                        sub038 sub045 sub047 sub048 \
#                        sub049 sub051 sub059 sub060 )
#             ;;

#         * )
#             HelpMessage
#             ;;
#     esac

#     HP="/Exps/Analysis/HuanpingWB1"
#     BASE="/Exps/Data/WordBoundary1"
#     TEMPLATE="Subject\tLeft Prefontal\tLeft Temporal\tRight Prefrontal\tRight Temporal"
#     # printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_4D.txt
#     printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_CO.txt
#     printf "${TEMPLATE}" > Laterality_Report_${RUN}_${task}_${condition}_TT.txt

#     for subj in ${subjList[*]}; do

#         runsub=${scan}_${subj}
#         SDATA="${HP}/${condition}/${RUN}/${subj}/Stats"
#         NDATA="${HP}/${condition}/${RUN}/${subj}/NoNeg"
#         RDATA="${BASE}/${subj}/Func/${RUN}"

#         # -----------------
#         # Execute Functions
#         # -----------------
#         # getLaterality "${RDATA}/${runsub}_tshift_volreg_despike_mni_7mm_164tr.nii" Laterality_Report_${RUN}_${condition}_4D.txt
#         getLaterality "${SDATA}/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[0]" Laterality_Report_${RUN}_${task}_${condition}_CO.txt
#         getLaterality "${SDATA}/${runsub}_${task}_${condition}_co-tt_stats.nii.gz[1]" Laterality_Report_${RUN}_${task}_${condition}_TT.txt
#         getLaterality "${NDATA}/${runsub}_${task}_${condition}_co_nn.nii.gz" Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt
#         getLaterality "${NDATA}/${runsub}_${task}_${condition}_tt_nn.nii.gz" Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt
#         #+++++++++++++++++++++++++++++++++++++++++++++++

#         echo -e "++++++++++++++++++++++++\nMain has been called! ${runsub} $condition $task\n========================\n"
#     done
#     cat Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt >> Laterality_Report_${RUN}_${task}_${condition}_CO.txt
#     cat Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt >> Laterality_Report_${RUN}_${task}_${condition}_TT.txt
#     rm Laterality_Report_${RUN}_${task}_${condition}_TT_NN.txt
#     rm Laterality_Report_${RUN}_${task}_${condition}_CO_NN.txt

# } # End of Main

# #------------------------------------------------------------------------
# #
# #   Description: Main
# #
# #       Purpose: This function acts as the launching point of all other
# #                functions within this script. In addition to defining
# #                the path variables used to point to data within the
# #                various directories, it also controls the loop which
# #                iterates over experiment runs. Any operation the user
# #                wishes to be performed related to the analysis should
# #                be executed within this function.
# #
# #         Input: None
# #
# #        Output: None, see individual functions for output.
# #
# #------------------------------------------------------------------------

# function Main ()
# {
#     echo -e "\nMain has been called\n"

#     # The {5..19}-{1..4} is brace notation which acts as a nested for-loop
#     # The '-' acts as a separator which allows for easy substring operations when
#     # assigning the variable names for the rest of the program.

#     # for i in {6..19}-{1..4}; do
#     for i in {5..19}-{1..4}; do

#         #-----------------------------------#
#         # Define variable names for program #
#         #-----------------------------------#
#         run=run${i#*-}
#         sub=`printf "sub%03d" ${i%-*}`
#         runsub=${run}_${sub}

#         #-------------------------------------#
#         # Define pointers for Functional data #
#         #-------------------------------------#
#         RUN=Run${i#*-}
#         FUNC="/Volumes/Data/Iceword/${sub}/Func/${RUN}"
#         BASE="/Volumes/Data/Iceword"
#         #---------------------------------#
#         # Define pointers for GLM results #
#         #---------------------------------#
#         MASKS="/Exps/Analysis/Ice/Figure/Mask"
#         STRUCT="/Volumes/Data/StructuralImage"
#         DATA="/Volumes/Data/Iceword/ANALYSIS/Data/${sub}/${RUN}"
#         NNDATA="/Volumes/Data/Iceword/ANALYSIS/Data/${sub}/${RUN}/NoNeg"
#         #------------------------------------------------#
#         # Define pointers for Group Analysis Directories #
#         #------------------------------------------------#
#         ANOVA="/Volumes/Data/Iceword/ANOVA/${sub}/${RUN}"

#         #--------------------#
#         # Initiate functions #
#         #--------------------#

#         # We removed sub018 from the analysis, so dont perform any operations them.
#         if [[ $sub != "sub018" ]]; then
#             # split_mask
#             for delay in {0..7}; do     # This is a loop which runs the deconvolution at each delay (in seconds) the result of which is 8 seperate processes run.
#                 getLaterality ${runsub}_tshift_volreg_despike_mni_7mm_214tr_${delay}sec_ListenStats
#                 getLaterality ${runsub}_tshift_volreg_despike_mni_7mm_214tr_${delay}sec_ResponseStats
#             done

#         fi
#     done
# }



# #================================================================================
# #                              START OF MAIN
# #================================================================================

# opt=$1  # This is an optional command-line variable which should be supplied
#         # in for testing purposes only. The only available operation should
#         # "test"

# # Check whether Test_Main should or Main should be run
# case $opt in
#     "test" )
#         Test_Main 2>&1 | tee ${BASE}/log.TEST.txt
#         ;;

#       * )
#         Main
#         ;;
# esac



# #================================================================================
# #                              END OF MAIN
# #================================================================================
# <<NOTE
# This data is linked and as such has different path names, below are the differences
# between machines.

# On Hagar the path names are:
#     FUNC=/Volumes/Data/Iceword/${sub}/Func/${RUN}

#     STIM=/Volumes/Data/Iceword/GLM/STIM
#     GLM=/Volumes/Data/Iceword/GLM/${sub}/Glm/${RUN}
#     ID=/Volumes/Data/Iceword/GLM/${sub}/Glm/${RUN}/Ideal

# On Auk the path names are:
#     FUNC=/Exps/Data/Iceword/${sub}/Func/${RUN}

#     STIM=/Exps/Analysis/Iceword/STIM
#     GLM=/Exps/Analysis/Iceword/${sub}/Glm/${RUN}
#     ID=/Exps/Analysis/WordBoundary1/${sub}/Glm/${RUN}/Ideal
# NOTE
