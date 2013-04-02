. $UTL/${1}_profile.sh
cd ${run_dir}
####################################################################################################
# This script adds the additional Despike block to the analysis.

if [ ! -e ${subrun}_tcat+orig.HEAD ]; then
####################################################################################################
	echo "----------------------------------- register.sh -------------------------------------"
	echo "------------------------------------- ${subrun} -----------------------------------------"
	echo ""
####################################################################################################
	echo "----------------------------------- 3dTcat ----------------------------------- "
	echo "Removing first 4 trs from functional data"
	echo "Graph results"
	echo ""

	3dTcat -verb -prefix ${subrun}_tcat+orig ${subrun}_epan+orig'[4..$]'
	3dToutcount ${subrun}_tcat+orig > ${subrun}_Tcat_outs.txt
	1dplot -jpeg ${subrun}_Tcat_outs ${subrun}_Tcat_outs.txt
####################################################################################################
	echo "----------------------------------- 3dDespike ----------------------------------- "
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""
	3dDespike -prefix ${subrun}_despike -ssave ${subrun}_spikes ${subrun}_tcat+orig
	3dToutcount ${subrun}_despike+orig > ${subrun}_despike_outs.txt
	1dplot -jpeg ${subrun}_Despike_outs ${subrun}_despike_outs.txt
####################################################################################################
	echo "-----------------------------------  3dTshift ----------------------------------- "
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""

	3dTshift -verbose -tzero 0 -rlt+ -quintic -prefix ${subrun}_tshift+orig ${subrun}_despike+orig
	3dToutcount ${subrun}_tshift+orig > ${subrun}_Tshift_outs.txt
	1dplot -jpeg ${subrun}_Tshift_outs ${subrun}_Tshift_outs.txt
####################################################################################################
	echo "-----------------------------------  3dVolreg ----------------------------------- "
	echo "register each volume to the base"
	echo "what is you base value?"
	echo "Graph results"
	echo ""

	3dvolreg -verbose -verbose -zpad 1 -base ${subrun}_tshift+orig[`base_reg`]
		-1Dfile ${subrun}_dfile.1D -prefix ${subrun}_volreg+orig -cubic ${subrun}_tshift+orig
	3dToutcount ${subrun}_Volreg+orig > ${subrun}_Volreg_outs.txt
	1dplot -jpeg ${subrun}_volreg -volreg -xlabel TIME ${subrun}_dfile.1D
	1dplot -jpeg ${subrun}_Volreg_outs ${subrun}_Volreg_outs.txt
####################################################################################################
	echo "-----------------------------------  3dMerge ----------------------------------- "
	echo ""

	3dmerge -1blur_fwhm 6.0 -doall -prefix ${subrun}_blur+orig ${subrun}_volreg+orig
####################################################################################################
	echo "----------------------------------- 3dAutomask ----------------------------------- "
	echo ""

	3dAutomask -prefix ${subrun}_automask+orig ${subrun}_blur+orig
####################################################################################################
	echo "-----------------------------------  3dTstat ----------------------------------- "
	echo ""

	3dTstat -prefix ${subrun}_mean+orig ${subrun}_blur+orig
####################################################################################################
	echo "-----------------------------------  3dCalc ----------------------------------- "
	echo "Graph results"
	echo ""

	3dcalc -verbose -a ${subrun}_blur+orig -b ${subrun}_mean+orig -c ${subrun}_automask+orig -expr \
		'c * min(200, a/b*100)' -prefix ${subrun}_scale+orig
	3dToutcount ${subrun}_scale+orig > ${subrun}_scale.txt
	1dplot -jpeg ${subrun}_scale ${subrun}_scale.txt
####################################################################################################
	echo "----------------------------------- 1d_tool.py -----------------------------------"
	echo "create censor file motion_${subj}_censor.1D, for censoring motion"
	echo ""

	1d_tool.py -infile ${subrun}_dfile.1D -set_nruns 1 -set_tr 3.5 -show_censor_count \
		-censor_prev_TR -censor_motion .1 motion_${subrun} -verb 2
####################################################################################################
fi
echo ""


