. $PROFILE/${1}_profile.sh
cd ${func_dir}/${runsub}.reg
####################################################################################################
echo "----------------------------------- register.sh -------------------------------------"
echo "------------------------------------- ${runsub} -----------------------------------------"
echo ""

3dToutcount ${runsub}.nii.gz > ${runsub}.outliers.txt 
1dplot -jpeg ${runsub}.outliers ${runsub}.outliers.txt 
####################################################################################################
echo "----------------------------------- 3dDespike ----------------------------------- "
echo "Shift timeseries data back to zero"
echo "Graph results"
echo ""
3dDespike -prefix ${runsub}_despike.nii -ssave ${runsub}_spikes.nii ${runsub}.nii.gz
3dToutcount ${runsub}_despike.nii > ${runsub}_despike_outs.txt
1dplot -jpeg ${runsub}_despike_outs ${runsub}_despike_outs.txt
####################################################################################################
echo "-----------------------------------  3dVolreg ----------------------------------- "
echo "register each volume to the base"
echo "what is you base value?"
echo "Graph results"
echo ""


echo "base_reg = `base_reg`" > base_volume.volreg.txt
3dvolreg -verbose -verbose -zpad 4 -base ${runsub}.nii.gz[`base_reg`] -1Dfile \
	${runsub}_dfile.1D -prefix ${runsub}_volreg.nii -cubic ${runsub}_despike.nii
3dToutcount ${runsub}_volreg.nii > ${runsub}_volreg_outs.txt
1dplot -jpeg ${runsub}_volreg -volreg -xlabel TIME ${runsub}_dfile.1D
1dplot -jpeg ${runsub}_volreg_outs ${runsub}_volreg_outs.txt
####################################################################################################
echo "----------------------------------- Smoothing ----------------------------------- "
echo "....."

3dmerge -1blur_fwhm 6.0 -doall -prefix ${runsub}_blur.nii ${runsub}_volreg.nii
##################################################################################################
echo "-------------------------- Masking non-brain regions ------------------------------ "
echo ""

3dAutomask -prefix ${runsub}_automask.nii ${runsub}_blur.nii
##################################################################################################
echo "---------------------------- Normalizing time series -------------------------- "
echo ""

3dTstat -prefix ${runsub}_mean.nii ${runsub}_blur.nii
3dcalc -verbose -float -a ${runsub}_blur.nii -b ${runsub}_mean.nii -c ${runsub}_automask.nii \
	-expr 'c * min(200, a/b*100)' -prefix ${runsub}_scale.nii.gz
3dToutcount ${runsub}_scale.nii.gz > ${runsub}_scale.txt
1dplot -jpeg ${runsub}_scale ${runsub}_scale.txt
##################################################################################################
echo "----------------------------------- 1d_tool.py -----------------------------------"
echo "create censor file motion.${subj}_censor.1D, for censoring motion"
echo ""

1d_tool.py -infile ${runsub}_dfile.1D -set_nruns 1 -set_tr $tr -show_censor_count \
	-censor_prev_TR -censor_motion .1 motion_${runsub} -verb 2
##################################################################################################
echo "Move images and text/1D files to etc directory"
echo ""

mv *${runsub}* ${runsub}.reg