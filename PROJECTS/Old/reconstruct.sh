. $PROFILE/${1}_profile.sh
####################################################################################################
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This is a prep script designed to perform to3d on functional Pfiles and anatomical e-files in
# order to create epan, spgr, and fse files respectively
####################################################################################################

cd ${prep_dir}
####################################################################################################
# Based on the value of z1 designate I or S as the direction of the top z
# slice and the other as the bottom
####################################################################################################
if [ ${z1} = S ]; then
	z2=I
elif [ ${z1} = I ]; then
	z2=S
fi
####################################################################################################
# Based on the value of z1spgr designate L or R as the direction of the top z
# slice and the other as the bottom
####################################################################################################
if [ ${z1spgr} = R ];then
	z2spgr=L
elif [ ${z1spgr} = L ];	then
	z2spgr=R
fi
####################################################################################################
# Perform to3d on the raw unpacked P files, perform any byte swapping that needs to be done on the
# functional dataset, then graph the result. See the experiment profile if the appropriate parameter
# variables are not provided
####################################################################################################
if [ ! -e ${subrun}.epan.nii ]; then
####################################################################################################
	echo "----------------------------------- reconstruct.sh ----------------------------------"
	echo "------------------------------------- ${subrun} --------------------------------------"
	echo ""
	echo "reconstructing ${subrun}.epan....."

	to3d -epan -prefix ${subrun}.epan.nii -2swap -text_outliers -save_outliers ${subrun}.outliers.txt \
		-xFOV ${halffov}R-L -yFOV ${halffov}A-P -zSLAB ${z}${z1}-${z}${z2} -time:tz ${nfs} ${nas} \
		${tr} @${STIM}/offsets.1D ${run}.*

	1dplot -jpeg ${subrun}.outliers ${subrun}.outliers.txt

	3dToutcount -save ${subrun}.outs.nii ${subrun}.epan.nii | 1dplot -jpeg ${subrun}.outs \
		-stdin ${subrun}.outs.nii

	echo "Move unpacked P files to their own directory so we can keep things clean"
	mv ${run}.* ../Orig
	mv *jpeg etc/
#	cp ${subrun}.epan.nii ${ICA_dir}
fi
####################################################################################################
# Perform preprocessing steps for structural data
####################################################################################################
cd ${anat_dir}
if [ ! -e ${fse}+orig.HEAD ]; then
####################################################################################################
	echo "------------------------------------- ${fse} --------------------------------------"
	echo ""

	echo "Renaming fse efiles"
#	rename_fse e[0-9][0-9][0-9][0-9]s2i

	echo "reconstructing ${fse}....."
	to3d -fse -prefix ${fse} -xFOV ${halffov}R-L -yFOV ${halffov}A-P -zSLAB \
		${z}${z1}-${z}${z2} e[0-9][0-9][0-9][0-9]s2i*

	mv e[0-9][0-9][0-9][0-9]s2i* ../Orig
####################################################################################################
fi
if [ ! -e ${spgr}+orig.HEAD ]; then
####################################################################################################
	echo "------------------------------------- ${spgr} --------------------------------------"
	echo ""

	echo "Renaming spgr efiles"
#	rename_spgr e[0-9][0-9][0-9][0-9]s[789]i

	echo "reconstructing ${spgr}....."
	to3d -spgr -prefix ${spgr} -xFOV ${anatfov}A-P -yFOV ${anatfov}S-I -zSLAB \
		${zspgr}${z1spgr}-${zspgr}${z2spgr} e[0-9][0-9][0-9][0-9]s[789]i*

	mv e[0-9][0-9][0-9][0-9]s[789]i* ../Orig
####################################################################################################
fi
