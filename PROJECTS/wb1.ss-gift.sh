#!/bin/bash
#================================================================================
# Program Name: wb1.ss-gift.sh
#             Author: Kyle Reese Almryde
#                Date: 11/01/12 @ 11:39 AM
#
#      Description: This script tackles the single subject analysis of the gift
#                        ICA output for the wordboundary1 study.
#
#================================================================================
#                              FUNCTION DEFINITIONS
#================================================================================

function stripComponents () # s1 sub001 learn
{
    #------------------------------------------------------------------------
    #
    #  Purpose: This function strips out the components of interest from
    #                the supplied 'bucket file'
    #
    #      Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    run=$1; subj=$2

    echo -e "\n========================================================="
    echo -e "Stripping Components from Single Subjects: Scan: ${run}"
    echo -e "\nEtc: ${Etc}\nSubICA: ${SubICA}\nStripped: ${Stripped}\n"

    local input4dAllComps=${subj}_component_ica_${run}
    local output4dStripped=${subj}_stripped_ica_${run}
    for (( i = 0; i < ${#subjComps[*]}; i++ )); do
        3dbucket \
            -aglueto ${Etc}/${output4dStripped}+tlrc \
            ${SubICA}/${input4dAllComps}_.nii"[${subjComps[i]}]"

        echo -e "\n\tSubject: ${subj}, Component: ${subjComps[i]}\n"
    done

    3dCopy \
        ${Etc}/"${output4dStripped}+tlrc" \
        ${Stripped}/"${output4dStripped}.nii"

    3drefit -space MNI ${Stripped}/"${output4dStripped}.nii"

    echo -e "=========================================================\n"

} # End of stripComponents



function filterComponents ()
{
    #------------------------------------------------------------------------
    #
    #  Purpose: This function will filter the masked Component images
    #                through the stripped single subject images
    #
    #      Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    cond=$1; run=$2; subj=$3
    echo -e "\n========================================================="
    echo -e "Filtering Single Subject Data through Whole Component Masks and Clustered Component Masks"
    echo -e "\nEtc: ${Etc}\nFiltered: ${Filtered}\nStripped: ${Stripped}\nICMasks: ${ICMasks}\nEDITABLE: ${EDITABLE}\nClustered: ${Clustered}\n"

    for side in {L,R}; do
        for (( i = 0; i < ${#trueComps[*]}; i++ )); do
            # Whole Component Masks!!
            local inStrippedSubj=${subj}_stripped_ica_${run}
            local inputMask=all_${run}_IC${trueComps[i]}_bin
            local tempFilterSubj=temp_${subj}_filtered_IC${trueComps[i]}_${run}_${side}
            local outFilterSubj=${subj}_Filtered_ica_${run}_${side}

            echo -e "\t\nWhole Component Masks!!\n"
            3dcalc \
                -a "${EDITABLE}/${inputMask}.nii.gz" \
                -b "${Stripped}/${inStrippedSubj}.nii[$i]" \
                -c "${STRUCTURALS}/MNI_2mm_mask_${side}.nii" \
                -expr 'c * (a * b)' \
                -prefix ${Etc}/${tempFilterSubj}.nii

            3dbucket \
                -aglueto ${Etc}/${outFilterSubj}+tlrc \
                ${Etc}/${tempFilterSubj}.nii

            echo -e "\t\nSubject: ${subj}, Component: ${subjComps[i]}, Component: ${trueComps[i]}\n"
        done

        echo -e "\tCopying ${outFilterSubj}+tlrc to ${outFilterSubj}.nii"
        3dCopy \
            ${Etc}/"${outFilterSubj}+tlrc" \
            ${Filtered}/"${outFilterSubj}.nii"
    done

    echo -e "========================================================\n"

} # End of filterComponents


function reportComponents ()
{
    #------------------------------------------------------------------------
    #
    #  Purpose: This function will mask the session components to the
    #                single subjects session components
    #      Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    cond=$1; run=$2; subj=$3
    echo -e "\n========================================================="
    echo -e "Constructing Masks from Whole Component Images: Session: ${run}"
    echo -e "\nICMasks: ${ICMasks}\nEXPERT: ${EXPERT}\n"

    if [[ -f ${SubICA}/${Condition}_subject_report.txt ]]; then
        echo ""
    else
        echo -e "Scan\tHemisphere\tSubject\tComponent\tMean" \
            > ${SubICA}/${Condition}_subject_report.txt
    fi

    for side in {L,R}; do
        local input4d=${subj}_Filtered_ica_${run}_${side}

        for (( i = 0; i < ${#trueComps[*]}; i++ )); do

            stat=`3dBrickStat -mean -non-zero ${Filtered}/${input4d}.nii[$i]`

            echo -e "${run}\t${side}\t${subj}\tIC${trueComps[i]}\t${stat}" \
                >> ${SubICA}/${Condition}_subject_report.txt

            echo -e "\t\nComponent: ${trueComps[i]}\n"
        done
    done
    echo -e "========================================================\n"
} # End of reportComponents



function HelpMessage ()
{
    #------------------------------------------------------------------------
    #
    #   Description: HelpMessage
    #
    #       Purpose: This function provides the user with the instruction for
    #                how to correctly execute this script. It will only be
    #                called in cases in which the user improperly executes the
    #                script. In such a situation, this function will display
    #                instruction on how to correctly execute this script as
    #                as well as what is considered acceptable input. It will
    #                then exit the script, at which time the user may try again.
    #
    #         Input: None
    #
    #        Output: A help message instructing the user on how to properly
    #                execute this script.
    #
    #     Variables: none
    #
    #------------------------------------------------------------------------

    echo "-----------------------------------------------------------------------"
    echo "+                 +++ No arguments provided! +++                      +"
    echo "+                                                                     +"
    echo "+             This program requires at least 1 arguments.             +"
    echo "+                                                                     +"
    echo "+       NOTE: [words] in square brackets represent possible input.    +"
    echo "+             See below for available options.                        +"
    echo "+                                                                     +"
    echo "-----------------------------------------------------------------------"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "   +                Experimental condition                       +"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "   +                                                             +"
    echo "   +  [learn]   or  [learnable]    For the Learnable Condtion    +"
    echo "   +  [unlearn] or  [unlearnable]  For the Unlearnable Condtion  +"
    echo "   +  [debug]   or  [test]         For testing purposes only     +"
    echo "   +                                                             +"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "-----------------------------------------------------------------------"
    echo "+                Example command-line execution:                      +"
    echo "+                                                                     +"
    echo "+      bash wb1.ss-gift.sh learn > logfile_learn.txt 2>&1             +"
    echo "+                                                                     +"
    echo "+                   +++ Please try again +++                          +"
    echo "-----------------------------------------------------------------------"

    exit 1
}


#====================================================================================
#                         ++++++  Start of Main  ++++++
#====================================================================================


function MAIN ()
{
    #------------------------------------------------------------------------
    #
    #   Description: Main
    #
    #       Purpose: This function acts as the launching point of all other
    #                functions within this script. In addition to defining
    #                the path variables used to point to data within the
    #                various directories, it also controls the loop which
    #                iterates over experiment runs. Any operation the user
    #                wishes to be performed related to the analysis should
    #                be executed within this function.
    #         Input: sub0##
    #
    #                Primary input to this function is the subject number,
    #                which is supplied via a loop in the execution body of
    #                this script.
    #
    #        Output: None, see individual functions for output.
    #
    #     Variables: subj, RUN, runsub, FUNC, RD, STIM, GLM, ID, IM, STATS, FITTS
    #
    #------------------------------------------------------------------------

    #----------------------------#
    # Set components of interest #
    #----------------------------#
    case $cond in
          "learn" )
                      Condition="Learnable"
                      subjComps=(1 6 24 30 38)     # These comps reflect afni's 0-based indexing,
                                               # for the real values, see trueComps
                      trueComps=(2 7 25 31 39)
                    ;;

        "unlearn" )
                      Condition="Unlearnable"
                      subjComps=(13 28)
                      trueComps=(14 29)
                    ;;

                 *  )
                      HelpMessage
                    ;;
    esac

    #---------------------------------#
    # Set Top Level Pointer variables #
    #---------------------------------#
    STRUCTURALS=/Volumes/Data/ETC/Structurals   # The location for standard anatomical images
    GIFT=/Volumes/Data/WB1/GiftAnalysis         # Top level directory, all sub direcotries nested under this one

    #-----------------------#
    # Set Pointer variables #
    #-----------------------#
    ATLAS=${GIFT}/Atlas_analysis                          # Location of the pre-made masks
    EXPERT=${ATLAS}/${Condition}_Expert                   # Location of the cluster masks
    EDITABLE=${EXPERT}/Editable                           # Location of the editied cluster masks
    SubICA=${GIFT}/${Condition}/${Condition}_ss_analysis  # Parent dir for single subject analysis, sub dirs nested

    Stripped=${SubICA}/Stripped_component_subject_images  # Location of the single subject data with just the components of interest
    ICMasks=${SubICA}/Whole_component_masks               # Location of masked IC images
    Filtered=${SubICA}/Filtered_subject_images            # Location of the Filtered single subject images
    Clustered=${SubICA}/Clustered_subject_images
    Etc=${SubICA}/Etc                                     # Contains intermediate steps not used in final analysis but kept for reference

    #--------------------------#
    # Make Directory structure #
    #--------------------------#
    mkdir -p {${Stripped},${Etc},${Filtered}}

    #--------------------------#
    # Begin Session iterations #
    #--------------------------#
    for run in s{1..3}; do             # run = s1, s2, s3
        for subj in sub00{1..9}; do    # subj = sub001 sub002 ... sub009
            stripComponents ${run} ${subj}
            filterComponents ${cond} ${run} ${subj}
            reportComponents  ${cond} ${run} ${subj}
        done

        for subj in sub0{10..16}; do    # subj = sub010 sub011 ... sub016
            stripComponents ${run} ${subj}
            filterComponents ${cond} ${run} ${subj}
            reportComponents  ${cond} ${run} ${subj}
        done
    done
}

#====================================================================================
#                         ++++++  End of Main  ++++++
#====================================================================================


cond=$1   # This is a command-line supplied variable which determines
                # which experimental condition should be run. This value is
                # important in that it determines which group of subjects should
                # be run. If this variable is not supplied the program will
                # exit with an error and provide the user with instructions
                # for proper input and execution.


#----------------------------#
#   Execute MAIN function    #
#----------------------------#

MAIN ${cond}

exit

