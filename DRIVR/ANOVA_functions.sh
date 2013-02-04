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

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function 
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

function Anova_tap ()
{
	local Type=$1
	local head=$1
	Condition $Type
	Study_Variables
	Echo_progress "ANOVA $Type"

	cp ${SUBJ_glm}/${submod}.${Type}.stats+tlrc.* ${ANOVA_run}
	
	cd ${ANOVA_run}
	
	case $Type in
		Basic )
			if [[ ! -f mean.${runmod}.${cond1}.${Type}.nii ]]; then
				
				3dANOVA2 \
					-type 3 -alevels 2 -blevels 15 \
					-dset 1 1 TS001.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 1 TS001.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 2 TS002.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 2 TS002.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 3 TS003.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 3 TS003.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 4 TS004.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 4 TS004.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 5 TS005.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 5 TS005.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 6 TS006.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 6 TS006.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 7 TS007.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 7 TS007.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 8 TS008.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 8 TS008.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 9 TS009.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 9 TS009.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 10 TS010.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 10 TS010.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 11 TS011.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 11 TS011.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 12 TS012.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 12 TS012.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 13 TS013.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 13 TS013.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 14 TS014.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 14 TS014.${runmod}.${Type}.stats+tlrc'[4]' \
					-dset 1 15 TS015.${runmod}.${Type}.stats+tlrc'[1]' \
					-dset 2 15 TS015.${runmod}.${Type}.stats+tlrc'[4]' \
					-amean 1 mean.${runmod}.${cond1}.${Type} \
					-amean 2 mean.${runmod}.${cond2}.${Type} \
					-acontr 1 -1 contr.${runmod}.${cond1v2}.${Type} \
					-acontr -1 1 contr.${runmod}.${cond2v1}.${Type}
			fi
			;;

		Dprime )
			if [[ ! -f mean.${runmod}.${cond1}.${Type}.nii ]]; then
				if [[ $run = SP1 ]] ;then
					
					3dANOVA2 \
						-type 3 -alevels 2 -blevels 14 \
						-dset 1 1 TS001.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 1 TS001.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 2 TS002.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 2 TS002.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 3 TS003.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 3 TS003.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 4 TS004.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 4 TS004.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 5 TS005.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 5 TS005.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 6 TS006.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 6 TS006.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 7 TS007.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 7 TS007.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 8 TS008.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 8 TS008.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 9 TS009.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 9 TS009.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 10 TS010.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 10 TS010.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 11 TS011.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 11 TS011.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 12 TS012.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 12 TS012.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 13 TS013.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 13 TS013.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 1 14 TS014.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 14 TS014.${runmod}.${Type}.stats+tlrc'[4]' \
						-amean 1 mean.${runmod}.${cond1}.${Type} \
						-amean 2 mean.${runmod}.${cond2}.${Type} \
						-acontr 1 -1 contr.${runmod}.${cond1v2}.${Type} \
						-acontr -1 1 contr.${runmod}.${cond2v1}.${Type}
				else
					
					3dANOVA2 \
						-type 3 -alevels 4 -blevels 14 \
						-dset 1 1 TS001.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 1 TS001.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 1 TS001.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 1 TS001.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 2 TS002.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 2 TS002.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 2 TS002.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 2 TS002.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 3 TS003.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 3 TS003.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 3 TS003.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 3 TS003.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 4 TS004.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 4 TS004.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 4 TS004.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 4 TS004.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 5 TS005.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 5 TS005.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 5 TS005.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 5 TS005.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 6 TS006.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 6 TS006.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 6 TS006.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 6 TS006.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 7 TS007.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 7 TS007.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 7 TS007.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 7 TS007.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 8 TS008.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 8 TS008.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 8 TS008.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 8 TS008.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 9 TS009.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 9 TS009.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 9 TS009.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 9 TS009.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 10 TS010.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 10 TS010.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 10 TS010.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 10 TS010.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 11 TS011.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 11 TS011.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 11 TS011.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 11 TS011.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 12 TS012.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 12 TS012.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 12 TS012.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 12 TS012.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 13 TS013.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 13 TS013.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 13 TS013.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 13 TS013.${runmod}.${Type}.stats+tlrc'[10]' \
						-dset 1 14 TS014.${runmod}.${Type}.stats+tlrc'[1]' \
						-dset 2 14 TS014.${runmod}.${Type}.stats+tlrc'[4]' \
						-dset 3 14 TS014.${runmod}.${Type}.stats+tlrc'[7]' \
						-dset 4 14 TS014.${runmod}.${Type}.stats+tlrc'[10]' \
						-amean 1 mean.${runmod}.${cond1}.${Type} \
						-amean 2 mean.${runmod}.${cond2}.${Type} \
						-amean 3 mean.${runmod}.${cond3}.${Type} \
						-amean 4 mean.${runmod}.${cond4}.${Type} \
						-acontr 1 -1 0 0 contr.${runmod}.${cond1v2}.${Type} \
						-acontr -1 1 0 0 contr.${runmod}.${cond2v1}.${Type} \
						-acontr 0 0 1 -1 contr.${runmod}.${cond3v4}.${Type} \
						-acontr 0 0 -1 1 contr.${runmod}.${cond4v3}.${Type}
				fi
			fi
			;;
	esac
}
	
	
	
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function anova_AFNItoNIFTI
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
	
	function Anova_AFNItoNIFTI ()
	{
		local head
		local cond
		local contr
		local Type=$1
		
		Condition $Type; Study_Variables
	
		cd ${ANOVA_run}
		
		for head in IRF beta; do
			for cond in $cond_list; do
				if [[ ! -f mean.${runmod}.${cond}.${Type}.nii ]]; then
					3dAFNItoNIFTI \
						-float \
						-prefix mean.${runmod}.${cond}.${Type}.nii \
						mean.${runmod}.${cond}.${Type}+tlrc
				fi
			done
			
			for contr in $contr_list; do
				if [[ -f ${head}.${runmod}.contr.${contr}.${Type}+tlrc.HEAD ]]; then
					3dAFNItoNIFTI \
						-float \
						-prefix ${head}.${runmod}.contr.${contr}.${Type}.nii \
						${head}.${runmod}.contr.${contr}.${Type}+tlrc 
				fi
			done
		done
	}





	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function Anova_AlphaCorr
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

	function Anova_AlphaCorr ()
	{
		local Type=$1
		local fwhmx
		Condition $Type; Study_Variables
		
		cd ${ANOVA_run}
		
		fwhmx=`awk -v OFS=' ' '{ sum+=$3 } END { print sum/NR }' ${run}.${Type}.FWHMx.txt`
		
		
		3dClustSim \
			-mask ${ANOVA_masks}/Brain.Mask.nii \
			-fwhm ${fwhmx} \
			-prefix ${ANOVA_dir}/AlphaClust.${run}.${Type}.${study} 

		
		touch ${run}_FWHMx_${fwhmx}_${Type}.txt
	}






#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Anova_CleanUp
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

	function Anova_CleanUp ()
	{
		local cond
		local Type=$1
		
		Condition $Type; Study_Variables
	
		cd ${ANOVA_run}
	
		for cond in $cond_list; do 
		
			rm *.mean.*.${Type}+tlrc.HEAD
			rm *.mean.*.${Type}+tlrc.BRIK
			
			rm *.contr.*.${Type}+tlrc.HEAD
			rm *.contr.*.${Type}+tlrc.BRIK

			mv ${subj}.${run}.* ${ANOVA_orig}			
			
		done
	}

