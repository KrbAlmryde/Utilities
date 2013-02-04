#!/bin/bash
#================================================================================
#   Program Name: wb1.roi.sh
#         Author: Kyle Reese Almryde
#           Date: 11/07/12 @ 01:08 PM
#
#    Description: This program will cycle through the list of manual cluster
#                      images identifying the peak xyz and region of interest
#                      associated with that point. It will then print the information
#                      to a text file. The objective is to identify which clusters
#                      contain which ROIs, so that the single subject analysis can go
#                      a little smoother.
#                      A secondary object of this program is to compare AFNI's atlas
#                      with FSL's atlas tool.
#
#            Notes:  This program outputs the xyz coords in RAI orientation
#
#================================================================================
#                                START OF MAIN
#================================================================================

case $1 in
      "learn" )
                  Condition="Learnable"
                ;;

    "unlearn" )
                  Condition="Unlearnable"
                ;;
esac

GIFT=/Volumes/Data/WB1/GiftAnalysis
ATLAS=${GIFT}/Atlas_analysis
EXPERT=${ATLAS}/${Condition}_Expert
MANUAL=${EXPERT}/Clusters_manual
SubICA=${GIFT}/${Condition}/${Condition}_ss_analysis

clusters=(`basename $(ls ${MANUAL}/*_manual_*.nii.gz)`)

echo > ${SubICA}/afni_ROI_report.txt

for (( i = 0; i < ${#clusters[*]}; i++ )); do

    echo "==================== Processing file: $i ==============="
    echo $MANUAL

    compfile=`echo ${clusters[i]} \
            | python -c \
                "import sys; \
                print '\t'.join(sys.stdin.readline().split('_')[6:9])"`

    #------------------------------------------------------------------------
    echo -e "\n Clusterize\n"
    clustStats=`3dclust 2 1 ${clusters[i]} | tail +12`


    #------------------------------------------------------------------------
    echo -e "\n Get XYZ\n"
    xyz=`echo ${clustStats} \
        | python -c \
            "import sys; \
            print ' '.join(sys.stdin.readline().split()[13:])"`


    #------------------------------------------------------------------------
    echo -e "\n Where Am I?\n"
    atlas=`whereami ${xyz} -atlas CA_ML_18_MNIA -rai | egrep -C1 '^Atlas CA_ML_18_MNIA:'`


    #------------------------------------------------------------------------
    echo -e "\n Region of Interest\n"
    roi=`echo ${atlas} \
        | python -c \
            "import sys; \
            line = sys.stdin.readline().split(':')[-1].strip().split(); \
            print ''.join(line[0])+'\t'+' '.join(line[1:])"`


    #------------------------------------------------------------------------
    echo -e "\n Trim XYZ\n"
    xyzClean=`echo ${xyz} \
        | python -c \
            "import sys; \
            line = sys.stdin.readline(); \
            print '\t'.join(line.replace('.0','')[0:20].split())"`


    #------------------------------------------------------------------------
    echo -e "${clusters[i]}\t${compfile}\t${xyzClean}\t${roi}" >> ${SubICA}/afni_ROI_report.txt


done

exit


compfile=`echo ${clusters[16]} | python -c "import sys; print ' '.join(sys.stdin.readline().split('_')[9:12])"`
clustStats=`3dclust 2 274 c1_cm_c1_cm_c56_cm_learn_IC39_s3_p_gm_l_t_thr_t_manual_t.nii.gz | tail +12`
xyz=`echo ${clustStats} | python -c "import sys; print ' '.join(sys.stdin.readline().split()[13:])"`
atlas=`whereami ${xyz} -atlas CA_ML_18_MNIA -rai | egrep -C1 '^Atlas CA_ML_18_MNIA:'`
roi=`echo ${atlas} | python -c "import sys; line = sys.stdin.readline().split(); print ''.join(line[7])+'\t'+' '.join(line[8:])"`
xyzClean=`echo $xyz | python -c "import sys; line = sys.stdin.readline(); print line.replace('.0','')[0:20]"`
#out=`echo "$compfile $xyz $roi" | python -c "import sys; line = sys.stdin.readline(); lineList = line.replace('.0','').split(); out = '\t'.join(lineList[:-1]) + ' ' + lineList[-1]; print out"`


echo $compfile
echo $clustStats
echo $xyz
echo $atlas
echo $roi
echo $out