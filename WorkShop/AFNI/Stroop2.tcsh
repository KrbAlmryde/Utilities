#!/usr/bin/env tcsh
#This script was written by Kyle Almryde, University of Arizona, 6/19/2011
# execute via : tcsh -x S#-run-script |& tee output.S#-run-script
# --------------------------------------------------
# Script setup

echo "${STROOP}"
	set subj = S46
	set base = 78
	set stim = ${STROOP}/Utilities
	set anat = ${STROOP}/${subj}/Struct/spgr
		foreach run (voice word)
			set func = ${STROOP}/${subj}/run_${run}
				set results = ${STROOP}/${subj}_BV_Test/${run}

echo "Slice time correction"
	3dTcat -prefix ${subj}_${run}_sliceTimeCorrection $func/${subj}_${run}_epan+orig'[4..$]'

echo "Motion Correction"
	3dvolreg -verbose -zpad 1 -base ${subj}_${run}_sliceTimeCorrection+orig"[${base}]"  \
             -1Dfile motioncorrention_${subj}_${run}.1D -prefix ${subj}_${run}_motioncorrention  \
             -cubic ${subj}_${run}_sliceTimeCorrection+orig

echo "Spatial Smoothing"
	3dmerge -1blur_fwhm 6.0 -doall -prefix ${subj}_${run}_SpatialSmoothing ${subj}_${run}_motioncorrention+orig

echo "High-Pass filtering"
	3dAutomask -prefix ${subj}_${run}_automask2 ${subj}_${run}_SpatialSmoothing+orig
	3dTstat -prefix ${subj}_${run}_HighPass ${subj}_${run}_SpatialSmoothing+orig
	3dcalc -a ${subj}_${run}_SpatialSmoothing+orig -b ${subj}_${run}_HighPass+orig  \
		-c ${subj}_${run}_automask2+orig -expr 'c * min(200, a/b*100)' -prefix ${subj}_${run}_HighPassfiltering
	3dDeconvolve -input ${subj}_${run}_HighPassfiltering+orig   \
		-polort 5                                        \
		-mask ${subj}_${run}_automask2+orig -num_stimts 10	\
		-local_times \
		-stim_times 1 $stim/${run}_congruent.txt 'GAM' -stim_label 1 ${subj}_${run}_congruent  	\
		-stim_times 2 $stim/${run}_incongruent.txt 'GAM' -stim_label 2 ${subj}_${run}_incongruent \
		-stim_times 3 $stim/${run}_neutral.txt 'GAM' -stim_label 3 ${subj}_${run}_neutral      \
		-stim_times 4 $stim/${run}_null.txt 'GAM' -stim_label 4 ${subj}_${run}_null      \
		-stim_file 5 motioncorrention_${subj}_${run}.1D'[0]' -stim_base 5 -stim_label 5 roll    \
		-stim_file 6 motioncorrention_${subj}_${run}.1D'[1]' -stim_base 6 -stim_label 6 pitch   \
		-stim_file 7 motioncorrention_${subj}_${run}.1D'[2]' -stim_base 7 -stim_label 7 yaw  \
		-stim_file 8 motioncorrention_${subj}_${run}.1D'[3]' -stim_base 8 -stim_label 8 dS   \
		-stim_file 9 motioncorrention_${subj}_${run}.1D'[4]' -stim_base 9 -stim_label 9 dL   \
		-stim_file 10 motioncorrention_${subj}_${run}.1D'[5]' -stim_base 10 -stim_label 10 dP   \
		-iresp 1 ${subj}_${run}_congruent_irf_BV \
		-iresp 2 ${subj}_${run}_incongruent_irf_BV \
		-iresp 3 ${subj}_${run}_neutral_irf_BV \
		-iresp 4 ${subj}_${run}_null_irf_BV \
		-tout -x1D ${run}_X_matrix.1D -xjpeg ${run}_X_matrix.jpg                            \
		-bucket ${subj}_${run}_bucket_BV
	foreach cond (congruent incongruent neutral null)
		3dbucket -prefix ${subj}_${run}_${cond}_peak_irf_BV -fbuc ${subj}_${run}_${cond}_irf_BV+orig'[3]'
		end

	end
