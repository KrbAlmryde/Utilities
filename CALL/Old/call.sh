#!/bin/bash
# SCRIPT: call.bash
#
#
# PURPOSE:
#		The purpose of this script is to act as an operator hub which
#		calls multiple independant processes to be run through a list
#		of subjects, runs, and whatever else you wish in order to
#		manage and manipulate large volumes of data.
#
#################################################################################
#
# set -n	# Uncomment to check command syntax without any execution
# set -x	# Uncomment to debug this script
#
#################################################################################
#
# Sourcing the exp_profile.sh.sh and establishing variables
# Note: It is necessary to specify the experiment code after the exp_profile.sh.sh
#
. ${CALL}/exp_profile.sh ${2}
################################################################################
								########### START OF MAIN ############
#################################################################################
#
echo "----------------------------------- call.sh -----------------------------------"
echo ""
#################################################################################
#
# This is the main block of the script. Through two while loops, we initiate processing block
# containing a list of programs or a which can be executed for every subject and every run. At the
# completion of the block it removes all files with the "rm." tag, which will clean up the
# directories a bit.
#################################################################################
# Imaging-Block specific call loops

if [ "${1}" = "preprocess" ]; then
	while read subj; do
		 while read run; do
			. ${BLK}/blk.${1}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
		done <${RUNS}
	done <${SUBJECTS}

elif [ "${1}" = "GLM" ]; then
	while read subj; do
		 while read run; do
			. ${BLK}/blk.${1}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
		done <${RUNS}
	done <${SUBJECTS}

elif [ "${1}" = "analysis" ]; then
	 while read run; do
			. ${BLK}/blk.${1}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
	done <${RUNS}
#################################################################################
# restart.sh options, the $3 option will specify specifc processing blocks that 
# should be restarted ie the command line might look something like the following
# call restart dich GLM, which would restart only those files created during in 
# the GLM block. Be sure to see the restart.sh script for specific details

elif [ "${1}" = "restart" ]; then
	while read subj; do
		 while read run; do
 		 	while read clust; do
				. ${PROG}/${1}.sh $2 $3	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
			done <${CLUST}
		done <${RUNS}
	done <${SUBJECTS}
	
elif [ "${1}" = "reg" ]; then
	while read subj; do
		 while read run; do
			. ${PROG}/${1}.${2}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
		done <${RUNS}
	done <${SUBJECTS}

################################################################################
# Behavioral specific call loops

elif [ "${2}" = "behav" ]; then
	while read subj; do
		 while read run; do
			while read cond; do
				. ${PROG}/${1}.${2}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
			done <${CONDITIONS}
		done <${RUNS}
	done <${SUBJECTS}
#################################################################################
# General <program>_<study> call loops iterating over subject and run only.

elif [ -f "${1}.sh" ]; then
	while read subj; do
		 while read run; do
			. ${PROG}/${1}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
		done <${RUNS}
	done <${SUBJECTS}

elif [ -f "${1}.${2}.sh" ]; then
	while read subj; do
		while read run; do
			. ${PROG}/${1}.${2}.sh $3	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.${3}.txt
		done <${RUNS}
	done <${SUBJECTS}

elif [ -f "${1}.${2}.sh" ]; then
	while read subj; do
		 while read run; do
			while read cond; do
				. ${PROG}/${1}.${2}.sh $2	 2>&1 | tee -a ${study_dir}/log.${1}.${2}.txt
			done <${CONDITIONS}
		done <${RUNS}
	done <${SUBJECTS}

fi
#################################################################################
echo "Our Motto"
echo "We've suffered so you wont have to!"
echo "Because we put the RE in RESEARCH"
echo "afterall"
echo "Its not Rocket science, its BRAIN science!"
echo ""
exit 0
