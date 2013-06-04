#!/bin/sh
3dDeconvolve -input ${func}/${name}_norm.nii -polort A \
	-mask ${func}/${name}_automask.nii -num_stimts 9 -local_times \
	-stim_times 1 tap.${run}_${stim}.stim 'GAM' -stim_label 1 ${func}/${name}_${stim}.nii  	\
	-stim_times 2 tap.${run}_${stim}.stim 'GAM' -stim_label 2 ${func}/${name}_${stim}.nii \
	-stim_times 3 tap.${run}_${stim}.stim 'GAM' -stim_label 3 ${func}/${name}_${stim}.nii \
	-stim_file 4 ${func}/${subj}_dfile_${run}.txt'[0]' -stim_base 4 -stim_label 4 roll   \
	-stim_file 5 ${func}/${subj}_dfile_${run}.txt'[1]' -stim_base 5 -stim_label 5 pitch \
	-stim_file 6 ${func}/${subj}_dfile_${run}.txt'[2]' -stim_base 6 -stim_label 6 yaw \
	-stim_file 7 ${func}/${subj}_dfile_${run}.txt'[3]' -stim_base 7 -stim_label 7 dS \
	-stim_file 8 ${func}/${subj}_dfile_${run}.txt'[4]' -stim_base 8 -stim_label 8 dL \
	-stim_file 9 ${func}/${subj}_dfile_${run}.txt'[5]' -stim_base 9 -stim_label 9 dP \
	-iresp 1 ${func}/${name}_${stim}_irf.nii -iresp 2 ${func}/${name}_${stim}_irf.nii -iresp 3 ${func}/${name}_${stim}_irf.nii \
	-bucket ${func}/${name}_bucket.nii