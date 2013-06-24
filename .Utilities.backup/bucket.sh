#!/bin/sh
# This script determines which stimulus file should be used for each run, then performs 3dDecovolve
# It also extracts subbrick of interest using 3dbucket

	if [ "${run}" = "SP1" ]; then
			for stim in animal food null; do
				tap.deconvolve.prog
				3dbucket -prefix ${name}_${stim}_peak_irf.nii -fbuc ${name}_${stim}_norm_irf+orig '[8]'
			done

		elif [ "${run}" = "TP1" ]; then
			for stim in old new null; do
				tap.deconvolve.prog
				3dbucket -prefix ${name}_${stim}_peak_irf.nii -fbuc ${name}_${stim}_norm_irf+orig '[8]'
			done

		else
			for stim in male female null; do
				tap.deconvolve.prog
				3dbucket -prefix ${name}_${stim}_peak_irf.nii -fbuc ${name}_${stim}_norm_irf+orig '[8]'
			done
	fi