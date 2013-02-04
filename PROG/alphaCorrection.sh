. $PROFILE/${1}_profile.sh
cd ${ANOVA_dir}
#---------------------------------------------------------------------------------------------------
# Run 3dFWHMx to determine the required smoothing for cluster analysis.
# Place the results into a text file living in the GLM_dir that can be later referenced
	3dFWHMx -dset FUNC/${submod}.errts+orig -automask -combine -detrend \
		-out ${submod}.errts.detrend.1D -detprefix ${submod}.errts.detrend+orig 

	echo "${subrun} = `tail -c 8 log.${subrun}.alphaCorrection.txt`" >> \
		${GLM_dir}/${run}.FWHMx.txt


fwhmx=`awk -v OFS=' ' '{ sum+=$3 } END { print sum/NR }' ${glm_dir}/etc/${run}.FWHMx.txt`

3dClustSim -mask Masks/Brain.Mask.nii \
#	-nxyz 161 191 151 -dxyz 1 1 1 \			this option is ignored when -mask is used
	-fwhm ${fwhmx} -niml -NN 3 -nodec -both -prefix cs.${run}.tap


AlphaSim \
	-nxyz 161 191 151 \
	-dxyz 1 1 1 -iter 1000 \
	-pthr .005 -rmm 1 -fwhm ${fwhmx}
	
	
	AlphaSim -nxyz 161 191 151 -dxyz 1 1 1 -iter 1000 -pthr .005 -rmm 1 -fwhm 10