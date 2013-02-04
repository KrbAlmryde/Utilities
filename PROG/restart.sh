. $PROFILE/${1}_profile.sh
####################################################################################################
echo "------------------------------- restart.sh --------------------------------"
echo "-------------------------------- ${2} ------------------------------"
####################################################################################################
# Usage call restart <experiment_tag> <block_option>
#Be very careful with this option, it will restart everything!
####################################################################################################
if [ "${2}" = "preprocess" ]; then
	################################################################################################
	# Move the unpacked pfiles and efiles to their respective directories
	cd ${orig_dir}
		mv ${run}.* ${prep_dir}
	cd ${orig_dir}
		mv ??.* ${prep_dir}
		mv ???.* ${prep_dir}
	################################################################################################
	# Remove functional .nii files
	cd ${prep_dir}/etc
		rm ${subrun}.dfile.1D
		rm ${subrun}.outliers.txt
		rm ${subrun}.tcat_outs.txt
		rm ${subrun}.tshift_outs.txt
		rm ${subrun}.despike_outs.txt
		rm ${subrun}.volreg_outs.txt
		rm ${subrun}.scale.txt
		rm ${subrun}.outliers.jpg
		rm ${subrun}.tcat_outs.jpg
		rm ${subrun}.tshift_outs.jpg
		rm ${subrun}.despike_outs.jpg
		rm ${subrun}.outs.jpg
		rm ${subrun}.scale.jpg
		rm ${subrun}.volreg.jpg
		rm ${subrun}.volreg_outs.jpg
		rm log.${subrun}.register.txt
		rm log.${subrun}.reconstruct.txt
		rm log.${subrun}.restart.txt
		rm motion.${subrun}_CENSORTR.txt
		rm motion.${subrun}_censor.1D
		rm motion.${subrun}_enorm.1D
	################################################################################################
	# Remove .txt, .1D, and .jpg files
	cd ${prep_dir}
		rm *.epan*
		rm ${subrun}.outs*
		rm ${subrun}.tcat*
		rm ${subrun}.despike*
		rm ${subrun}.spikes*
		rm ${subrun}.tshift*
		rm ${subrun}.volreg*
		rm ${subrun}.blur.nii*
		rm ${subrun}.automask.nii*
		rm ${subrun}.mean.nii*
		rm ${subrun}.scale.nii*
###################################################################################################
elif [ "${2}" = "glm" ]; then
	################################################################################################
	cd ${glm_dir}
		rm log.*
		rm ideal.*
		rm *.FWHMx.txt
		rm *.detrend.1D
		rm 3dDeconvolve.err
		rm ${subj}.REML_cmd
		rm log.${subrun}.deconvolve.txt
	################################################################################################
	cd ${glm_dir}/etc
		rm ${submod}.RegressofInterest.jpg
		rm ${submod}.Regressors-All.jpg
		rm ${submod}.xmat.jpg
		rm ${subrun}.automask.nii
		rm ${subrun}.dfile.1D
		rm ${subrun}.scale.nii*
		rm ${run}.FWHMx.txt
		rm motion.${subrun}_censor.1D
################################################################################################
	cd ${glm_dir}/FUNC
		rm ${submod}.errts*
		rm ${submod}.fitts*
		rm ${submod}.stats*
		rm ${submod}.Full*
		rm ${subrun}.scale.nii*
	################################################################################################
	cd ${glm_dir}/IRESP
		rm ${subcond1}.irf*
		rm ${subcond1}.sirf*
		rm ${subcond2}.irf*
		rm ${subcond2}.sirf*
		rm ${subcond3}.irf*
		rm ${subcond3}.sirf*
		rm ${subcond4}.irf*
		rm ${subcond4}.sirf*
		rm ${subrun}.scale.nii*
	################################################################################################
	cd ${glm_dir}/MODEL
		rm ${submod}.xmat.1D
		rm ideal.${subcond1}.1D
		rm ideal.${subcond2}.1D
		rm ideal.${subcond3}.1D
		rm ideal.${subcond4}.1D
	################################################################################################
	cd ${glm_dir}/REML
		rm *REML*
		rm ${submod}.errts.REML*
		rm ${submod}.fitts.REML*
		rm ${submod}.stats.REML*
		rm ${submod}.stats.REMLvar*
		rm ${subrun}.scale.nii*
		rm ${subcond1}.Fstat+tlrc.*
		rm ${subcond2}.Fstat+tlrc.*
		rm ${subcond3}.Fstat+tlrc.*
		rm ${subcond4}.Fstat+tlrc.*
	################################################################################################
	cd ${prep_dir}
		cp ${subrun}.scale.nii.gz ${glm_dir}
		cp ${subrun}.automask.nii ${glm_dir}
		cp etc/${subrun}.dfile.1D ${glm_dir}
		cp etc/motion.${subrun}_censor.1D ${glm_dir}
####################################################################################################
elif [ "${2}" = "GLM" ]; then
	################################################################################################
	cd ${GLM_dir}/FUNC
		rm ${subcond1}.FUNC+tlrc.*
		rm ${subcond2}.FUNC+tlrc.*
		rm ${subcond3}.FUNC+tlrc.*
		rm ${subcond4}.FUNC+tlrc.*
	################################################################################################
	cd ${GLM_dir}/FUNC/Fstat
		rm ${subcond1}.Fstat+tlrc.*
		rm ${subcond2}.Fstat+tlrc.*
		rm ${subcond3}.Fstat+tlrc.*
		rm ${subcond4}.Fstat+tlrc.*
	################################################################################################
	cd ${GLM_dir}/REML
		rm ${subcond1}.REML+tlrc.*
		rm ${subcond2}.REML+tlrc.*
		rm ${subcond3}.REML+tlrc.*
		rm ${subcond4}.REML+tlrc.*
	################################################################################################
	cd ${GLM_dir}/IRESP/${run}
		rm ${subcond1}.peak*+tlrc.*
		rm ${subcond2}.peak*+tlrc.*
		rm ${subcond3}.peak*+tlrc.*
		rm ${subcond4}.peak*+tlrc.*
####################################################################################################
# This section is for individual scripts that need to be restarted as opposed to whole processing
# blocks.
####################################################################################################
elif [ "${2}" = "reconstruct" ]; then
	# Remove all output from "reconstruct
	cd ${orig_dir}
		mv ${run}.* ${prep_dir}
		mv e[0-9][0-9][0-9][0-9]s[2789]i* ${anat_dir}
	################################################################################################
	cd ${anat_dir}
		#rm *fse*
		#rm *spgr_*
	################################################################################################
	cd ${prep_dir}
		rm ${subrun}.epan*
		rm ${subrun}.outs*
	################################################################################################
	cd ${prep_dir}/etc
		rm ${subrun}.outliers.txt
		rm ${subrun}.outliers.jpg
		rm log.${subrun}.reconstruct.txt
####################################################################################################
elif [ "${2}" = "register" ]; then
	# Remove output from register.sh
	cd ${prep_dir}
		rm ${subrun}.tcat*
		rm ${subrun}.despike*
		rm ${subrun}.spikes*
		rm ${subrun}.tshift*
		rm ${subrun}.volreg*
		rm ${subrun}.blur.nii*
		rm ${subrun}.automask.nii*
		rm ${subrun}.mean.nii*
		rm ${subrun}.scale*
		rm ${subrun}.outs*
		rm *motion.${subrun}*
		rm log.${subrun}.register.txt
		rm log.${subrun}.reconstruct.txt
		rm log.${subrun}.restart.txt
	cd ${prep_dir}/etc
		rm ${subrun}.dfile.1D
		rm ${subrun}.outliers.txt
		rm ${subrun}.tcat_outs.txt
		rm ${subrun}.tshift_outs.txt
		rm ${subrun}.despike_outs.txt
		rm ${subrun}.volreg_outs.txt
		rm ${subrun}.scale.txt
		rm ${subrun}.outliers.jpg
		rm ${subrun}.tcat_outs.jpg
		rm ${subrun}.tshift_outs.jpg
		rm ${subrun}.despike_outs.jpg
		rm ${subrun}.outs.jpg
		rm ${subrun}.scale.jpg
		rm ${subrun}.volreg.jpg
		rm ${subrun}.volreg_outs.jpg
		rm motion.${subrun}_CENSORTR.txt
		rm motion.${subrun}_censor.1D
		rm motion.${subrun}_enorm.1D
####################################################################################################
# This section is for Group related block restarts
####################################################################################################
elif [ "${2}" = "analysis" ]; then
	# Remove output from register.sh
	cd ${ANOVA_dir}
		rm ${runmean}.${cond1}+tlrc*
		rm ${runmean}.${cond2}.+tlrc*
		rm ${runcontr}.${cond1v2}.+tlrc*
		rm ${runcontr}.${cond2v1}.+tlrc*
		rm ${runmean}.${cond1}.${plvl}.nii
		rm ${runmean}.${cond2}.${plvl}.nii
		rm ${runcontr}.${cond1v2}.${plvl}.nii
		rm ${runcontr}.${cond2v1}.${plvl}.nii
		rm log.ANOVA.${runmod}.txt
		rm log.Threshold.${runmod}.txt
	cd ${ANOVA_dir}/etc/Orig
		rm ${runmean}.${cond1}+tlrc*
		rm ${runmean}.${cond2}.+tlrc*
		rm ${runcontr}.${cond1v2}.+tlrc*
		rm ${runcontr}.${cond2v1}.+tlrc*
	cd ${ANOVA_dir}/etc/Clean
		rm ${runmean}.${cond1}.*.nii
		rm ${runmean}.${cond2}.*.nii
		rm ${runmean}.${cond1}.clean.nii
		rm ${runmean}.${cond2}.clean.nii
		rm ${runcontr}.${cond1v2}.*.nii
		rm ${runcontr}.${cond2v1}.*.nii
		rm ${runcontr}.${cond1v2}.clean.nii
		rm ${runcontr}.${cond2v1}.clean.nii
	cd ${ANOVA_dir}/etc/Threshold
		rm ${plvl}.${runmean}.${cond1}.?.nii
		rm ${plvl}.${runmean}.${cond2}.?.nii
		rm ${plvl}.${runcontr}.${cond1v2}.?.nii
		rm ${plvl}.${runcontr}.${cond2v1}.?.nii
	cd ${ANOVA_dir}/etc
		rm ${subcond1}.peak+tlrc* ${ANOVA_dir}
		rm ${subcond2}.peak+tlrc* ${ANOVA_dir}
####################################################################################################
elif [ "${2}" = "anat" ]; then
	# Purge the Anatomical directory
	cd ${anat_dir}
		rm *fse*
		rm *spgr*
		rm log.${subrun}.aligning.txt
	cd ${orig_dir}
		mv e[0-9][0-9][0-9][0-9]s[2789]i* ../Struc
####################################################################################################
elif [ "${2}" = "reg" ]; then
	################################################################################################
	# Remove functional .nii files
		cd ${func_dir}/
		rm -r ${runsub}.reg
		rm ${runsub}.*.nii
		rm ${runsub}*scale*
		rm ${runsub}_*.nii
		rm ${runsub}.*.txt
		rm ${runsub}_*.txt
		rm ${runsub}.*.jpeg
		rm ${runsub}_*.jpeg
		rm ${runsub}.*.jpg
		rm ${runsub}_*.jpg
		rm ${runsub}_*.1D
		rm motion*

fi

