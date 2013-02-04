. $PROFILE/${1}_profile.sh
cd ${glm_dir}
#################################################################################################
if [ ! -e  ${subrun}.scale.nii.gz -a ! -e ${subrun}.automask.nii -a ! -e ${subrun}.dfile.1D ]; then
	echo "Regression has been completed"
	echo ""
else
#---------------------------------------------------------------------------------------------------
	echo "------------------------------- Deconvolution.sh -------------------------------"
	echo "------------------------------------ ${subrun} ${mod} ------------------------------------"
	echo ""
#---------------------------------------------------------------------------------------------------
# Main Deconvolution block #-censor motion.${subrun}.censor.1D (before GOFORIT)

	if [ "${run}" = "SP1" ]; then
		3dDeconvolve -input ${subrun}.scale.nii.gz -polort A \
		-censor motion.${subrun}_censor.1D -GOFORIT \
		-mask ${subrun}.automask.nii -num_stimts 8 -local_times \
		-stim_times 1 ${STIM}/stim.${subrun}.${cond1}.1D "$mod" -stim_label 1 ${subcond1} \
		-stim_times 2 ${STIM}/stim.${subrun}.${cond2}.1D "$mod" -stim_label 2 ${subcond2} \
		-stim_file 3 ${subrun}.dfile.1D'[0]' -stim_base 3 -stim_label 3 roll \
		-stim_file 4 ${subrun}.dfile.1D'[1]' -stim_base 4 -stim_label 4 pitch \
		-stim_file 5 ${subrun}.dfile.1D'[2]' -stim_base 5 -stim_label 5 yaw \
		-stim_file 6 ${subrun}.dfile.1D'[3]' -stim_base 6 -stim_label 6 dS \
		-stim_file 7 ${subrun}.dfile.1D'[4]' -stim_base 7 -stim_label 7 dL \
		-stim_file 8 ${subrun}.dfile.1D'[5]' -stim_base 8 -stim_label 8 dP \
		-xout -x1D ${submod}.xmat.1D -xjpeg ${submod}.xmat.jpg \
		-fout -tout -TR_times 1 \
		-sresp 1 ${subcond1}.sirf+orig -sresp 2 ${subcond2}.sirf+orig \
		-iresp 1 ${subcond1}.irf+orig -iresp 2 ${subcond2}.irf+orig \
		-errts ${submod}.errts+orig -fitts ${submod}.fitts+orig \
		-bucket ${submod}.stats+orig
	fi
	if [ "${run}" = "SP2" -o "${run}" = "TP1" -o "${run}" = "TP2" ]; then
		3dDeconvolve -input ${subrun}.scale.nii.gz -polort A \
		-censor motion.${subrun}_censor.1D -GOFORIT \
		-mask ${subrun}.automask.nii -num_stimts 10 -local_times \
		-stim_times 1 ${STIM}/stim.${subrun}.${cond1}.1D "$mod" -stim_label 1 ${subcond1} \
		-stim_times 2 ${STIM}/stim.${subrun}.${cond2}.1D "$mod" -stim_label 2 ${subcond2} \
		-stim_times 3 ${STIM}/stim.${subrun}.${cond3}.1D "$mod" -stim_label 3 ${subcond3} \
		-stim_times 4 ${STIM}/stim.${subrun}.${cond4}.1D "$mod" -stim_label 4 ${subcond4} \
		-stim_file 5 ${subrun}.dfile.1D'[0]' -stim_base 5 -stim_label 5 roll \
		-stim_file 6 ${subrun}.dfile.1D'[1]' -stim_base 6 -stim_label 6 pitch \
		-stim_file 7 ${subrun}.dfile.1D'[2]' -stim_base 7 -stim_label 7 yaw \
		-stim_file 8 ${subrun}.dfile.1D'[3]' -stim_base 8 -stim_label 8 dS \
		-stim_file 9 ${subrun}.dfile.1D'[4]' -stim_base 9 -stim_label 9 dL \
		-stim_file 10 ${subrun}.dfile.1D'[5]' -stim_base 10 -stim_label 10 dP \
		-xout -x1D ${submod}.xmat.1D -xjpeg ${submod}.xmat.jpg \
		-fout -tout -TR_times 1 \
		-sresp 1 ${subcond1}.sirf+orig -sresp 2 ${subcond2}.sirf+orig \
		-iresp 1 ${subcond1}.irf+orig -iresp 2 ${subcond2}.irf+orig \
		-sresp 3 ${subcond3}.sirf+orig -sresp 4 ${subcond4}.sirf+orig \
		-iresp 3 ${subcond3}.irf+orig -iresp 4 ${subcond4}.irf+orig \
		-errts ${submod}.errts+orig -fitts ${submod}.fitts+orig \
		-bucket ${submod}.stats+orig
	fi
#################################################################################################
# Plot Regressors and Regressors of interest
#	1dplot -sepscl -jpeg ${submod}.Regressors-All ${submod}.xmat.1D'[14..0]'
#	1dplot -jpeg ${submod}.RegressofInterest ${submod}.xmat.1D'[8..5]'
#---------------------------------------------------------------------------------------------------
# Create ideal files that we can use to estimate our model
#	1dcat ${submod}.xmat.1D'[5]' > ideal.${subcond1}.1D
#	1dcat ${submod}.xmat.1D'[6]' > ideal.${subcond2}.1D
#	1dcat ${submod}.xmat.1D'[7]' > ideal.${subcond3}.1D
#	1dcat ${submod}.xmat.1D'[8]' > ideal.${subcond4}.1D
#---------------------------------------------------------------------------------------------------
# Run 3dREMLfit command that does...something...
	3dREMLfit -matrix ${submod}.xmat.1D \
		-input ${subrun}.scale.nii.gz \
		-mask ${subrun}.automask.nii \
		-fout -tout\
		-Rbuck ${submod}.stats.REML+orig \
		-Rvar ${submod}.stats.REMLvar+orig \
		-Rfitts ${submod}.fitts.REML+orig \
		-Rerrts ${submod}.errts.REML+orig -verb
		
#---------------------------------------------------------------------------------------------------
# Run 3dFWHMx to determine the required smoothing for cluster analysis.
# Place the results into a text file living in the GLM_dir that can be later referenced
	3dFWHMx -dset ${submod}.errts+orig \
		-automask -combine -detrend \
		-out ${submod}.errts.detrend.1D \
		-detprefix ${submod}.errts.detrend+orig \
		2>&1 | tee -a ${subrun}.FWHMx.txt
		
	echo "${subrun} = `tail -c 8 ${subrun}.FWHMx.txt`" >> \
		etc/${run}.FWHMx.txt

#---------------------------------------------------------------------------------------------------
#Organize directory by placing images, text files, and 1D files to their appropriate space
#---------------------------------------------------------------------------------------------------
	if [ -e ${subcond1}.irf+orig.HEAD -a ${subcond2}.irf+orig.HEAD ]; then
	# Move extra stuff to the etc directory
		mv ${submod}.RegressofInterest.jpg etc/
		mv ${submod}.Regressors-All.jpg etc/
		mv ${submod}.xmat.jpg etc/
		mv ${subrun}.automask.nii etc/
		mv ${subrun}.dfile.1D etc/
		mv motion.${subrun}_censor.1D etc/
 	#---------------------------------------------------------------------------------------------------
	# Move functional files to the FUNC directory
		mv ${submod}.errts*+orig.* FUNC/
		mv ${submod}.fitts+orig.* FUNC/
		mv ${submod}.stats+orig.* FUNC/
	#---------------------------------------------------------------------------------------------------
	# Move the Impulse Response Function data files to the IRESP directory
		mv ${subcond1}.irf+orig.* IRESP/
		mv ${subcond1}.sirf+orig.* IRESP/
		mv ${subcond2}.irf+orig.* IRESP/
		mv ${subcond2}.sirf+orig.* IRESP/
		mv ${subcond3}.irf+orig.* IRESP/
		mv ${subcond3}.sirf+orig.* IRESP/
		mv ${subcond4}.irf+orig.* IRESP/
		mv ${subcond4}.sirf+orig.* IRESP/
	#---------------------------------------------------------------------------------------------------
		mv ${submod}.xmat.1D MODEL/
		mv ideal.${subcond1}.1D MODEL/
		mv ideal.${subcond2}.1D MODEL/
	#---------------------------------------------------------------------------------------------------
		mv ${submod}.errts.REML+orig.* REML/
		mv ${submod}.fitts.REML+orig.* REML/
		mv ${submod}.stats.REML+orig.* REML/
		mv ${submod}.stats.REMLvar+orig.* REML/
	#---------------------------------------------------------------------------------------------------
		rm ${subj}.REML_cmd
	#---------------------------------------------------------------------------------------------------
	fi
#---------------------------------------------------------------------------------------------------
fi
