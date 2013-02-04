. $PROFILE/${1}_profile.sh
cd ${glm_dir}
####################################################################################################
if [ ! -e  ${subrun}.scale.nii.gz -a ! -e ${subrun}.automask.nii -a ! -e ${subrun}.dfile.1D ]; then
	echo "Regression has been completed"
	echo ""
else
####################################################################################################
	echo "------------------------------- Deconvolution.sh -------------------------------"
	echo "------------------------------------ ${hrm} ------------------------------------"
	echo ""
####################################################################################################
# Main Deconvolution block #-censor motion.${subrun}.censor.1D (before GOFORIT)
#
	3dDeconvolve -input ${subrun}.scale.nii.gz -polort A \
	-censor motion.${subrun}_censor.1D -GOFORIT \
	-mask ${subrun}.automask.nii -num_stimts 8 -global_times \
	-stim_times 1 ${STIM}/stim_${run}_${cond1}.1D "$mod" -stim_label 1 ${subcond1} \
	-stim_times 2 ${STIM}/stim_${run}_${cond2}.1D "$mod" -stim_label 2 ${subcond2} \
	-stim_file 3 ${subrun}.dfile.1D'[0]' -stim_base 3 -stim_label 3 roll \
	-stim_file 4 ${subrun}.dfile.1D'[1]' -stim_base 4 -stim_label 4 pitch \
	-stim_file 5 ${subrun}.dfile.1D'[2]' -stim_base 5 -stim_label 5 yaw \
	-stim_file 6 ${subrun}.dfile.1D'[3]' -stim_base 6 -stim_label 6 dS \
	-stim_file 7 ${subrun}.dfile.1D'[4]' -stim_base 7 -stim_label 7 dL \
	-stim_file 8 ${subrun}.dfile.1D'[5]' -stim_base 8 -stim_label 8 dP \
#	-gltsym "SYM: +${subcond1} -${subcond2}" -glt_label 1 ${submod}.${cond1}.vs.${cond2} \
#	-gltsym "SYM: +${subcond2} -${subcond1}" -glt_label 2 ${submod}.${cond2}.vs.${cond1} \
#	-gltsym "SYM: +${subcond1} +${subcond2}" -glt_label 3 ${submod}.glt.FullF \
	-xout -x1D ${submod}.xmat.1D -xjpeg ${submod}.xmat.jpg \
	-fout -tout -TR_times 1 \
	-sresp 1 ${subcond1}.sirf+orig -sresp 2 ${subcond2}.sirf+orig \
	-iresp 1 ${subcond1}.irf+orig -iresp 2 ${subcond2}.irf+orig \
	-errts ${submod}.errts+orig -fitts ${submod}.fitts+orig \
	-bucket ${submod}.stats+orig
####################################################################################################
# Plot Regressors and Regressors of interest
	1dplot -sepscl -jpeg ${submod}.Regressors-All ${submod}.xmat.1D'[12..0]'
	1dplot -jpeg ${submod}.RegressofInterest ${submod}.xmat.1D'[6..5]'
####################################################################################################
# Create ideal files that we can use to estimate our model
	1dcat ${submod}.xmat.1D'[5]' > ideal.${subcond1}.1D
	1dcat ${submod}.xmat.1D'[6]' > ideal.${subcond1}.1D
####################################################################################################
# Run 3dREMLfit command that does...something...
	3dREMLfit -matrix ${submod}.xmat.1D -input ${subrun}.scale.nii.gz -mask \
		${subrun}.automask.nii -fout -tout -Rbuck ${submod}.stats.REML+orig -Rvar \
		${submod}.stats.REMLvar+orig -Rfitts ${submod}.fitts.REML+orig -Rerrts \
		${submod}.errts.REML+orig -verb
####################################################################################################
#Organize directory by placing images, text files, and 1D files to their appropriate space
####################################################################################################
	if [ -e ${subcond1}.irf+orig.HEAD -a ${subcond2}.irf+orig.HEAD ]; then
	# Move extra stuff to the etc directory
		mv ${submod}.RegressofInterest.jpg etc/
		mv ${submod}.Regressors-All.jpg etc/
		mv ${submod}.xmat.jpg etc/
		#mv ${subrun}.automask.nii etc/
		#mv motion.${subrun}_censor.1D etc/
		#mv ${subrun}.dfile.1D etc/
 	################################################################################################
	# Move functional files to the FUNC directory
		mv ${submod}.errts+orig.* FUNC/
		mv ${submod}.fitts+orig.* FUNC/
		mv ${submod}.stats+orig.* FUNC/
	################################################################################################
		mv ${subcond1}.irf+orig.* IRESP/
		mv ${subcond1}.sirf+orig.* IRESP/
		mv ${subcond2}.irf+orig.* IRESP/
		mv ${subcond2}.sirf+orig.* IRESP/
	################################################################################################
		mv ${submod}.xmat.1D MODEL/
		mv ideal.${subcond1}.1D MODEL/
		mv ideal.${subcond2}.1D MODEL/
	################################################################################################
		mv ${submod}.errts.REML+orig.* REML/
		mv ${submod}.fitts.REML+orig.* REML/
		mv ${submod}.stats.REML+orig.* REML/
		mv ${submod}.stats.REMLvar+orig.* REML/
	################################################################################################
		rm ${subj}.REML_cmd
	################################################################################################
	fi
####################################################################################################
fi
