####################################################################################################
# This is a preprocessing block aimed at running the prep.sh, preprocessing.sh, deconvolve_tap.sh
# and adwarp.sh. Please see individual scripts for specific instructions regarding their use.
####################################################################################################
# Source the experiment profile
. $PROFILE/${1}_profile
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# It is crucial that each script is sourced and is followed by the ${1} tag
#. $PROG/deconvolve.sh ${1}  2>&1 | tee -a ${glm_dir}/log.${subrun}.deconvolve.txt
. $PROG/aligning.sh ${1}  2>&1 | tee -a ${anat_dir}/log.${subj}.aligning.txt
. $PROG/bucket.sh ${1}  2>&1 | tee -a ${glm_dir}/log.${subrun}.bucket.txt
####################################################################################################
