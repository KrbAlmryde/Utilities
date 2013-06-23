. $UTL/${1}_profile
cd ${run_dir}
####################################################################################################
# Check to see that the talairached spgr is in the $run_dir, if not, change to the anat_dir and...
#
if [ ! -e ${spgr}_al+tlrc.HEAD ]; then
	cd ${anat_dir}
####################################################################################################
	echo "------------------------------------- adwarp.sh -------------------------------------"
	echo "---------------------------------- ${subbrik} -------------------------------------"
	echo ""
####################################################################################################
# ...check to see if has been warped to talairach space. If not, do so, then...

	if [ ! -e ${spgr}_al+tlrc.HEAD ]; then
		@auto_tlrc -no_ss -base TT_N27+tlrc -input ${spgr}_al+orig -suffix NONE
	fi
####################################################################################################
# copy it to the run_dir, then change to the run_dir

	cp ${spgr}_al+tlrc.* ${run_dir}
	cd ${run_dir}
fi
####################################################################################################
# Warp peak IRF, Coef, Tstat, Fstat, and Full_Fstat files.
if [ ! -e ${submod}_peak+tlrc.HEAD ]; then
	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond}peak_irf+orig
fi

if [ ! -e ${subcond}_Coef+orig+tlrc.HEAD ]; then
	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond}_Coef+orig
fi

if [ ! -e ${subcond}_Tstat+tlrc.HEAD ]; then
	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond}_Tstat+orig
fi

if [ ! -e ${subcond}_Fstat+tlrc.HEAD ]; then
	adwarp -apar ${spgr}_al+tlrc -dpar ${subcond}_Fstat+orig
fi

if [ ! -e ${submod}_Full_Fstat+tlrc.HEAD ]; then
	adwarp -apar ${spgr}_al+tlrc -dpar ${submod}_Full_Fstat+orig
fi
####################################################################################################
# Copy the peak IRF, Coef, Tstat, Fstat, and Full_Fstat files to the ANOVA directory.
	cp ${submod}_peak+tlrc.* $anova_dir
	cp ${subcond}_Coef+tlrc.* $anova_dir
	cp ${subcond}_Tstat+tlrc.* $anova_dir
	cp ${subcond}_Fstat+tlrc.* $anova_dir
	cp ${submod}_Full_Fstat+tlrc.* $anova_dir
####################################################################################################
# Then remove them from their home directory
	rm ${submod}_peak+tlrc.*
	rm ${subcond}_Coef+tlrc.*
	rm ${subcond}_Tstat+tlrc.*
	rm ${subcond}_Fstat+tlrc.*
	rm ${submod}_Full_Fstat+tlrc.*
####################################################################################################
# Then remove the standarized brain from the functional directory
rm ${spgr}_al+tlrc.*

echo ""
