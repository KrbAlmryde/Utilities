. $UTL/${1}_profile
cd ${func_dir}
####################################################################################################
# Set up check to ensure we are looping too many times.

if [ ! -e ${runnm}_tcat+orig.HEAD ]; then
####################################################################################################
	echo "3dTcat....."
	echo "Removing first 4 trs from functional data"
	echo "Graph results"
	echo ""

	3dTcat -prefix ${runnm}_tcat+orig ${runnm}_epan+orig'[4..$]'
	3dToutcount ${runnm}_tcat+orig > ${runnm}_precount.txt
	1dplot -jpeg ${runnm}_precount ${runnm}_precount.txt
####################################################################################################
	echo "3dTshift....."
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""

	3dTshift -tzero 0 -rlt+ -quintic -prefix ${runnm}_tshift+orig ${runnm}_tcat+orig
	3dToutcount ${runnm}_tshift+orig > ${runnm}_postcount.txt
	1dplot -jpeg ${runnm}_postcount ${runnm}_postcount.txt
####################################################################################################
	echo "3dVolreg....."
	echo "register each volume to the base"
	echo "what is you base value?"
	echo "Graph results"
	echo ""

	3dvolreg -verbose -zpad 1 -base ${runnm}_tshift+orig'[75]' -1Dfile ${runnm}_dfile.1D -prefix \
		${runnm}_volreg+orig -cubic ${runnm}_tshift+orig
	1dplot -jpeg ${runnm}_volreg -volreg -xlabel TIME ${runnm}_dfile.1D
####################################################################################################
	echo "3dMerge.."
	echo ""

	3dmerge -1blur_fwhm 6.0 -doall -prefix ${runnm}_blur+orig ${runnm}_volreg+orig
####################################################################################################
	echo "3dAutomask"
	echo ""

	3dAutomask -prefix ${runnm}_automask+orig ${runnm}_blur+orig
####################################################################################################
	echo "3dTstat"
	echo ""

	3dTstat -prefix ${runnm}_mean+orig ${runnm}_blur+orig
####################################################################################################
	echo "3dCalc"
	echo "Graph results"
	echo ""

	3dcalc -a ${runnm}_blur+orig -b ${runnm}_mean+orig -c ${runnm}_automask+orig -expr \
		'c * min(200, a/b*100)' -prefix ${runnm}_scale+orig
	3dToutcount ${runnm}_scale+orig > ${runnm}_scale.txt
	1dplot -jpeg ${runnm}_scale ${runnm}_scale.txt
#####################################################################################################
	echo "create censor file motion_${subj}_censor.1D, for censoring motion"
	echo ""

	1d_tool.py -infile ${runnm}_dfile.1D -set_nruns 1 -set_tr 3.5 -show_censor_count \
		-censor_prev_TR -censor_motion .1 motion_${runnm}
####################################################################################################
fi
