#!/bin/sh
function driver() {
	echo "The driver.sh has been initiated"
	while echo $SUBJECT > subj; do
		for run in `cat $UTL/lst_run_${exp}.txt`; do
			echo "======= $subj $run ========"
			${UTL}/lst_${1}_${exp}.txt
			echo "clean up rm.* files"

		if	[ -f ${func}/rm.\* ]
		then
			rm -f ${func}/rm.\*
		fi

		done
	done
}