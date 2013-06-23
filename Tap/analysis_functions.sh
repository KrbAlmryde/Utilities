#!/bin/bash
#================================================================================
#	Program Name: analysis_functions.bash
#		  Author: Kyle Reese Almryde
#			Date: June 05 2012
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

	function analysis_roi_dump ()
	{
		local run=$1
		local type=$2
		local plvl=0.05
		local atlas=CA_N27_ML
		
		local ANAT=/Volumes/Data/TAP/ANAT
		local IMAGES=/Volumes/Data/TAP/IMAGES
		local MASK=/Volumes/Data/TAP/ANOVA/Masks
		local ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		local ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
		local LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
		local ORIG=/Volumes/Data/TAP/ANOVA/${run}/Thresh/0.05
		
		
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

		declare -a region=(`cat ${TAP}/ROIs.txt`) # counter = r
		
		local label=( mean.${run}.${ev1} 
					  mean.${run}.${ev2} 
					  contr.${run}.${ev1}-${ev2} 
					  contr.${run}.${ev2}-${ev1} )
					  
		local label2=( mean_${ev1} mean_${ev2} 
					  contr_${ev1}-${ev2} 
					  contr_${ev2}-${ev1} )
	
	
		roi1_mask ()
		{		
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
		
		
		for (( i = 0; i < ${#subj_list}; i++ )); do
		
			${ORIG}/${subj_high[0]}.${run}.${model}.${type}.stats+tlrc'[1]'
	
	
		clusterCoords () 
		{
			echo -e "#X\tY\tZ\tT-Max\tVolume\tCondition"

			for (( r=0; r<${#region[*]}; r++ )); do
				for (( l=0; l<${#label[*]}; l++ )); do 
					3dclust -orient LPI -nosum -1noneg -1Dformat 3.75 0 \
						${ROI}/roi.${plvl}.${type}.${region[r]}.${label[l]}+tlrc \
					| tail +13 \
					| awk -v OFS='\t' '{print $14, $15, $16, $13, $1, "'${label2[l]}'"}' \
					| sed '/#\*\*/d'
				done
			done
		}
	
		whereamiReport ()
		{
			roi_coord=$1
			echo -e "Side\tRegion of Interest"

			whereami \
				-lpi -ok_1D_text -atlas ${atlas} \
				-coord_file ${ROI}/${roi_coord}'[0,1,2]' \
				| egrep -C1 '^Atlas CA_N27_ML: Macro Labels \(N27\)$' \
				| egrep '^   Focus point|Within . mm' \
				| colrm 1 16 \
				| awk -v OFS='\t' '{print $1,$2" "$3" "$4" "$5" "$6}'
		}
			
		clusterCoords > ${ROI}/etc/coord_${type}.${run}.1D
		
		whereamiReport coord_${type}.${run}.1D \
			> ${ROI}/etc/whereami_${type}.${run}.1D
	
		paste \
			${ROI}/etc/whereami_${type}.${run}.1D \
			${ROI}/etc/coord_${type}.${run}.1D \
			> ${TAP}/report_${type}.${run}.1D


	}

3dcalc -


