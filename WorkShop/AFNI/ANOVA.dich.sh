. $PROFILE/${1}_profile.sh
####################################################################################################
# 3dANOVA2 -type (k)=3  mixed efecDL model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor A - Semantic/Voice/Familiarity/Recollection
# 		(fixed, alevels) = (1) animal/male/old, (2) food/female/new, (3) null
# Factor B - SubjecDL (random, blevels) = (1) DL1, (2) DL2, (DL3), ...., (14) DL14
####################################################################################################
# Notes: DL7 has been removed from the analysis due to a problem with run 3 (TP1)
####################################################################################################
cd ${anova_dir}
####################################################################################################
if [ ! -e Fstat_${mod}_${alevel1}_${factorA}+tlrc.HEAD -a \
	! -e Fstat_${mod}_${alevel2}_${factorA}+tlrc.HEAD ]; then
####################################################################################################
echo "------------------------------------- ANOVA_tap.sh -------------------------------------"
echo "---------------------- ${run} ${mod} ${factorA} --------------------------"
echo ""
####################################################################################################
	3dANOVA2 -type 3 -alevels 2 -blevels 5 \
	-dset 1 1 DL4_${run}_${alevel1}_${mod}_peak+tlrc \
	-dset 2 1 DL4_${run}_${alevel2}_${mod}_peak+tlrc \
	-dset 1 2 DL5_${run}_${alevel1}_${mod}_peak+tlrc \
	-dset 2 2 DL5_${run}_${alevel2}_${mod}_peak+tlrc \
	-dset 1 3 DL5_${run}_${alevel1}_${mod}_peak+tlrc \
	-dset 2 3 DL6_${run}_${alevel2}_${mod}_peak+tlrc \
	-dset 1 4 DL7_${run}_${alevel1}_${mod}_peak+tlrc \
	-dset 2 4 DL7_${run}_${alevel2}_${mod}_peak+tlrc \
	-dset 1 4 DL8_${run}_${alevel1}_${mod}_peak+tlrc \
	-dset 2 4 DL8_${run}_${alevel2}_${mod}_peak+tlrc \
	-fa Fstat_${mod}_${alevel1}_${factorA} \
	-fa Fstat_${mod}_${alevel2}_${factorA} \
	-amean 1 mean_${run}_${mod}_${alevel1} \
	-amean 2 mean_${run}_${mod}_${alevel2} \
	-adiff 1 2 diff_${run}_${mod}_${alevel1}_vs_${alevel2} \
	-acontr 1 -1 contr_${run}_${mod}_${alevel1}_vs_${alevel2} \
	-acontr -1 1 contr_${run}_${mod}_${alevel2}_vs_${alevel1} \
	-acontr 1 0 base_${run}_${mod}_${alevel1} \
	-acontr 0 1 base_${run}_${mod}_${alevel2}
##################################################################################################
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
####################################################################################################
	cp DL*${run}_${alevel1}_${mod}_peak.nii ../Data
	cp DL*${run}_${alevel2}_${mod}_peak.nii ../Data
	rm DL*${run}_${alevel1}_${mod}_peak.nii
	rm DL*${run}_${alevel2}_${mod}_peak.nii
####################################################################################################
fi
