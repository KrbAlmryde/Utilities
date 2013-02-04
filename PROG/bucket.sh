. $PROFILE/${1}_profile.sh
#---------------------------------------------------------------------------------------------------####
								########### START OF MAIN ############
#---------------------------------------------------------------------------------------------------####
# This script uses the AFNI program 3dbucket to extract subbricks 1-9 from the IRF files generated
# by 3dDeconvolve. In addtion it extracts the Full_Fstat, Coef, Tstat, and Fstat subbriks from the
# Deconvolve bucket file for each condition. The Full_Fstat resides at index 0. The Coef(iccient)
# resides at indices 1, 4, and 7. The Tstat resides at indicies 2, 5, and 8. The Fstat resides at
# indicies 3, 6, and 9
#---------------------------------------------------------------------------------------------------####
	echo "----------------------------------- bucket.sh -------------------------------------"
	echo "------------------------------- ${submod} ----------------------------------"
	echo ""
#---------------------------------------------------------------------------------------------------####
cd ${glm_dir}/FUNC
#---------------------------------------------------------------------------------------------------####
# extracting subrick index from the bucket files
if [ ! -e ${subcond2}.FUNC+tlrc.HEAD -o \
	! -e ${subcond2}.FUNC+tlrc.HEAD -o \
	! -e ${subcond2}.Fstat+tlrc.HEAD -o \
	! -e ${submod}.Full_Fstat+tlrc.HEAD ]; then
	
	if [ "${run}" = "SP1" ]; then
		#Extracting the Coefficient and T-statistic
		3dbucket -prefix ${subcond1}.FUNC -fbuc ${submod}.stats+tlrc'[1,2]'
		3dbucket -prefix ${subcond2}.FUNC -fbuc ${submod}.stats+tlrc'[4,5]'

		#Extracting the partial Fstat
		3dbucket -prefix ${subcond1}.Fstat -fbuc ${submod}.stats+tlrc'[3]'
		3dbucket -prefix ${subcond2}.Fstat -fbuc ${submod}.stats+tlrc'[6]'

		#Extracting the Full Fstat
		3dbucket -prefix ${submod}.Full_Fstat -fbuc ${submod}.stats+tlrc'[0]'
		
	else

		#Extracting the Coefficient and T-statistic
		3dbucket -prefix ${subcond1}.FUNC -fbuc ${submod}.stats+tlrc'[1,2]'
		3dbucket -prefix ${subcond2}.FUNC -fbuc ${submod}.stats+tlrc'[4,5]'
		3dbucket -prefix ${subcond3}.FUNC -fbuc ${submod}.stats+tlrc'[7,8]'
		3dbucket -prefix ${subcond4}.FUNC -fbuc ${submod}.stats+tlrc'[10,11]'
		
		#Extracting the partial Fstat
		3dbucket -prefix ${subcond1}.Fstat -fbuc ${submod}.stats+tlrc'[3]'
		3dbucket -prefix ${subcond2}.Fstat -fbuc ${submod}.stats+tlrc'[6]'
		3dbucket -prefix ${subcond3}.Fstat -fbuc ${submod}.stats+tlrc'[9]'
		3dbucket -prefix ${subcond4}.Fstat -fbuc ${submod}.stats+tlrc'[12]'
		
		#Extracting the Full Fstat
		3dbucket -prefix ${submod}.Full_Fstat -fbuc ${submod}.stats+tlrc'[0]'
	fi
fi

#---------------------------------------------------------------------------------------------------####
cd ${glm_dir}/REML
#---------------------------------------------------------------------------------------------------####
if [ ! -e ${subcond2}.REML+tlrc.HEAD -o \
	! -e ${subcond2}.REML+tlrc.HEAD -o \
	! -e ${subcond2}.REM.Fstat+tlrc.HEAD -o \
	! -e ${submod}.REM.Full_Fstat+tlrc.HEAD ]; then

	if [ "${run}" = "SP1" ]; then
		#Extracting the Coefficient and T-statistic
		3dbucket -prefix ${subcond1}.REML -fbuc ${submod}.stats.REML+tlrc'[1,2]'
		3dbucket -prefix ${subcond2}.REML -fbuc ${submod}.stats.REML+tlrc'[4,5]'

		#Extracting the partial Fstat
		3dbucket -prefix ${subcond1}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[3]'
		3dbucket -prefix ${subcond2}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[6]'

		#Extracting the Full Fstat
		3dbucket -prefix ${submod}.REML.Full_Fstat -fbuc ${submod}.stats.REML+tlrc'[0]'

	else

		#Extracting the Coefficient and T-statistic
		3dbucket -prefix ${subcond1}.REML -fbuc ${submod}.stats.REML+tlrc'[1,2]'
		3dbucket -prefix ${subcond2}.REML -fbuc ${submod}.stats.REML+tlrc'[4,5]'
		3dbucket -prefix ${subcond3}.REML -fbuc ${submod}.stats.REML+tlrc'[7,8]'
		3dbucket -prefix ${subcond4}.REML -fbuc ${submod}.stats.REML+tlrc'[10,11]'

		#Extracting the partial Fstat
		3dbucket -prefix ${subcond1}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[3]'
		3dbucket -prefix ${subcond2}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[6]'
		3dbucket -prefix ${subcond3}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[9]'
		3dbucket -prefix ${subcond4}.REML.Fstat -fbuc ${submod}.stats.REML+tlrc'[12]'

		#Extracting the Full Fstat
		3dbucket -prefix ${submod}.REML.Full_Fstat -fbuc ${submod}.stats.REML+tlrc'[0]'
	fi
fi
#---------------------------------------------------------------------------------------------------####
# Move the results to their respective GLM directory

	cd ${glm_dir}/FUNC
	
	cp ${subcond1}.FUNC+tlrc.* ${ANOVA_dir}
	cp ${subcond2}.FUNC+tlrc.* ${ANOVA_dir}
	cp ${subcond3}.FUNC+tlrc.* ${ANOVA_dir}
	cp ${subcond4}.FUNC+tlrc.* ${ANOVA_dir}

	mv ${subcond1}.FUNC+tlrc.* ${GLM_dir}/FUNC
	mv ${subcond2}.FUNC+tlrc.* ${GLM_dir}/FUNC
	mv ${subcond3}.FUNC+tlrc.* ${GLM_dir}/FUNC
	mv ${subcond4}.FUNC+tlrc.* ${GLM_dir}/FUNC

	cd ${glm_dir}/REML
	mv ${subcond1}.REML+tlrc.* ${GLM_dir}/REML
	mv ${subcond2}.REML+tlrc.* ${GLM_dir}/REML
	mv ${subcond3}.REML+tlrc.* ${GLM_dir}/REML
	mv ${subcond4}.REML+tlrc.* ${GLM_dir}/REML
	#---------------------------------------------------------------------------------------------------
	mv ${subcond1}.Fstat+tlrc.* ${GLM_dir}/REML/Fstat
	mv ${subcond2}.Fstat+tlrc.* ${GLM_dir}/REML/Fstat
	mv ${subcond3}.Fstat+tlrc.* ${GLM_dir}/REML/Fstat
	mv ${subcond4}.Fstat+tlrc.* ${GLM_dir}/REML/Fstat
#---------------------------------------------------------------------------------------------------####
cd ${glm_dir}/IRESP
#---------------------------------------------------------------------------------------------------####
# extracting peak subrick indices 5 and 6 of GAM and WAV impulse response function respectively.
if [ ! -e ${submod}.peak+tlrc.HEAD ]; then

	if [ "${run}" = SP1 ] ;then
		echo "${submod}.peak+tlrc"
		3dbucket -prefix ${subcond1}.peak -fbuc ${subcond1}.irf+tlrc'[5]'
		3dbucket -prefix ${subcond2}.peak -fbuc ${subcond2}.irf+tlrc'[5]'
	else
		echo "${submod}.peak+tlrc"
		3dbucket -prefix ${subcond1}.peak -fbuc ${subcond1}.irf+tlrc'[5]'
		3dbucket -prefix ${subcond2}.peak -fbuc ${subcond2}.irf+tlrc'[5]'
		3dbucket -prefix ${subcond3}.peak -fbuc ${subcond3}.irf+tlrc'[5]'
		3dbucket -prefix ${subcond4}.peak -fbuc ${subcond4}.irf+tlrc'[5]'
	fi
fi
#---------------------------------------------------------------------------------------------------####
# Move the results to their respective GLM directory
	cp ${subcond1}.peak+tlrc.* ${GLM_dir}/IRESP
	cp ${subcond2}.peak+tlrc.* ${GLM_dir}/IRESP
	cp ${subcond3}.peak+tlrc.* ${GLM_dir}/IRESP
	cp ${subcond4}.peak+tlrc.* ${GLM_dir}/IRESP

	mv ${subcond1}.peak+tlrc.* ${ANOVA_dir}
	mv ${subcond2}.peak+tlrc.* ${ANOVA_dir}
	mv ${subcond3}.peak+tlrc.* ${ANOVA_dir}
	mv ${subcond4}.peak+tlrc.* ${ANOVA_dir}
#---------------------------------------------------------------------------------------------------####
echo ""
