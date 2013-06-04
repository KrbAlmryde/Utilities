####################################################################################################
#
# This is a prep script designed to perform to3d on functional Pfiles and anatomical e-files in
# order to create epan, spgr, and fse files respectively
####################################################################################################
. $UTL/${1}_profile

cd ${func_dir}
####################################################################################################
# Based on the value of z1 designate I or S as the direction of the top z
# slice and the other as the bottom
####################################################################################################
if [ ${z1} = S ]
then
	z2=I
else
	if [ ${z1} = I ]
	then
		z2=S
	fi
fi
####################################################################################################
# Based on the value of z1spgr designate L or R as the direction of the top z
# slice and the other as the bottom
####################################################################################################
if [ ${z1spgr} = R ]
then
	z2spgr=L
else
	if [ ${z1spgr} = L ]
	then
		z2spgr=R
	fi
fi
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This is an collection of echos to allow the user to keep track of whats going on from within the
# terminal application

echo "------------------------------------------ prep.sh -------------------------------------"
echo "------------------------------------- ${runnm} -----------------------------------------"
####################################################################################################
# Perform to3d on the raw unpacked P files, perform any byte swapping that needs to be done on the
# functional dataset, then graph the result. See the experiment profile if the appropriate parameter
# variables are not provided
####################################################################################################
# if [ ! -e ${runnm}_epan+orig.HEAD ]
# then
#
# 	echo ""
# 	echo "reconstructing ${runnm}_epan....."
# 	echo ""
#
# 	to3d -epan -prefix ${runnm}_epan -2swap -text_outliers -save_outliers ${runnm}_outliers.txt \
# 		-xFOV ${halffov}R-L -yFOV ${halffov}A-P -zSLAB ${z}${z1}-${z}${z2} -time:tz ${nfs} ${nas} \
# 		${tr} @${UTL}/offsets.1D ${run}.*
#
# 	1dplot -jpeg ${runnm}_outliers ${runnm}_outliers.txt
#
# 	3dToutcount -save ${runnm}_outs ${runnm}_epan+orig | 1dplot -jpeg ${runnm}_outs \
# 		-stdin ${runnm}_outs+orig
#
# 	echo "Move unpacked P files to their own directory so we can keep things clean"
#
# 	mv ${run}.* ../Orig
#
# fi
# ####################################################################################################
# # Perform preprocessing steps for structural data
# cd ${anat_dir}
# ####################################################################################################
# echo "Have efiles been renamed?"
# echo ""
#
# if [ ! -e ${fse}+orig.HEAD ]
# then
# 	echo "Nope, renaming fse efiles"
# 	rename_fse e*s2
#
# 	echo "reconstructing ${fse}....."
# 	to3d -fse -prefix ${fse} -xFOV ${halffov}R-L -yFOV ${halffov}A-P -zSLAB \
# 		${z}${z1}-${z}${z2} e*2i*
#
# 	echo "Moving efiles to Orig directory so we can keep things clutter free!"
# 	mv e*2i* ../Orig
#
# fi
####################################################################################################
if [ ! -e ${spgr}+orig.HEAD ]
then
	echo "rename spgr efiles"
	rename_spgr e*s7

	echo "reconstructing ${spgr}....."
	to3d -spgr -prefix ${spgr} -xFOV ${anatfov}A-P -yFOV ${anatfov}S-I -zSLAB \
		${zspgr}${z1spgr}-${zspgr}${z2spgr} e*7i*

	echo "Move unpacked P files to their own directory so we can keep things clean"
	mv e*7i* ../Orig

fi
####################################################################################################
# if [ ! -e ${spgr}_al+orig.HEAD ]
# then
# 	align_epi_anat.py -dset1to2 -dset1 ${spgr}+orig -dset2 ${fse}+orig -cost lpa
#
# 	rm __tt_${spgr}*
# 	rm __tt_${fse}*
#
# 	echo "Removing temporary files"
#
# fi
# ####################################################################################################
#
#
#
# echo "reconstruction of ${runnm} is complete"
# echo ""
