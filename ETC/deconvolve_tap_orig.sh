. $UTL/${1}_profile
cd ${func_dir}
####################################################################################################
echo "Deconvolution!!"
####################################################################################################
if [ ! -e ${runnm}_bucket+orig.HEAD ]; then

if [ "${run}" = "SP1" ]; then
	3dDeconvolve -input ${runnm}_scale+orig -polort A \
	    -censor motion_${runnm}_censor.1D \
		-mask ${runnm}_automask+orig -num_stimts 9 -global_times \
		-stim_times 1 ${UTL}/stim_${run}_animal.txt 'WAV(7.0)' -stim_label 1 ${runnm}_animal+orig \
		-stim_times 2 ${UTL}/stim_${run}_food.txt 'WAV(7.0)' -stim_label 2 ${runnm}_food+orig \
		-stim_times 3 ${UTL}/stim_${run}_null.txt 'WAV(7.0)' -stim_label 3 ${runnm}_null+orig \
		-stim_file 4 ${runnm}_dfile.1D'[0]' -stim_base 4 -stim_label 4 roll \
		-stim_file 5 ${runnm}_dfile.1D'[1]' -stim_base 5 -stim_label 5 pitch \
		-stim_file 6 ${runnm}_dfile.1D'[2]' -stim_base 6 -stim_label 6 yaw \
		-stim_file 7 ${runnm}_dfile.1D'[3]' -stim_base 7 -stim_label 7 dS \
		-stim_file 8 ${runnm}_dfile.1D'[4]' -stim_base 8 -stim_label 8 dL \
		-stim_file 9 ${runnm}_dfile.1D'[5]' -stim_base 9 -stim_label 9 dP \
		-iresp 1 ${runnm}_animal_irf+orig \
		-iresp 2 ${runnm}_food_irf+orig \
		-iresp 3 ${runnm}_null_irf+orig \
		-bucket ${runnm}_bucket+orig
####################################################################################################
elif [ "${run}" = "TP1" ]; then
	3dDeconvolve -input ${runnm}_scale+orig -polort A \
	    -censor motion_${runnm}_censor.1D \
		-mask ${runnm}_automask+orig -num_stimts 9 -global_times \
		-stim_times 1 ${UTL}/stim_${run}_old.txt 'WAV(7.0)' -stim_label 1 ${runnm}_old+orig \
		-stim_times 2 ${UTL}/stim_${run}_new.txt 'WAV(7.0)' -stim_label 2 ${runnm}_new+orig \
		-stim_times 3 ${UTL}/stim_${run}_null.txt 'WAV(7.0)' -stim_label 3 ${runnm}_null+orig \
		-stim_file 4 ${runnm}_dfile.1D'[0]' -stim_base 4 -stim_label 4 roll \
		-stim_file 5 ${runnm}_dfile.1D'[1]' -stim_base 5 -stim_label 5 pitch \
		-stim_file 6 ${runnm}_dfile.1D'[2]' -stim_base 6 -stim_label 6 yaw \
		-stim_file 7 ${runnm}_dfile.1D'[3]' -stim_base 7 -stim_label 7 dS \
		-stim_file 8 ${runnm}_dfile.1D'[4]' -stim_base 8 -stim_label 8 dL \
		-stim_file 9 ${runnm}_dfile.1D'[5]' -stim_base 9 -stim_label 9 dP \
		-iresp 1 ${runnm}_old_irf+orig \
		-iresp 2 ${runnm}_new_irf+orig \
		-iresp 3 ${runnm}_null_irf+orig \
		-bucket ${runnm}_bucket+orig
####################################################################################################
else
	3dDeconvolve -input ${runnm}_scale+orig -polort A \
	    -censor motion_${runnm}_censor.1D \
		-mask ${runnm}_automask+orig -num_stimts 9 -global_times \
		-stim_times 1 ${UTL}/stim_${run}_male.txt 'WAV(7.0)' -stim_label 1 ${runnm}_male+orig \
		-stim_times 2 ${UTL}/stim_${run}_female.txt 'WAV(7.0)' -stim_label 2 ${runnm}_female+orig \
		-stim_times 3 ${UTL}/stim_${run}_null.txt 'WAV(7.0)' -stim_label 3 ${runnm}_null+orig \
		-stim_file 4 ${runnm}_dfile.1D'[0]' -stim_base 4 -stim_label 4 roll \
		-stim_file 5 ${runnm}_dfile.1D'[1]' -stim_base 5 -stim_label 5 pitch \
		-stim_file 6 ${runnm}_dfile.1D'[2]' -stim_base 6 -stim_label 6 yaw \
		-stim_file 7 ${runnm}_dfile.1D'[3]' -stim_base 7 -stim_label 7 dS \
		-stim_file 8 ${runnm}_dfile.1D'[4]' -stim_base 8 -stim_label 8 dL \
		-stim_file 9 ${runnm}_dfile.1D'[5]' -stim_base 9 -stim_label 9 dP \
		-iresp 1 ${runnm}_male_irf+orig \
		-iresp 2 ${runnm}_female_irf+orig \
		-iresp 3 ${runnm}_null_irf+orig \
		-bucket ${runnm}_bucket+orig
####################################################################################################
fi
####################################################################################################
# This marks the end of this script. Thanks for playing!
fi
