#!/bin/sh

# This program is a work in progress, it is designed to test the fitted-ness
# of an alignment between a subjects brain and a standard brain. Ideally, it 
# compare the overlap between two masks of anatomical images (standard and subject)
# and see how well they overlap. If they have a nice fit, then the program
# proceeds with the standard preprocessing pipeline, if it doesnt fit well, then
# it will run an alternative algorithm until it does fit. 

for subj in TS004; do

	run=SP1
	subrun=${subj}.${run}
	spgr=${subj}.spgr
	fse=${subj}.fse

	function base_reg ()
	{ 
	awk '/  [0-9] / {print NR-5;exit}' ${subrun}.outliers.txt
	}

	function jaccard_index () 
	{
	roi1=$1
	roi2=$2
	total_voxels1=`fslstats ${roi1} -V | awk '{printf $1 "\n"}'`
	echo "total voxels ${roi1} is ${total_voxels1}" 
	total_voxels2=`fslstats ${roi2} -V | awk '{printf $1 "\n"}'`
	echo "total voxels ${roi2} is ${total_voxels2}" 
	intersect_voxels=`fslstats ${roi1} -k ${roi2} -V | awk '{printf $1 "\n"}'`
	echo "intersect voxels are ${intersect_voxels}"
	fslmaths ${roi1} -add ${roi2} -bin union
	union_voxels=`fslstats union -V | awk '{printf $1 "\n"}'`
	echo "union voxels are ${union_voxels}" 
	jaccard_index=`echo "scale=6; ${intersect_voxels}/${union_voxels}" | bc`
	echo "Jaccard index is ${jaccard_index}"
	jaccard_distance=`echo "scale=6; 1-(${intersect_voxels}/${union_voxels})" | bc`
	echo "Jaccard distance is ${jaccard_distance}"
	touch jaccard.txt
	echo "${roi1} ${roi2} ${jaccard_index} ${jaccard_distance}" >>jaccard.txt
	}

####################################################################################################
	cd $TAP/${subj}/Test
####################################################################################################
	echo "----------------------------------- Test_reg.sh -------------------------------------"
	echo "------------------------------------- ${subrun} -----------------------------------------"
	echo ""
####################################################################################################
	echo "----------------------------------- 3dTcat ----------------------------------- "
 	3dTcat -verb -prefix ${subrun}.tcat.nii ${subrun}.epan.nii'[4..$]'

	3dDespike -prefix ${subrun}.despike.nii -ssave ${subrun}.spikes.nii ${subrun}.tcat.nii

	3dTshift -verbose -tzero 0 -rlt+ -quintic -prefix ${subrun}.tshift.nii ${subrun}.despike.nii
	
	3dvolreg -verbose -verbose -zpad 4 -base ${subrun}.tshift.nii[`base_reg`] -1Dfile \
		${subrun}.dfile.1D -prefix ${subrun}.volreg.nii -cubic ${subrun}.tshift.nii
	
	1dplot -jpeg ${subrun}.volreg -volreg -xlabel TIME ${subrun}.dfile.1D

	3dmerge -1blur_fwhm 6.0 -doall -prefix ${subrun}.blur.vr.nii ${subrun}.volreg.nii
	
	3dAutomask -prefix ${subrun}.vr.automask.nii ${subrun}.blur.vr.nii
	
	3dTstat -prefix ${subrun}.mean.vr.nii ${subrun}.blur.vr.nii

	3dcalc -verbose -float -a ${subrun}.blur.vr.nii -b ${subrun}.mean.vr.nii \
		-c ${subrun}.vr.automask.nii -expr 'c * min(200, a/b*100)' \
		-prefix ${subrun}.scale+orig
 
####################################################################################################
echo "-------------------------------- align_epi_anat.py ----------------------------------"
echo "--------------------------- ${spgr}+orig => ${fse}+orig ---------------------------"
echo "-------------------------------  ${spgr}_al+orig ----------------------------------- "
echo ""
####################################################################################################
# Align the SPGR to the FSE with the assumption that the FSE is in all ways identical to the
# functional data. This way the SPGR will theoretically match the functional data in terms of
# orientation. Following the applicaton of align_epi_anat.py we need to perform 3drefit on the
# newly created ${spgr}_al+orig in order to reset talairach markers, as align_epi_anat.py removes
# them completely.

	align_epi_anat.py -dset1to2 -big_move -dset1 ${spgr}+orig -dset2 ${fse}+orig -cost lpa
	
	@NoisySkullStrip -input ${fse}+orig 
	3dAutomask -prefix mask.${fse}.nii ${fse}.ns+orig
	3dAutomask -prefix mask.${spgr}_al.nii ${spgr}_al+orig
####################################################################################################
	echo ""
	echo "The Jaccard index measures the similarity between 2 sample sets" 
	echo "The Jaccard distance measures the dissimilarity between 2 sample data sets"
	echo ""
####################################################################################################
# This will eventually be a program which tests how good the alignment is, then decides whether to 
# perform a different alignment operation or move forward
	
	jaccard_index mask.${fse}.nii mask.${spgr}_al.nii
	
	if [ "$jaccard_distance" -ge .8 ]; then
		echo "Alignment looks good!!"
	elif [ "$jaccard_distance" -lt .8 ]; then
		
		rm ${spgr}_al+orig*
		rm mask.${spgr}_al.nii

		align_epi_anat.py -dset1to2 -cmass cmass -dset1 ${spgr}+orig -dset2 ${fse}+orig \
			-cost lpa -suffix _cmass
	
		3dAutomask -prefix mask.${spgr}_cmass.nii ${spgr}_cmass+orig
	
		jaccard_index mask.${fse}.nii mask.${spgr}_al.nii
	
		if [ "$jaccard_distance" -ge .8 ]; then
			echo "Alignment looks good!!"
		elif [ "$jaccard_distance" -lt .8 ]; then
			echo "Fuckit, try something else"
		fi
	fi
#################################################################################################
echo "-------------------------------- 3drefit ----------------------------------"
echo ""
####################################################################################################
	if (${spgr}_al+orig); then
		3drefit -markers ${spgr}_al+orig
		spgr=${spgr}_al
	else
		3drefit -markers ${spgr}_cmass+orig
		spgr=${spgr}_cmass
	fi	

	echo "Removing temporary files"
	rm __tt_${spgr}*
	rm __tt_${fse}*
####################################################################################################
echo "------------------------------------- @auto_tlrc -------------------------------------"
echo ""
####################################################################################################
# Check to see that the talairached spgr is in the $anat_dir, if not, warp it to talairach space.
# This will create a Talairached version of the Fse-aligned SPGR. If this step has already been
# completed the program will skip this step and move on to the next block.
		@auto_tlrc -no_ss -base TT_N27+tlrc -input ${spgr}+orig -suffix NONE
##################################################################################################
echo "------------------------------------- adwarp -------------------------------------"
echo "------------------------------ ${subrun}.scale+orig --------------------------------"

	adwarp -apar ${spgr}+tlrc -dpar ${subrun}.scale+orig
		
		3dAutomask -prefix mask.${spgr} ${spgr}+tlrc
		3dAutomask -prefix mask.${subrun}.scale ${subrun}.scale+tlrc[`base_reg`]

	jaccard_index mask.${spgr}+tlrc mask.${subrun}.scale+tlrc
####################################################################################################
	echo "The Jaccard index measures the similarity between 2 sample sets" 
	echo "The Jaccard distance measures the dissimilarity between 2 sample data sets"
####################################################################################################

	if [ "$jaccard_distance" -ge .8 ]; then
		echo "Alignment looks good!!"
	elif [ "$jaccard_distance" -lt .8 ]; then
		echo "Fuckit, try something else"		
	fi

#		rm ${subrun}.scale+tlrc
#		rm mask.${subrun}.scale+tlrc

#		align_epi_anat.py -epi2anat -master_tlrc 1 -cmass cmass -epi ${subrun}.scale+orig \
#			-epi_base 0 -prep_off -epi_strip None -anat ${spgr}_cmass+orig -anat_has_skull no \
#			-tlrc_apar ${spgr}+tlrc
	
#		3dAutomask -prefix mask.${spgr}_cmass.nii ${spgr}_cmass+orig
	
#		jaccard_index mask.${spgr}+tlrc mask.${subrun}.scale+tlrc
	
#		if [ "$jaccard_distance" -ge .8 ]; then
			echo "Alignment looks good!!"
#		elif [ "$jaccard_distance" -lt .8 ]; then
#			echo "Fuckit, try something else"
#		fi
#	fi

#		align_epi_anat.py -epi2anat -master_tlrc 1 -epi ${subrun}.scale.vr+orig \
#			-epi_base 0 -prep_off -epi_strip None -anat ${spgr}+orig -anat_has_skull no \
#			-tlrc_apar ${spgr}+tlrc

#		align_epi_anat.py -epi2anat -master_tlrc 1 -cmass cmass -epi ${subrun}.scale.cmass+orig \
#			-epi_base 0 -prep_off -epi_strip None -anat ${spgr}_cmass+orig -anat_has_skull no \
#			-tlrc_apar ${spgr}_cmass+tlrc


#		adwarp -apar ${spgr}+tlrc -dpar ${subrun}.scale+orig

#################################################################################################
#	cp ${fse}* $TAP/TEST
#	cp ${spgr}_al+* $TAP/TEST
#	cp ${spgr}_cmass+* $TAP/TEST	
#	cp ${subrun}.scale.* $TAP/TEST
#	cp ${subrun}.*.automask.nii $TAP/TEST
#	cp ${subrun}.blur.*.nii $TAP/TEST

done

align_epi_anat.py -dset1to2 -cmass cmass -dset1 TS004.spgr+orig -dset2 TS004.fse+orig -cost lpa -suffix _cmass

@auto_tlrc -no_ss -base TT_N27+tlrc -input TS004.spgr_cmass+orig -suffix NONE




