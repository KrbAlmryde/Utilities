#!/bin/sh
# Remove the first 4 trs to account for scanner equilibration. Identify and report outliers
# following tr removal.
# Graph outliers, save image to Jpeg

# =============================================== tcat =============================================
echo "3dTcat....."
echo "Removing first 4 trs from functional data"
		3dTcat -prefix ${name}_tcat.nii ${name}_epan.nii'[4..$]'
		3dToutcount ${name}_tcat.nii > ${name}_precount.txt
		1dplot -jpeg -one ${name}_precount.txt
# ===============================================  tshift ==========================================
echo "3dTshift....."
echo "Shift timeseries data back to zero"
echo "Graph results"

		3dTshift -tzero 0 -rlt+ -quintic -prefix ${name}_tshift.nii ${name}_tcat.nii #
		3dToutcount ${name}_tshift.nii > ${name}_postcount.txt #
		1dplot -jpeg -one ${name}_postcount.txt #

# =============================================== align ============================================
# align anatomy to EPI registration base
echo "Align..."
echo "Align anatomy to EPI registration base"

		align_epi_anat.py -anat2epi -anat ${anat}/${subj}_spgr.nii -epi ${name}_tshift.nii \
			-epi_base 0 -volreg off -tshift off
# I chose 0 as the base because that is the very first scan and subjects are more likely to hold
# still
# ===================================================== tlrc =======================================
# warp anatomy to standard space
echo "auto_tlrc...."
echo "warp anatomy to standard space"

		@auto_tlrc -base TT_N27+tlrc -input ${anat}/${subj}_spgr.nii -suffix NONE

# =================================================== volreg ===================================================
# align each dset to base volume, align to anat, warp to tlrc space
echo "3dVolreg....."
echo "align each dset to base volume, align to anat, warp to tlrc space"

# verify that we have a +tlrc warp dataset
if ( ! -f ${anat}/${subj}_spgr+tlrc.HEAD ) then
    echo "** missing +tlrc warp dataset: ${anat}/${subj}_spgr+tlrc.HEAD"
    exit
endif

# create an all-1 dataset to mask the extents of the warp
3dcalc -a ${name}_tshift.nii -expr 1 -prefix ${func}/rm.${subj}.epi.all1

# register and warp

# register each volume to the base
    3dvolreg -verbose -zpad 1 -base ${name}_tshift.nii"[${base}]" -1Dfile ${name}_dfile.txt \
    	-prefix ${func}/rm.${subj}.epi.volreg.${run} -cubic -1Dmatrix_save \
    	${name}.mat.vr.aff12.txt ${name}_tshift.nii

# catenate volreg, epi2anat and tlrc transformations
    cat_matvec -ONELINE ${anat}/${subj}_spgr+tlrc::WARP_DATA -I \
    	${anat}/${subj}_spgr_al_mat.aff12.txt -I \
        ${name}.mat.vr.aff12.txt > ${name}.mat.warp.aff12.txt

# =================================================== Allineate ====================================================
echo "3dAllineate"
# apply catenated xform : volreg, epi2anat and tlrc
    3dAllineate -base ${anat}/${subj}_spgr+tlrc -input ${name}_tshift.nii \
		-1Dmatrix_apply ${name}.mat.warp.aff12.txt -mast_dxyz 3.5 \
		-prefix ${func}/rm.${subj}.epi.nomask

# warp the all-1 dataset for extents masking
    3dAllineate -base ${anat}/${subj}_spgr+tlrc -input ${func}/rm.${subj}.epi.all1.nii \
    	-1Dmatrix_apply ${name}.mat.warp.aff12.txt -mast_dxyz 3.5 -final NN -quiet \
    	-prefix ${func}/rm.${subj}.epi.1.${run}

# make an extents intersection mask of this run
    3dTstat -min -prefix ${func}/rm.${subj}.epi.min.${run} ${func}/rm.${subj}.epi.1.${run}+tlrc


# make a single file of registration params
cat ${name}_dfile.txt > ${name}_dfile.rall.txt

# ----------------------------------------
# create the extents mask: mask_epi_extents+tlrc
# (this is a mask of voxels that have valid data at every TR)
# (only 1 run, so just use 3dcopy to keep naming straight)
3dcopy ${func}/rm.${subj}.epi.min.${run} mask_epi_extents

# and apply the extents mask to the EPI data
# (delete any time series with missing data)

    3dcalc -a ${func}/rm.${subj}.epi.nomask.${run}+tlrc -b mask_epi_extents+tlrc
		-expr 'a*b' -prefix ${name}_volreg.nii

# ==================================================== blur =====================================================
# blur each volume of each run
echo "Blur..."

    3dmerge -1blur_fwhm 5.0 -doall -prefix ${name}_blur ${name}_volreg+tlrc

# ===================================================== mask ====================================================
# create 'full_mask' dataset (union mask)
echo "masking"

    3dAutomask -dilate 1 -prefix ${func}/rm.${subj}.mask_${run} ${name}_blur+tlrc


# only 1 run, so copy this to full_mask
    3dcopy ${func}/rm.${subj}.mask_${run}+tlrc ${anat}_full_mask

# ---- create subject anatomy mask, mask_anat.${subj}+tlrc ----
#      (resampled from tlrc anat)
    3dresample -master ${anat}_full_mask+tlrc -prefix ${func}/rm.${subj}.resam.anat    \
           -input ${anat}/${subj}_spgr+tlrc

# convert resampled anat brain to binary mask
    3dcalc -a ${func}/rm.${subj}.resam.anat+tlrc -expr 'ispositive(a)' -prefix mask_anat.${subj}

# ---- create group anatomy mask, mask_group+tlrc ----
#      (resampled from tlrc base anat, TT_N27+tlrc)
    3dresample -master ${anat}_full_mask+tlrc -prefix ${func}/rm.${subj}.resam.group \
           -input TT_N27+tlrc

# convert resampled group brain to binary mask
    3dcalc -a ${func}/rm.${subj}.resam.group+tlrc -expr 'ispositive(a)' -prefix mask_group

# ===================================================== scale ===================================================
# scale each voxel time series to have a mean of 100
# (be sure no negatives creep in)
# (subject to a range of [0,200])
echo "scale"

    3dTstat -prefix ${func}/rm.${subj}.mean_${run} ${name}_blur+tlrc
    3dcalc -a ${name}_blur+tlrc -b ${func}/rm.${subj}.mean_${run}+tlrc -c mask_group+tlrc \
           -expr 'c * min(200, a/b*100)*step(a)*step(b)' -prefix ${name}_scale

# =================================================== regress ===================================================
# run the regression analysis
echo "Regress"

# create censor file motion_${subj}_censor.1D, for censoring motion
	1d_tool.py -infile ${name}_dfile.rall.txt -set_nruns 1 -set_tr 3.5 -show_censor_count \
		-censor_prev_TR -censor_motion 1 ${name}_motion