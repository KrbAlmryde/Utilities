	#----------------------------------------------------------------------------
	#		Function Echo_progress
	#
	#		Purpose:  This function declares the step currently being performed
	#				  in the analysis pipeline
	#
	#
	#
	#		  Input:  The name of the current step being performed. 
	#
	#
	#		 Output:  =========== $subrun $step ============== padded by newlines
	#
	#
	#----------------------------------------------------------------------------
	
	function Echo_progress ()
	{
		Study_Variables
		local step=$1
		echo
		echo =========== $subrun $step ==============
		echo
	}


	#----------------------------------------------------------------------------
	#		Function Mask_check
	#
	#		Purpose:   This function checks the current directory for the mask 
	# 				   file, and returns the 'maskfile' variable
	#
	#		  Input:   None; This function checks the directory only
	#
	#
	#		 Output:   'maskfile' variable. If ${subrun}.fullmask.edit exists
	#					in the current direcotry, maskfile=fullmask.edit, 
	#					otherwise maskfile=fullmask.edit
	#
	#----------------------------------------------------------------------------
	
	function Mask_check ()
	{
		if [[ ! -f ${SUBJ_prep}/${subrun}.fullmask.edit+orig.HEAD ]]; then
			maskfile=fullmask
		else
			maskfile=fullmask.edit
		fi
	}




	#----------------------------------------------------------------------------
	#		function Regress_Plot
	#
	#		Purpose:   This function will plot Regressors and 'Regressors of 
	#				   interest'
	#
	#		  Input: 'Type' of condition
	#
	#		 Output: ${submod}.${Type}.Regressors-All
	#				 ${submod}.${Type}.RegressofInterest
	#				 ideal.${submod}.${cond}.${Type}.1D
	#
	#----------------------------------------------------------------------------
	
	function Regress_Plot ()
	{
		local index=5
		local Type=$1
		
		Condition $Type; Study_Variables; Mask_check
		
		if [[ ! -e ${SUBJ_model}/${submod}.${Type}.RegressofInterest.jpg ]]; then
			for cond in $cond_list; do
				
				cd ${SUBJ_glm}
				
				1dcat \
					${submod}.${Type}.xmat.1D'['${index}']' \
					> ${SUBJ_model}/ideal.${submod}.${cond}.${Type}.1D
				
				((index++))
				
			done
			
			1dplot \
				-sepscl \
				-jpeg ${SUBJ_model}/${submod}.${Type}.Regressors-All \
				${submod}.${Type}.xmat.1D'[$..0]'
			
			1dplot \
				-jpeg ${SUBJ_model}/${submod}.${Type}.RegressofInterest \
				${submod}.${Type}.xmat.1D'['${index}'..5]'
	
			mv ${submod}.${Type}.xmat.jpg ${SUBJ_model}/
			mv ${submod}.${Type}.Regress* ${SUBJ_model}/
		fi 
	}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Regress_censor
#
#		Purpose:
#
#
#
#
#		  Input:
#
#
#		 Output:
#
#
#----------------------------------------------------------------------------

function Regress_censor ()
{
	Study_Variables
	Echo_progress CENSOR

	if [[ ! -f ${SUBJ_glm}/motion.${subrun}_censor.1D ]]; then
		
		cd ${SUBJ_glm}

		# compute de-meaned motion parameters (for use in regression)
		1d_tool.py \
			-infile ${subrun}.dfile.1D -set_nruns 1                                \
			  -demean -write motion.${subrun}_demean.1D

		# compute motion parameter derivatives (for use in regression)
		1d_tool.py \
			-infile ${subrun}.dfile.1D \
			-set_nruns 1 -derivative -demean \
			-write motion.${subrun}_deriv.1D

		# create censor file motion_${subj}_censor.1D, for censoring motion 
		1d_tool.py -verb 2 \
			-infile ${subrun}.dfile.1D \
			-set_nruns 1 -set_tr ${tR} \
			-show_censor_count -censor_prev_TR \
			-censor_motion .1 motion.${subrun}


	fi 2>&1 | tee -a $SUBJ_glm/log.censor.txt
}


#============================================================================
#						 Transfer-Appropriate Processing 
#============================================================================

#----------------------------------------------------------------------------
#		Function Regress_tap
#
#		Purpose:
#
#
#
#
#		  Input:
#
#
#		 Output:
#
#
#----------------------------------------------------------------------------

function Regress_tap ()
{
	local Type=$1
	
	Condition $Type; Study_Variables; Mask_check
	Echo_progress "REGRESSION ${Type}"
	
	if [[ ! -e ${SUBJ_glm}/${submod}.${Type}.stats+tlrc.HEAD ]]; then	

		cd ${SUBJ_glm}
			
		case $Type in
			
			Basic )
			#------------------------------------------------------------
			#				 Regression_tap Basic
			#
			# This function performs the Regression analysis on the
			# subject's performance during the behavioral task. Hence,
			# the name tapD, as in D-prime
			#------------------------------------------------------------
	
				3dDeconvolve \
					-polort A -GOFORIT \
					-input ${subrun}.scale+tlrc \
					-censor motion.${subrun}_censor.1D \
					-mask ${subrun}.${maskfile}+tlrc \
					-num_stimts 8 -local_times \
					-stim_times 1 \
							${STIM_dir}/stim.${run}.${cond1}.1D "${model}" \
							-stim_label 1 ${submod}.${cond1}.${Type} \
					-stim_times 2 \
							${STIM_dir}/stim.${run}.${cond2}.1D "${model}" \
							-stim_label 2 ${submod}.${cond2}.${Type} \
					-stim_file 3 \
							${subrun}.dfile.1D'[0]' \
							-stim_base 3 \
							-stim_label 3 roll \
					-stim_file 4 \
							${subrun}.dfile.1D'[1]' \
							-stim_base 4 \
							-stim_label 4 pitch \
					-stim_file 5 \
							${subrun}.dfile.1D'[2]' \
							-stim_base 5 \
							-stim_label 5 yaw \
					-stim_file 6 \
							${subrun}.dfile.1D'[3]' \
							-stim_base 6 \
							-stim_label 6 dS \
					-stim_file 7 \
							${subrun}.dfile.1D'[4]' \
							-stim_base 7 \
							-stim_label 7 dL \
					-stim_file 8 \
							${subrun}.dfile.1D'[5]' \
							-stim_base 8 \
							-stim_label 8 dP \
					-xout -x1D \
							${submod}.${Type}.xmat.1D \
							-xjpeg ${submod}.${Type}.xmat.jpg \
					-jobs 4 \
					-fout -tout \
					-TR_times 1 \
						-sresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.sirf+tlrc \
						-sresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.sirf+tlrc \
						-iresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.irf+tlrc \
						-iresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.irf+tlrc \
					-errts ${submod}.${Type}.errts+tlrc \
					-fitts ${submod}.${Type}.fitts+tlrc \
					-bucket ${submod}.${Type}.stats+tlrc
			;; 
			
			Dprime )
				#============================================================
				#				 Regression_tapD
				#
				# This function performs the Regression analysis on the
				# subject's performance during the behavioral task. Hence,
				# the name tapD, as in D-prime
				#============================================================

				if [[ $run = SP1 ]]; then
					
					3dDeconvolve \
						-polort A -GOFORIT \
						-input ${subrun}.scale+tlrc \
						-censor motion.${subrun}_censor.1D \
						-mask ${subrun}.${maskfile}+tlrc \
						-num_stimts 8 -local_times \
						-stim_times 1 \
							${STIM_dir}/stim.${subrun}.${cond1}.1D "${model}" \
							-stim_label 1 ${submod}.${cond1}.${Type} \
						-stim_times 2 \
							${STIM_dir}/stim.${subrun}.${cond2}.1D "${model}" \
							-stim_label 2 ${submod}.${cond2}.${Type} \
						-stim_file 3 \
							${subrun}.dfile.1D'[0]' \
							-stim_base 3 \
							-stim_label 3 roll \
						-stim_file 4 \
							${subrun}.dfile.1D'[1]' \
							-stim_base 4 \
							-stim_label 4 pitch \
						-stim_file 5 \
							${subrun}.dfile.1D'[2]' \
							-stim_base 5 \
							-stim_label 5 yaw \
						-stim_file 6 \
							${subrun}.dfile.1D'[3]' \
							-stim_base 6 \
							-stim_label 6 dS \
						-stim_file 7 \
							${subrun}.dfile.1D'[4]' \
							-stim_base 7 \
							-stim_label 7 dL \
						-stim_file 8 \
							${subrun}.dfile.1D'[5]' \
							-stim_base 8 \
							-stim_label 8 dP \
						-xout \
							-x1D ${submod}.${Type}.xmat.1D \
							-xjpeg ${submod}.${Type}.xmat.jpg \
						-jobs 4 \
						-fout -tout \
						-TR_times 1 \
							-sresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.sirf+tlrc \
							-sresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.sirf+tlrc \
							-iresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.irf+tlrc \
							-iresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.irf+tlrc \
						-errts ${submod}.${Type}.errts+tlrc \
						-fitts ${submod}.${Type}.fitts+tlrc \
						-bucket ${submod}.${Type}.stats+tlrc
				else
					echo; echo =========== $subrun ${Type} ==============; echo
					
					3dDeconvolve \
						-polort A -GOFORIT \
						-input ${subrun}.scale+tlrc \
						-censor motion.${subrun}_censor.1D \
						-mask ${subrun}.${maskfile}+tlrc \
						-num_stimts 10 -local_times \
						-stim_times 1 \
							${STIM_dir}/stim.${subrun}.${cond1}.1D "${model}" \
							-stim_label 1 ${submod}.${cond1}.${Type} \
						-stim_times 2 \
							${STIM_dir}/stim.${subrun}.${cond2}.1D "${model}" \
							-stim_label 2 ${submod}.${cond2}.${Type} \
						-stim_times 3 \
							${STIM_dir}/stim.${subrun}.${cond3}.1D "${model}" \
							-stim_label 3 ${submod}.${cond3}.${Type} \
						-stim_times 4 \
							${STIM_dir}/stim.${subrun}.${cond4}.1D "${model}" \
							-stim_label 4 ${submod}.${cond4}.${Type} \
						-stim_file 5 \
							${subrun}.dfile.1D'[0]' \
							-stim_base 5 \
							-stim_label 5 roll \
						-stim_file 6 \
							${subrun}.dfile.1D'[1]' \
							-stim_base 6 \
							-stim_label 6 pitch \
						-stim_file 7 \
							${subrun}.dfile.1D'[2]' \
							-stim_base 7 \
							-stim_label 7 yaw \
						-stim_file 8 \
							${subrun}.dfile.1D'[3]' \
							-stim_base 8 \
							-stim_label 8 dS \
						-stim_file 9 \
							${subrun}.dfile.1D'[4]' \
							-stim_base 9 \
							-stim_label 9 dL \
						-stim_file 10 \
							${subrun}.dfile.1D'[5]' \
							-stim_base 10 \
							-stim_label 10 dP \
						-xout \
							-x1D ${submod}.${Type}.xmat.1D \
							-xjpeg ${submod}.${Type}.xmat.jpg \
						-jobs 4 \
						-fout -tout \
						-TR_times 1 \
							-sresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.sirf+tlrc \
							-sresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.sirf+tlrc \
							-sresp 3 ${SUBJ_iresp}/${submod}.${cond3}.${Type}.sirf+tlrc \
							-sresp 4 ${SUBJ_iresp}/${submod}.${cond4}.${Type}.sirf+tlrc \
							-iresp 1 ${SUBJ_iresp}/${submod}.${cond1}.${Type}.irf+tlrc \
							-iresp 2 ${SUBJ_iresp}/${submod}.${cond2}.${Type}.irf+tlrc \
							-iresp 3 ${SUBJ_iresp}/${submod}.${cond3}.${Type}.irf+tlrc \
							-iresp 4 ${SUBJ_iresp}/${submod}.${cond4}.${Type}.irf+tlrc \
						-errts ${submod}.${Type}.errts+tlrc \
						-fitts ${submod}.${Type}.fitts+tlrc \
						-bucket ${submod}.${Type}.stats+tlrc
				fi
			;;
		esac
	fi 
}




	
	
	
	#----------------------------------------------------------------------------
	#		Function  Regression_REML
	#
	#		Purpose:  This function performs REML on the now Deconvolved data. 
	#
	#
	#		  Input: Condition 'Type'; Basic or Dprime
	#
	#
	#		 Output: ${submod}.${Type}.REML.stats
	#				 ${submod}.${Type}.REMLvar.stats
	#				 ${submod}.${Type}.REML.fitts.stats
	#				 ${submod}.${Type}.REML.errts.stats
	#
	#----------------------------------------------------------------------------
	
	function Regress_REML () 
	{
		Echo_progress REML 
		
		local Type=$1
		Condition $Type; Study_Variables; Mask_check
		
		cd ${SUBJ_glm}
		
		if [[ ! -e ${submod}.${Type}.REML.stats+tlrc.HEAD ]]; then
			
			3dREMLfit -matrix ${submod}.${Type}.xmat.1D \
				-input ${subrun}.scale+tlrc \
				-mask ${subrun}.${maskfile}+tlrc \
				-fout -tout \
				-Rbuck ${submod}.${Type}.REML.stats+tlrc \
				-Rvar ${submod}.${Type}.REMLvar.stats+tlrc \
				-Rfitts ${submod}.${Type}.REML.fitts+tlrc \
				-Rerrts ${submod}.${Type}.REML.errts+tlrc \
				-verb
		fi
	}
	
	#----------------------------------------------------------------------------
	#		Function  Regression_FWHMx
	#
	#		Purpose:  Run 3dFWHMx to determine the required smoothing for cluster 
	# 				  analysis. Place the results into a text file living in the
	#				  GLM_dir that can be later referenced. 
	#
	#
	#		  Input: Condition 'Type'; Basic or Dprime
	#
	#
	#		 Output: ${submod}.${Type}.REML.stats
	#				 ${submod}.${Type}.REMLvar.stats
	#				 ${submod}.${Type}.REML.fitts.stats
	#				 ${submod}.${Type}.REML.errts.stats
	#
	#----------------------------------------------------------------------------
	
	
	function Regress_FWHMx ()
	{
		local Type=$1
	
		Condition $Type; Study_Variables
		Echo_progress 
	
		if [[ ! -e ${submod}.${Type}.errts.detrend+tlrc.HEAD ]]; then
			
			cd ${SUBJ_glm}
			
			3dFWHMx \
				-dset ${submod}.${Type}.errts+tlrc \
				-mask ${SUBJ_glm}/${subrun}.${maskfile}+tlrc \
				-combine -detrend \
				2>&1 | tee -a ${subrun}.${Type}.FWHMx.txt
		fi
		

			echo "${subrun}.${Type} = `tail -c 8 ${subrun}.${Type}.FWHMx.txt`" \
				>> ${ANOVA_run}/${run}.${Type}.FWHMx.txt
	}





	#----------------------------------------------------------------------------
	#		Function  Regression_FWHMxyz
	#
	#		Purpose:  Run 3dFWHMx to determine the required smoothing for cluster 
	# 				  analysis. Place the results into a text file living in the
	#				  GLM_dir that can be later referenced. 
	#
	#
	#		  Input: Condition 'Type'; Basic or Dprime
	#
	#
	#		 Output: ${submod}.${Type}.REML.stats
	#				 ${submod}.${Type}.REMLvar.stats
	#				 ${submod}.${Type}.REML.fitts.stats
	#				 ${submod}.${Type}.REML.errts.stats
	#
	#----------------------------------------------------------------------------
	
	function Regress_FWHMxyz ()
	{
		local Type=$1
		local blur_epi
		local blur_erts
		local fxyz
		local fwhmx
		
		Condition $Type; Study_Variables; Mask_check
		Echo_progress DENOISE
		
		if [[ ! -e ${SUBJ_glm}/${subrun}.ClustSim.* ]]; then

			cd ${SUBJ_glm}
			
			3dFWHMx \
				-detrend \
				-mask ${subrun}.${maskfile}+tlrc \
				${subrun}.scale+tlrc'[0..$]' \
				> blur.epits.${subrun}.1D
			
			3dFWHMx \
				-detrend \
				-mask ${subrun}.${maskfile}+tlrc \
				${submod}.${Type}.errts+tlrc"[0..$]" \
				> blur.errts.${subrun}.1D
			
			blur_epi=`cat blur.epits.${subrun}.1D`
			blur_erts=`cat blur.errts.${subrun}.1D`

			echo "$blur_epi" > ${SUBJ_getc}/blur.est.${subrun}.1D
			echo "$blur_erts" >> ${SUBJ_getc}/blur.est.${subrun}.1D

			# add 3dClustSim results as attributes to the stats dset

			fxyz=(`tail -1 ${SUBJ_getc}/blur.est.${subrun}.1D`)
			
			fwhmx=`3dFWHMx \
					-dset ${submod}.${Type}.errts+tlrc \
					-mask ${SUBJ_glm}/${subrun}.${maskfile}+tlrc \
					-combine -detrend`

			3dClustSim \
				-both -NN 123 \
				-mask ${subrun}.${maskfile}+tlrc \
				-fwhm "${fwhmx}" -prefix ClustSim
	
			3drefit -atrstring AFNI_CLUSTSIM_MASK file:ClustSim.mask \
					-atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.NN1.niml \
					-atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.NN2.niml \
					-atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.NN3.niml \
					${submod}.${Type}.stats+tlrc
		fi
	}
	
	
3dDeconvolve -polort A -input input.scale+tlrc \
-num_stimts -local_times \
-stim_times 1 '1D: 1 2 3 4 5 6 7 8 9 10' 'BLOCK4(10,1)' -stim_label 1 listen \
-stim_times 2 '1D: 1 2 3 4 5 6 7 8 9 10' 'BLOCK4(10,1)' -stim_label 2 response \
-stim_times 3 '1D: 1 2 3 4 5 6 7 8 9 10' 'BLOCK4(10,1)' -stim_label 3 control \
-xout -x1D output.xmat.1D -jobs 4 \
-fout -tout -bucket output.stats+tlrc

