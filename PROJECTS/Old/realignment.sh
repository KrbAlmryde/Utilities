. $PROFILE/${1}_profile.sh
cd ${run_dir}
####################################################################################################
# This script does not perform Despike

if [ ! -e ${subrun}_tcat.nii ]; then
####################################################################################################
	echo "----------------------------------- register.sh -------------------------------------"
	echo "------------------------------------- ${subrun} -----------------------------------------"
	echo ""
####################################################################################################
	echo "----------------------------------- 3dTcat ----------------------------------- "
	echo "Removing first 4 trs from functional data"
	echo "Graph results"
	echo ""

	3dTcat -verb -prefix ${subrun}_tcat.nii ${subrun}_epan.nii'[4..$]'
	3dToutcount ${subrun}_tcat.nii > ${subrun}_tcat_outs.txt
	1dplot -jpeg ${subrun}_tcat_outs ${subrun}_tcat_outs.txt
##################################################################################################
	echo "-----------------------------------  3dTshift ----------------------------------- "
	echo "Shift timeseries data back to zero"
	echo "Graph results"
	echo ""

	3dTshift -verbose -tzero 0 -rlt+ -quintic -prefix ${subrun}_tshift.nii ${subrun}_tcat.nii
	3dToutcount ${subrun}_tshift.nii > ${subrun}_tshift_outs.txt
	1dplot -jpeg ${subrun}_tshift_outs ${subrun}_tshift_outs.txt
##################################################################################################
	echo "-----------------------------------  3dVolreg ----------------------------------- "
	echo "register each volume to the base"
	echo "what is you base value?"
	echo "Graph results"
	echo ""

	3dvolreg -verbose -verbose -zpad 1 -base ${subrun}_tshift.nii[`base_reg`] -1Dfile \
		${subrun}_dfile.1D -prefix ${subrun}_volreg.nii -cubic ${subrun}_tshift.nii
	3dToutcount ${subrun}_volreg.nii > ${subrun}_volreg_outs.txt
	1dplot -jpeg ${subrun}_volreg -volreg -xlabel TIME ${subrun}_dfile.1D
	1dplot -jpeg ${subrun}_volreg_outs ${subrun}_volreg_outs.txt
##################################################################################################
# This will all need to change!!!

echo "-----------------------------------  3dCalc ----------------------------------- "
	echo "Graph results"
	echo ""

	3dcalc -verbose -float -a ${subrun} .nii -b ${subrun} .nii -c ${subrun} .nii -expr \
		'c * min(200, a/b*100)' -prefix ${subrun}_scale.nii
	3dToutcount ${subrun}_scale.nii > ${subrun}_scale.txt
	1dplot -jpeg ${subrun}_scale ${subrun}_scale.txt
