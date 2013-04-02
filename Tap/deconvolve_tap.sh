. $PROFILE/${1}_profile
cd ${run_dir}
####################################################################################################
if [ ! -e ${subrunmod}_bucket.nii ]; then
####################################################################################################
	echo "----------------------------------- Deconvolution!! -------------------------------------"
	echo "----------------------------------- ${hrm} -----------------------------------------"
	echo "----------------------------------- ${subcond} ---------------------------------------"
	echo ""
####################################################################################################
# Main Deconvolution block
	3dDeconvolve -input ${subrun}_scale.nii -polort A \
	-censor motion_${subrun}_censor.1D -GOFORIT \
	-mask ${subrun}_automask.nii -num_stimts 8 -global_times \
	-stim_times 1 ${UTL}/stim_${run}_${cond1}.1D "$hrm" -stim_label 1 ${subrun}_${cond1}_${mod}.nii \
	-stim_times 2 ${UTL}/stim_${run}_${cond2}.1D "$hrm" -stim_label 2 ${subrun}_${cond2}_${mod}.nii \
	-stim_file 4 ${subrun}_dfile.1D'[0]' -stim_base 3 -stim_label 3 roll \
	-stim_file 5 ${subrun}_dfile.1D'[1]' -stim_base 4 -stim_label 4 pitch \
	-stim_file 6 ${subrun}_dfile.1D'[2]' -stim_base 5 -stim_label 5 yaw \
	-stim_file 7 ${subrun}_dfile.1D'[3]' -stim_base 6 -stim_label 6 dS \
	-stim_file 8 ${subrun}_dfile.1D'[4]' -stim_base 7 -stim_label 7 dL \
	-stim_file 9 ${subrun}_dfile.1D'[5]' -stim_base 8 -stim_label 8 dP \
	-xout -x1D ${subrunmod}.xmat.1D -xjpeg ${subrunmod}.xmat.jpg \
	-full_first -fout -tout -nobout \
	-iresp 1 ${subrun}_${cond1}_${mod}_irf.nii \
	-iresp 2 ${subrun}_${cond2}_${mod}_irf.nii \
	-TR_times 1.75 -fitts ${subrunmod}_fitts -bucket ${subrunmod}_bucket.nii
####################################################################################################
# This marks the end of the test function that will determine whether this script runs or not.
# It also marks the end of this script. Thanks for playing!
####################################################################################################
	3dToutcount ${submod}_irf.nii > ${submod}_irf_outs.txt
	1dplot -jpeg ${submod}_irf_outs.nii ${submod}_irf_outs.txt
fi

