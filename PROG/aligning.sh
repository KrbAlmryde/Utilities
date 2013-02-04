. $PROFILE/${1}_profile.sh
#---------------------------------------------------------------------------------------------------
								########### START OF MAIN ############
#---------------------------------------------------------------------------------------------------
# This is the aligning.sh program. Using AFNI programs such as align_epi_anat.py, @auto_tlrc, and
# 3drefit, this script aims to align functional data to standard space (Talairach). Next its
# applies the transformations made to the ${spgr}_aligned+tlrc to the Functional data using the
# adwarp command found in the AFNI program suite
#---------------------------------------------------------------------------------------------------

cd ${anat_dir}

#---------------------------------------------------------------------------------------------------
echo "-------------------------------- align_epi_anat.py ----------------------------------"
echo "--------------------------- ${spgr}+orig => ${fse}+orig ---------------------------"
echo "-------------------------------  ${spgr}_al+orig ----------------------------------- "
echo ""
#---------------------------------------------------------------------------------------------------
# Align the SPGR to the FSE with the assumption that the FSE is in all ways identical to the
# functional data. This way the SPGR will theoretically match the functional data in terms of
# orientation. Following the applicaton of align_epi_anat.py we need to perform 3drefit on the
# newly created ${spgr}_al+orig in order to reset talairach markers, as align_epi_anat.py removes
# them completely.

if [ ! -e ${spgr}_cmass+orig.HEAD ]; then

#	align_epi_anat.py -dset1to2 -dset1 ${spgr}+orig -dset2 ${fse}+orig -cost lpa
	align_epi_anat.py -dset1to2 -cmass cmass -dset1 ${spgr}+orig -dset2 ${fse}+orig \
		-cost lpa -suffix _cmass

	echo "-------------------------------- 3drefit ----------------------------------"

	3drefit -markers ${spgr}_al+orig
		rm __tt_${spgr}*
		rm __tt_${fse}*

	echo "Removing temporary files"

fi
#---------------------------------------------------------------------------------------------------
#echo "---------------------------- Jaccard Index and Distance ------------------------------"
#echo "--------------------------- ${spgr}+orig => ${fse}+orig ---------------------------"
#echo "-------------------------------  ${spgr}_al+orig ----------------------------------- "
#echo ""
#---------------------------------------------------------------------------------------------------
# This step

#3dAutomask -prefix mask.${spgr}_al.nii ${spgr}_al+orig
#3dAutomask -prefix mask.${spgr}_al.nii ${spgr}_al+orig




#---------------------------------------------------------------------------------------------------
echo "------------------------------------- @auto_tlrc -------------------------------------"
echo "------------------------- ${spgr}_al+orig * TT_N27+tlrc ---------------------------"
echo "-------------------------------  ${spgr}_al+tlrc ------------------------------------- "
echo ""
#---------------------------------------------------------------------------------------------------
# Check to see that the talairached spgr is in the $anat_dir, if not, warp it to talairach space.
# This will create a Talairached version of the Fse-aligned SPGR. If this step has already been
# completed the program will skip this step and move on to the next block.

if [ ! -e ${spgr}_cmass+tlrc.HEAD ]; then

	@auto_tlrc -no_ss -base TT_N27+tlrc -input ${spgr}_cmass+orig -suffix NONE

fi
#---------------------------------------------------------------------------------------------------
								########### START OF MAIN ############
#---------------------------------------------------------------------------------------------------
	echo "----------------------------------- adwarp -------------------------------------"
	echo "-------------------- ${spgr}_al+tlrc * ${submod}.stats+orig ----------------------"
	echo "------------------------------- ${submod}.stats+tlrc -----------------------------"
	echo ""
#---------------------------------------------------------------------------------------------------
# Warp the stats-bucket file to Talairach space

if [ ! -e ${submod}.stats+tlrc.HEAD ]; then

	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${glm_dir}/FUNC/${submod}.stats+orig
	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${glm_dir}/REML/${submod}.stats.REML+orig
fi

#---------------------------------------------------------------------------------------------------
# Warp the IRF files for condition 1 and condition 2 to Talairach space

cd ${glm_dir}/IRESP

if [ ! -e ${subcond1}.irf+tlrc.HEAD -o ! -e ${subcond2}.irf+tlrc.HEAD ]; then

	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${subcond1}.irf+orig
	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${subcond2}.irf+orig
	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${subcond3}.irf+orig
	adwarp -apar ${anat_dir}/${spgr}_cmass+tlrc -dpar ${subcond4}.irf+orig

fi

#---------------------------------------------------------------------------------------------------
echo ""
