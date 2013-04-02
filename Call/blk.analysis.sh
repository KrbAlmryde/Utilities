####################################################################################################
#
# This is a preprocessing block aimed at running the prep.sh, preprocessing.sh, and deconvolve_tap.sh
# Please see individual scripts for specific instructions regarding their use.
####################################################################################################
# Source the experiment profile
. $PROFILE/${1}_profile
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This is an collection of echos to allow the user to keep track of whats going on from within the
# terminal application

echo "------------------------ blk_analysis_tap.sh -------------------------"
echo ""
####################################################################################################
# It is crucial that each script is sourced and is followed by the ${1} tag
. $PROG/ANOVA.${1}.sh ${1}  2>&1 | tee -a ${TAP}/ANOVA/${mod}/${run}/log.ANOVA.${runmod}.txt
#. $PROG/ANOVA.${1}.sh ${1}  2>&1 | tee -a ${TAP}/ANOVA/${mod}/${run}/log.ANOVA.${runmod}.txt
####################################################################################################

