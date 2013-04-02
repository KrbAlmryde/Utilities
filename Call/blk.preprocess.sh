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
. $PROG/reconstruct.sh ${1}  2>&1 | tee -a ${prep_dir}/log.${subrun}.reconstruct.txt
. $PROG/register.sh ${1}  2>&1 | tee -a ${prep_dir}/log.${subrun}.register.txt
####################################################################################################
