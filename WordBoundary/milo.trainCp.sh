# This script copies a selection of fMRI data from the WordBoundary1 dataset
# for uses of training. Only those datasets which have been skull-stripped and
# otherwise de-identified are used. 
#
# 8 subjects have been selected; four from each condition. 
#


# learnable sub013 sub016 sub019 sub021
# unlearnable sub009 sub011 sub012 sub018



BASE="/Volumes/Data/WordBoundary1"
TARGET="${BASE}/MiloTrainData"

for subj in sub{009,011,012,018,013,016,019,021}; do
    for r in {1..3}; do 

        # Directory Variables
        RUN=Run$r
        FUNC=${BASE}/${subj}/Func/${RUN}
        MORPH=${BASE}/${subj}/Morph
        DATA=${TARGET}/${subj}
        DATAF=${DATA}/Func/${RUN}
        DATAM=${DATA}/Morph

        # Identifier variables
        runsub=run${r}_${subj}
        

        mkdir -p ${DATA}/{Func/${RUN},Morph}

        3dcopy ${FUNC}/${runsub}.nii.gz ${DATAF}/${runsub}.nii.gz

    done
    3dcopy ${MORPH}/${subj}_T1_brain.nii.gz ${DATAM}/${subj}_T1_brain.nii.gz
    3dcopy ${MORPH}/${subj}_flair_brain.nii.gz ${DATAM}/${subj}_flair_brain.nii.gz
    3dcopy ${MORPH}/${subj}_struct.nii.gz ${DATAM}/${subj}_struct.nii.gz
done
