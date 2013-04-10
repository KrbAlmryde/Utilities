. $PROFILE/${1}_profile.sh
cd ${test_dir}
####################################################################################################
	echo "----------------------------------- Deconvolution_test! -------------------------------------"
	echo "----------------------------------- ${subj} -----------------------------------------"
	echo ""
####################################################################################################
# Main Deconvolution block #-censor motion.${subrun}.censor.1D (before GOFORIT)

# 	3dDeconvolve -input ${subrun}.scale.vr+orig -polort A -GOFORIT \
# 	-mask ${subrun}.vr.automask.nii -num_stimts 8 -global_times \
# 	-stim_times 1 ${STIM}/stim_${run}_${cond1}.1D "GAM" -stim_label 1 ${subcond1} \
# 	-stim_times 2 ${STIM}/stim_${run}_${cond2}.1D "GAM" -stim_label 2 ${subcond2} \
# 	-stim_file 3 ${subrun}.dfile.1D'[0]' -stim_base 3 -stim_label 3 roll \
# 	-stim_file 4 ${subrun}.dfile.1D'[1]' -stim_base 4 -stim_label 4 pitch \
# 	-stim_file 5 ${subrun}.dfile.1D'[2]' -stim_base 5 -stim_label 5 yaw \
# 	-stim_file 6 ${subrun}.dfile.1D'[3]' -stim_base 6 -stim_label 6 dS \
# 	-stim_file 7 ${subrun}.dfile.1D'[4]' -stim_base 7 -stim_label 7 dL \
# 	-stim_file 8 ${subrun}.dfile.1D'[5]' -stim_base 8 -stim_label 8 dP \
# 	-xout -x1D ${submod}.xmat.1D -xjpeg ${submod}.xmat.jpg \
# 	-fout -tout -TR_times 1 \
# 	-iresp 1 ${subcond1}.irf -iresp 2 ${subcond2}.irf \
# 	-errts ${submod}.errts -fitts ${submod}.fitts \
# 	-bucket ${submod}.stats
####################################################################################################
# Plot Regressors and Regressors of interest
#	1dplot -sepscl -jpeg ${submod}.Regressors-All ${submod}.xmat.1D'[12..0]'
#	1dplot -jpeg ${submod}.RegressofInterest ${submod}.xmat.1D'[6..5]'
####################################################################################################
# Create ideal files that we can use to estimate our model
#	1dcat ${submod}.xmat.1D'[5]' > ideal.${subcond1}.1D
#	1dcat ${submod}.xmat.1D'[6]' > ideal.${subcond1}.1D
####################################################################################################
#	adwarp -apar ${spgr}_al+tlrc -dpar ${submod}.stats+orig
#	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond1}.irf+orig
#	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond2}.irf+orig

	cp ${submod}.stats+* $TAP/TEST
	cp ${subcond1}.irf+* $TAP/TEST
	cp ${subcond2}.irf+* $TAP/TEST
