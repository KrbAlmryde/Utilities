. $PROFILE/${1}_profile.sh
cd ${run_dir}
####################################################################################################
#
# This is a prep script designed to perform to3d on functional Pfiles and anatomical e-files in
# order to create epan, spgr, and fse files respectively
####################################################################################################
#
# Source the experiment profile and enter functional data directory
#
#
# echo "3dAFNItoNIFTI ${runnm}_epan.nii ${runnm}_epan+orig"
#
# if [ ! -e ${runnm}_epan.nii ]; then
#
# 	3dAFNItoNIFTI -prefix ${runnm}_epan.nii ${runnm}_epan+orig.BRIK
# fi
#
# cp ${runnm}_epan.nii $fsl_dir
# rm ${runnm}_epan.nii
# ####################################################################################################
# cd ${anat_dir}
#
# if [ ! -e ${spgr}_al.nii ]; then
# 	3dAFNItoNIFTI -prefix ${spgr}_al.nii ${spgr}_al+orig.BRIK
# fi
#
# cp ${spgr}_al.nii $fsl_dir
# rm ${spgr}_al.nii

####################################################################################################
3dAFNItoNIFTI -float -prefix ${submod}_irf+orig
3dAFNItoNIFTI -float -prefix ${subrunmod}_fitts
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix
3dAFNItoNIFTI -float -prefix


cd ${anova_dir}
3dAFNItoNIFTI -float -prefix diff_${run}_${mod}_${alevel1}_vs_${alevel2}.nii diff_${run}_${mod}_${alevel1}_vs_${alevel2}+tlrc
3dAFNItoNIFTI -float -prefix diff_${run}_${mod}_${alevel1}_vs_${alevel2}.nii diff_${run}_${mod}_${alevel1}_vs_${alevel2}+tlrc
3dAFNItoNIFTI -float -prefix contr_${run}_${mod}_${alevel2}_vs_${alevel1}.nii contr_${run}_${mod}_${alevel2}_vs_${alevel1}+tlrc
3dAFNItoNIFTI -float -prefix Fstat_${mod}_${alevel1}_${factorA}.nii Fstat_${mod}_${alevel1}_${factorA}+tlrc
3dAFNItoNIFTI -float -prefix Fstat_${mod}_${alevel2}_${factorA}.nii Fstat_${mod}_${alevel2}_${factorA}+tlrc
3dAFNItoNIFTI -float -prefix mean_${run}_${mod}_${alevel1}.nii mean_${run}_${mod}_${alevel1}+tlrc
3dAFNItoNIFTI -float -prefix mean_${run}_${mod}_${alevel2}.nii mean_${run}_${mod}_${alevel2}+tlrc
3dAFNItoNIFTI -float -prefix base_${run}_${mod}_${alevel1}.nii base_${run}_${mod}_${alevel1}+tlrc
3dAFNItoNIFTI -float -prefix base_${run}_${mod}_${alevel2}.nii base_${run}_${mod}_${alevel2}+tlrc


	3dAFNItoNIFTI -float -prefix Fstat_${mod}_${alevel1}_${factorA}.nii \
		Fstat_${mod}_${alevel1}_${factorA}+tlrc

	3dAFNItoNIFTI -float -prefix Fstat_${mod}_${alevel2}_${factorA}.nii \
		Fstat_${mod}_${alevel2}_${factorA}+tlrc

	3dAFNItoNIFTI -float -prefix mean_${run}_${mod}_${alevel1}.nii mean_${run}_${mod}_${alevel1}+tlrc
	3dAFNItoNIFTI -float -prefix mean_${run}_${mod}_${alevel2}.nii mean_${run}_${mod}_${alevel2}+tlrc

	3dAFNItoNIFTI -float -prefix diff_${run}_${mod}_${alevel1}_vs_${alevel2}.nii \
		diff_${run}_${mod}_${alevel1}_vs_${alevel2}+tlrc

	3dAFNItoNIFTI -float -prefix diff_${run}_${mod}_${alevel1}_vs_${alevel2}.nii \
		diff_${run}_${mod}_${alevel1}_vs_${alevel2}+tlrc

	3dAFNItoNIFTI -float -prefix contr_${run}_${mod}_${alevel2}_vs_${alevel1}.nii \
		contr_${run}_${mod}_${alevel2}_vs_${alevel1}+tlrc

	3dAFNItoNIFTI -float -prefix base_${run}_${mod}_${alevel1}.nii base_${run}_${mod}_${alevel1}+tlrc
	3dAFNItoNIFTI -float -prefix base_${run}_${mod}_${alevel2}.nii base_${run}_${mod}_${alevel2}+tlrc
