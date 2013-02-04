. $PROFILE/${1}_profile.sh
#--------------------------------------------------------------------------------
# 3dANOVA2 -type (k)=3  mixed efects model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor A - Semantic/Voice/Familiarity/Recollection
# 		(fixed, alevels) = (1) animal/male/old, (2) food/female/new, (3) null
# Factor B - Subjects (random, blevels) = (1) TS1, (2) TS2, (TS3), ...., (14) TS14
#--------------------------------------------------------------------------------

#--------------------------------------------------------------------------------

echo "try to source the functions"


function anova_irf_tap () 
{
	echo "--------------------------------- ANOVA_tap.sh ---------------------------------"

	cd ${ANOVA_dir}
	echo "this is the anova_irf_tap function"
#	if [ ! -e ${subcond1}.peak+tlrc.HEAD -a ! -e ${subcond2}.peak+tlrc.HEAD ]; then
#		echo "ANOVA has already been performed!"
#		echo ""
#	else
		if [ "${run}" = SP1 ] ;then
			echo "------------------------- ${run}: ${cond1} ${cond2} ------------------------"
			echo ""
			3dANOVA2 -type 3 -alevels 2 -blevels 14 \
			-dset 1 1 TS001.${runcond1}.peak+tlrc \
			-dset 2 1 TS001.${runcond2}.peak+tlrc \
			-dset 1 2 TS002.${runcond1}.peak+tlrc \
			-dset 2 2 TS002.${runcond2}.peak+tlrc \
			-dset 1 3 TS003.${runcond1}.peak+tlrc \
			-dset 2 3 TS003.${runcond2}.peak+tlrc \
			-dset 1 4 TS004.${runcond1}.peak+tlrc \
			-dset 2 4 TS004.${runcond2}.peak+tlrc \
			-dset 1 5 TS005.${runcond1}.peak+tlrc \
			-dset 2 5 TS005.${runcond2}.peak+tlrc \
			-dset 1 6 TS006.${runcond1}.peak+tlrc \
			-dset 2 6 TS006.${runcond2}.peak+tlrc \
			-dset 1 7 TS007.${runcond1}.peak+tlrc \
			-dset 2 7 TS007.${runcond2}.peak+tlrc \
			-dset 1 8 TS008.${runcond1}.peak+tlrc \
			-dset 2 8 TS008.${runcond2}.peak+tlrc \
			-dset 1 9 TS009.${runcond1}.peak+tlrc \
			-dset 2 9 TS009.${runcond2}.peak+tlrc \
			-dset 1 10 TS010.${runcond1}.peak+tlrc \
			-dset 2 10 TS010.${runcond2}.peak+tlrc \
			-dset 1 11 TS011.${runcond1}.peak+tlrc \
			-dset 2 11 TS011.${runcond2}.peak+tlrc \
			-dset 1 12 TS012.${runcond1}.peak+tlrc \
			-dset 2 12 TS012.${runcond2}.peak+tlrc \
			-dset 1 13 TS013.${runcond1}.peak+tlrc \
			-dset 2 13 TS013.${runcond2}.peak+tlrc \
			-dset 1 14 TS014.${runcond1}.peak+tlrc \
			-dset 2 14 TS014.${runcond2}.peak+tlrc \
			-amean 1 ${runmod}.mean.${cond1} \
			-amean 2 ${runmod}.mean.${cond2} \
			-acontr 1 -1 ${runmod}.contr.${cond1v2} \
			-acontr -1 1 ${runmod}.contr.${cond2v1} 
		else
			echo "------------------------- ${run}: ${cond1} ${cond2} --------------"
			echo "------------------------- ${run}: ${cond3} ${cond4} --------------"
			echo ""
			3dANOVA2 -type 3 -alevels 4 -blevels 14 \
			-dset 1 1 TS001.${runcond1}.peak+tlrc \
			-dset 2 1 TS001.${runcond2}.peak+tlrc \
			-dset 3 1 TS001.${runcond3}.peak+tlrc \
			-dset 4 1 TS001.${runcond4}.peak+tlrc \
			-dset 1 2 TS002.${runcond1}.peak+tlrc \
			-dset 2 2 TS002.${runcond2}.peak+tlrc \
			-dset 3 2 TS002.${runcond3}.peak+tlrc \
			-dset 4 2 TS002.${runcond4}.peak+tlrc \
			-dset 1 3 TS003.${runcond1}.peak+tlrc \
			-dset 2 3 TS003.${runcond2}.peak+tlrc \
			-dset 3 3 TS003.${runcond3}.peak+tlrc \
			-dset 4 3 TS003.${runcond4}.peak+tlrc \
			-dset 1 4 TS004.${runcond1}.peak+tlrc \
			-dset 2 4 TS004.${runcond2}.peak+tlrc \
			-dset 3 4 TS004.${runcond3}.peak+tlrc \
			-dset 4 4 TS004.${runcond4}.peak+tlrc \
			-dset 1 5 TS005.${runcond1}.peak+tlrc \
			-dset 2 5 TS005.${runcond2}.peak+tlrc \
			-dset 3 5 TS005.${runcond3}.peak+tlrc \
			-dset 4 5 TS005.${runcond4}.peak+tlrc \
			-dset 1 6 TS006.${runcond1}.peak+tlrc \
			-dset 2 6 TS006.${runcond2}.peak+tlrc \
			-dset 3 6 TS006.${runcond3}.peak+tlrc \
			-dset 4 6 TS006.${runcond4}.peak+tlrc \
			-dset 1 7 TS007.${runcond1}.peak+tlrc \
			-dset 2 7 TS007.${runcond2}.peak+tlrc \
			-dset 3 7 TS007.${runcond3}.peak+tlrc \
			-dset 4 7 TS007.${runcond4}.peak+tlrc \
			-dset 1 8 TS008.${runcond1}.peak+tlrc \
			-dset 2 8 TS008.${runcond2}.peak+tlrc \
			-dset 3 8 TS008.${runcond3}.peak+tlrc \
			-dset 4 8 TS008.${runcond4}.peak+tlrc \
			-dset 1 9 TS009.${runcond1}.peak+tlrc \
			-dset 2 9 TS009.${runcond2}.peak+tlrc \
			-dset 3 9 TS009.${runcond3}.peak+tlrc \
			-dset 4 9 TS009.${runcond4}.peak+tlrc \
			-dset 1 10 TS010.${runcond1}.peak+tlrc \
			-dset 2 10 TS010.${runcond2}.peak+tlrc \
			-dset 3 10 TS010.${runcond3}.peak+tlrc \
			-dset 4 10 TS010.${runcond4}.peak+tlrc \
			-dset 1 11 TS011.${runcond1}.peak+tlrc \
			-dset 2 11 TS011.${runcond2}.peak+tlrc \
			-dset 3 11 TS011.${runcond3}.peak+tlrc \
			-dset 4 11 TS011.${runcond4}.peak+tlrc \
			-dset 1 12 TS012.${runcond1}.peak+tlrc \
			-dset 2 12 TS012.${runcond2}.peak+tlrc \
			-dset 3 12 TS012.${runcond3}.peak+tlrc \
			-dset 4 12 TS012.${runcond4}.peak+tlrc \
			-dset 1 13 TS013.${runcond1}.peak+tlrc \
			-dset 2 13 TS013.${runcond2}.peak+tlrc \
			-dset 3 13 TS013.${runcond3}.peak+tlrc \
			-dset 4 13 TS013.${runcond4}.peak+tlrc \
			-dset 1 14 TS014.${runcond1}.peak+tlrc \
			-dset 2 14 TS014.${runcond2}.peak+tlrc \
			-dset 3 14 TS014.${runcond3}.peak+tlrc \
			-dset 4 14 TS014.${runcond4}.peak+tlrc \
			-amean 1 ${runmod}.mean.${cond1} \
			-amean 2 ${runmod}.mean.${cond2} \
			-amean 3 ${runmod}.mean.${cond3} \
			-amean 4 ${runmod}.mean.${cond4} \
			-acontr 1 -1 0 0 ${runmod}.contr.${cond1v2} \
			-acontr -1 1 0 0 ${runmod}.contr.${cond2v1} \
			-acontr 0 0 1 -1 ${runmod}.contr.${cond3v4} \
			-acontr 0 0 -1 1 ${runmod}.contr.${cond4v3}
		fi
			#---------------------------------------------------------------------------
			# Convert Output ANOVA data files to NIFTI -float types
		
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond1}.nii \
				${runmod}.mean.${cond1}+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond2}.nii \
				${runmod}.mean.${cond2}+tlrc 
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond3}.nii \
				${runmod}.mean.${cond3}+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond4}.nii \
				${runmod}.mean.${cond4}+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond1v2}.nii \
				${runmod}.contr.${cond1v2}+tlrc 
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond2v1}.nii \
				${runmod}.contr.${cond2v1}+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond3v4}.nii \
				${runmod}.contr.${cond3v4}+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond4v3}.nii \
				${runmod}.contr.${cond4v3}+tlrc
		
			#---------------------------------------------------------------------------
			# Move the single subject files to the etc directory to keep the folder less 
			# cluttered
			
			mv TS0*.${runcond1}.peak+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond2}.peak+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond3}.peak+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond4}.peak+tlrc.* ${ANOVA_dir}/etc/
			
			#---------------------------------------------------------------------------
			# Move the Original ANOVA data files (of type short) to the etc/ dir to keep 
			# things less cluttered
			
			mv ${runmod}.mean.*+tlrc.* ${ANOVA_dir}/etc/Orig
			mv ${runmod}.contr.*+tlrc.* ${ANOVA_dir}/etc/Orig
#	fi

}






function anova_betas_tap () 
{

	echo "this is the anova_betas_tap function"
	cd ${ANOVA_dir}
	
#	if [ ! -e ${subcond1}.FUNC+tlrc.HEAD -a ! -e ${subcond2}.FUNC+tlrc.HEAD ]; then
#		echo "ANOVA has already been performed!"
#		echo ""
#	else

		if [ "${run}" = SP1 ] ;then
			echo "------------------------- ${run}: ${cond1} ${cond2} ------------------------"
			echo ""
			3dANOVA2 -type 3 -alevels 2 -blevels 14 \
			-dset 1 1 TS001.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 1 TS001.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 2 TS002.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 2 TS002.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 3 TS003.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 3 TS003.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 4 TS004.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 4 TS004.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 5 TS005.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 5 TS005.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 6 TS006.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 6 TS006.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 7 TS007.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 7 TS007.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 8 TS008.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 8 TS008.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 9 TS009.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 9 TS009.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 10 TS010.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 10 TS010.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 11 TS011.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 11 TS011.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 12 TS012.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 12 TS012.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 13 TS013.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 13 TS013.${runcond2}.FUNC+tlrc'[1]' \
			-dset 1 14 TS014.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 14 TS014.${runcond2}.FUNC+tlrc'[1]' \
			-amean 1 ${runmod}.mean.${cond1}.beta \
			-amean 2 ${runmod}.mean.${cond2}.beta \
			-acontr 1 -1 ${runmod}.contr.${cond1v2}.beta \
			-acontr -1 1 ${runmod}.contr.${cond2v1}.beta 
		else
			echo ------------------------- ${run}: ${cond1} ${cond2} -------------------------
			echo ------------------------- ${run}: ${cond3} ${cond4} -------------------------
			echo
			
			3dANOVA2 -type 3 -alevels 4 -blevels 13 \
			-dset 1 1 TS001.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 1 TS001.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 1 TS001.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 1 TS001.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 2 TS002.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 2 TS002.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 2 TS002.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 2 TS002.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 3 TS003.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 3 TS003.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 3 TS003.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 3 TS003.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 4 TS005.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 4 TS005.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 4 TS005.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 4 TS005.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 5 TS006.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 5 TS006.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 5 TS006.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 5 TS006.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 6 TS007.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 6 TS007.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 6 TS007.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 6 TS007.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 7 TS008.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 7 TS008.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 7 TS008.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 7 TS008.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 8 TS009.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 8 TS009.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 8 TS009.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 8 TS009.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 9 TS010.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 9 TS010.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 9 TS010.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 9 TS010.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 10 TS011.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 10 TS011.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 10 TS011.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 10 TS011.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 11 TS012.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 11 TS012.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 11 TS012.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 11 TS012.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 12 TS013.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 12 TS013.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 12 TS013.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 12 TS013.${runcond4}.FUNC+tlrc'[1]' \
			-dset 1 13 TS014.${runcond1}.FUNC+tlrc'[1]' \
			-dset 2 13 TS014.${runcond2}.FUNC+tlrc'[1]' \
			-dset 3 13 TS014.${runcond3}.FUNC+tlrc'[1]' \
			-dset 4 13 TS014.${runcond4}.FUNC+tlrc'[1]' \
			-amean 1 ${runmod}.mean.${cond1}.beta \
			-amean 2 ${runmod}.mean.${cond2}.beta \
			-amean 3 ${runmod}.mean.${cond3}.beta \
			-amean 4 ${runmod}.mean.${cond4}.beta \
			-acontr 1 -1 0 0 ${runmod}.contr.${cond1v2}.beta \
			-acontr -1 1 0 0 ${runmod}.contr.${cond2v1}.beta \
			-acontr 0 0 1 -1 ${runmod}.contr.${cond3v4}.beta \
			-acontr 0 0 -1 1 ${runmod}.contr.${cond4v3}.beta
		fi
		
			#---------------------------------------------------------------------------
			# Convert Output ANOVA data files to NIFTI -float types
			
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond1}.nii \
				${runmod}.mean.${cond1}.beta+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond2}.nii \
				${runmod}.mean.${cond2}.beta+tlrc 
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond3}.nii \
				${runmod}.mean.${cond3}.beta+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.mean.${cond4}.nii \
				${runmod}.mean.${cond4}.beta+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond1v2}.nii \
				${runmod}.contr.${cond1v2}.beta+tlrc 
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond2v1}.nii \
				${runmod}.contr.${cond2v1}.beta+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond3v4}.nii \
				${runmod}.contr.${cond3v4}.beta+tlrc
			3dAFNItoNIFTI -float -prefix ${runmod}.contr.${cond4v3}.nii \
				${runmod}.contr.${cond4v3}.beta+tlrc
		
			#---------------------------------------------------------------------------
			# Move the single subject files to the etc directory to keep the folder less 
			# cluttered
		
			mv TS0*.${runcond1}.FUNC+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond2}.FUNC+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond3}.FUNC+tlrc.* ${ANOVA_dir}/etc/
			mv TS0*.${runcond4}.FUNC+tlrc.* ${ANOVA_dir}/etc/
			
			#---------------------------------------------------------------------------
			# Move the Original ANOVA data files (of type short) to the etc/ dir to keep 
			# things less cluttered
		
			mv ${runmod}.mean.*+tlrc.* ${ANOVA_dir}/etc/Orig
			mv ${runmod}.contr.*+tlrc.* ${ANOVA_dir}/etc/Orig
#	fi	
}
