#!/bin/sh
# tap.preprocess
# Written by Kyle Reese Almryde, 7/12/11
# Thanks to Dianne Patterson for her help and advice
# The purpose of this script is to perform preprocessing operations on 4D timeseries data collected by the BLAM lab
# Version 1.0
# --------------------------------------------------------------------------------------------------------------
# I may make this into a seperate script called like variable or tap_profile
#
while read subj; do
	for run in echo "'cat tap.run.lst'"; do
		func= ${TAP}/${subj}/${run}
		name= ${subj}_${run}
		anat= ${TAP}/${subj}/struc
		base= 'something with awk'
#---------------------------------------------------------------------------------------------------------------
# I think I am going to make this a seperate script called tap.preprocess

		3dTcat -prefix ${func}/${name}_tcat.nii ${func}/${name}_epan.nii'[4..$]'
		3dToutcount ${func}/${name}_tcat.nii > ${func}/${name}_precount.txt
		1dplot -jpeg -one ${func}/${name}_precount.txt
#---------------------------------------------------------------------------------------------------------------
#
		3dTshift -tzero 0 -rlt+ -quintic -prefix ${func}/${name}_tshift.nii ${func}/${name}_tcat.nii
		3dToutcount ${func}/${name}_tshift.nii > ${func}/${name}_postcount.txt
		1dplot -jpeg -one ${func}/${name}_postcount.txt
#---------------------------------------------------------------------------------------------------------------
#
		3dvolreg -verbose -zpad 1 -base ${func}/${name}_tshift.nii"[${base}]" -1Dfile ${func}/${name}_dfile.txt -prefix \
			${func}/${name}_volreg.nii -cubic ${func}/${name}_tshift.nii
		1dplot -jpeg -sep -ynames roll pitch yaw dS dL dP -xlabel TIME ${func}/${name}_volreg.txt
#---------------------------------------------------------------------------------------------------------------
#
		3dmerge -1blur_fwhm 6.0 -doall -prefix ${func}/${name}_blur.nii ${func}/${name}_volreg.nii
#---------------------------------------------------------------------------------------------------------------
#
		3dAutomask -prefix ${func}/${name}_automask.nii ${func}/${name}_blur.nii
#---------------------------------------------------------------------------------------------------------------
#
		3dTstat -prefix ${func}/${name}_mean.nii ${func}/${name}_blur.nii
#---------------------------------------------------------------------------------------------------------------
#
		3dcalc -a ${func}/${name}_blur.nii -b ${func}/${name}_mean.nii -c ${func}/${name}_automask.nii \
			-expr 'c * min(200, a/b*100)' -prefix ${func}/${name}_norm.nii
		3dToutcount ${func}/${name}_norm.nii > ${func}/${name}_norm.txt
		1dplot -jpeg -one ${func}/${name}_norm.txt
#---------------------------------------------------------------------------------------------------------------
#
		if [ "${run}" = "SP1" ]; then
			for stim in animal food null; do
				tap.deconvolve
				3dbucket -prefix ${func}/${name}_${stim}_peak_irf -fbuc ${func}/${name}_${stim}_norm_irf+orig '[8]'
			done

		elif [ "${run}" = "TP1" ]; then
			for stim in old new null; do
				tap.deconvolve
				3dbucket -prefix ${func}/${name}_${stim}_peak_irf -fbuc ${func}/${name}_${stim}_norm_irf+orig '[8]'
			done

		else
			for stim in male female null; do
				tap.deconvolve
				3dbucket -prefix ${func}/${name}_${stim}_peak_irf -fbuc ${func}/${name}_${stim}_norm_irf+orig '[8]'
			done
		fi

	done
done <tap.subjls.txt
