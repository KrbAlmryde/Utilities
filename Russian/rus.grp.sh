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
    #   Output:  /Volumes/Data/Exps/Analysis/Russian/TTEST/RESULTS/
    #                                        Ru1/
    #                                            0/
    #                                              Mean/
    #                                              Mask/
    #                                              Filtered/
    #                                                   Negative/
    #                                              Final/
    #                                                   Negative/
    #
    #------------------------------------------------------------------------

    mkdir -p /Volumes/Data/Exps/Analysis/Russian/TTEST/RESULTS/Run{1..4}/{0..7}/{Mean,Mask,Merge,Final}

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
    local astr="$1[*]"; local inputArray=(${!astr})
    local STRUCT="/Volumes/Data/GlobalSession"  # This directory is dependant on Hagar!
    output3D=$2


    echo -e "group_tTest $RUN $delay $task has been called!\n"

    3dttest++ \
            -mask ${STRUCT}/MNI_2mm_mask.nii \
            -setA "${inputArray[*]}" \
            -prefix ${MEAN}/${output3D}.nii.gz

} # End of group_tTest



function group_mergeThresh() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Remove negative activation from input file and apply threshold
    #           and cluster correction.
    #
    #------------------------------------------------------------------------

    input3D=$1
    output3D=${2}
    statpar=$(3dinfo "${MEAN}/${input3D}.nii.gz[1]" \
            | awk '/statcode = fitt/ {print $6}')

    thresh=$(ccalc -expr "fitt_p2t(${plvl}0000,${statpar})")

    # Threshold via tStat, write beta-weights to file 
    3dmerge -dxyz=1 \
        -1noneg \
        -1dindex 0 \
        -1tindex 1 \
        -1clust 1 ${clust} \
        -1thresh ${thresh} \
        -prefix ${MERGE}/${output3D}_Coef.nii.gz \
        ${MEAN}/${input3D}.nii.gz

    # Threshold via tStat, write tStats to file
    3dmerge -dxyz=1 \
        -1noneg \
        -1dindex 1 \
        -1tindex 1 \
        -1clust 1 ${clust} \
        -1thresh ${thresh} \
        -prefix ${MERGE}/${output3D}_tStat.nii.gz \
        ${MEAN}/${input3D}.nii.gz 


    3dmerge -dxyz=1 -1noneg -1dindex 1 -1tindex 1 -1clust 1 ${clust} \
        -1thresh ${thresh} \
        -prefix ${MERGE}/${output3D}_tStat.nii.gz \
        ${MEAN}/${input3D}.nii.gz 


    # Bucket the Coef and Tstat together
    3dBucket \
        -fbuc \
        -prefix ${MERGE}/${output3D}.nii.gz \
        ${MERGE}/${output3D}_Coef.nii.gz \
        ${MERGE}/${output3D}_tStat.nii.gz

    # Inject the stat information to the Tstat subbrik and relabel both briks
    3drefit \
        -substatpar 1 fitt ${statpar} \
        -sublabel 0 Sent#Mean \
        -sublabel 1 Sent#Tstat \
        ${MERGE}/${output3D}.nii.gz


    # remove the Coef and Tstat auxiliary images
    rm ${MERGE}/${output3D}_Coef.nii.gz \
        ${MERGE}/${output3D}_tStat.nii.gz

} # End of group_mergeThresh




function group_() {
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

    local DIRNAME=/path/
    local var=param1

} # End of group_




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

function HelpMessage() {
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
   echo "+                    bash rus.grp.sh learn                            +"
   echo "+                                                                     +"
   echo "+                  +++ Please try again +++                           +"
   echo "-----------------------------------------------------------------------"

   exit 1
}


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
                                         sub156 sub163 sub164  ) # sub171  Not preprocessed yet

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

    # Begin iterating across runs
    for var in {1..4}-{0..7}; do   
        #----------------------------
        # Setup some variables
        #----------------------------
        RUN=Run$(echo ${var} | cut -d'-' -f1)
        delay=$(echo ${var} | cut -d'-' -f2)
        run=$(tr [A-Z] [a-z] <<< $RUN)  # converts 1st char of Run# to lowercase
        task=Sent
        plvl=0.5
        clust=578
    
        #----------------------------
        # Setup Directory Path names
        #----------------------------
        TTEST=/Volumes/Data/Exps/Analysis/Russian/TTEST
        RESULTS=${TTEST}/RESULTS
        MEAN=${RESULTS}/${RUN}/${delay}/Mean
        MASK=${RESULTS}/${RUN}/${delay}/Mask
        MERGE=${RESULTS}/${RUN}/${delay}/Merge
        FINAL=${RESULTS}/${RUN}/${delay}/Final

        #-------------------------
        # Setup output file names
        #-------------------------
        statName=volreg_despike_mni_5mm_176tr_${delay}sec_${condition}_${task}Stats
        tTestName=${run}_${delay}sec_${condition}_${task}_tTest
        mergeName=${tTestName}_mergeNN_p${plvl}_vmul${clust}
        maskName=mask_${mergeName}_orderd

        #---------------------------
        # Setup ttest subject array
        #---------------------------
        ttestList=()                  

        for sub in ${subjList[*]}; do  # Populate the array
            updateArray ttestList "${TTEST}/${sub}/${RUN}/${run}_${sub}_${statName}.nii.gz[0]"
        done

        #--------------------
        # Initiate Functions
        #--------------------  
        setup_resultsdir     
        group_tTest ttestList ${tTestName}
        group_mergeThresh ${tTestName} ${mergeName}

    done

} # End of Main

#================================================================================
#                                START OF MAIN
#================================================================================

cond=$1

Main $cond 2>&1 | tee /Volumes/Data/Exps/Analysis/Russian/TTEST/log.GROUP.txt

exit
#================================================================================
#                              END OF MAIN
#================================================================================

<<NOTE
 3dClustSim -nxyz 91 109 91 -dxyz 2 2 2 -fwhm 5 -pthr 0.05 0.01
# Grid: 91x109x91 2.00x2.00x2.00 mm^3 (902629 voxels)
#
# CLUSTER SIZE THRESHOLD(pthr,alpha) in Voxels
# -NN 1  | alpha = Prob(Cluster >= given size)
#  pthr  | .10000 .05000 .02000 .01000
# ------ | ------ ------ ------ ------
 0.050000   427.8  472.0  527.7  578.0
 0.010000    92.0  100.8  111.6  118.7

NOTE