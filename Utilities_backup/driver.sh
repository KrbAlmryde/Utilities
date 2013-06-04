#!/bin/sh
# tap.run.prog
# Written by Kyle Reese Almryde, 7/12/11
# Thanks to Dianne Patterson for her help and advice
# So the idea behind this script is it will 

# Version 1.0
# --------------------------------------------------------------------------------------------------------------
#

if [ $# -lt 2 ]
then
    echo "Usage: $0 <set_list> <experiment_code>"
    echo "Example: $0 test tap"
    echo "This is a Call script that runs a set of programs specified by the $1 $2 file."
    echo "operations will be performed on each subject for each run"
    exit 1
fi

file= $1
exp= $2

	while subj; do

		for run; do
			
			${UTL}/lst_profile_${exp}.txt
			${UTL}/lst_${file}_${exp}.txt
			
			if	[-f "${func}"/rm.\*]; then
				rm -f ${func}/rm.\*
			fi
			
		done
		
	done


