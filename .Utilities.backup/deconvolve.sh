#!/bin/sh
#
3dDeconvolve -input ${name}_scale+tlrc \
	-censor motion_${subj}_censor.1D \
    -polort A \
    -mask ${name}_mask_group+tlrc \
	-num_stimts 9 -local_times \
	-stim_times 1 tap.${run}_${stim}.stim 'GAM' -stim_label 1 ${name}_${stim}  	\
	-stim_times 2 tap.${run}_${stim}.stim 'GAM' -stim_label 2 ${name}_${stim} \
	-stim_times 3 tap.${run}_${stim}.stim 'GAM' -stim_label 3 ${name}_${stim} \
	-stim_file 4 ${name}_dfile.txt'[0]' -stim_base 4 -stim_label 4 ${name}_roll   \
	-stim_file 5 ${name}_dfile.txt'[1]' -stim_base 5 -stim_label 5 ${name}_pitch \
	-stim_file 6 ${name}_dfile.txt'[2]' -stim_base 6 -stim_label 6 ${name}_yaw \
	-stim_file 7 ${name}_dfile.txt'[3]' -stim_base 7 -stim_label 7 ${name}_dS \
	-stim_file 8 ${name}_dfile.txt'[4]' -stim_base 8 -stim_label 8 ${name}_dL \
	-stim_file 9 ${name}_dfile.txt'[5]' -stim_base 9 -stim_label 9 ${name}_dP \
    -fout -tout -x1D ${name}_X.xmat.txt -xjpeg ${name}_X.jpg         \
	-iresp 1 ${name}_${stim}_irf -iresp 2 ${name}_${stim}_irf -iresp 3 ${name}_${stim}_irf \
    -fitts ${name}_fitts                                                \
	-bucket ${name}_bucket

if ( $status != 0 ) then
    echo '---------------------------------------'
    echo '** 3dDeconvolve error, failing...'
    echo '   (consider the file 3dDeconvolve.err)'
    exit
endif

3dTcat -prefix ${name}_all_runs ${name}_scale+tlrc

# in case of censoring, create uncensored X-matrix
1d_tool.py -infile X.xmat.1D -censor_fill -write ${name}_X.uncensored.xmat.1D

# create ideal files for each stim type
1dcat ${name}_${name}_X.uncensored.xmat.1D'[6]' > ${name}_ideal_stim01.1D
1dcat ${name}_X.uncensored.xmat.1D'[7]' > ${name}_ideal_stim02.1D
1dcat ${name}_X.uncensored.xmat.1D'[8]' > ${name}_ideal_stim03.1D
1dcat ${name}_X.uncensored.xmat.1D'[9]' > ${name}_ideal_stim04.1D
1dcat ${name}_X.uncensored.xmat.1D'[10]' > ${name}_ideal_stim05.1D
1dcat ${name}_X.uncensored.xmat.1D'[11]' > ${name}_ideal_stim06.1D
1dcat ${name}_X.uncensored.xmat.1D'[12]' > ${name}_ideal_stim07.1D