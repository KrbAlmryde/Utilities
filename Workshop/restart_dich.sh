. $PROFILE/${1}_profile

echo "------------------------------- restart_tap.sh --------------------------------"
echo "-------------------------------- ${subrun} ------------------------------"

cd ${run_dir}
mv ${run}.* ../Orig
rm ${subrun}_epan*
rm ${subrun}_tcat*
rm ${subrun}_despike*
rm ${subrun}_spikes*
rm ${subrun}_tshift*
rm ${subrun}_volreg*
rm ${subrun}_blur*
rm ${subrun}_mean*
rm ${subrun}_scale*
rm ${subrun}_automask*
rm motion_${subrun}*
rm *.jpg
rm *${subrun}*.1D
rm ${subrun}*.txt
rm ${subrun}_out*
rm log.${subrun}.bucket.txt
rm log.${subrun}.register.txt
rm log.${subrun}.prep.txt
rm log.${subrun}.deconvolve.txt
rm 3dDeconvolve.err
rm ${submod}_fitts*
rm ${subcond}_irf*
rm ${subrun}_bucket*
rm ${subrun}_GAM*
rm ${submod}_WAV*
rm ${submod}_peak*
rm ${submod}_Coef*
rm ${submod}_Tstat*
rm ${submod}_Fstat*
rm ${subrun}*
#cd ${anat_dir}
# rm $fse*
# rm $spgr*
# rm $spgr_al*
# rm *spgr*+tlrc*
# rm *.1D



# cd ${anova_dir}
# rm ${run}
# rm *irf*

cd ${orig_dir}
mv TV.* ../TV
mv PL.* ../PL
mv UF.* ../UF
mv FR.* ../FR
mv FL.* ../FL
#mv e[0-9][0-9][0-9][0-9]s[789]i* ../struc
#mv e[0-9][0-9][0-9][0-9]s2i* ../struc
