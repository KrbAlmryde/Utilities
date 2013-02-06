. $PROFILE/${1}_profile.sh
cd ${prep_dir}
####################################################################################################
	echo "------------------------------------- adwarp.sh -------------------------------------"
	echo "---------------------------------- ${submod} -------------------------------------"
	echo ""
####################################################################################################
# Check to see that the talairached spgr is in the $prep_dir, if not, change to the anat_dir and...
if [ ! -e ${spgr}.aligned+tlrc.HEAD ]; then
	cd ${anat_dir}
####################################################################################################
# ...check to see if has been warped to talairach space. If not, do so, then, the align to TT_N27...
	if [ ! -e ${spgr}.al+tlrc.HEAD -a ! -e ${spgr}.aligned+tlrc.HEAD  ]; then
		@auto_tlrc -no_ss -base TT_N27+tlrc -input ${spgr}.al+orig -suffix NONE

		align_epi_anat.py -dset1to2 -dset1 ${spgr}.al+tlrc -dset2 ${anova_dir}/TT_N27+tlrc \
			-suffix igned -cost lpa

	fi
####################################################################################################
# copy it to the prep_dir, then change to the prep_dir
	cp ${spgr}.aligned+tlrc.* ${prep_dir}
	cd ${prep_dir}
####################################################################################################
fi
####################################################################################################
# Warp peak IRF
if [ ! -e ${submod}.peak+tlrc.HEAD ]; then
	adwarp -apar ${spgr}.aligned+tlrc -dpar ${submod}.peak+orig
fi
####################################################################################################
# Warp Coef
# if [ ! -e ${submod}.Coef+tlrc.HEAD ]; then
# 	adwarp -apar ${spgr}.al+tlrc -dpar ${submod}.Coef.nii
# fi
# ####################################################################################################
# # Warp Tstat
# if [ ! -e ${submod}.Tstat+tlrc.HEAD ]; then
# 	adwarp -apar ${spgr}.al+tlrc -dpar ${submod}.Tstat.nii
# fi
# ####################################################################################################
# # Warp Fstat
# if [ ! -e ${submod}.Fstat+tlrc.HEAD ]; then
# 	adwarp -apar ${spgr}.al+tlrc -dpar ${submod}.Fstat.nii
# fi
# ####################################################################################################
# # Warp Full_Fstat
# if [ ! -e ${subrunmod}.Full_Fstat+tlrc.HEAD ]; then
# 	adwarp -apar ${spgr}.al+tlrc -dpar ${subrunmod}.Full_Fstat.nii
# fi
####################################################################################################
# Copy the peak IRF, Coef, Tstat, Fstat, and Full_Fstat files to the ANOVA directory.
	cp ${submod}.peak+tlrc.* $anova_dir
# 	cp ${submod}.Coef+tlrc.* $anova_dir
# 	cp ${submod}.Tstat+tlrc.* $anova_dir
# 	cp ${submod}.Fstat+tlrc.* $anova_dir
# 	cp ${subrunmod}.Full_Fstat+tlrc.* $anova_dir
####################################################################################################
# Then remove them from their home directory
	rm ${submod}.peak+tlrc.*
# 	rm ${submod}.Coef+tlrc.*
# 	rm ${submod}.Tstat+tlrc.*
# 	rm ${submod}.Fstat+tlrc.*
# 	rm ${subrunmod}.Full_Fstat+tlrc.*
####################################################################################################
# Then remove the standarized brain from the functional directory
rm ${spgr}.aligned+tlrc.*
####################################################################################################
echo ""
