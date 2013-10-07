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
        echo $RUN
        echo $BASE
        echo $MASK
    done
done

#================================================================================
#                                START OF MAIN
#================================================================================

