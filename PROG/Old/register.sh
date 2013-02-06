. $PROFILE/${1}_profile.sh
cd ${prep_dir}


if [ ! -e ${subrun}.tcat.nii ]; then
####################################################################################################
	echo "----------------------------------- register.sh -------------------------------------"
	echo "------------------------------------- ${subrun} -----------------------------------------"
	echo ""
####################################################################################################
	echo "----------------------------------- 3dTcat ----------------------------------- "
	echo "Removing first 4 trs from functional data"
	echo "Graph results"
	echo ""

	3dTcat -verb -prefix ${subrun}.tcat.nii ${subrun}.epan.nii'[4..$]'
	3dToutcount ${subrun}.tcat.nii > ${subrun}.tcat_outs.txt
	1dplot -jpeg ${subrun}.tcat_outs ${subrun}.tcat_outs.txt
####################################################################################################
	echo "----------------------------------- 3dDespike ----------------------------------- "
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""
	
	3dDespike -prefix ${subrun}.despike.nii \
		-ssave ${subrun}.spikes.nii ${subrun}.tcat.nii
		
	3dToutcount ${subrun}.despike.nii > ${subrun}.despike_outs.txt
	1dplot -jpeg ${subrun}.despike_outs ${subrun}.despike_outs.txt
####################################################################################################
	echo "-----------------------------------  3dTshift ----------------------------------- "
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""

	3dTshift -verbose -tzero 0 -rlt+ -quintic \
		-prefix ${subrun}.tshift.nii ${subrun}.despike.nii
		
	3dToutcount ${subrun}.tshift.nii > ${subrun}.tshift_outs.txt
	1dplot -jpeg ${subrun}.tshift_outs ${subrun}.tshift_outs.txt
####################################################################################################
	echo "-----------------------------------  3dVolreg ----------------------------------- "
	echo "register each volume to the base"
	echo "what is you base value?"
	echo "Graph results"
	echo ""
	
	3dvolreg -verbose -verbose -zpad 4 \
		-base ${subrun}.tshift.nii[`base_reg`] \
		-1Dfile ${subrun}.dfile.1D \
		-prefix ${subrun}.volreg.nii \
		-cubic ${subrun}.tshift.nii
		
	echo "base volume = `base_reg`" > ${subrun}.base_volreg.txt
	3dToutcount ${subrun}.volreg.nii > ${subrun}.volreg_outs.txt
	1dplot -jpeg ${subrun}.volreg -volreg -xlabel TIME ${subrun}.dfile.1D
	1dplot -jpeg ${subrun}.volreg_outs ${subrun}.volreg_outs.txt
	cp ${subrun}.dfile.1D ${glm_dir}
####################################################################################################
	echo "----------------------------------- Smoothing ----------------------------------- "
	echo "....."

	3dmerge -1blur_fwhm 6.0 -doall -prefix ${subrun}.blur.nii ${subrun}.volreg.nii
##################################################################################################
	echo "-------------------------- Masking non-brain regions ------------------------------ "
	echo ""

	3dAutomask -prefix ${subrun}.automask.nii ${subrun}.blur.nii
	cp ${subrun}.automask.nii ${glm_dir}
##################################################################################################
	echo "---------------------------- Normalizing time series -------------------------- "
	echo ""

	3dTstat -prefix ${subrun}.mean.nii ${subrun}.blur.nii
	
	3dcalc -verbose -float \
		-a ${subrun}.blur.nii \
		-b ${subrun}.mean.nii \
		-c ${subrun}.automask.nii \
		-expr 'c * min(200, a/b*100)' \
		-prefix ${subrun}.scale.nii.gz
		
	3dToutcount ${subrun}.scale.nii.gz > ${subrun}.scale.txt
	1dplot -jpeg ${subrun}.scale ${subrun}.scale.txt
	cp ${subrun}.scale.nii.gz ${glm_dir}
##################################################################################################
	echo "----------------------------------- 1d_tool.py -----------------------------------"
	echo "create censor file motion.${subj}.censor.1D, for censoring motion"
	echo ""

	1d_tool.py -verb 2 \
		-infile ${subrun}.dfile.1D \
		-set_nruns 1 -set_tr 3.5 \
		-show_censor_count \
		-censor_prev_TR \
		-censor_motion .1 \
		motion.${subrun}
		
	cp motion.${subrun}_censor.1D ${glm_dir}
##################################################################################################
	echo "Move images and text/1D files to etc directory"
	echo ""

	mv *.jpg etc/
	mv *.1D etc/
	mv *.txt etc/
##################################################################################################
fi
