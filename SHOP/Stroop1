#!/usr/bin/env tcsh
#This script was written by Kyle Almryde, University of Arizona, 6/19/2011
# execute via : tcsh -x S#-run-script |& tee output.S#-run-script
# --------------------------------------------------
# Script setup

echo "${STROOP}"

foreach run (voice word)
	set subj = S46
	set base = 78
	set stim = ${STROOP}/Utilities
	set anat = ${STROOP}/${subj}/Struct/spgr
	set results = ${STROOP}/${subj}/${subj}_results
	set func = ${STROOP}/${subj}/run*_${run}/${subj}_${run}_epan

	mkdir $results
	cd $results
#-------------------------------------------------------
echo "apply 3dTcat to copy input dsets to results dir, while removing the first 4 TRs"

	3dTcat -prefix ${subj}_${run}_tcat $func/${subj}_${run}_epan+orig'[4..$]'

#-------------------------------------------------------
echo "run 3dToutcount on Tcat BRIK/HEAD files, then plot"

	3dToutcount ${subj}_${run}_tcat+orig > precount_${subj}_${run}.1D

	1dplot -one precount_${subj}_${run}.1D

#-------------------------------------------------------
echo "run 3dTshift and 3dToutcount for Tshift BRIK/HEAD File, then plot"

	3dTshift -tzero 0 -rlt+ -quintic -prefix ${subj}_${run}_tshift ${subj}_${run}_clean_tcat+orig

	3dToutcount ${subj}_${run}_tshift+orig > postcount_${subj}_${run}.1D

	1dplot -one postcount_${subj}_${run}.1D

#-------------------------------------------------------
echo "align each dset to the base volume"

	3dvolreg -verbose -zpad 1 -base ${subj}_${run}_tshift+orig"[${base}]"  \
    	-1Dfile dfile_${subj}_${run}_1D -prefix ${subj}_${run}_volreg  \
        -cubic ${subj}_${run}_tshift+orig

	1dplot -jpeg -sep -ynames roll pitch yaw dS dL dP -xlabel TIME volreg_${subj}_${run}_1D

#-------------------------------------------------------
echo "blur each volume"

    3dmerge -1blur_fwhm 6.0 -doall -prefix ${subj}_${run}_blur ${subj}_${run}_volreg+orig

#-------------------------------------------------------
echo "create 'full_mask' dataset (union mask)"

	3dAutomask -prefix ${subj}_${run}_automask ${subj}_${run}_blur+orig

#-------------------------------------------------------
echo "scale each voxel time series to have a mean of 100 (subject to maximum value of 200)"

	3dTstat -prefix ${subj}_${run}_mean ${subj}_${run}_blur+orig

	3dcalc -a ${subj}_${run}_blur+orig -b ${subj}_${run}_mean+orig  \
		-c ${subj}_${run}_automask+orig -expr 'c * min(200, a/b*100)' -prefix ${subj}_${run}_norm

#-------------------------------------------------------
echo "Perform 3dToutcount on Nomralized data BRIK/HEAD files, then plot"
	3dToutcount ${subj}_${run}_norm+orig > Normalized_${subj}_${run}.1D

	1dplot -one Normalized_${subj}_${run}.1D

#-------------------------------------------------------
#run the regression analysis
echo "Deconvolution!"

	3dDeconvolve -input ${subj}_${run}_norm+orig.HEAD   \
		-polort 5                                        \
		-mask ${subj}_${run}_automask+orig -num_stimts 	\
		-local_times \
		-stim_times 1 $stim/${run}_congruent.txt 'GAM' -stim_label 1 ${subj}_${run}_congruent  	\
		-stim_times 2 $stim/${run}_incongruent.txt 'GAM' -stim_label 2 ${subj}_${run}_incongruent \
		-stim_times 3 $stim/${run}_neutral.txt 'GAM' -stim_label 3 ${subj}_${run}_neutral      \
		-stim_times 4 $stim/${run}_null.txt 'GAM' -stim_label 4 ${subj}_${run}_null      \
		-stim_file 5 dfile_${subj}_${run}_1D'[0]' -stim_base 5 -stim_label 5 roll    \
		-stim_file 6 dfile_${subj}_${run}_1D'[1]' -stim_base 6 -stim_label 6 pitch   \
		-stim_file 7 dfile_${subj}_${run}_1D'[2]' -stim_base 7 -stim_label 7 yaw  \
		-stim_file 8 dfile_${subj}_${run}_1D'[3]' -stim_base 8 -stim_label 8 dS   \
		-stim_file 9 dfile_${subj}_${run}_1D'[4]' -stim_base 9 -stim_label 9 dL   \
		-stim_file 10 dfile_${subj}_${run}_1D'[5]' -stim_base 10 -stim_label 10 dP   \
		-iresp 1 ${subj}_${run}_congruent_irf \
		-iresp 2 ${subj}_${run}_incongruent_irf \
		-iresp 3 ${subj}_${run}_neutral_irf \
		-iresp 4 ${subj}_${run}_null_irf \
		-tout -x1D X_matrix.1D -xjpeg X_matrix.jpg                            \
		-bucket ${subj}_${run}_stats

#-------------------------------------------------------
# Extract sub-brick data information
echo "Extracting sub-bricked data from bucket files"

3dbucket -prefix ${subj}_${run}_${stim}_peak_irf -fbuc ${subj}_${run}_${stim}_norm_irf+orig'[8]'

	end
