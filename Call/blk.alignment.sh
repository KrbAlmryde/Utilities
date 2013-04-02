####################################################################################################
# This is the alignment block aimed at running aligning.sh and adwarp.sh. It is crucial that a
# visual inspection be performed after this block has been performed before any further analysis
# is performed. In addition see individual scripts for specific instructions regarding their use.
####################################################################################################
# Source the experiment profile
. $PROFILE/${1}_profile
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# It is crucial that each script is sourced and is followed by the ${1} tag
. $PROG/aligning.sh ${1}  2>&1 | tee -a ${anat_dir}/log.${subj}.aligning.txt
. $PROG/adwarp.sh ${1}  2>&1 | tee -a ${glm_dir}/log.${subrun}.adwarp.txt
####################################################################################################
