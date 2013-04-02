#!/bin/bash
#================================================================================
#	Program Name: anova_functions.bash
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


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#						ANOVA Functions
#
# Includes functions for performing the ANOVA(s), Alpha Correction, and
# thresholding
#
# The current list of functions under this heading include :
#					anova_group
#					anova_alphacorr
#					anova_merge_cluster
#					anova_mask_gen
#					anova_mask_calc
#
#
#
#
#
# Note: Each step should be performed in the order listed above as they are
# 		dependant on the previous for the proper input.
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	function anova_alphacorr ()
	{
		#------------------------------------------------------------------------
		#		Function   alphacorr
		#
		#		Purpose:   This program performs a family-wise error correction
		#				   on the statistical output of the 3dANOVA2 program. It
		#				   the program 3dClustSim developed by the AFNI software
		#				   team.
		#
		#
		#
		#		  Input:   anova.${run}.stats+tlrc
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------

		local run fwhmx fwhmy fwhmz
		local ANOVA ORIG MASK

		run=$1 type=$2

		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
		MASK=/Volumes/Data/TAP/ANOVA/Masks

		fwhmx=$(awk -v OFS=' ' '{ sum+=$1 } END { print sum/NR }' \
				${ANOVA}/${run}.${type}.FWHMx.txt)

		fwhmy=$(awk -v OFS=' ' '{ sum+=$2 } END { print sum/NR }' \
				${ANOVA}/${run}.${type}.FWHMx.txt)

		fwhmz=$(awk -v OFS=' ' '{ sum+=$3 } END { print sum/NR }' \
				${ANOVA}/${run}.${type}.FWHMx.txt)


		3dClustSim \
			-both -NN 123 \
			-mask ${MASK}/N27.mask+tlrc \
			-fwhmxyz "${fwhmx}" "${fwhmy}" "${fwhmz}" \
			-prefix ${ETC}/${run}.ClustSim.${type}

<<_
		cd ${ETC}

		3drefit -atrstring AFNI_CLUSTSIM_MASK file:${run}.ClustSim.${type}.mask \
			-atrstring AFNI_CLUSTSIM_NN1  file:${run}.ClustSim.${type}.NN1.niml \
			-atrstring AFNI_CLUSTSIM_NN2  file:${run}.ClustSim.${type}.NN2.niml \
			-atrstring AFNI_CLUSTSIM_NN3  file:${run}.ClustSim.${type}.NN3.niml \
			${ANOVA}/anova.${type}.${run}.stats+tlrc
_
	}





	function anova_colapsed ()
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

		local run ev1 ev2 subj_high subj_low
		local ANOVA ETC ROI ORIG THRESH

		run=$1; type=$2; model=GAM;
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ETC=/Volumes/Data/TAP/ANOVA/${run}/Etc
		ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI
		ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
		THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh


		case $run in
			SP1 )
				subj_low=(TS014 TS015 TS016 TS005 TS012 TS003 TS018 TS006)
				subj_high=(TS004 TS007 TS002 TS001 TS011 TS017 TS008 TS010)
				;;
			SP2 )
				subj_low=(TS008 TS016 TS017 TS002 TS014 TS001 TS015 TS005)
				subj_high=(TS003 TS013 TS018 TS004 TS006 TS007 TS010 TS011)
				;;
			TP1 )
				subj_low=(TS006 TS016 TS008 TS014 TS010 TS012 TS011 TS002)
				subj_high=(TS013 TS003 TS017 TS001 TS004 TS005 TS015 TS007)
				;;
			TP2 )			
				subj_low=(TS010 TS012 TS006 TS015 TS013 TS014 TS004 TS016)
				subj_high=(TS003 TS008 TS001 TS002 TS011 TS017 TS007 TS005)
				;;
		esac
	
		if [[ $type == "basic" ]]; then
		
			case $run in
				SP1 ) ev1=animal
					  ev2=food   ;;
				SP2 ) ev1=male
					  ev2=female ;;
				TP1 ) ev1=old
					  ev2=new    ;;
				TP2 ) ev1=male
					  ev2=female ;;
			esac

		elif [[ $type == "match" ]]; then
			
			case $run in
				SP2 ) ev1=O_hits
					  ev2=O_miss ;;
				TP1 ) ev1=HitRate
					  ev2=FaRate    ;;
			esac
		
		elif [[ $type == "OLD" ]]; then
			
			case $run in
				TP1 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "NEW" ]]; then
					
			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		fi

		label=( 
				mean_${ev1} mean_${ev1}-t \
				mean_${ev2} mean_${ev2}-t \
				contr_${ev1} contr_${ev1}-t \
				contr_${ev2} contr_${ev2}-t \
			  )

		# alevels = upper and lower (2) 
		# blevels = ev1 ev2
		# clevels = Subjects (16) nested within the upper/lower (8) 

		3dANOVA3 \
			-type 5 -alevels 2 -blevels 2 -clevels 8 \
			-dset 1 1 1 ${ORIG}/${subj_high[0]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 1 ${ORIG}/${subj_high[0]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 2 ${ORIG}/${subj_high[1]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 2 ${ORIG}/${subj_high[1]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 3 ${ORIG}/${subj_high[2]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 3 ${ORIG}/${subj_high[2]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 4 ${ORIG}/${subj_high[3]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 4 ${ORIG}/${subj_high[3]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 5 ${ORIG}/${subj_high[4]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 5 ${ORIG}/${subj_high[4]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 6 ${ORIG}/${subj_high[5]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 6 ${ORIG}/${subj_high[5]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 7 ${ORIG}/${subj_high[6]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 7 ${ORIG}/${subj_high[6]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 1 1 8 ${ORIG}/${subj_high[7]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 1 2 8 ${ORIG}/${subj_high[7]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 1 ${ORIG}/${subj_low[0]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 1 ${ORIG}/${subj_low[0]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 2 ${ORIG}/${subj_low[1]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 2 ${ORIG}/${subj_low[1]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 3 ${ORIG}/${subj_low[2]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 3 ${ORIG}/${subj_low[2]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 4 ${ORIG}/${subj_low[3]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 4 ${ORIG}/${subj_low[3]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 5 ${ORIG}/${subj_low[4]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 5 ${ORIG}/${subj_low[4]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 6 ${ORIG}/${subj_low[5]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 6 ${ORIG}/${subj_low[5]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 7 ${ORIG}/${subj_low[6]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 7 ${ORIG}/${subj_low[6]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-dset 2 1 8 ${ORIG}/${subj_low[7]}.${run}.${model}.${type}.stats+tlrc'[1]' \
			-dset 2 2 8 ${ORIG}/${subj_low[7]}.${run}.${model}.${type}.stats+tlrc'[4]' \
			-bmean 1 ${ANOVA}/mean.${run}.${ev1}.${type} \
			-bmean 2 ${ANOVA}/mean.${run}.${ev2}.${type} \
			-bcontr 1 -1 ${ANOVA}/contr.${run}.${ev1}-${ev2}.${type} \
			-bcontr -1 1 ${ANOVA}/contr.${run}.${ev2}-${ev1}.${type} 

		anova_alphacorr ${run} ${type}

	}


	function anova_merge_cluster ()
	{
		#------------------------------------------------------------------------
		#		Function   merge_cluster
		#
		#		Purpose:   This program thresholds the statistical output data
		#				   from 3dANOVA2. It thresholds the data for both
		#				   conditions and at each corrected p/alpha threshold.
		#				   It is intended to facilitate the identification of
		#				   ROIs and masking.
		#
		#				   NOTE: I changed the code so the data is merged at 0.05
		#				   and only computes the %chage. I will fix this as needed
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------

		local run ev1 ev2 label option plvl clust statpar thresh j k l
		local ANOVA THRESH ETC type

		run=$1; type=$2; plvl=0.05

		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ETC=/Volumes/Data/TAP/ANOVA/${run}/Etc
		THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh/${plvl}

		if [[ $type == "basic" ]]; then
		
			case $run in
				SP1 ) ev1=animal
					  ev2=food   ;;
				SP2 ) ev1=male
					  ev2=female ;;
				TP1 ) ev1=old
					  ev2=new    ;;
				TP2 ) ev1=male
					  ev2=female ;;
			esac
		
		elif [[ $type == "dprime" ]]; then
			
			case $run in
				SP1 ) ev1=O.HitRate
					  ev2=O.FaRate   ;;
				TP1 ) ev1=HitRate
					  ev2=FaRate    ;;
			esac
		
		elif [[ $type == "match" ]]; then
			
			case $run in
				SP2 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "NEW" ]]; then
					
			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "OLD" ]]; then
			
			case $run in
				SP1 ) ev1=old
					  ev2=notold ;;
				* ) echo "This is for SP1 only!!"
					exit 0 ;;
			esac

		fi
		
		
		label=( mean.${run}.${ev1} \
				mean.${run}.${ev2} \
				contr.${run}.${ev1}-${ev2} \
				contr.${run}.${ev2}-${ev1} )

		for (( l=0; l<${#label[*]}; l++ )); do

			clust=$(awk 'match($1,'${plvl}'0000 ) {print $11}' \
					${ETC}/${run}.ClustSim.${type}.NN1.1D)

			statpar=$(3dinfo ${ANOVA}/${label[l]}.${type}+tlrc"[1]" \
					| awk '/statcode = fitt/ {print $6}')

			thresh=$(ccalc -expr "fitt_p2t(${plvl}0000,${statpar})")

			3dmerge -dxyz=1 \
				-1clust 1.01 ${clust} \
				-1thresh ${thresh} \
				-prefix ${THRESH}/merge.${type}.${label[l]} \
				${ANOVA}/${label[l]}.${type}+tlrc[1]
		done
				
	}


	function anova_mask_calc ()
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

		local run plvl hemi region r label l
		local ANOVA MASK ROI

		run=$1; type=$2; plvl=0.05; atlas=CA_N27_ML

		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
		LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
		ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI/${plvl}
		THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh/${plvl}
		REVIEW=/Volumes/Data/TAP/REVIEW/ANOVA/${run}/


		if [[ $type == "basic" ]]; then
		
			case $run in
				SP1 ) ev1=animal
					  ev2=food   ;;
				SP2 ) ev1=male
					  ev2=female ;;
				TP1 ) ev1=old
					  ev2=new    ;;
				TP2 ) ev1=male
					  ev2=female ;;
			esac
			
		elif [[ $type == "match" ]]; then
			
			case $run in
				TP1 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "NEW" ]]; then
					
			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "OLD" ]]; then
			
			case $run in
				SP1 ) ev1=old
					  ev2=notold ;;
				* ) echo "This is for SP1 only!!"
					exit 0 ;;
			esac
		
		fi
		

		label=( mean.${run}.${ev1} \
				mean.${run}.${ev2} \
				contr.${run}.${ev1}-${ev2} \
				contr.${run}.${ev2}-${ev1} )

		
		region=(`cat ${TAP}/ROIs`) # counter = r
		
		
		calc_mask () 
		{	
			local roi=$1
			
			for (( l = 0; l < ${#label[*]}; l++ )); do
				3dcalc \
					-a ${THRESH}/merge.${type}.${label[l]}+tlrc \
					-b ${LORES}/mask.LowRes.${roi}+tlrc \
					-expr 'a * b' \
					-prefix ${ROI}/roi.${type}.${label[l]}.${roi}+tlrc
			done
		}
		
		

		for (( r=0; r < ${#region[*]}; r++ )); do
			calc_mask ${region[r]} 		# filter thresholded image through mask
		done

	}




	roi_mask ()
	{
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

		region=(`cat ${TAP}/ROIs1.txt`)
		LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
		HIRES=/Volumes/Data/TAP/ANOVA/Masks/Hi-Res
		
		if [[ ! -e ${HIRES}/suma.mask.10.HiRes+tlrc.HEAD ]]; then 
			for (( i=0, j=1, k=3; i < ${#region[*]}; i++, j++, k++ )); do
				
				if [[ ! -e ${HIRES}/suma.mask.0.HiRes+tlrc.HEAD ]]; then 
					3dcalc \
						-a ${HIRES}/mask.HiRes.${region[0]}+tlrc \
						-b ${HIRES}/mask.HiRes.${region[1]}+tlrc \
						-c ${HIRES}/mask.HiRes.${region[2]}+tlrc \
						-expr 'step(a + b + c)' \
						-prefix ${HIRES}/suma.mask.0.HiRes+tlrc
				fi
	
	
				if [[ $k -ge ${#region[*]} ]]; then
					break
				else

					echo -e "\nsuma.mask.$i"
					echo ${region[k]}
					echo -e "suma.mask.$j\n"

					3dcalc \
						-a ${HIRES}/suma.mask.$i.HiRes+tlrc \
						-b ${HIRES}/mask.HiRes.${region[k]}+tlrc \
						-expr "a + step(b)*$k" \
						-prefix ${HIRES}/suma.mask.$j.HiRes+tlrc
				fi
			done
		else
			rm ${HIRES}/suma.mask.*.HiRes+tlrc.*
		fi

	}


	function whereami_strip ()
	{
		#----------------------------------------------------------------------------
		#		Function   whereami_strip
		#
		#		Purpose:   This string prints the contents of the file (cat),
		#				   removes columns 10-73 (colrm 10 73: This makes it so only
		#				   the Volume, Mean, Sem, Max Int, X, Y, and Z are printed)
		#				   then removes any rows that begin with "#" from the output
		#				   (sed '/^#/d') ((Note:^ represents the start of the line,
		#				   the 'd' means delete)) the "." Following that, it replaces
		#				   any combination of spaces within the text with a single
		#				   space (tr -s '[:space:]'), which it is itself replaced
		#				   with a tab (awk -v OFS='\t' '$1=$1') before limiting only
		#				   the first 2 rows of the text (head -2).
		#
		#		  Input:
		#
		#
		#		 Output:
		#
		#
		#----------------------------------------------------------------------------

		local run=$1
		local type=$2
		local plvl=0.05
		local atlas=CA_N27_ML
		
		local ANAT=/Volumes/Data/TAP/ANAT
		local ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		local MASK=/Volumes/Data/TAP/ANOVA/Masks
		local HIRES=/Volumes/Data/TAP/ANOVA/Masks/Hi-Res
		local LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
		local ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI/${plvl}

		
		if [[ $type == "basic" ]]; then
		
			case $run in
				SP1 ) ev1=animal
					  ev2=food   ;;
				SP2 ) ev1=male
					  ev2=female ;;
				TP1 ) ev1=old
					  ev2=new    ;;
				TP2 ) ev1=male
					  ev2=female ;;
			esac
			
		elif [[ $type == "OLD" ]]; then
			
			case $run in
				TP1 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "NEW" ]]; then
					
			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		fi


		declare -a region=(`cat ${TAP}/ROIs`) # counter = r
		
		local label=( mean.${run}.${ev1} 
					  mean.${run}.${ev2} 
					  contr.${run}.${ev1}-${ev2} 
					  contr.${run}.${ev2}-${ev1} )
					  
		local label2=( mean_${ev1} mean_${ev2} 
					  contr_${ev1}-${ev2} 
					  contr_${ev2}-${ev1} )

		clusterCoords () 
		{
			local roi=$1

			for (( l=0; l<${#label[*]}; l++ )); do 
				3dclust -orient LPI -nosum -1Dformat 3.75 0 \
					${ROI}/roi.${type}.${label[l]}.${roi}+tlrc \
				| tail +13 \
				| awk -v OFS='\t' '{print $14, $15, $16, $13, $1, "'${label2[l]}'"}' \
				| sed '/#\*\*/d'
			done
		}

		whereamiReport ()
		{
			local roi_coord=$1
			
			whereami \
				-lpi -ok_1D_text -atlas ${atlas} \
				-coord_file ${ROI}/${roi_coord}'[0,1,2]' \
			| egrep -C1 '^Atlas CA_N27_ML: Macro Labels \(N27\)$' \
			| egrep '^   Focus point|Within . mm' \
			| colrm 1 16 \
			| awk -v OFS='\t' '{print $1,$2" "$3" "$4}'
		}
			
		for (( r=0; r<${#region[*]}; r++ )); do
			clusterCoords ${region[r]} >> ${ROI}/${run}.${type}.roi_coord.1D
		done

		whereamiReport ${run}.${type}.roi_coord.1D > ${ROI}/${run}.${type}.whereami.1D

		paste \
			${ROI}/${run}.${type}.whereami.1D \
			${ROI}/${run}.${type}.roi_coord.1D \
			> ${ANOVA}/${run}.${type}.report.1D
	}


	#------------------------------------------------------------------------
	#		Function   summa_displays
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

	summa_displays ()
	{
		local type=$1
		local ANOVA=/Volumes/Data/TAP/ANOVA/
		local sp1=/Volumes/Data/TAP/ANOVA/SP1/Thresh/0.05
		local tp1=/Volumes/Data/TAP/ANOVA/TP1/Thresh/0.05
		
		local label=( mean.${run}.${ev1} 
					  mean.${run}.${ev2} 
					  contr.${run}.${ev1}-${ev2} 
					  contr.${run}.${ev2}-${ev1} )
					  
		if [[ $type == "basic" ]]; then
		
			case $run in
				SP1 ) ev1=animal
					  ev2=food   ;;
				SP2 ) ev1=male
					  ev2=female ;;
				TP1 ) ev1=old
					  ev2=new    ;;
				TP2 ) ev1=male
					  ev2=female ;;
			esac
			
		elif [[ $type == "match" ]]; then
			
			case $run in
				TP1 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "NEW" ]]; then
					
			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for TP1 only!!"
					exit 0 ;;
			esac
		
		elif [[ $type == "OLD" ]]; then
			
			case $run in
				SP1 ) ev1=old
					  ev2=notold ;;
				* ) echo "This is for SP1 only!!"
					exit 0 ;;
			esac
		
		fi
		
		3dcalc \
			-a ${sp1}/merge.OLD.${label[0]}+tlrc \
			-b ${tp1}/merge.${type}.${label[0]}+tlrc \
			-expr 'ispositive(a) + ispositive(b)*2' \
			-prefix ${ANOVA}/allResp_OLD_Encode_Retrieval+tlrc
			
		3dcalc \
			-a ${sp1}/merge.OLD.${label[2]}+tlrc \
			-b ${tp1}/merge.${type}.${label[2]}+tlrc \
			-expr 'ispositive(a) + ispositive(b)*2' \
			-prefix ${ANOVA}/allResp_OLD_DM_effect+tlrc
	}




	function anova_mask_gen ()
	{
		#------------------------------------------------------------------------
		#		Function   anova_mask_gen
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
		#----------------------------------------------
	
		local run hemi plvl atlas region r
		local ANOVA HIRES LORES
	
		run=$1; type=$2; plvl=0.05
		atlas=CA_N27_ML
	
		declare -a region=(`cat ${TAP}/ROIs`) # counter = r
	
		ANAT=/Volumes/Data/TAP/ANAT
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		MASK=/Volumes/Data/TAP/ANOVA/Masks
		HIRES=/Volumes/Data/TAP/ANOVA/Masks/Hi-Res
		LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
		ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI/${plvl}
		THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh/${plvl}

		case $run in
			SP1 )
				ev1=old
				ev2=notold			
				;;
			TP1 )
				ev1=old
				ev2=new
				;;
			* )
				echo "This is for SP1 only!!"
				exit
				;;
		esac

		label=( mean.${run}.${ev1} \
				mean.${run}.${ev2} \
				contr.${run}.${ev1}-${ev2} \
				contr.${run}.${ev2}-${ev1}
				)

		for (( r = 0; r < ${#region[@]}; r++ )); do
			echo "
			# Use whereami to generate atlas-defined mask
			whereami \
				-mask_atlas_region ${atlas}::${region[r]} \
				-prefix ${HIRES}/mask.HiRes.${region[r]}+tlrc
	
			# Bucket hires masks to keep things organized
			3dbucket \
				-aglueto ${MASK}/mask.HiRes.stats+tlrc \
				${HIRES}/mask.HiRes.${region[r]}+tlrc
	
	
			# Resample hires masks to 3.75 x 3.75 x 3.75
			3dfractionize \
				-template ${THRESH}/Etc/merge.${type}.${label[0]}+tlrc \
				-input ${HIRES}/mask.HiRes.${region[r]}+tlrc \
				-clip 0.3 -preserve  \
				-prefix ${LORES}/mask.LowRes.${region[r]}+tlrc
			
			"

			for (( l = 0; l < ${#label[@]}; l++ )); do
				3dcalc \
					-a ${THRESH}/Etc/merge.${type}.${label[l]}+tlrc \
					-b ${LORES}/mask.LowRes.${region[r]}+tlrc \
					-expr 'a * b' \
					-prefix ${ROI}/Etc/roi.${plvl}.${type}.${region[r]}.${label[l]}+tlrc
				
				# Bucket roi images together to keep them sorted
				3dbucket \
					-aglueto ${ROI}/roi.${plvl}.${type}.${label[l]}.stats+tlrc \
					${ROI}/Etc/roi.${plvl}.${type}.${region[r]}.${label[l]}+tlrc
				
				# Add label so we know what it is
				3drefit \
					-sublabel $r ${region[r]} \
					${ROI}/roi.${plvl}.${type}.${label[l]}.stats+tlrc
					
			done
						
		done
	
	}

