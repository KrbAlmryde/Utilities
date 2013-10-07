#!/bin/bash
#================================================================================
#    Program Name: ice.ss-gift.sh
#          Author: Kyle Reese Almryde
#            Date: 9/03/13 @ 11:30 AM
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
MASKS="/Exps/Analysis/Ice/Figure/Mask"
STRUCTURALS="/Volumes/Data/ETC/StructuralImages"   # The location for standard anatomical images
SSANALYSIS="/Exps/Analysis/Ice/GiftAnalysis/ice_scaling_components_files/Single_Subject_Analysis"

function main() {

    printf "Main has begun!\n"
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" Subject Scan Component Hemisphere 'Mean %change' 'NZ-Mean %change' 'NZ-Voxels'> ${SSANALYSIS}/IceWord_Laterality_Report_s1.txt
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" Subject Scan Component Hemisphere 'Mean %change' 'NZ-Mean %change' 'NZ-Voxels'> ${SSANALYSIS}/IceWord_Laterality_Report_s2.txt
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" Subject Scan Component Hemisphere 'Mean %change' 'NZ-Mean %change' 'NZ-Voxels'> ${SSANALYSIS}/IceWord_Laterality_Report_s3.txt
    printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" Subject Scan Component Hemisphere 'Mean %change' 'NZ-Mean %change' 'NZ-Voxels'> ${SSANALYSIS}/IceWord_Laterality_Report_s4.txt

    for i in {1..14}-{1..4}; do
        #-----------------------------------#
        # Define variable names for program #
        #-----------------------------------#
        run=s${i#*-}
        sub=`printf "sub%03d" ${i%-*}`

        # printf "%s\t%s:\n" $sub $run
        #-------------------------------------#
        # Define pointers for Functional data #
        #-------------------------------------#
        SUBIC="/Exps/Analysis/Ice/GiftAnalysis/ice_scaling_components_files/${sub}_component_ica_${run}"




        for IC in IC{4,11,12,18}; do

            case $IC in
                IC4 )
                    i=3;;
                IC11 )
                    i=10;;
                IC12 )
                    i=11;;
                IC18 )
                    i=17;;
            esac

            # printf "    %s\n" $IC
            #-----------------------------------#
            # Define variable names for program #
            #-----------------------------------#
            subComp=${sub}_${IC}_${run}
            rawSubComp=${sub}_component_ica_${run}_


            # Remove negative activation from dataset
            # 3dmerge \
            #     -1noneg \
            #     -prefix ${SSANALYSIS}/${subComp}.nii \
            #     ${SUBIC}/"${rawSubComp}.nii[$i]"


            for hemi in {L,R}; do

                mask=${hemi}_mask_${IC}_${run}_2.6503

                # Whole Component Masks!!
                # printf "\t%s\n" $hemi
                # printf "\t%s\n" $mask
                # printf "\t%s\n" $subComp

                mean=`3dROIstats -median -nzsigma -quiet -mask ${MASKS}/${mask}.nii "${SSANALYSIS}/${subComp}.nii"`
                nzmean=`3dROIstats -quiet -nzmean -nzvoxels -mask ${MASKS}/${mask}.nii "${SSANALYSIS}/${subComp}.nii"`
                printf "${nzmean}\n"
                printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\n" $sub $run $IC $hemi $nzmean >> ${SSANALYSIS}/IceWord_Laterality_Report_${run}.txt
            done
        done
    done

}

#================================================================================
#                                START OF MAIN
#================================================================================



main