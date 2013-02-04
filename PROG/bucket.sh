. $PROFILE/${1}_profile.sh
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This script uses the AFNI program 3dbucket to extract subbricks 1-9 from the IRF files generated
# by 3dDeconvolve. In addtion it extracts the Full_Fstat, Coef, Tstat, and Fstat subbriks from the
# Deconvolve bucket file for each condition. The Full_Fstat resides at index 0. The Coef(iccient)
# resides at indices 1, 4, and 7. The Tstat resides at indicies 2, 5, and 8. The Fstat resides at
# indicies 3, 6, and 9
####################################################################################################
	echo "----------------------------------- bucket.sh -------------------------------------"
	echo "------------------------------- ${submod} ----------------------------------"
	echo ""
####################################################################################################
cd ${glm_dir}/FUNC
####################################################################################################
# extracting subrick index from the bucket files
if [ ! -e ${subcond2}.FUNC+tlrc.HEAD -o ! -e ${subcond2}.FUNC+tlrc.HEAD \
	-o ! -e ${subcond2}.Fstat+tlrc.HEAD -o ! -e ${submod}.Full_Fstat+tlrc.HEAD ]; then

	#Extracting the Coefficient and T-statistic
	3dbucket -prefix ${subcond1}.FUNC -fbuc ${submod}.stats+tlrc'[1,2]'
	3dbucket -prefix ${subcond2}.FUNC -fbuc ${submod}.stats+tlrc'[4,5]'
	3dbucket -prefix GLT.${subcond1}.VS.${cond2}.FUNC -fbuc ${submod}.stats+tlrc'[7,8]'
	3dbucket -prefix GLT.${subcond2}.VS.${cond1}.FUNC -fbuc ${submod}.stats+tlrc'[10,11]'

	#Extracting the partial Fstat
	3dbucket -prefix ${subcond1}.Fstat -fbuc ${submod}.stats+tlrc'[3]'
	3dbucket -prefix ${subcond2}.Fstat -fbuc ${submod}.stats+tlrc'[6]'
	3dbucket -prefix GLT.${subcond1}.VS.${cond2}.Fstat -fbuc ${submod}.stats+tlrc'[9]'
	3dbucket -prefix GLT.${subcond2}.VS.${cond1}.Fstat -fbuc ${submod}.stats+tlrc'[12]'

	#Extracting the Full Fstat
	3dbucket -prefix ${submod}.Full_Fstat -fbuc ${submod}.stats+tlrc'[0]'

fi
####################################################################################################
# Move the results to their respective GLM directory
	mv ${subcond1}.FUNC+tlrc.* ${GLM_dir}/FUNC/${mod}/${run}
	mv ${subcond2}.FUNC+tlrc.* ${GLM_dir}/FUNC/${mod}/${run}
	################################################################################################
	mv ${subcond1}.Fstat+tlrc.* ${GLM_dir}/FUNC/Fstat/${mod}/${run}
	mv ${subcond2}.Fstat+tlrc.* ${GLM_dir}/FUNC/Fstat/${mod}/${run}
	################################################################################################
	mv GLT.${subcond1}.VS.${cond2}.FUNC+tlrc.* ${GLM_dir}/GLT/${mod}/${run}
	mv GLT.${subcond2}.VS.${cond1}.FUNC+tlrc.* ${GLM_dir}/GLT/${mod}/${run}
	mv GLT.${subcond1}.VS.${cond2}.Fstat+tlrc.* ${GLM_dir}/GLT/Fstat
	mv GLT.${subcond2}.VS.${cond1}.Fstat+tlrc.* ${GLM_dir}/GLT/Fstat
####################################################################################################
cd ${glm_dir}/IRESP
####################################################################################################
# extracting peak subrick indices 5 and 6 of GAM and WAV impulse response function respectively.
if [ ! -e ${submod}.peak+tlrc.HEAD ]; then

	if [ "$mod" = GAM ] ;then
		echo "${submod}.peak+tlrc"
		3dbucket -prefix ${subcond1}.peak -fbuc ${subcond1}.irf+tlrc'[5]'
		3dbucket -prefix ${subcond2}.peak -fbuc ${subcond2}.irf+tlrc'[5]'

	elif [ "$mod" = WAV ] ;then
		echo "${submod}.peak+tlrc"
		3dbucket -prefix ${subcond1}.peak -fbuc ${subcond1}.irf+tlrc'[6]'
		3dbucket -prefix ${subcond2}.peak -fbuc ${subcond2}.irf+tlrc'[6]'
	fi
fi
####################################################################################################
# Move the results to their respective GLM directory
	cp ${subcond1}.peak+tlrc.* ${GLM_dir}/IRESP/${mod}/${run}
	cp ${subcond2}.peak+tlrc.* ${GLM_dir}/IRESP/${mod}/${run}

	mv ${subcond1}.peak+tlrc.* ${ANOVA_dir}
	mv ${subcond2}.peak+tlrc.* ${ANOVA_dir}
####################################################################################################
echo ""
