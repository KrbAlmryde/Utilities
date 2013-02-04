. $UTL/${1}_profile.sh
cd ${run_dir}
####################################################################################################
# This script uses the AFNI program 3dbucket to extract subbricks 1-9 from the IRF files generated
# by 3dDeconvolve. In addtion it extracts the Full_Fstat, Coef, Tstat, and Fstat subbriks from the
# Deconvolve bucket file for each condition. The Full_Fstat resides at index 0. The Coef(iccient)
# resides at indices 1, 4, and 7. The Tstat resides at indicies 2, 5, and 8. The Fstat resides at
# indicies 3, 6, and 9
####################################################################################################
echo "----------------------------------- bucket_dich.sh -------------------------------------"
echo "------------------------------- ${subbrik} ----------------------------------"
####################################################################################################
# extracting subrick index from the peak impulse response function.

if [ ! -e ${subbrik}peak_irf+orig.HEAD ]; then

	3dbucket -prefix ${subbrik}peak_irf+orig -fbuc ${subcond}_irf+orig["${brik}"]
fi
####################################################################################################
# extracting subrick index from the bucket files

if [ ! -e ${submod}_Full_Fstat+orig.HEAD ]; then

	if [ $brik = "1" -o $brik = "4" -o $brik = "7" ]; then
		3dbucket -prefix ${subcond}_Coef+orig -fbuc ${submod}_bucket+orig["${brik}"]

	elif [ $brik = "2" -o $brik = "5" -o $brik = "8" ]; then
		3dbucket -prefix ${subcond}_Tstat+orig -fbuc ${submod}_bucket+orig["${brik}"]

	elif [ $brik = "3" -o $brik = "6" -o $brik = "9" ]; then
		3dbucket -prefix ${subcond}_Fstat+orig -fbuc ${submod}_bucket+orig["${brik}"]

	else
		# Note well that the Full_Fstat applies to the entire dataset, and not just the conditions
		3dbucket -prefix ${submod}_Full_Fstat+orig -fbuc ${submod}_bucket+orig["${brik}"]
	fi

fi
####################################################################################################
echo ""
