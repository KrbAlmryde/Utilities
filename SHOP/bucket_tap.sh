. $PROFILE/${1}_profile.sh
cd ${run_dir}
####################################################################################################
# This script uses the AFNI program 3dbucket to extract subbricks 1-9 from the IRF files generated
# by 3dDeconvolve. In addtion it extracts the Full_Fstat, Coef, Tstat, and Fstat subbriks from the
# Deconvolve bucket file for each condition. The Full_Fstat resides at index 0. The Coef(iccient)
# resides at indices 1, 4, and 7. The Tstat resides at indicies 2, 5, and 8. The Fstat resides at
# indicies 3, 6, and 9
####################################################################################################
	echo "----------------------------------- bucket_tap.sh -------------------------------------"
	echo "------------------------------- ${submod} ----------------------------------"
####################################################################################################
# extracting subrick index from the bucket files
#if [ ! -e ${submod}_Fstat.nii ]; then
####################################################################################################
	#Extracting the Coefficient
#	3dbucket -prefix ${submod}_Coef+orig -fbuc ${subrunmod}_bucket+orig'[1..7(3)]'

	#Extracting the Tstat
#	3dbucket -prefix ${submod}_Tstat+orig -fbuc ${subrunmod}_bucket+orig'[2..8(2)]'

	#Extracting the partial Fstat
#	3dbucket -prefix ${submod}_Fstat+orig -fbuc ${subrunmod}_bucket+orig'[3..9(3)]'
#fi
####################################################################################################
#if [ ! -e ${subrunmod}_Full_Fstat.nii ]; then
	# Note well that the Full_Fstat applies to the entire dataset, and not just the conditions
#	3dbucket -prefix ${subrunmod}_Full_Fstat+orig -fbuc ${subrunmod}_bucket+orig'[0]'
#fi
####################################################################################################
if [ ! -e ${submod}_peak.nii ]; then
####################################################################################################
# extracting peak subrick indices 3 and 4 of WAV impulse response function.
	if [ "$mod" = WAV ] ;then
		echo "${submod}_peak+orig"
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[3]'
		3dbucket -prefix ${submod}_peak2+orig -fbuc ${submod}_irf+orig'[4]'
	fi
####################################################################################################
# Extracting peak subbrick index 3 from dafault GAM irf
	if [ "$mod" = GAM ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[3]'
	fi
####################################################################################################
# Extracting peak subbrick indices 1..14 from TR-shifted GAM irfs
	if [ "$mod" = GAM1 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[1]'
	elif [ "$mod" = GAM2 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[2]'
	elif [ "$mod" = GAM3 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[3]'
	elif [ "$mod" = GAM4 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[4]'
	elif [ "$mod" = GAM5 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[5]'
	elif [ "$mod" = GAM6 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[6]'
	elif [ "$mod" = GAM7 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[7]'
	elif [ "$mod" = GAM8 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[8]'
	elif [ "$mod" = GAM9 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[9]'
	elif [ "$mod" = GAM10 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[10]'
	elif [ "$mod" = GAM11 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[11]'
	elif [ "$mod" = GAM12 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[12]'
	elif [ "$mod" = GAM13 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[13]'
	elif [ "$mod" = GAM14 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[14]'
	fi
####################################################################################################
# Extracting peak subbrick indices 1...5 from seconds shifted GAM irfs
	if [ "$mod" = sec1 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[1]'
	elif [ "$mod" = sec2 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[1]'
	elif [ "$mod" = sec3 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[2]'
	elif [ "$mod" = sec4 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[2]'
	elif [ "$mod" = sec5 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[3]'
	elif [ "$mod" = sec6 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[3]'
	elif [ "$mod" = sec7 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[4]'
	elif [ "$mod" = sec8 ] ;then
		3dbucket -prefix ${submod}_peak+orig -fbuc ${submod}_irf+orig'[5]'
	fi
####################################################################################################
fi
echo ""
