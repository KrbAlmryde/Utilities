. $UTL/${1}_profile.sh

3dDeconvolve -input ${func_dir}/${name}_scale+tlrc \
	-censor motion_${subj}_censor.1D \
	-polort A \
	-mask ${func_dir}/${name}_mask_group+tlrc \
	-num_stimts 9 -local_times \
	-stim_times 1 stim_${run}_${stim}.txt 'GAM' -stim_label 1 ${func_dir}/${name}_${stim}		\
	-stim_times 2 stim_${run}_${stim}.txt 'GAM' -stim_label 2 ${func_dir}/${name}_${stim} \
	-stim_times 3 stim_${run}_${stim}.txt 'GAM' -stim_label 3 ${func_dir}/${name}_${stim} \
	-stim_file 4 ${func_dir}/${name}_dfile.txt'[0]' -stim_base 4 -stim_label 4 ${func_dir}/${name}_roll	 \
	-stim_file 5 ${func_dir}/${name}_dfile.txt'[1]' -stim_base 5 -stim_label 5 ${func_dir}/${name}_pitch \
	-stim_file 6 ${func_dir}/${name}_dfile.txt'[2]' -stim_base 6 -stim_label 6 ${func_dir}/${name}_yaw \
	-stim_file 7 ${func_dir}/${name}_dfile.txt'[3]' -stim_base 7 -stim_label 7 ${func_dir}/${name}_dS \
	-stim_file 8 ${func_dir}/${name}_dfile.txt'[4]' -stim_base 8 -stim_label 8 ${func_dir}/${name}_dL \
	-stim_file 9 ${func_dir}/${name}_dfile.txt'[5]' -stim_base 9 -stim_label 9 ${func_dir}/${name}_dP \
		-fout -tout -x1D ${func_dir}/${name}_X.xmat.txt -xjpeg ${func_dir}/${name}_X.jpg				 \
	-iresp 1 ${func_dir}/${name}_${stim}_irf -iresp 2 ${func_dir}/${name}_${stim}_irf -iresp 3 ${func_dir}/${name}_${stim}_irf \
		-fitts ${func_dir}/${name}_fitts																								\
	-bucket ${func_dir}/${name}_bucket

if ( $status != 0 ) then
		echo '---------------------------------------'
		echo '** 3dDeconvolve error, failing...'
		echo '	 (consider the file 3dDeconvolve.err)'
		exit
endif

3dTcat -prefix ${func_dir}/${name}_all_runs ${func_dir}/${name}_scale+tlrc

# in case of censoring, create uncensored X-matrix
1d_tool.py -infile X.xmat.1D -censor_fill -write ${func_dir}/${name}_X.uncensored.xmat.1D

# create ideal files for each stim type
1dcat ${func_dir}/${name}_${func_dir}/${name}_X.uncensored.xmat.1D'[6]' > ${func_dir}/${name}_ideal_stim01.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[7]' > ${func_dir}/${name}_ideal_stim02.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[8]' > ${func_dir}/${name}_ideal_stim03.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[9]' > ${func_dir}/${name}_ideal_stim04.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[10]' > ${func_dir}/${name}_ideal_stim05.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[11]' > ${func_dir}/${name}_ideal_stim06.1D
1dcat ${func_dir}/${name}_X.uncensored.xmat.1D'[12]' > ${func_dir}/${name}_ideal_stim07.1D
