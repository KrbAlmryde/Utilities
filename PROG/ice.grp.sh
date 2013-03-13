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


group_ANOVA () {
    #=========================================
    # alevels: 3 -- Listen, Response, Control
    # blevels: 14 -- Subjects
    #=========================================
    cd ${RESULT}

    for delay in {0..7}; do
        listen_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ListenStats.nii.gz`)
        response_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ResponseStats.nii.gz`)
        control_array=(`ls ${BASE}/sub0*/${RUN}/*_${delay}sec_ControlStats.nii.gz`)

        3dANOVA2 \
            -type 3 -alevels 3 -blevels 14 \
            -dset 1 1 ${listen_array[0]}'[1]' \
            -dset 2 1 ${response_array[0]}'[1]' \
            -dset 3 1 ${control_array[0]}'[1]' \
            -dset 1 2 ${listen_array[1]}'[1]' \
            -dset 2 2 ${response_array[1]}'[1]' \
            -dset 3 2 ${control_array[1]}'[1]' \
            -dset 1 3 ${listen_array[2]}'[1]' \
            -dset 2 3 ${response_array[2]}'[1]' \
            -dset 3 3 ${control_array[2]}'[1]' \
            -dset 1 4 ${listen_array[3]}'[1]' \
            -dset 2 4 ${response_array[3]}'[1]' \
            -dset 3 4 ${control_array[3]}'[1]' \
            -dset 1 5 ${listen_array[4]}'[1]' \
            -dset 2 5 ${response_array[4]}'[1]' \
            -dset 3 5 ${control_array[4]}'[1]' \
            -dset 1 6 ${listen_array[5]}'[1]' \
            -dset 2 6 ${response_array[5]}'[1]' \
            -dset 3 6 ${control_array[5]}'[1]' \
            -dset 1 7 ${listen_array[6]}'[1]' \
            -dset 2 7 ${response_array[6]}'[1]' \
            -dset 3 7 ${control_array[6]}'[1]' \
            -dset 1 8 ${listen_array[7]}'[1]' \
            -dset 2 8 ${response_array[7]}'[1]' \
            -dset 3 8 ${control_array[7]}'[1]' \
            -dset 1 9 ${listen_array[8]}'[1]' \
            -dset 2 9 ${response_array[8]}'[1]' \
            -dset 3 9 ${control_array[8]}'[1]' \
            -dset 1 10 ${listen_array[9]}'[1]' \
            -dset 2 10 ${response_array[9]}'[1]' \
            -dset 3 10 ${control_array[9]}'[1]' \
            -dset 1 11 ${listen_array[10]}'[1]' \
            -dset 2 11 ${response_array[10]}'[1]' \
            -dset 3 11 ${control_array[10]}'[1]' \
            -dset 1 12 ${listen_array[11]}'[1]' \
            -dset 2 12 ${response_array[11]}'[1]' \
            -dset 3 12 ${control_array[11]}'[1]' \
            -dset 1 13 ${listen_array[12]}'[1]' \
            -dset 2 13 ${response_array[12]}'[1]' \
            -dset 3 13 ${control_array[12]}'[1]' \
            -dset 1 14 ${listen_array[13]}'[1]' \
            -dset 2 14 ${response_array[13]}'[1]' \
            -dset 3 14 ${control_array[13]}'[1]' \
            -amean 1 mean_${run}_${delay}sec_Listen.nii.gz \
            -amean 2 mean_${run}_${delay}sec_Response.nii.gz \
            -amean 3 mean_${run}_${delay}sec_Control.nii.gz \
            -acontr 1 0 -1 contrast_${run}_${delay}sec_Lsn-Ctr.nii.gz \
            -acontr -1 1 0 contrast_${run}_${delay}sec_Rsp-Lsn.nii.gz \
            -acontr 0 1 -1 contrast_${run}_${delay}sec_Rsp-Ctr.nii.gz
    done

}


function Main () {
    echo -e "\nMain has been called\n"

    #--------------------#
    # Initiate functions #
    #--------------------#
    group_ANOVA 2>&1 | tee -a ${RESULT}/log.txt
    # regress_alphcor ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee ${GLM}/log.txt
}



#================================================================================
#                                START OF MAIN
#================================================================================

opt=$1  # This is an optional command-line variable which should be supplied
        # in for testing purposes only. The only available operation should
        # "test"



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
    BASE=/Volumes/Data/ICE/ANOVA
    RESULT=/Volumes/Data/ICE/ANOVA/RESULTS/${RUN}

    # We removed sub018 from the analysis, so dont perform any operations them.
    if [[ $sub != "sub018" ]]; then

        # Check whether Test_Main should or Main should be run
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
    fi

done

# regress_nodata

#================================================================================
#                              END OF MAIN
#================================================================================
