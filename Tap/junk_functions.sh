#!/bin/bash
#================================================================================
#	Program Name: junk_functions.bash
#		  Author: Kyle Reese Almryde
#			Date: May 04 2012
#
#	 Description: 
#				  
#				  
#
#	Deficiencies: 
#				  
#				  
#				  
#				  
#
#================================================================================
#								START OF MAIN
#================================================================================


	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

	
	function regress_synthesize ()
	{
		local subj run model
		local GLM
	
		subj=$1; run=$2; model=GAM
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
	
		3dSynthesize \
			-cbucket ${GLM}/${subj}.${run}.${model}.cbuc+tlrc \
			-matrix ${GLM}/${subj}.${run}.${model}.xmat.1D \
			-select baseline 5 \
			-prefix ${GLM}/${subj}.${run}.${model}.synthesized+tlrc
	}
	
	
	
	function func_hist ()
	{
		local run group brik
		local ANOVA ANOVAMask
	
		run=$1; group=$2; brik=$3 infile=$4 thresh=$5
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks
	
		3dhistog \
			-dind $brik \
			-mask ${ANOVAMask}/N27.mask+tlrc \
			-min ${thresh} \
			-prefix ${ANOVA}/${infile}.${thresh}.histout \
			${ANOVA}/${infile}+tlrc
	
	#			anova.${run}.stats+tlrc
	
		1dRplot \
			-input ${ANOVA}/${infile}.${thresh}.histout.1D
	}
	
	
	function anova_group ()
	{
		#------------------------------------------------------------------------
		#		Function
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------
	
		local run model subj_group ev1 ev2
		local ANOVA ORIG
	
		run=$1; model=GAM
		subj_group=( TS001 TS002 TS003 TS004 TS005 TS006 TS007 TS008 TS009\
					 TS010 TS011 TS012 TS013 TS014 TS015 TS016 TS017 TS018 )
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}/Group
		ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
	
		cd ${ORIG}
	
		case $run in
			SP1 )
				ev1=animal
				ev2=food
				;;
			TP1 )
				ev1=old
				ev2=new
				;;
			SP2 | TP2 )
				ev1=male
				ev2=female
				;;
		esac
	
	
		3dANOVA2 \
			-type 3 -alevels 2 -blevels 16 \
			-dset 1 1 ${subj_group[0]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 1 ${subj_group[0]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 2 ${subj_group[1]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 2 ${subj_group[1]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 3 ${subj_group[2]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 3 ${subj_group[2]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 4 ${subj_group[3]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 4 ${subj_group[3]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 5 ${subj_group[4]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 5 ${subj_group[4]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 6 ${subj_group[5]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 6 ${subj_group[5]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 7 ${subj_group[6]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 7 ${subj_group[6]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 8 ${subj_group[7]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 8 ${subj_group[7]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 9 ${subj_group[8]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 9 ${subj_group[8]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 10 ${subj_group[9]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 10 ${subj_group[9]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 11 ${subj_group[10]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 11 ${subj_group[10]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 12 ${subj_group[11]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 12 ${subj_group[11]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 13 ${subj_group[12]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 13 ${subj_group[12]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 14 ${subj_group[13]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 14 ${subj_group[13]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 15 ${subj_group[14]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 15 ${subj_group[14]}.${run}.${model}.stats+tlrc'[4]' \
			-dset 1 16 ${subj_group[15]}.${run}.${model}.stats+tlrc'[1]' \
			-dset 2 16 ${subj_group[15]}.${run}.${model}.stats+tlrc'[4]' \
			-amean 1 ${ANOVA}/mean.group.${run}.${ev1} \
			-amean 2 ${ANOVA}/mean.group.${run}.${ev2} \
			-acontr 1 -1 ${ANOVA}/contr.group.${run}.${ev1}-${ev2} \
			-acontr -1 1 ${ANOVA}/contr.group.${run}.${ev2}-${ev1} \
			-bucket ${ANOVA}/anova.group.${run}.stats
	
		3drefit \
			-sublabel 0 ${ev1} \
			-sublabel 2 ${ev2} \
			-sublabel 4 Contr${ev1} \
			-sublabel 6 Contr${ev2} \
			${ANOVA}/anova.group.${run}.stats+tlrc
	}
	
	

	
	function anova_cleanup ()
	{
		local run group
		local ANOVA ANOVA_orig
	
		run=$1; group=$2;
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ANOVA_orig=/Volumes/Data/TAP/ANOVA/${run}/Orig
	
		if [[ ! -e TS001.${run}.GAM.stats+tlrc.HEAD ]]; then
			mv ${ANOVA}/${group}.ClustSim.* ${ANOVA_orig}
		else
			mv ${ANOVA}/TS0*.${run}.GAM.stats+tlrc.* ${ANOVA_orig}
			mv ${ANOVA}/${group}.ClustSim.* ${ANOVA_orig}
		fi
	}
	
	
	function anova_ipad_mask ()
	{
		#------------------------------------------------------------------------
		#		Function   mask_calc
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------
	
		local run brik brik2 plvl
		local ANOVA MASKs ROIs THRESH DBOX
	
		run=$1; plvl=$2; label=$3
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ROI=/Volumes/Data/TAP/ANOVA/${run}/ROIs
		MASK=/Volumes/Data/TAP/ANOVA/${run}/Masks
	
	
		if [[ ! -e ${DBOX}/merge.${run}.p${plvl}_${label}.nii ]]; then
	
			3dAFNItoNIFTI \
				-prefix ${DBOX}/merge.${run}.p${plvl}_${label}.nii \
				${ANOVA}/merge.${run}.p${plvl}.stats+tlrc"[${label}]"
	
		else
	
			# Specify template space and add template label.
			3drefit \
				-space TLRC \
				-sublabel 0 ${label} \
				${MASK}/tmp.mask.${run}.p${plvl}_${label}.nii
	
			# Convert nifti to brik/head
			3dcalc \
				-a ${MASK}/tmp.mask.${run}.p${plvl}_${label}.nii \
				-expr 'a' \
				-prefix ${MASK}/rm.mask.${run}.p${plvl}.${label}+tlrc \
	
			# resample to ensure mask is in same grid space
			3dresample \
				-master ${ANOVA}/anova.${run}.stats+tlrc"[${label}]" \
				-prefix ${MASK}/mask.${run}.p${plvl}.${label}+tlrc \
				-inset ${MASK}/rm.mask.${run}.p${plvl}.${label}+tlrc
	
			# filter thresholded image through mask
			3dcalc \
				-a ${ANOVA}/merge.${run}.p${plvl}.stats+tlrc"[${label}]" \
				-b ${MASK}/mask.${run}.p${plvl}.${label}+tlrc \
				-expr 'a * b' \
				-prefix ${ROI}/roi.${run}.p${plvl}_${label}+tlrc
	
			# Bucket mask images together to keep them sorted
			3dbucket \
				-aglueto ${ANOVA}/mask.${run}.stats+tlrc \
				${MASKs}/mask.${run}.p${plvl}.${label}+tlrc
	
			# Bucket roi images together to keep them sorted
			3dbucket \
				-aglueto ${ANOVA}/roi.${run}.p${plvl}.stats+tlrc \
				${ROIs}/roi.${run}.p${plvl}_${label}+tlrc
	
			# remove the temporary files
			rm ${MASKs}/*.mask.${run}.p${plvl}*${label}*
	
		fi
	}
	
	
	function threshmask ()
	{
		local run group brik thresh plvl alvl clust
		local ANOVA ANOVAMask
	
		run=$1; group=$2; brik=$3 thresh=$4
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks
	
		3dcalc \
			-a ${ANOVA}/anova.${run}.stats+tlrc'['${brik}']' \
			-expr 'ispositive(a-'${thresh}')' \
			-prefix ${run}.mask.${thresh}
	}
	
	
	
	
	function anova_upper ()
	{
		local run model ev1 ev2
		local ANOVA
	
		run=$1; model=GAM;
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
	
		cd $ANOVA
	
		case $run in
			SP1 | TP1 )
	
				if [[ $run = SP1 ]]; then
					ev1=animal
					ev2=food
				else
					ev1=old
					ev2=new
				fi
	
				3dANOVA2 \
					-type 3 -alevels 2 -blevels 7 \
					-dset 1 1 TS001.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 1 TS001.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 2 TS002.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 2 TS002.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 3 TS004.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 3 TS004.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 4 TS005.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 4 TS005.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 5 TS007.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 5 TS007.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 6 TS011.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 6 TS011.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 7 TS013.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 7 TS013.${run}.${model}.stats+tlrc'[4]' \
					-amean 1 mean.${run}.${model}.${ev1} \
					-amean 2 mean.${run}.${model}.${ev2} \
					-acontr 1 -1 contr.${run}.${model}.${ev1}-${ev2} \
					-acontr -1 1 contr.${run}.${model}.${ev2}-${ev1} \
					-bucket anova.${run}.upper.stats
				;;
			SP2 | TP2 )
	
				ev1=female
				ev2=male
	
				3dANOVA2 \
					-type 3 -alevels 2 -blevels 7 \
					-dset 1 1 TS001.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 1 TS001.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 2 TS002.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 2 TS002.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 3 TS005.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 3 TS005.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 4 TS007.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 4 TS007.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 5 TS011.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 5 TS011.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 6 TS012.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 6 TS012.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 7 TS014.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 7 TS014.${run}.${model}.stats+tlrc'[4]' \
					-amean 1 mean.${run}.${model}.${ev1} \
					-amean 2 mean.${run}.${model}.${ev2} \
					-acontr 1 -1 contr.${run}.${model}.${ev1}-${ev2} \
					-acontr -1 1 contr.${run}.${model}.${ev2}-${ev1} \
					-bucket anova.${run}.upper.stats
				;;
		esac
	}
	
	
	function anova_lower ()
	{
		local run model ev1 ev2
		local ANOVA ANOVAMask
	
		run=$1; model=GAM;
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
	
		cd $ANOVA
	
		case $run in
			SP1 | TP1 )
	
				if [[ $run = SP1 ]]; then
					ev1=animal
					ev2=food
				else
					ev1=old
					ev2=new
				fi
	
				3dANOVA2 \
					-type 3 -alevels 2 -blevels 7 \
					-dset 1 1 TS003.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 1 TS003.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 2 TS006.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 2 TS006.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 3 TS008.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 3 TS008.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 4 TS009.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 4 TS009.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 5 TS010.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 5 TS010.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 6 TS012.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 6 TS012.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 7 TS014.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 7 TS014.${run}.${model}.stats+tlrc'[4]' \
					-amean 1 mean.${run}.${model}.${ev1} \
					-amean 2 mean.${run}.${model}.${ev2} \
					-acontr 1 -1 contr.${run}.${model}.${ev1}-${ev2} \
					-acontr -1 1 contr.${run}.${model}.${ev2}-${ev1} \
					-bucket anova.${run}.lower.stats
				;;
			SP2 | TP2 )
				ev1=female
				ev2=male
	
				3dANOVA2 \
					-type 3 -alevels 2 -blevels 7 \
					-dset 1 1 TS003.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 1 TS003.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 2 TS004.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 2 TS004.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 3 TS006.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 3 TS006.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 4 TS008.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 4 TS008.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 5 TS009.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 5 TS009.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 6 TS010.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 6 TS010.${run}.${model}.stats+tlrc'[4]' \
					-dset 1 7 TS013.${run}.${model}.stats+tlrc'[1]' \
					-dset 2 7 TS013.${run}.${model}.stats+tlrc'[4]' \
					-amean 1 mean.${run}.${model}.${ev1} \
					-amean 2 mean.${run}.${model}.${ev2} \
					-acontr 1 -1 contr.${run}.${model}.${ev1}-${ev2} \
					-acontr -1 1 contr.${run}.${model}.${ev2}-${ev1} \
					-bucket anova.${run}.lower.stats
				;;
		esac
	}
	
	
	function fwhmx_fix ()
	{
		local subj run fwhmx
		local GLM ANOVA ANOVAMask
	
		for subj in ${subj_list}; do
			for run in ${run_list}; do
	
				GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
				ANOVA=/Volumes/Data/TAP/ANOVA/${run}
	
				fwhmx=`3dFWHMx \
				-dset ${GLM}/${subj}.${run}.GAM.errts+tlrc \
				-mask ${GLM}/${subj}.${run}.fullmask+tlrc \
				-combine -detrend`
	
				echo $fwhmx >> ${ANOVA}/${run}.FWHMx.txt
	
			done
		done
	}
	
	
	function cluster_max ()
	{
		#----------------------------------------------------------------------------
		#		Function
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		# Threshold was set to 3.25 based on a preliminary scan of functional data
		#				I increased this to 4.25
		# Radius of sphere is set to 5 x 3.75^3 voxels
		#				I have changed this to 1 because the spheres were too large
		# minimum distance was set to 6 voxel to ensure that no overlap occurs
		#							# change this to 3
		#----------------------------------------------------------------------------
	
		local run group brik thresh
		local ANOVA ANOVAMask
	
		run=$1; brik=$2 thresh=$3
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks
	
		3dMaxima \
			-input ${ANOVA}/anova.${run}.stats+tlrc'['${brik}']' \
			-prefix ${ANOVA}/${run}.maxima_${thresh}.${brik} \
			-spheres_Nto1 \
			-thresh ${thresh} \
			-out_rad 1 \
			-min_dist 1 \
			-overwrite \
			-debug 2 \
			| head -n 1 \
			>> ${run}.maxima_${thresh}.${brik}.1D
	
		3dExtrema \
			-prefix ${run}.extrema_${thresh}.${brik} \
			-session ${ANOVA} \
			-mask_file ${ANOVAMask}/N27.mask+tlrc \
			-data_thr ${thresh} \
			-sep_dist 2 \
			-strict \
			-closure \
			-volume \
			${ANOVA}/anova.${run}.stats+tlrc'['${brik}']' \
			| tail -n 1 \
			>> ${run}.extrema_${thresh}.${brik}.1D
	}
	
	
	function cluster_calc ()
	{
		#------------------------------------------------------------------------
		#		Function
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------
	
		local run brik clust thresh plvl
		local ANOVA ANOVAMask
	
		run=$1;
	
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks
	
		cd ${ANOVA}
	
		3dcalc \
			-a ${run}.extrema_p05_min0.1+tlrc \
			-b ${run}.extrema_p04_min0.1+tlrc \
			-c ${run}.extrema_p03_min0.1+tlrc \
			-d ${run}.extrema_p02_min0.1+tlrc \
			-e ${run}.extrema_p015_min0.1+tlrc \
			-f ${run}.extrema_p01_min0.1+tlrc \
			-g ${run}.extrema_p007_min0.1+tlrc \
			-h ${run}.extrema_p005_min0.1+tlrc \
			-i ${run}.extrema_p003_min0.1+tlrc \
			-expr 'a+b+c+d+e+f+g+h+i' \
			-prefix ${run}.extrema_overlap
	
		3dcalc \
			-a ${run}.extrema_p05_min0.1+tlrc \
			-b ${run}.extrema_p04_min0.1+tlrc \
			-c ${run}.extrema_p03_min0.1+tlrc \
			-d ${run}.extrema_p02_min0.1+tlrc \
			-e ${run}.extrema_p015_min0.1+tlrc \
			-f ${run}.extrema_p01_min0.1+tlrc \
			-g ${run}.extrema_p007_min0.1+tlrc \
			-h ${run}.extrema_p005_min0.1+tlrc \
			-i ${run}.extrema_p003_min0.1+tlrc \
			-expr '(a-b-c-d-e-f-g-h-i)' \
			-prefix ${run}.extrema_underlap
	
		3dclust \
			-nosum \
			-1Dformat 0 0 \
			${run}.extrema_overlap+tlrc \
			> ${run}.extrema_overerlap.1D
	
		3dclust \
			-nosum \
			-1Dformat 0 0 \
			${run}.extrema_underlap+tlrc \
			> ${run}.extrema_underlap.1D
	}
	
	


