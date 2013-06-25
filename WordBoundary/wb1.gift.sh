#!/bin/bash
#================================================================================
#   Program Name: wb1.gift.sh
#         Author: Kyle Reese Almryde
#           Date:
#
#    Description:
#
#
#
#          Notes:
#
#   Deficiencies: It may be necessary at points to construct and edit masks
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================

function thresh_components ()
{
    #------------------------------------------------------------------------
    #
    #   Description: thresh_components
    #
    #       Purpose: Threshold components of interest at the provided p-lvl
    #                 as well as remove any negative activation from the
    #                 image.
    #
    #         Input: cond => THe present condition, availale options are
    #                        learn or unlearn
    #                comp => The component number of interest
    #                run => The current scan, options incude run1-4
    #
    #        Output: Produces a positive actiavtion only statistical map
    #                 thresholded to the desired p-lvl.
    #
    #------------------------------------------------------------------------
    cond=$1; comp=$2; run=$3

    if [[ ${cond} == 'unlearn' ]]; then
        local input4d=${cond}_${run}_IC${comp}
    else
        local input4d=${cond}_IC${comp}_${run}
    fi

    local output4=${cond}_IC${comp}_${run}_${tstat}

    echo -e "\n========================================================="
    echo -e "Thresholding Components @ ${tstat}"

    # Merge clusters exlcuding Negative activations
    3dmerge \
        -1noneg \
        -dxyz=1 \
        -1clust 1 ${clust} \
        -1thresh ${tstat} \
        -prefix ${Merged}/Etc/${output4}.nii \
        ${EXPERT}/${input4d}.nii.gz

    3drefit -space MNI ${Merged}/Etc/"${output4}.nii"


    echo -e "========================================================\n"
}


function filterComponents ()
{
    #------------------------------------------------------------------------
    #
    #   Purpose: This function will filter the masked Component images
    #            through the stripped single subject images. It produces
    #            a whole brain filtered image as well as hemisphere specific
    #            images
    #     Input: condition, component, scan
    #
    #    Output: Whole brain filtered image, hemishpere specific image
    #
    #------------------------------------------------------------------------

    cond=$1; comp=$2; run=$3

    echo -e "\n========================================================="
    echo -e "Filtering Single Subject Data through Whole Component Masks and Clustered Component Masks"
    local input4dMerged=${cond}_IC${comp}_${run}_${tstat}
    local inputMask=all_${run}_IC${comp}_bin
    local output4dFilter=${cond}_IC${comp}_${run}_${tstat}_Filtered

    echo -e "\t\nFiltering component masks!!\n"
    3dcalc \
        -a "${EDITABLE}/${inputMask}.nii.gz" \
        -b "${Merged}/Etc/${input4dMerged}.nii" \
        -expr 'a * b' \
        -prefix ${Merged}/${output4dFilter}.nii

    for side in {L,R}; do
        # Whole Component Masks!!

        echo -e "\t\nFiltering ${side} side image!!\n"
        3dcalc \
            -a "${EDITABLE}/${inputMask}.nii.gz" \
            -b "${Merged}/Etc/${input4dMerged}.nii" \
            -c "${STRUCTURALS}/MNI_2mm_mask_${side}.nii" \
            -expr 'c * (a * b)' \
            -prefix ${Merged}/${side}/${output4dFilter}_${side}.nii

    done

    echo -e "========================================================\n"

} # End of filterComponents



function display_components ()
{
    #------------------------------------------------------------------------
    #
    #   Description: display_components
    #
    #       Purpose: Create a static value mask from the supplied datasets in
    #                order to display each components unique ROI as well as
    #                which portions of those components that overlap with one
    #                another. Below is the value and mapped color assigned to
    #                each component, and the associated overlap value and color
    #
    #                Component colors
    #                     1 - Red     ==> 1.01
    #                     2 - Yellow  ==> 1.02
    #                     3 - Orange  ==> 1.03
    #                     4 - Green   ==> 1.04
    #                     5 - Purple  ==> 1.05
    #
    #                Overlapping Component colors
    #                   2 Components - Cyan blue
    #                   3 Components - Light blue
    #                   4 Components - Dark Blue
    #                   5 Components - Navy blue
    #
    #------------------------------------------------------------------------

    echo -e "\n\n=============================================="
    echo -e "\tOverlapping Components for ${cond} ${run}"
    echo -e "=============================================="

    # If the condition is Learnable, do the following
    if [[ $cond == learn ]]; then
        # Create overlapping display images that contain all components
        3dcalc \
            -a "${Merged}/${cond}_IC${realComps[0]}_${run}_${tstat}_Filtered.nii" \
            -b "${Merged}/${cond}_IC${realComps[1]}_${run}_${tstat}_Filtered.nii" \
            -c "${Merged}/${cond}_IC${realComps[2]}_${run}_${tstat}_Filtered.nii" \
            -d "${Merged}/${cond}_IC${realComps[3]}_${run}_${tstat}_Filtered.nii" \
            -e "${Merged}/${cond}_IC${realComps[4]}_${run}_${tstat}_Filtered.nii" \
            -expr 'step(a)*1.01 + step(b)*1.02 + step(c)*1.03 + step(d)*1.04 + step(e)*1.05' \
            -prefix ${Images}/${cond}_Figure_${run}_${tstat}.nii

    # Else if the condition is Unlearnable, do the following
    elif [[ $cond == unlearn ]]; then

        if [[  ${run} == 's1' && ${comp} == 29 ]]; then
            3dcalc \
                -a "${Merged}/${cond}_IC${realComps[0]}_${run}_${tstat}_Filtered.nii" \
                -expr 'step(a)*1.01' \
                -prefix ${Images}/${cond}_Figure_${run}_${tstat}.nii
        else
            3dcalc \
                -a "${Merged}/${cond}_IC${realComps[0]}_${run}_${tstat}_Filtered.nii" \
                -b "${Merged}/${cond}_IC${realComps[1]}_${run}_${tstat}_Filtered.nii" \
                -expr 'step(a)*1.01 + step(b)*1.02' \
                -prefix ${Images}/${cond}_Figure_${run}_${tstat}.nii
        fi
    fi
}



function reportComponents ()
{
    #------------------------------------------------------------------------
    #
    #   Description: reportComponents
    #
    #       Purpose: Filters the single-subject data through a group mask of
    #                the activation in order to see which subjects contributed
    #                to the group activations.
    #
    #------------------------------------------------------------------------
    cond=$1; comp=$2; run=$3

    echo -e "\n========================================================="
    echo -e "Constructing Masks from Whole Component Images: Session: ${run}"

    if [[ -f ${Report}/temp_${Condition}_grp_rpt.txt ]]; then
        echo ""
    else
        echo -e \
            "Scan\tHemisphere\tSubject\tComponent\tMean\tVariance" \
            > ${Report}/temp_${Condition}_grp_rpt.txt
    fi

    for side in {L,R}; do
        local input4d=${cond}_IC${comp}_${run}_${tstat}_Filtered_${side}

        if [[ ${cond} == 'unlearn' && ${run} == 's1' && ${comp} == 29 ]]; then
            stat="0.0000     0.0000"
        else
            stat=$(3dBrickStat \
                        -mean -var \
                        -non-zero \
                        ${Merged}/${side}/${input4d}.nii)
        fi

        echo -e \
            "${run}\t${side}\tIC${comp}\t${stat}" \
            >> ${Report}/temp_${Condition}_grp_rpt.txt

        echo -e "\t\nComponent: ${trueComps[i]}\n"
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
    echo "+             bash wb1.gift.sh learn [display || report]              +"
    echo "+                                                                     +"
    echo "+                  +++ Please try again +++                           +"
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
    #
    #         Input: sub0##
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
                      comps=(1 6 24 30 38)     # These comps reflect afni's 0-based indexing,
                                               # for the real values, see realComps
                      realComps=(2 7 25 31 39)
                    ;;

        "unlearn" )
                      Condition="Unlearnable"
                      comps=(13 28)
                      realComps=(14 29)
                    ;;

               *  )
                       HelpMessage
                    ;;
    esac

    #--------------------------#
    # Begin Session iterations #
    #--------------------------#
    for run in s1 s2 s3; do

        #--------------------------#
        # Set additional variables #
        #--------------------------#
        tstat=2.6026     # This is our t-threshold value @ 0.05
        clust=274      # Cluster correction value @ 0.05


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

        Figure=${GIFT}/${Condition}/${Condition}_figure      # Parent dir for WB1 figure, for each condition, sub dirs nested
        Images=${Figure}/Images     # contains jpg/png images and rgb images
        Merged=${Figure}/Merged     # contains thresholded & and corrected ica data
        Report=${Figure}/Report     # contains txt files reporting ROIs and other information

        #--------------------------#
        # Make Directory structure #
        #--------------------------#
        mkdir -p {${Images},${Merged}/{L,R,Etc},${Report}}


        #--------------------#
        # Initiate functions #
        #--------------------#

        for (( i = 0; i < ${#realComps[*]}; i++ )); do
            thresh_components $cond ${realComps[i]} $run
            filterComponents $cond ${realComps[i]} $run
            reportComponents $cond ${realComps[i]} $run
        done
        display_components $cond $run
        python ${UTL}/wb1_${Condition}Grp_formatter.py
    done
}

#====================================================================================
#                         ++++++  End of Main  ++++++
#====================================================================================


cond=$1     # This is a command-line supplied variable which determines
                # which experimental condition should be run. This value is
                # important in that it determines which group of subjects should
                # be run. If this variable is not supplied the program will
                # exit with an error and provide the user with instructions
                # for proper input and execution.

operation=$2    # This command-line supplied variable is optional. If it is left


#----------------------------#
#   Execute MAIN function    #
#----------------------------#

MAIN ${cond} ${operation}

exit



function report_components ()
{
    #------------------------------------------------------------------------
    #
    #   Description: report_components
    #
    #       Purpose:
    #
    #         Input:
    #
    #        Output:
    #
    #     Variables:
    #
    #------------------------------------------------------------------------

    filterComps ()
    {
        if [[ -f ${Merged}/${mergedComponents}_${tstat}_filtered.nii ]]; then
            echo "exists, skipping"
            # rm ${Merged}/${mergedComponents}_${tstat}_filtered.nii
            # rm ${Etc}/${mergedComponents}_${tstat}_filter_Comp*
        else
            for (( i = 0; i < ${#comps[*]}; i++ )); do
                3dcalc \
                    -a "${Merged}/${mergedComponents}_${tstat}.nii[$i]" \
                    -b "${Structurals}/MNI_2mm_mask.nii" \
                    -expr "a * b" \
                    -prefix ${Etc}/${mergedComponents}_${tstat}_filter_Comp${i}

                # Bucket the merged files together to keep directories clean
                3dbucket \
                    -aglueto ${Etc}/${mergedComponents}_${tstat}_filtered+tlrc \
                    ${Etc}/${mergedComponents}_${tstat}_filter_Comp${i}+tlrc
            done

            3dCopy \
                ${Etc}/${mergedComponents}_${tstat}_filtered+tlrc \
                ${Merged}/${mergedComponents}_${tstat}_filtered.nii
        fi
    }

    clusterCoords ()
    {
        for (( i = 0; i < ${#comps[*]}; i++ )); do
            3dclust \
                -1noneg \
                -1dindex $i \
                -1tindex $i \
                -1Dformat 2 1402 \
                ${Merged}/${mergedComponents}_${tstat}_filtered.nii \
            | tail +12 \
            | awk -v OFS='\t' '{print "'${run}'", "'${comps[i]}'", $1, $13, $14, $15, $16 }' \
            | sed '/#/d'
        done
    }

    whereamiReport ()
    {
        roi_coord=${1}

        whereami \
            -ok_1D_text \
            -atlas CA_ML_18_MNIA \
            -coord_file ${ROI}/${roi_coord}'[4,5,6]' \
        | egrep -C1 '^Atlas CA_ML_18_MNIA: Macro Labels \(N27\)$' \
        | egrep '^   Focus point|Within . mm' \
        | colrm 1 16 \
        | awk -v OFS='\t' '{print $1,$2" "$3" "$4}'
    }


    filterComps

    rm ${Report}/${reportComponents}_clusterCoords.1D
    clusterCoords >> ${Report}/${reportComponents}_clusterCoords.1D

    whereamiReport ${Report}/${reportComponents}_clusterCoords.1D > ${Report}/${reportComponents}_whereami.1D

    paste \
        ${Report}/${reportComponents}_whereami.1D \
        ${Report}/${reportComponents}_clusterCoords.1D \
        > ${Report}/${reportComponents}_report.txt
}


