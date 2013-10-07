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

for task in {un,}learnable; do
    echo $task
    for scanNum in {1..4}; do
        RUN=Run$scanNum

        BASE="/Exps/Analysis/HuanpingWB1/${task}/${RUN}"
        MASK="$BASE/Masks"

        rois=($(ls $MASK/$RUN.$task.*.nii))
        abc=({a..z})

        cmd="3dcalc "

        cmd+=$(3dcalcInputBuilder ${MASK}/overlapMask.nii)

        cmd+=$(3dcalcExprBuilder)

        echo $RUN
        echo $BASE
        echo $MASK
        echo $cmd
    done
done


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
    local prefix=$1

    for (( i = 0; i < ${rois[*]}; i++ )); do
        cmd+="-${abc[i]} ${rois[i]} "   # looks like "-a filename1.nii "
    done

    cmd+="-prefix $prefix "
    echo "$cmd"

} # End of 3dcalcInputBuilder


function 3dcalcExprBuilder() {
    cmd+="-expr \""
    for (( i = 0; i < ${rois[*]}; i++ )); do
        cmd+="step(${abc[i]}) + "
    done
    echo "$cmd"
}

#================================================================================
#                                START OF MAIN
#================================================================================

