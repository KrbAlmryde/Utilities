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

function 3dcalcInputBuilder() {
    #------------------------------------------------------------------------
    #
    #  Purpose: builds the input flags of 3dcalc using the alphabet array
    #  and the filenames.
    #
    #
    #    Input: prefix -- The filename prefix
    #
    #   Output: cmd -- The string representation of cmd, the latest updated
    #   version of it.
    #
    #------------------------------------------------------------------------
    declare -a alpha=(${!1})
    declare -a filenames=(${!2})
    local cmd="3dcalc "

    for (( i = 0; i < ${#filenames[*]}; i++ )); do
        cmd+="-${alpha[i]} ${filenames[i]} "   # looks like "-a filename1.nii "
    done

    echo "$cmd"

} # End of 3dcalcInputBuilder


function 3dcalcExprBuilder() {
    declare -a alpha=(${!1})
    declare -a filenames=(${!2})
    local prefix=$3
    local cmd="-expr '"

    for (( i = 0; i < ${#filenames[*]}; i++ )); do
        if [[ $i == 0 ]]; then
            cmd+="step(${alpha[i]})"
        else
            cmd+=" + step(${alpha[i]})"
        fi
    done
    cmd+="'"
    cmd+=" -prefix $prefix "
    echo "$cmd"
}

#================================================================================
#                                START OF MAIN
#================================================================================

abc=({a..z})  # 3dcalc labels arguments as letters, so we need alphabet array

for task in {un,}learnable; do
        BASE="/Exps/Analysis/HuanpingWB1/${task}"
        TASKMASK="${BASE}/MASK"
        mkdir -p ${TASKMASK}
    for num in {1..3}; do
        RUN=Run$num
        run=run$num
        MASK="${BASE}/${RUN}/Masks"

        cmd=""
        rois=($(ls ${MASK}/${run}_${task}_*.nii.gz))
        cmd+=$(3dcalcInputBuilder abc[*] rois[*])
        cmd+=$(3dcalcExprBuilder abc[*] rois[*] ${TASKMASK}/${run}_${task}_overlapMask.nii)
        calcCMD[$num]=$(echo "$cmd")
        eval ${calcCMD[$num]}
    done
    overlapMasks=($(ls ${TASKMASK}/*overlapMask.nii))
    cmd=$(3dcalcInputBuilder abc[*] overlapMasks[*])
    cmd+=$(3dcalcExprBuilder abc[*] overlapMasks[*] ${TASKMASK}/${task}_GroupMasks.nii)
    eval $cmd
done

