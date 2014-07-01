#!/bin/bash
#================================================================================
#    Program Name: wb2.laterality.sh
#          Author: Kyle Reese Almryde
#            Date: 
#
#     Description: This program extracts the laterality information from the 
#                  supplied subject
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


function laterality() {
    #------------------------------------------------------------------------
    #
    #  Purpose: To determine the laterality of supplied mask values
    #
    #
    #    Input: input3D -- is the data file you wish to get your laterality 
    #                      scores from. Can contain multiple subbricks if so
    #                      desired.
    #           mask -- is the masked roi(s) you wish to use to determine the
    #                   the laterality value. Can contain multiple ROIs which
    #                   must be (ideally) different whole integers
    #
    #   Output: a tab seperated document with the following form:
    #           sub_run_condition.nii:Coef\tmaskValue0\tmaskValue1\tmaskValue2\tmaskValue3
    #           sub_run_condition.nii:Tstat   maskValue0   maskValue1   maskValue2   maskValue3
    #
    #------------------------------------------------------------------------

    local mask=$1
    local input3D=$2
    local inFileName=$(basename ${input3D})

    results=$(3dROIstats -quiet -mask $mask $input3D)

    # assuming there are two subbricks per input3D file, and up to 4 mask values
    #+per run. ROIstats will give something like the following:
    #+subbrick0  maskValue0   maskValue1   maskValue2   maskValue3
    #+subbrick1  maskValue0   maskValue1   maskValue2   maskValue3

    # If you store the values in an array you can iterate over each of them as
    # if they were store in this format:
    # subbrick0  maskValue0   maskValue1   maskValue2   maskValue3 subbrick1  maskValue0   maskValue1   maskValue2   maskValue3

    report=""
    
    for((i=0; i<${#results[*]}; i++)); do
        case $i in
            0 ) 
                report="${inFileName}:Coef\t"
            ;;
            4 )
                report="\n${inFileName}:Tstat\t"
            ;;
            * )
                report="${results[i]}\t"
        esac
    done
    
    printf "${report}\n"  

    # The output of this function will be 
}

# All three functions will strip negative activation from datasets, all you
# need to do then is specify the correction threshold and cluster value for
# the appropriate functions. All you're after here is being able to remove
# negative activation (confirm with Elena), and doing appropriate level of
# correction, if at all. These functions should be VERY similar otherwise

function corrected() {
    input3D=$1
    output3D=$2
    threshold=1.234
    clsuter=5678

    3dmerge \
        -dxyz=1 -1noneg \
        -1thresh $threshold \
        -1clust $cluster \
        # 1tindex is referring to which subbrick contains the tStat, double check this!!
        # idindex assumes you want the output data values to be based on the list subbrick, double check this with elena!!
        -1tindex 1 -1dindex 0 \
        -prefix $output3D \
        $input3D

    echo $outFilename
}


function unCorrected() {
    input3D=$1
    output3D=$2
    threshold=1.234

    3dmerge \
        -dxyz=1 -1noneg \
        -1thresh $threshold \
        # 1tindex is referring to which subbrick contains the tStat, double check this!!
        # idindex assumes you want the output data values to be based on the list subbrick, double check this with elena!!
        -1tindex 1 -1dindex 0 \
        -prefix $output3D \
        $input3D

    echo $outFilename

}

function unThresholded() {
    input3D=$1
    output3D=$2

    3dmerge \
        -dxyz=1 -1noneg \
        -prefix $output3D \
        $input3D

    echo $outFilename
}

#================================================================================
#                                START OF MAIN
#================================================================================

function main() {

    for run in Run{1..3}; do


        laterality $mask $(corrected $subrun_$cond_glm.nii.gz) > Laterality_Report_$run.txt
}