#!/bin/bash
#================================================================================
#    Program Name: ice.grp.sh
#          Author: Kyle Reese Almryde
#            Date:
#
#     Description: This program computes the ANOVA of the Iceword group data
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


function group_tTest () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Perform a one-sample ttest using 3dttest++
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    for delay in {0..0}; do

        # mkdir -p ${TTEST}/${delay}
        cd ${TTEST}

        listen_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ListenStats.nii.gz`)
        response_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ResponseStats.nii.gz`)
        control_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ControlStats.nii.gz`)


        3dttest++ \
            -paired \
            -mask ${MASK}/MNI_2mm_mask.nii \
            -prefix tTest_${run}_Lsn-Ctr_${delay}sec.nii.gz \
            -setA ${listen_array[0]}'[0]' \
                  ${listen_array[1]}'[0]' \
                  ${listen_array[2]}'[0]' \
                  ${listen_array[3]}'[0]' \
                  ${listen_array[4]}'[0]' \
                  ${listen_array[5]}'[0]' \
                  ${listen_array[6]}'[0]' \
                  ${listen_array[7]}'[0]' \
                  ${listen_array[8]}'[0]' \
                  ${listen_array[9]}'[0]' \
                  ${listen_array[10]}'[0]' \
                  ${listen_array[11]}'[0]' \
                  ${listen_array[12]}'[0]' \
                  ${listen_array[13]}'[0]' \
            -setB ${control_array[0]}'[0]' \
                  ${control_array[1]}'[0]' \
                  ${control_array[2]}'[0]' \
                  ${control_array[3]}'[0]' \
                  ${control_array[4]}'[0]' \
                  ${control_array[5]}'[0]' \
                  ${control_array[6]}'[0]' \
                  ${control_array[7]}'[0]' \
                  ${control_array[8]}'[0]' \
                  ${control_array[9]}'[0]' \
                  ${control_array[10]}'[0]' \
                  ${control_array[11]}'[0]' \
                  ${control_array[12]}'[0]' \
                  ${control_array[13]}'[0]'

        3dttest++ \
            -paired \
            -mask ${MASK}/MNI_2mm_mask.nii \
            -prefix tTest_${run}_Rsp-Lsn_${delay}sec.nii.gz \
            -setA ${response_array[0]}'[0]' \
                  ${response_array[1]}'[0]' \
                  ${response_array[2]}'[0]' \
                  ${response_array[3]}'[0]' \
                  ${response_array[4]}'[0]' \
                  ${response_array[5]}'[0]' \
                  ${response_array[6]}'[0]' \
                  ${response_array[7]}'[0]' \
                  ${response_array[8]}'[0]' \
                  ${response_array[9]}'[0]' \
                  ${response_array[10]}'[0]' \
                  ${response_array[11]}'[0]' \
                  ${response_array[12]}'[0]' \
                  ${response_array[13]}'[0]' \
            -setB ${listen_array[0]}'[0]' \
                  ${listen_array[1]}'[0]' \
                  ${listen_array[2]}'[0]' \
                  ${listen_array[3]}'[0]' \
                  ${listen_array[4]}'[0]' \
                  ${listen_array[5]}'[0]' \
                  ${listen_array[6]}'[0]' \
                  ${listen_array[7]}'[0]' \
                  ${listen_array[8]}'[0]' \
                  ${listen_array[9]}'[0]' \
                  ${listen_array[10]}'[0]' \
                  ${listen_array[11]}'[0]' \
                  ${listen_array[12]}'[0]' \
                  ${listen_array[13]}'[0]'

    done
} # End of group_tTest



function group_ANOVA () {
    #=========================================
    # alevels: 3 -- Listen, Response, Control
    # blevels: 14 -- Subjects
    #=========================================
    for delay in {0..7}; do

        mkdir -p ${ANOVA}/${delay}
        cd ${ANOVA}/${delay}

        listen_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ListenStats.nii.gz`)
        response_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ResponseStats.nii.gz`)
        control_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ControlStats.nii.gz`)

        3dANOVA2 \
            -type 3 -alevels 3 -blevels 14 \
            -dset 1 1 ${listen_array[0]}'[0]' \
            -dset 2 1 ${response_array[0]}'[0]' \
            -dset 3 1 ${control_array[0]}'[0]' \
            -dset 1 2 ${listen_array[1]}'[0]' \
            -dset 2 2 ${response_array[1]}'[0]' \
            -dset 3 2 ${control_array[1]}'[0]' \
            -dset 1 3 ${listen_array[2]}'[0]' \
            -dset 2 3 ${response_array[2]}'[0]' \
            -dset 3 3 ${control_array[2]}'[0]' \
            -dset 1 4 ${listen_array[3]}'[0]' \
            -dset 2 4 ${response_array[3]}'[0]' \
            -dset 3 4 ${control_array[3]}'[0]' \
            -dset 1 5 ${listen_array[4]}'[0]' \
            -dset 2 5 ${response_array[4]}'[0]' \
            -dset 3 5 ${control_array[4]}'[0]' \
            -dset 1 6 ${listen_array[5]}'[0]' \
            -dset 2 6 ${response_array[5]}'[0]' \
            -dset 3 6 ${control_array[5]}'[0]' \
            -dset 1 7 ${listen_array[6]}'[0]' \
            -dset 2 7 ${response_array[6]}'[0]' \
            -dset 3 7 ${control_array[6]}'[0]' \
            -dset 1 8 ${listen_array[7]}'[0]' \
            -dset 2 8 ${response_array[7]}'[0]' \
            -dset 3 8 ${control_array[7]}'[0]' \
            -dset 1 9 ${listen_array[8]}'[0]' \
            -dset 2 9 ${response_array[8]}'[0]' \
            -dset 3 9 ${control_array[8]}'[0]' \
            -dset 1 10 ${listen_array[9]}'[0]' \
            -dset 2 10 ${response_array[9]}'[0]' \
            -dset 3 10 ${control_array[9]}'[0]' \
            -dset 1 11 ${listen_array[10]}'[0]' \
            -dset 2 11 ${response_array[10]}'[0]' \
            -dset 3 11 ${control_array[10]}'[0]' \
            -dset 1 12 ${listen_array[11]}'[0]' \
            -dset 2 12 ${response_array[11]}'[0]' \
            -dset 3 12 ${control_array[11]}'[0]' \
            -dset 1 13 ${listen_array[12]}'[0]' \
            -dset 2 13 ${response_array[12]}'[0]' \
            -dset 3 13 ${control_array[12]}'[0]' \
            -dset 1 14 ${listen_array[13]}'[0]' \
            -dset 2 14 ${response_array[13]}'[0]' \
            -dset 3 14 ${control_array[13]}'[0]' \
            -amean 1 mean_${run}_${delay}sec_Listen.nii.gz \
            -amean 2 mean_${run}_${delay}sec_Response.nii.gz \
            -amean 3 mean_${run}_${delay}sec_Control.nii.gz \
            -acontr 1 0 -1 contrast_${run}_${delay}sec_Ln-Ct.nii.gz \
            -acontr -1 1 0 contrast_${run}_${delay}sec_Rs-Ln.nii.gz \
            -acontr 0 1 -1 contrast_${run}_${delay}sec_Rs-Ct.nii.gz
    done

}


function group_MergePos () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Merge the data so only the positive activation remains
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    plvl=$1
    input3d=$2
    output3d=''

    clust=$(awk 'match($1,'${plvl}'0000 ) {print $11}' \
            ${ETC}/ClustSim.NN1.1D)

    statpar=$(3dinfo ${TTEST}/${label[l]}.${type}+tlrc"[1]" \
            | awk '/statcode = fitt/ {print $6}')

    thresh=$(ccalc -expr "fitt_p2t(${plvl}0000,${statpar})")

    3dmerge -dxyz=1 \
        -1clust 2.01 ${clust} \
        -1thresh ${thresh} \
        -prefix ${THRESH}/merge.${type}.${label[l]} \
        ${TTEST}/${label[l]}.${type}+tlrc[1]

} # End of group_MergePos



function Main () {
    echo -e "\nMain has been called\n"

    # The {5..19}-{1..4} is brace notation which acts as a nested for-loop
    # The '-' acts as a seperator which allows for easy substring operations when
    # assiging the variable names for the rest of the program.

    for i in {1..4}; do
        #-----------------------------------#
        # Define variable names for program #
        #-----------------------------------#
        run=run${i}
        RUN=Run${i}

        #---------------------------------#
        # Define pointers for GLM results #
        #---------------------------------#
        GLM=/Volumes/Data/Iceword/GLM/
        BASE=/Volumes/Data/Iceword/ANALYSIS
        ANOVA=/Volumes/Data/Iceword/ANALYSIS/ANOVA/${RUN}
        TTEST=/Volumes/Data/Iceword/ANALYSIS/TTEST/${RUN}
        MASK=/Volumes/Data/StructuralImage

        #--------------------#
        # Initiate functions #
        #--------------------#
        # group_ANOVA 2>&1 | tee -a ${ANOVA}/log_anova.txt
        # group_tTest 2>&1 | tee -a ${ANOVA}/log_ttest.txt

    done

}



#================================================================================
#                                START OF MAIN
#================================================================================

opt=$1  # This is an optional command-line variable which should be supplied
        # in for testing purposes only. The only available operation should
        # be "test"


# Check whether Test_Main or Main should be run
case $opt in
    "test" )
        Test_Main 2>&1 | tee ${BASE}/log.TEST.txt
        ;;

    "check" )
        check_outLog
        ;;

      * )
        Main 2>&1 | tee -a ${BASE}/log.txt
        ;;
esac


#================================================================================
#                              END OF MAIN
#================================================================================
