. $PROFILE/${1}_profile.sh
cd $TAP/GLM
################################################################################
sub=(`cat $LST/lst_subj_${1}.txt`)
run=(`cat $LST/lst_run_${1}.txt`)

subl=${#sub[@]}
runl=${#run[@]}



#for (( i = 0; i < ${subl}; i++ )); do
#	for (( j = 0; j < ${runl}; j++ )); do
		
#		echo "${sub[${i}]} ${run[${j}]}"
#		3dcopy $TAP/${sub[${i}]}/Prep/${sub[${i}]}.${run[${j}]}.automask.nii \
#			${sub[${i}]}.${run[${j}]}.automask+orig
			
#		adwarp -apar $TAP/${sub[${i}]}/Struc/${sub[${i}]}.spgr_cmass+tlrc \
#			-dpar ${sub[${i}]}.${run[${j}]}.automask+orig
		
#	done
#done





for (( j = 0; j < ${runl}; j++ )); do
	
	echo "run = ${run[${j}]}"
	
	3dMean \
		-mask_inter \
		-prefix ${run[${j}]}.3dmeanMask.${1}.inter.tlrc.nii \
		TS001.${run[${j}]}.automask+tlrc \
		TS002.${run[${j}]}.automask+tlrc \
		TS003.${run[${j}]}.automask+tlrc \
		TS004.${run[${j}]}.automask+tlrc \
		TS005.${run[${j}]}.automask+tlrc \
		TS006.${run[${j}]}.automask+tlrc \
		TS007.${run[${j}]}.automask+tlrc \
		TS008.${run[${j}]}.automask+tlrc \
		TS009.${run[${j}]}.automask+tlrc \
		TS010.${run[${j}]}.automask+tlrc \
		TS011.${run[${j}]}.automask+tlrc \
		TS012.${run[${j}]}.automask+tlrc \
		TS013.${run[${j}]}.automask+tlrc \
		TS014.${run[${j}]}.automask+tlrc
		
	3dMean \
		-mask_union \
		-prefix ${run[${j}]}.3dmeanMask.${1}.union.tlrc.nii \
		TS001.${run[${j}]}.automask+tlrc \
		TS002.${run[${j}]}.automask+tlrc \
		TS003.${run[${j}]}.automask+tlrc \
		TS004.${run[${j}]}.automask+tlrc \
		TS005.${run[${j}]}.automask+tlrc \
		TS006.${run[${j}]}.automask+tlrc \
		TS007.${run[${j}]}.automask+tlrc \
		TS008.${run[${j}]}.automask+tlrc \
		TS009.${run[${j}]}.automask+tlrc \
		TS010.${run[${j}]}.automask+tlrc \
		TS011.${run[${j}]}.automask+tlrc \
		TS012.${run[${j}]}.automask+tlrc \
		TS013.${run[${j}]}.automask+tlrc \
		TS014.${run[${j}]}.automask+tlrc

	3dMean \
		-prefix ${run[${j}]}.3dmeanMask.${1}.tlrc.nii \
		TS001.${run[${j}]}.automask+tlrc \
		TS002.${run[${j}]}.automask+tlrc \
		TS003.${run[${j}]}.automask+tlrc \
		TS004.${run[${j}]}.automask+tlrc \
		TS005.${run[${j}]}.automask+tlrc \
		TS006.${run[${j}]}.automask+tlrc \
		TS007.${run[${j}]}.automask+tlrc \
		TS008.${run[${j}]}.automask+tlrc \
		TS009.${run[${j}]}.automask+tlrc \
		TS010.${run[${j}]}.automask+tlrc \
		TS011.${run[${j}]}.automask+tlrc \
		TS012.${run[${j}]}.automask+tlrc \
		TS013.${run[${j}]}.automask+tlrc \
		TS014.${run[${j}]}.automask+tlrc

	
#	3dcalc \
#		-prefix ${run[${j}]}.3dcalcMask.${1}.tlrc.nii \
#		-a TS001.${run[${j}]}.automask+tlrc \
#		-b TS002.${run[${j}]}.automask+tlrc \
#		-c TS003.${run[${j}]}.automask+tlrc \
#		-d TS004.${run[${j}]}.automask+tlrc \
#		-e TS005.${run[${j}]}.automask+tlrc \
#		-f TS006.${run[${j}]}.automask+tlrc \
#		-g TS007.${run[${j}]}.automask+tlrc \
#		-h TS008.${run[${j}]}.automask+tlrc \
#		-i TS009.${run[${j}]}.automask+tlrc \
#		-j TS010.${run[${j}]}.automask+tlrc \
#		-k TS011.${run[${j}]}.automask+tlrc \
#		-l TS012.${run[${j}]}.automask+tlrc \
#		-m TS013.${run[${j}]}.automask+tlrc \
#		-n TS014.${run[${j}]}.automask+tlrc \
#		-expr '(a+b+c+d+e+f+g+h+i+j+k+l+m+n)/14'
	
#	3dmerge \
#		-gmean \
#		-prefix ${run[${j}]}.3dmergeMask.${1}.tlrc.nii \
#		TS001.${run[${j}]}.automask+tlrc \
#		TS002.${run[${j}]}.automask+tlrc \
#		TS003.${run[${j}]}.automask+tlrc \
#		TS004.${run[${j}]}.automask+tlrc \
#		TS005.${run[${j}]}.automask+tlrc \
#		TS006.${run[${j}]}.automask+tlrc \
#		TS007.${run[${j}]}.automask+tlrc \
#		TS008.${run[${j}]}.automask+tlrc \
#		TS009.${run[${j}]}.automask+tlrc \
#		TS010.${run[${j}]}.automask+tlrc \
#		TS011.${run[${j}]}.automask+tlrc \
#		TS012.${run[${j}]}.automask+tlrc \
#		TS013.${run[${j}]}.automask+tlrc \
#		TS014.${run[${j}]}.automask+tlrc
		
		
	3dMean \
		-mask_inter \
		-prefix ${run[${j}]}.3dmeanMask.${1}.inter.nii \
		$TAP/TS001/Prep/TS001.${run[${j}]}.automask.nii \
		$TAP/TS002/Prep/TS002.${run[${j}]}.automask.nii \
		$TAP/TS003/Prep/TS003.${run[${j}]}.automask.nii \
		$TAP/TS004/Prep/TS004.${run[${j}]}.automask.nii \
		$TAP/TS005/Prep/TS005.${run[${j}]}.automask.nii \
		$TAP/TS006/Prep/TS006.${run[${j}]}.automask.nii \
		$TAP/TS007/Prep/TS007.${run[${j}]}.automask.nii \
		$TAP/TS008/Prep/TS008.${run[${j}]}.automask.nii \
		$TAP/TS009/Prep/TS009.${run[${j}]}.automask.nii \
		$TAP/TS010/Prep/TS010.${run[${j}]}.automask.nii \
		$TAP/TS011/Prep/TS011.${run[${j}]}.automask.nii \
		$TAP/TS012/Prep/TS012.${run[${j}]}.automask.nii \
		$TAP/TS013/Prep/TS013.${run[${j}]}.automask.nii \
		$TAP/TS014/Prep/TS014.${run[${j}]}.automask.nii \

	3dMean \
		-mask_union \
		-prefix ${run[${j}]}.3dmeanMask.${1}.union.nii \
		$TAP/TS001/Prep/TS001.${run[${j}]}.automask.nii \
		$TAP/TS002/Prep/TS002.${run[${j}]}.automask.nii \
		$TAP/TS003/Prep/TS003.${run[${j}]}.automask.nii \
		$TAP/TS004/Prep/TS004.${run[${j}]}.automask.nii \
		$TAP/TS005/Prep/TS005.${run[${j}]}.automask.nii \
		$TAP/TS006/Prep/TS006.${run[${j}]}.automask.nii \
		$TAP/TS007/Prep/TS007.${run[${j}]}.automask.nii \
		$TAP/TS008/Prep/TS008.${run[${j}]}.automask.nii \
		$TAP/TS009/Prep/TS009.${run[${j}]}.automask.nii \
		$TAP/TS010/Prep/TS010.${run[${j}]}.automask.nii \
		$TAP/TS011/Prep/TS011.${run[${j}]}.automask.nii \
		$TAP/TS012/Prep/TS012.${run[${j}]}.automask.nii \
		$TAP/TS013/Prep/TS013.${run[${j}]}.automask.nii \
		$TAP/TS014/Prep/TS014.${run[${j}]}.automask.nii \
	
	3dMean \
		-prefix ${run[${j}]}.3dmeanMask.${1}.nii \
		$TAP/TS001/Prep/TS001.${run[${j}]}.automask.nii \
		$TAP/TS002/Prep/TS002.${run[${j}]}.automask.nii \
		$TAP/TS003/Prep/TS003.${run[${j}]}.automask.nii \
		$TAP/TS004/Prep/TS004.${run[${j}]}.automask.nii \
		$TAP/TS005/Prep/TS005.${run[${j}]}.automask.nii \
		$TAP/TS006/Prep/TS006.${run[${j}]}.automask.nii \
		$TAP/TS007/Prep/TS007.${run[${j}]}.automask.nii \
		$TAP/TS008/Prep/TS008.${run[${j}]}.automask.nii \
		$TAP/TS009/Prep/TS009.${run[${j}]}.automask.nii \
		$TAP/TS010/Prep/TS010.${run[${j}]}.automask.nii \
		$TAP/TS011/Prep/TS011.${run[${j}]}.automask.nii \
		$TAP/TS012/Prep/TS012.${run[${j}]}.automask.nii \
		$TAP/TS013/Prep/TS013.${run[${j}]}.automask.nii \
		$TAP/TS014/Prep/TS014.${run[${j}]}.automask.nii \


done


	3dcalc \
		-prefix ${run[${j}]}.3dcalcMask.${1}.tlrc.nii \
		-a $TAP/TS001/Prep/TS001.${run[${j}]}.automask+tlrc \
		-b $TAP/TS002/Prep/TS002.${run[${j}]}.automask+tlrc \
		-c $TAP/TS003/Prep/TS003.${run[${j}]}.automask+tlrc \
		-d $TAP/TS004/Prep/TS004.${run[${j}]}.automask+tlrc \
		-e $TAP/TS005/Prep/TS005.${run[${j}]}.automask+tlrc \
		-f $TAP/TS006/Prep/TS006.${run[${j}]}.automask+tlrc \
		-g $TAP/TS007/Prep/TS007.${run[${j}]}.automask+tlrc \
		-h $TAP/TS008/Prep/TS008.${run[${j}]}.automask+tlrc \
		-i $TAP/TS009/Prep/TS009.${run[${j}]}.automask+tlrc \
		-j $TAP/TS010/Prep/TS010.${run[${j}]}.automask+tlrc \
		-k $TAP/TS011/Prep/TS011.${run[${j}]}.automask+tlrc \
		-l $TAP/TS012/Prep/TS012.${run[${j}]}.automask+tlrc \
		-m $TAP/TS013/Prep/TS013.${run[${j}]}.automask+tlrc \
		-n $TAP/TS014/Prep/TS014.${run[${j}]}.automask+tlrc \
		-expr '(a+b+c+d+e+f+g+h+i+j+k+l+m+n)/14'
	
	3dmerge \
		-gmean \
		-prefix ${run[${j}]}.3dmergeMask.${1}.tlrc.nii \
		$TAP/TS001/Prep/TS001.${run[${j}]}.automask+tlrc \
		$TAP/TS002/Prep/TS002.${run[${j}]}.automask+tlrc \
		$TAP/TS003/Prep/TS003.${run[${j}]}.automask+tlrc \
		$TAP/TS004/Prep/TS004.${run[${j}]}.automask+tlrc \
		$TAP/TS005/Prep/TS005.${run[${j}]}.automask+tlrc \
		$TAP/TS006/Prep/TS006.${run[${j}]}.automask+tlrc \
		$TAP/TS007/Prep/TS007.${run[${j}]}.automask+tlrc \
		$TAP/TS008/Prep/TS008.${run[${j}]}.automask+tlrc \
		$TAP/TS009/Prep/TS009.${run[${j}]}.automask+tlrc \
		$TAP/TS010/Prep/TS010.${run[${j}]}.automask+tlrc \
		$TAP/TS011/Prep/TS011.${run[${j}]}.automask+tlrc \
		$TAP/TS012/Prep/TS012.${run[${j}]}.automask+tlrc \
		$TAP/TS013/Prep/TS013.${run[${j}]}.automask+tlrc \
		$TAP/TS014/Prep/TS014.${run[${j}]}.automask+tlrc

