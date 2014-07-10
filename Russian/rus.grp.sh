#!/bin/bash
#================================================================================
#    Program Name: rus.grp.sh
#          Author: Kyle Reese Almryde
#            Date: 07/09/2014
#
#     Description: This program performs a group analysis on the Russian GLM
#                  data.
#                
#                
#    Deficiencies: 
#                
#                
#                
#                
#
#================================================================================
#                        GLOBAL VARIABLE DEFINITIONS 
#================================================================================





#================================================================================
#                            FUNCTION DEFINITIONS 
#================================================================================


function updateArray() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Updates the provided array by adding the supplied dataset(s)
    #            to it.
    #
    #    Input: An Array, and at least one 3D or 4D dataset
    #
    #------------------------------------------------------------------------
    local astr="$1[*]"
    echo $astr
    local arr=(${!astr})
    local index=${#arr[*]}

    for ((input4D=2;input4D<=$#;input4D++)); do
        eval $1[index]=${!input4D}
        ((index++))
    done

    arr=(${!astr})
    
    echo -e "$1 has ${#arr[*]} elements!"

} # End of updateArray


function setup_resultsdir() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Sets up the results directory for the group tTest
    #
    #   Output:  
    #
    #------------------------------------------------------------------------

    mkdir -p /Volumes/Data/Exps/Analysis/Russian/TTEST/RESULTS/Run{1..4}/{0..7}/{Mean,Mask,Filtered,Final}

} # End of setup_resultsdir



function group_tTest() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Performs a group one sample tTest on 
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    delay=$1
    output3D=$2
    astr="$1[*]"; 
    inputArray=(${!astr})

    3dttest++ \
        -setA "${inputArray[*]}" \
        -prefix run1_tTest_${task}_

} # End of group_tTest




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
    
    echo -e "\nMain has been called\n"

    condition=$1        # This is a command-line supplied variable which determines
                        # which experimental condition should be run. This value is
                        # important in that it determines which group of subjects should
                        # be run. If this variable is not supplied the program will
                        # exit with an error and provide the user with instructions
                        # for proper input and execution.

    case $condition in
    "learn"|"learnable"     )
                              condition="learnable"
                              subjList=( sub100 sub104 sub105 sub106
                                         sub109 sub116 sub117 sub145
                                         sub158 sub159 sub160 sub161
                                         sub166                       )

                              ;;

    "unlearn"|"unlearnable" )
                              condition="unlearnable"
                              subjList=( sub111 sub120 sub121 sub124
                                         sub129 sub132 sub133 sub144
                                         sub156 sub163 sub164 sub171  )

                              ;;

    "debug"|"test"          )
                              echo -e "Debugging session\n"
                              condition="debugging"
                              subjList=( sub100 sub111 )
                              ;;

    *                       )
                              HelpMessage
                              ;;
    esac
for 
    # Begin iterating across runs
    for r in {1..4}; do
        #----------------------------
        # Setup Directory Path names
        #----------------------------
        TTEST=/Volumes/Data/Exps/Analysis/Russian/TTEST
        RESULTS=${TTEST}

        for delay in {0..7}; do
            for task in {Sent,Tone}; do
                #---------------------------
                # Setup ttest subject array
                #---------------------------
                ttestList=()           
                for sub in ${subjList[*]}; do  # Populate the array
                    updateArray ttestList "${TTEST}/${sub}/${RUN}/*${delay}sec*${task}*.nii.gz[0]"
                done

            done
        done
    done
} # End of Main




#================================================================================
#                                START OF MAIN
#================================================================================

