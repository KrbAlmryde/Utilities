#---------------------------------------------------------------------------------------------------
								########### START OF MAIN ############
#---------------------------------------------------------------------------------------------------
# This is the aligning.sh program. Using AFNI programs such as align_epi_anat.py, @auto_tlrc, and
# 3drefit, this script aims to align functional data to standard space (Talairach). Next its
# applies the transformations made to the ${spgr}_aligned+tlrc to the Functional data using the
# adwarp command found in the AFNI program suite
#---------------------------------------------------------------------------------------------------

#----------------------------------------------------------------------------
#		Function Coreg_SPGRtoFSE
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




function Coreg_spgr2fse ()
{
	Study_Variables; cd $SUBJ_struc
	
	if [[ ! -e ${subj}.spgr.standard+orig.HEAD ]]; then

		align_epi_anat.py \
			-dset1to2 -cmass cmass \
			-dset1 ${subj}.spgr+orig \
			-dset2 ${subj}.fse+orig \
			-cost lpa -suffix .cmass
			
		3dSkullStrip \
			-input ${subj}.spgr.cmass+orig \
			-prefix ${subj}.spgr.standard

	fi 2>&1 | tee -a $SUBJ_struc/log.SPGR.standard.txt
}





#----------------------------------------------------------------------------
#		Function Coreg_spgr2tlrc
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

function Coreg_spgr2tlrc () 
{
	Study_Variables; cd $SUBJ_struc

	if [[ ! -e ${subj}.spgr.standard+tlrc.HEAD ]]; then
		echo; echo =========== $subj.spgr TLRC ==============; echo
		@auto_tlrc \
			-no_ss -suffix NONE \
			-base TT_N27+tlrc \
			-input ${subj}.spgr.standard+orig
	
		3drefit -anat ${subj}.spgr.standard+tlrc
	fi
}






#----------------------------------------------------------------------------
#		Function Coreg_WarpIRF
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

function Coreg_WarpIRF ()
{
	local Type=$1
	Condition $Type; Study_Variables

	
	cd $GLM_subj
	
	for cond in $cond_list; do
		if [[ ! -e ${IRESP_glm}/${submod}.${cond}.${Type}.irf+tlrc.HEAD ]]; then
			if [[ ! -e ${submod}.${cond}.${Type}.irf+tlrc.HEAD ]]; then
				adwarp \
					-apar ${STRUC_subj}/${subj}.spgr_aligned+tlrc \
					-dpar ${submod}.${cond}.${Type}.irf+orig
			fi
		fi

		echo; echo "============= IRF =========="		
		ls ${submod}.${cond}.${Type}.irf*; echo

		if [[ ! -e ${ANOVA_run}/${submod}.${cond}.${Type}.irf+tlrc.HEAD ]]; then
			3dbucket \
				-prefix ${submod}.${cond}.${Type}.peak \
				-fbuc ${submod}.${cond}.${Type}.irf+tlrc'[5]'
			
			mv ${submod}.${cond}.${Type}.peak* $TEST_dir
		fi
	done
}




#----------------------------------------------------------------------------
#		Function Coreg_WarpFUNC
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

function Coreg_WarpFUNC ()
{
	local Type=$1
	local coef=1
	local tstat=2
	
	Condition $Type; Study_Variables

	cd $GLM_subj
	
	for cond in $cond_list; do
		if [[ ! -e ${FUNC_glm}/${submod}.${Type}.stats+tlrc.HEAD ]]; then
			if [[ ! -e ${submod}.${Type}.stats+tlrc.HEAD ]]; then
				adwarp \
					-apar ${STRUC_subj}/${subj}.spgr_aligned+tlrc \
					-dpar ${submod}.${Type}.stats+orig
			fi
		fi

		echo; echo "============= FUNC =========="
		ls ${submod}.${Type}.stats*

		if [[ ! -e ${ANOVA_run}/${submod}.${cond}.${Type}.FUNC+tlrc.HEAD ]]; then
			3dbucket \
				-prefix ${submod}.${cond}.${Type}.FUNC \
				-fbuc ${submod}.${Type}.stats+tlrc'['${coef}','${tstat}']'
			
			mv ${submod}.${cond}.${Type}.FUNC* $TEST_dir
			
			((coef=$coef+3)); ((tstat=$tstat+3))
		fi
	done
}




#----------------------------------------------------------------------------
#		Function Coreg_WarpREML
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

function Coreg_WarpREML ()
{
	local Type=$1
	local coef=1
	local tstat=2
	
	Condition $Type; Study_Variables
	
	cd $GLM_subj
	
	for cond in $cond_list; do
		if [[ ! -e ${REML_glm}/${submod}.${Type}.REML.stats+tlrc.HEAD ]]; then
			if [[ ! -e ${submod}.${Type}.REML.stats+tlrc.HEAD ]]; then
				adwarp \
					-apar ${STRUC_subj}/${subj}.spgr_aligned+tlrc \
					-dpar ${submod}.${Type}.REML.stats+orig
			fi
			
		fi

		echo; echo "============= REML =========="
		ls ${submod}.${Type}.REML.stats*; echo

		if [[ ! -e ${GLM_run}/${submod}.${cond}.${Type}.REML+tlrc.HEAD ]]; then
			3dbucket \
				-prefix ${submod}.${cond}.${Type}.REML \
				-fbuc ${submod}.${Type}.REML.stats+tlrc'['${coef}','${tstat}']'
				
			mv ${submod}.${cond}.${Type}.REML* $TEST_dir

			((coef=$coef+3)); ((tstat=$tstat+3))
		fi
	done
}





#----------------------------------------------------------------------------
#		Function Coreg_CleanUp
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

function Coreg_CleanUp ()
{
	local Type=$1
	Condition $Type; Study_Variables

	cd $GLM_subj

	for cond in $cond_list; do
		mv ${submod}.${cond}.${Type}.REML* ${GLM_run}
		mv ${submod}.${Type}.REML* ${REML_glm}
		
		mv ${submod}.${cond}.${Type}.FUNC+tlrc.* ${ANOVA_run}
		mv ${submod}.${Type}.stats* ${FUNC_glm}
		mv ${submod}.${Type}.errts* ${FUNC_glm}
		mv ${submod}.${Type}.fitts* ${FUNC_glm}

		mv ${submod}.${cond}.${Type}.peak+tlrc.* ${ANOVA_run}
		mv ${submod}.${cond}.${Type}.sirf+orig.* ${IRESP_glm}	
		mv ${submod}.${cond}.${Type}.irf* ${IRESP_glm}
	done
}


