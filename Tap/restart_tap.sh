. $PROFILE/${1}_profile
####################################################################################################
#echo "------------------------------- restart_tap.sh --------------------------------"
#echo "-------------------------------- ${submod} ------------------------------"
####################################################################################################
if [ "${2}" = "All" ]; then #Be very careful with this option, it will restart everything!
	cd ${orig_dir}
	mv SP1.* ../SP1
	mv SP2.* ../SP2
	mv TP1.* ../TP1
	mv TP2.* ../TP2
	################################################################################################
	# Remove output from the reconstruct.sh
	cd ${run_dir}
	rm log.${subrun}.reconstruct.txt
 	rm ${subrun}_epan*
 	rm ${subrun}_outliers.txt
 	rm ${subrun}_outs*
 	rm ${subrun}_outliers.jpg
	################################################################################################
	# Remove output from register.sh
	rm log.${subrun}.register.txt
 	rm ${subrun}_tcat*
 	rm ${subrun}_tshift*
 	rm ${subrun}_volreg*
 	rm ${subrun}_dfile.1D
 	rm ${subrun}_blur.nii*
 	rm ${subrun}_automask.nii*
 	rm ${subrun}_mean.nii*
 	rm ${subrun}_scale.nii*
 	rm ${subrun}_scale.txt
 	rm ${subrun}_scale.jpg
 	rm *motion_${subrun}*
	# Remove output from deconvolove_tap.sh
	rm 3dDeconvolve.err
	rm ${submod}_irf.nii*
	rm ${subrunmod}.xmat.1D
	rm ${subrunmod}.xmat.jpg
	rm ${subrunmod}_bucket.nii*
	rm ${subrunmod}_fitts.nii*
	# Remove output from bucket_tap.sh
	rm ${submod}_Coef.nii*
	rm *_Coef.nii*
	rm ${submod}_Tstat.nii*
	rm *_Tstat.nii*
	rm ${submod}_Fstat.nii*
	rm *_Fstat.nii*
	rm ${subcond}_Full_Fstat.nii*
	rm *_Full_Fstat.nii*
	rm ${submod}_peak.nii*
	rm *peak_irf.nii*
	rm ${submod}_peak2.nii*
	rm ${submod}_peak2_irf.nii*
	# Begin purge of the ANOVA data files
	cd ${anova_dir}
	rm ${submod}_peak+tlrc*
	rm ${submod}_peak2+tlrc*
	rm ${submod}_Coef+tlrc*
	rm ${submod}_Tstat+tlrc*
	rm ${submod}_Fstat+tlrc*
	rm ${subcond}_Full_Fstat+tlrc*
	rm ${runcond}_ANOVA_Results+tlrc*
	rm log.${runcond}.ANOVA.txt
	################################################################################################
	#Purge the Anatomical directory
	cd ${anat_dir}
	#Remove FSE and SPGR related files
	rm ${fse}*
	rm ${spgr}*
	mv e[0-9][0-9][0-9][0-9]s[2789]i* ../Struc
####################################################################################################
elif [ "${2}" = "preprocess" ]; then
	####################################################################################################
	# Move the unpacked pfiles and efiles to their respective directories
	cd ${orig_dir}
	mv SP1.* ../SP1
	mv SP2.* ../SP2
	mv TP1.* ../TP1
	mv TP2.* ../TP2
	####################################################################################################
	# Remove output from the reconstruct.sh
	rm log.${subrun}.reconstruct.txt
	rm ${subrun}_epan*
	rm ${subrun}_outliers.txt
	rm ${subrun}_outs*
	rm ${subrun}_outliers.jpg
	####################################################################################################
	# Remove output from register.sh
	rm log.${subrun}.register.txt
	rm ${subrun}_tcat*
	rm ${subrun}_tshift*
	rm ${subrun}_volreg*
	rm ${subrun}_dfile.1D
	rm ${subrun}_blur.nii*
	rm ${subrun}_automask.nii*
	rm ${subrun}_mean.nii*
	rm ${subrun}_scale*
	rm *motion_${subrun}*
####################################################################################################
elif [ "${2}" = "GLM" ]; then
	rm log.${subrun}.deconvolve.txt
	rm log.${subrun}.bucket.txt
	rm log.${subrun}.adwarp.txt
	rm 3dDeconvolve.err
	rm ${submod}.xmat*
	rm ${subrunmod}_fitts*
	rm ${subrunmod}_bucket*
	rm ${submod}*_irf*
	rm ${submod}*_peak*
	rm ${submod}*_peak2*
	################################################################################################
	# Remove output from bucket_tap.sh
	rm ${submod}_Coefi*
	rm ${submod}_Tstat*
	rm ${submod}_Fstat*
	rm ${subcond}_Full_Fstat*
####################################################################################################
elif [ "${2}" = "reconstruct" ]; then # This only applies to functional data, use All to remove anat
	# Remove output from the reconstruct.sh
	cd ${orig_dir}
	mv SP1.* ../SP1
	mv SP2.* ../SP2
	mv TP1.* ../TP1
	mv TP2.* ../TP2
	################################################################################################
	cd ${run_dir}
	rm log.${subrun}.reconstruct.txt
	rm ${subrun}_epan*
	rm ${subrun}_outliers.txt
	rm ${subrun}_outs*
	rm ${subrun}_outliers.jpg
####################################################################################################
elif [ "${2}" = "register" ]; then
	# Remove output from register.sh
	rm log.${subrun}.register.txt
	rm ${subrun}_tcat*
	rm ${subrun}_tshift*
	rm ${subrun}_volreg*
	rm ${subrun}_dfile.1D
	rm ${subrun}_blur.nii*
	rm ${subrun}_automask.nii*
	rm ${subrun}_mean.nii*
	rm ${subrun}_scale*
	rm *motion_${subrun}*
####################################################################################################
	# # Begin purge of the ANOVA data files
	# cd ${anova_dir}
####################################################################################################
	# # Remove output from ANOVA_tap.sh
	# #if [ -f ${submod}_peak2+tlrc.HEAD -o ${subcond}_Full_Fstat+tlrc -o ${submod}_peak+tlrc ]; then
	# 	rm ${submod}_peak+tlrc*
	# 	rm ${submod}_peak2+tlrc*
	# 	rm ${submod}_Coef+tlrc*
	# 	rm ${submod}_Tstat+tlrc*
	# 	rm ${submod}_Fstat+tlrc*
	# 	rm ${subcond}_Full_Fstat+tlrc*
	# 	rm ${runcond}_ANOVA_Results+tlrc*
	# 	rm log.${runcond}.ANOVA.txt
	# #fi
####################################################################################################
	# # Purge the Anatomical directory
	# #cd ${anat_dir}
####################################################################################################
	# # Remove FSE and SPGR related files
	# # rm ${fse}*
	# # rm ${spgr}*
	# #mv e[0-9][0-9][0-9][0-9]s[2789]i* ../Struc
####################################################################################################
fi
