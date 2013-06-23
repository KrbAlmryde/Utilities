. $UTL/${1}_profile.sh
cd ${run_dir}
####################################################################################################
echo "------------------------------------- adwarp_tap.sh -------------------------------------"
echo "---------------------------------- ${subbrik} -------------------------------------"
echo ""
####################################################################################################
# Check to see that the talairached spgr is in the $run_dir, if not, change to the anat_dir and...
#
if [ ! -e ${spgr}_al+tlrc.HEAD ]; then
	cd ${anat_dir}
####################################################################################################
# ...check to see if has been warped to talairach space. If not, do so, then...
#
	if [ ! -e ${spgr}_al+tlrc.HEAD ]; then
		@auto_tlrc -base TT_N27+tlrc -input ${spgr}_al+orig -suffix NONE
	fi
####################################################################################################
# copy it to the run_dir, then change to the run_dir

	cp ${spgr}_al+tlrc.* ${run_dir}
	cd ${run_dir}
fi
####################################################################################################
#
if [ "${run}" = "TP" -o "${run}" = "TV" ]; then
	for cond in $cond1 $cond2 $cond3 $cond4; do
	adwarp -apar ${spgr}_al+tlrc -dpar ${subbrik}peak_irf+orig
else
	for cond in $cond1 $cond2 $cond3; do
	adwarp -apar ${spgr}_al+tlrc -dpar ${subbrik}peak_irf+orig
####################################################################################################
	cp ${subbrik}peak_irf+tlrc.* $anova_dir
	rm ${subbrik}peak_irf+tlrc.*
done
####################################################################################################
rm ${spgr}_al+tlrc.*
echo ""
