. $UTL/${1}_profile

cd ${anat_dir}
############################################## auto_tlrc ###########################################
#
# warp anatomy to standard space

echo "auto_tlrc...."
echo "warp anatomy to standard space"
echo "Then move to ${func_dir}"
echo ""

@auto_tlrc -base TT_N27+tlrc -input ${spgr}+orig -suffix NONE

mv ${spgr}+tlrc.* ${func_dir}
####################################################################################################
#
# Change directories functional directory
#

cd ${func_dir}
############################################## tcat ################################################
#
# Remove the first 4 trs to account for scanner equilibration. Identify and report outliers
# following tr removal.
# Graph outliers, save image to Jpeg

echo "3dTcat....."
echo "Removing first 4 trs from functional data"
echo ""

3dTcat -prefix ${runnm}_tcat+orig ${runnm}_epan+orig'[4..$]'
3dToutcount ${runnm}_tcat+orig > ${runnm}_precount.txt
1dplot -jpeg -one ${runnm}_precount.txt
############################################## tshift ##############################################
#
#

echo "3dTshift....."
echo "Shift timeseries data back to zero"
echo "Graph results"
echo ""

3dTshift -tzero 0 -rlt+ -quintic -prefix ${runnm}_tshift+orig ${runnm}_tcat+orig
3dToutcount ${runnm}_tshift+orig > ${runnm}_postcount.txt
1dplot -jpeg -one ${runnm}_postcount.txt
############################################### align ##############################################
#
# I chose 0 as the base because that is the very first scan and subjects are more likely to hold
# still
#

echo "build spgr dataset"

to3d -spgr -prefix ${spgr} -xFOV ${anatfov}A-P -yFOV ${anatfov}S-I -zSLAB \
	${zspgr}${z1spgr}-${zspgr}${z2spgr} e*7i*

echo "Align..."
echo "Align anatomy to EPI registration base"
echo ""

align_epi_anat.py -anat2epi -anat ${anat_dir}/${spgr}+orig -epi ${runnm}_tshift+orig -epi_base 0 \
	-volreg off -tshift off
#================================================== volreg =======================================
echo "3dVolreg....."
echo "align each dset to base volume, align to anat, warp to tlrc space"
echo ""

####################################################################################################
#
# verify that we have a +tlrc warp dataset in the functional directory

if [ ! -e ${spgr}+tlrc.HEAD ]; then
		echo "** missing +tlrc warp dataset: ${spgr}+tlrc.HEAD"
		exit
fi
####################################################################################################
#
#

echo ""
echo " create an all-1 dataset to mask the extents of the warp"

3dcalc -a ${runnm}_tshift+orig -expr 1 -prefix rm.${runnm}.epi.all1
####################################################################################################
#
# register each volume to the base

echo ""
echo "register each volume to the base"

3dvolreg -verbose -zpad 1 -base ${runnm}_tshift+orig"[${base}]" -1Dfile ${runnm}_dfile.txt \
	-prefix rm.${runnm}.epi.volreg.${run} -cubic -1Dmatrix_save \
	${runnm}.mat.vr.aff12.txt ${runnm}_tshift+orig
####################################################################################################
#
# catenate volreg, epi2anat and tlrc transformations

cat_matvec -ONELINE ${anat_dir}/${spgr}+tlrc::WARP_DATA -I ${anat_dir}/${spgr}_al_mat.aff12.txt \
	-I ${runnm}.mat.vr.aff12.txt > ${runnm}.mat.warp.aff12.txt
####################################################################################################
#
# Run 3dAllineate protocol

echo "3dAllineate..."
echo "apply catenated xform : volreg, epi2anat and tlrc"
echo ""

3dAllineate -base ${anat_dir}/${spgr}+tlrc -input ${runnm}_tshift+orig -1Dmatrix_apply \
	${runnm}.mat.warp.aff12.txt -mast_dxyz ${tr} -prefix rm.${runnm}.epi.nomask

# warp the all-1 dataset for extents masking
3dAllineate -base ${anat_dir}/${spgr}+tlrc -input rm.${runnm}.epi.all1+orig \
	-1Dmatrix_apply ${runnm}.mat.warp.aff12.txt -mast_dxyz 3.5 -final NN -quiet \
	-prefix rm.${runnm}.epi.1.${run}

# make an extents intersection mask of this run
3dTstat -min -prefix rm.${runnm}.epi.min.${run} rm.${runnm}.epi.1.${run}+tlrc


# make a single file of registration params
cat ${runnm}_dfile.txt > ${runnm}_dfile.rall.txt

# ----------------------------------------
# create the extents mask: mask_epi_extents+tlrc
# (this is a mask of voxels that have valid data at every TR)
# (only 1 run, so just use 3dcopy to keep naming straight)
3dcopy rm.${runnm}.epi.min.${run} mask_epi_extents

# and apply the extents mask to the EPI data
# (delete any time series with missing data)

3dcalc -a rm.${runnm}.epi.nomask.${run}+tlrc -b mask_epi_extents+tlrc \
	-expr 'a*b' -prefix ${runnm}_volreg+orig

# ==================================================== blur =====================================================
echo "Blur..."
echo "blur each volume of each run"
echo ""

3dmerge -1blur_fwhm 5.0 -doall -prefix ${runnm}_blur ${runnm}_volreg+tlrc

# ===================================================== mask ====================================================
echo "Masking"
echo "create 'full_mask' dataset (union mask)"
echo ""

3dAutomask -dilate 1 -prefix rm.${runnm}.mask_${run} ${runnm}_blur+tlrc


# only 1 run, so copy this to full_mask
3dcopy rm.${runnm}.mask_${run}+tlrc ${runnm}_full_mask

# ---- create subject anatomy mask,  ${runnm}_mask_anat.+tlrc ----
#			(resampled from tlrc anat)
3dresample -master ${runnm}_full_mask+tlrc -prefix rm.${runnm}.resam.anat -input ${anat_dir}/${spgr}+tlrc

# convert resampled anat brain to binary mask
3dcalc -a rm.${runnm}.resam.anat+tlrc -expr 'ispositive(a)' -prefix ${spgr}_${run}_mask_anat

# ---- create group anatomy mask, ${runnm}_mask_group+tlrc ----
#			(resampled from tlrc base anat, TT_N27+tlrc)
3dresample -master ${runnm}_full_mask+tlrc -prefix rm.${runnm}.resam.group 	-input TT_N27+tlrc

# convert resampled group brain to binary mask
3dcalc -a rm.${runnm}.resam.group+tlrc -expr 'ispositive(a)' -prefix ${runnm}_mask_group

# ===================================================== scale ===================================================
echo "Scale..."
echo "scale each voxel time series to have a mean of 100"
echo ""

# (be sure no negatives creep in)
# (subject to a range of [0,200])

3dTstat -prefix rm.${runnm}.mean_${run} ${runnm}_blur+tlrc

3dcalc -a ${runnm}_blur+tlrc -b rm.${runnm}.mean_${run}+tlrc -c ${runnm}_mask_group+tlrc \
	-expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix ${runnm}_scale

# =================================================== regress ===================================================
echo "Regress..."
echo "run the regression analysis"
echo "create censor file motion_${subj}_censor.1D, for censoring motion"
echo ""

1d_tool.py -infile ${runnm}_dfile.rall.txt -set_nruns 1 -set_tr ${tr} -show_censor_count \
	-censor_prev_TR -censor_motion 1 ${runnm}_motion
