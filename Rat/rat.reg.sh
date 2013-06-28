#!/bin/bash



to3d-fse \
	-prefix rat.fse.nii \
	-xSLAB 12.750L-R \
	-ySLAB 12.750S-I \
	-zSLAB 10.50P-A \
	MRIm*

to3d -epan \
	-prefix ${subj}.${run}.epan.nii \
	-text_outliers \
	-save_outliers ${subj}.${run}.outs.txt \
	-xSLAB 12.60L-R \
	-ySLAB 12.60S-I \
	-zSLAB 10.50P-A \
	-time:zt 15 50 3000 @rat_offsets.1D \
	MRIm*

to3d -epan \
	-prefix ${subj}.${run}.epan.nii \
	-text_outliers \
	-save_outliers ${subj}.${run}.outs.txt \
	-xSLAB 12.60L-R \
	-ySLAB 12.60S-I \
	-zSLAB 10.50P-A \
	-time:zt 15 700 3000 @rat_offsets.1D \
	MRIm*

3dToutcount -save ${subj}.${run}.outs.nii ${subj}.${run}.epan.nii \
	| 1dplot -jpeg ${subj}.${run}.outs -stdin ${subj}.${run}.outs.nii

3dTshift -verbose -tzero 0 -prefix ${subj}.${run}.tshift.nii ${subj}.${run}.epan.nii

cat -n ${subrun}.outliers.txt \
| sort -k2,2n \
| head -1 \
| awk '{print $1-1}'

3dvolreg \
	-verbose \
	-zpad 1 \
	-base ${subj}.${run}.tshift.nii'[276]' \
	-1Dfile ${subj}.${run}.dfile.1D \
	-prefix ${subj}.${run}.volreg \
	${subj}.${run}.tshift.nii > log.${subj}.${run}.volreg.txt

1dplot -jpeg ${subj}.${run}.volreg -volreg -xlabel TIME ${subj}.${run}.dfile.1D



3dAutomask \
	-dilate 1 \
	-prefix ${subj}.${run}.automask.nii \
	${subj}.${run}.volreg.nii > log.${subj}.${run}.automask.txt


3dMean -datum short -prefix rm.mean.nii ${subj}.${run}.automask.nii


3dcalc \
	-a rm.mean.nii \
	-expr 'ispositive(a-0)' \
	-prefix ${subj}.${run}.fullmask.nii


3dTstat -prefix rm.${subj}.${run}.mean.nii ${subj}.${run}.volreg.nii




3dcalc \
	-verbose \
	-float \
	-a ${subj}.${run}.volreg.nii \
	-b rm.${subj}.${run}.mean.nii \
	-c ${subj}.${run}.fullmask.edit.nii \
	-expr 'c * min(200, a/b*100)' \
	-prefix ${subj}.${run}.scale.nii

while read hrm; do
	3dDeconvolve \
		-polort A \
		-input ${subj}.${run}.scale.nii.gz \
		-mask ${subj}.${run}.fullmask.edit.nii \
		-num_stimts 7 -global_times \
		-stim_times 1 '1D: 240' "$hrm"  -stim_label 1 ${subj}.${run}.$hrm \
		-stim_file 2 ${subj}.${run}.dfile.1D'[0]' -stim_base 2 -stim_label 2 roll \
		-stim_file 3 ${subj}.${run}.dfile.1D'[1]' -stim_base 3 -stim_label 3 pitch \
		-stim_file 4 ${subj}.${run}.dfile.1D'[2]' -stim_base 4 -stim_label 4 yaw \
		-stim_file 5 ${subj}.${run}.dfile.1D'[3]' -stim_base 5 -stim_label 5 dS \
		-stim_file 6 ${subj}.${run}.dfile.1D'[4]' -stim_base 6 -stim_label 6 dL \
		-stim_file 7 ${subj}.${run}.dfile.1D'[5]' -stim_base 7 -stim_label 7 dP \
		-xout -x1D ${subj}.${run}.$hrm.xmat.1D \
		-xjpeg ${subj}.${run}.$hrm.xmat.jpg \
		-fout -tout -TR_times 1 \
		-iresp 1 ${subj}.${run}.$hrm.irf.nii \
		-fitts ${subj}.${run}.$hrm.fitt.nii \
		-errts ${subj}.${run}.$hrm.errts.nii \
		-bucket ${subj}.${run}.$hrm.stats.nii

	3dREMLfit \
		-matrix ${subj}.${run}.$hrm.xmat.1D \
		-input ${subj}.${run}.scale.nii.gz \
		-mask ${subj}.${run}.fullmask.edit.nii \
		-fout -tout \
		-Rbuck ${subj}.${run}.$hrm.func.REML.nii \
		-Rvar ${subj}.${run}.$hrm.func.REMLvar.nii \
		-Rfitts ${subj}.${run}.$hrm.fitt.REML.nii \
		-Rerrts ${subj}.${run}.$hrm.REML.nii \
		-verb $*

	 1dgrayplot -sep -jpeg ${hrm}.xmat ${subj}.${run}.$hrm.xmat.1D

	 1dplot -sepscl -jpeg ${hrm}.Regressors-All ${subj}.${run}.$hrm.xmat.1D

	 1dplot -sepscl -jpeg ${hrm}.MotionStim ${subj}.${run}.$hrm.xmat.1D'[22..16]'

	 1dcat ${subj}.${run}.$hrm.xmat.1D'[16]' > ideal.${subj}.${run}.$hrm.1D

	 mv ${subj}.${run}.$hrm.* BLOCK
	 
	 
	 
	 
done < RATHRF2.txt






3dToutcount \
	-save ${subj}.${run}.outs.nii ${subj}.${run}.epan.nii \
| 1dplot \
	-jpeg ${subj}.${run}.outs \
	-stdin ${subj}.${run}.outs.nii




3dTshift \
	-verbose \
	-tzero 0 \
	-prefix ${subj}.${run}.tshift.nii \
	${subj}.${run}.epan.nii

3dvolreg \
	-verbose \
	-zpad 1 \
	-base ${subj}.${run}.tshift.nii'[276]' \
	-1Dfile ${subj}.${run}.dfile.1D \
	-prefix ${subj}.${run}.volreg \
	${subj}.${run}.tshift.nii > log.${subj}.${run}.volreg.txt


1dplot \
	-jpeg ${subj}.${run}.volreg \
	-volreg \
	-xlabel TIME \
	${subj}.${run}.dfile.1D

3dAutomask \
	-dilate 1 \
	-prefix ${subj}.${run}.automask.nii \
	${subj}.${run}.volreg.nii > log.${subj}.${run}.automask.txt

3dMean \
	-datum short \
	-prefix rm.mean.nii \
	${subj}.${run}.automask.nii


3dcalc \
	-a rm.mean.nii \
	-expr 'ispositive(a-0)' \
	-prefix ${subj}.${run}.fullmask.nii


3dTstat \
	-prefix rm.mean_r$run \
	pb03.$subj.r$run.blur+orig


3dcalc \
	-a pb03.$subj.r$run.blur+orig \
	-b rm.mean_r$run+orig \
	-c full_mask.$subj+orig \
	-expr 'c * min(200, a/b*100)' \
	-prefix pb04.$subj.r$run.scale



3dTstat \
	-prefix rm.${subj}.${run}.mean.nii \
	${subj}.${run}.volreg.nii > log.${subj}.${run}.tstat.txt

3dcalc \
	-verbose -float \
	-a ${subj}.${run}.volreg.nii \
	-b rm.${subj}.${run}.mean.nii \
	-c ${subj}.${run}.fullmask.edit.nii \
	-expr 'c * min(200, a/b*100)' \
	-prefix ${subj}.${run}.scale

1d_tool.py \
	-infile ${subj}.${run}.dfile.1D \
	-set_nruns 1 \
	-set_tr 3.5 \
	-show_censor_count \
	-censor_prev_TR \
	-censor_motion .1 motion_${subj}.${run}. \
	-verb 2


while read hrm; do
	echo "This is the Model I am going to use $hrm"
	3dDeconvolve -input rat.200.scale.nii -polort A \
	-mask rat.200.fullmask.edit.nii -num_stimts 7 -global_times \
	-stim_times 1 '1D: 240' "WAV(900,${hrm},2.5,4,0.5,1)" -stim_label 1 rat.200.$hrm \
	-stim_file 2 rat.200.dfile.1D'[0]' -stim_base 2 -stim_label 2 roll \
	-stim_file 3 rat.200.dfile.1D'[1]' -stim_base 3 -stim_label 3 pitch \
	-stim_file 4 rat.200.dfile.1D'[2]' -stim_base 4 -stim_label 4 yaw \
	-stim_file 5 rat.200.dfile.1D'[3]' -stim_base 5 -stim_label 5 dS \
	-stim_file 6 rat.200.dfile.1D'[4]' -stim_base 6 -stim_label 6 dL \
	-stim_file 7 rat.200.dfile.1D'[5]' -stim_base 7 -stim_label 7 dP \
	-xout -x1D rat.200.$hrm.xmat.1D -xjpeg rat.200.$hrm.xmat.jpg \
	-fout -tout -TR_times 1 \
	-iresp 1 rat.200.$hrm.irf.nii \
	-fitts rat.200.$hrm.fitt.nii \
	-errts rat.200.$hrm.errts.nii \
	-bucket rat.200.$hrm.func.nii

3dREMLfit \
-matrix rat.200.$hrm.xmat.1D \
-input rat.200.scale.nii \
-mask rat.200.fullmask.edit.nii \
-fout -tout \
-Rbuck rat.200.$hrm.func.REML.nii \
-Rvar rat.200.$hrm.func.REMLvar.nii \
-Rfitts rat.200.$hrm.fitt.REML.nii \
-Rerrts rat.200.$hrm.REML.nii \
-verb $*

1dgrayplot -sep -jpeg ${hrm}.xmat rat.200.$hrm.xmat.1D

1dplot -sepscl -jpeg ${hrm}.Regressors-All rat.200.$hrm.xmat.1D

1dplot -sepscl -jpeg ${hrm}.MotionStim rat.200.$hrm.xmat.1D'[22..16]'

1dplot -sepscl -jpeg ${hrm}.Model rat.200.$hrm.xmat.1D'[16]'

1dcat rat.200.$hrm.xmat.1D'[16]' > ideal.rat.200.$hrm.1D

mv *.func.nii WAV
mv *Motion* WAV/REGRESSORS
mv *-All* WAV/REGRESSORS
mv *$hrm.1D WAV/1D
mv *irf* WAV/IRF
mv *.REML* WAV/REML
mv *xmat.jpg* WAV/MODEL
mv *Model* WAV/MODEL
mv rat.200.$hrm.fitt.nii WAV/STATS
mv rat.200.$hrm.errts.nii WAV/STATS

done < RATHRF2.txt
