#!/bin/bash
#================================================================================
#	Program Name: tap_analysis.bash
#		  Author: Kyle Reese Almryde
#			Date: May 11 2012
#
#	 Description: Builds the Long file for input into R. 
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


plvl=0.05



subj=( $( basename $( ls -d /Volumes/Data/TAP/TS*) ) )
run=$1

j=0

for (( s=0; s<${#subj[*]}; s++ )); do
		
	REVIEW=/Volumes/Data/TAP/REVIEW/ANOVA
	ETC=/Volumes/Data/TAP/REVIEW/ANOVA/${run}/etc
	
	BEHAV=/Volumes/Data/TAP/${subj[$s]}/Behav/${run}
	
	LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
	ANOVA=/Volumes/Data/TAP/ANOVA/${run}
	ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
	ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI/${plvl}
	THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh/${plvl}
	
		
	case ${run} in
		SP1 )
			ev=( animal food )
			ev1=( Animal Food ) 
			;;
		TP1 )
			ev=( old new )
			ev1=( O N ) 
			;;
		[ST]P2 )
			ev=( male female )
			ev1=( Male Female )
		;;
	esac
	
	ref=$s
	
	hemi=( L R )
	
	label=( mean_${ev[0]} mean_${ev[1]} )
	
	roi=( $( basename $( ls ${LORES}/mask*+tlrc.HEAD ) | cut -d . -f4 | sed 's/+tlrc//' ) ) 
	#72 items, 
	#	0-35 left hem
	#	36-71 right hem
	
	
	#========================================================================
	# Dprime Calucluation Variables 
	#========================================================================
	
	# Correct Accecpts
	hits=$( egrep -c "${ev1[0]}.*[1]$" ${BEHAV}/stacked.${subj[$s]}.${run}.txt )
	
	# Incorrect Accepts
	miss=$( egrep -c "${ev1[0]}.*[0]$" ${BEHAV}/stacked.${subj[$s]}.${run}.txt )
	
	# Total possible Hits
	((total_hits=$hits+$miss))
	
	# Correct Rejects				
	cr=$( egrep -c "${ev1[1]}.*[1]$" ${BEHAV}/stacked.${subj[$s]}.${run}.txt )
	
	# False Alarms
	fa=$( egrep -c "${ev1[1]}.*[0]$" ${BEHAV}/stacked.${subj[$s]}.${run}.txt )
	
	# Total possible Correct Rejects
	((total_cr=$cr+$fa))
	
	# Hit Rate
	hitRate=$(echo "scale=2; ($hits)/($total_hits)" | bc)
		
		if [[ ${hitRate} = '0' ]]; then
			hitRate='.01'
		elif [[ ${hitRate} = '1.00' ]]; then
			hitRate='.99'
		fi
	
	# False Alarm Rate
	faRate=$(echo "scale=2; ($fa)/($total_cr)" | bc)
	
		if [[ ${faRate} = '0' ]]; then
			faRate='.01'
		elif [[ ${faRate} = '1.00' ]]; then
			faRate='.99'
		fi
	
	# Dprime score
	dprime=$( echo "( qnorm("$hitRate")-qnorm("$faRate") )" | R --slave | cut -c 5-12 ) 
	
	
	#========================================================================
	# Intensity, and Voxel Size
	#========================================================================
	# l is for the label vector; 0,1 (2)
	# b is for the subbrik vector; 0,4 (2)
	# r is for the region vector; 0,71 (72); 0-35 -> left side, 36-71 -> right side
	
	for (( l=0, b=1; l<${#label[*]}; l++, b+=3 )); do
	
		for (( r=0; r < ${#roi[*]}; r++ )); do	
			echo -e "${roi[$r]} $( \
				3dMaskave -mask \
						${ROI}/roi.${plvl}.${run}.${label[$l]}.stats+tlrc"[${r}]" \
						${ORIG}/${subj[$s]}.${run}.GAM.stats+tlrc"[${b}]" )" \
			>> ${ETC}/rm.roi.${subj[$s]}.${run}.${plvl}.${label[$l]}.txt
		done

	
	
		sed -e 's/$/ 0 0/g' ${ETC}/rm.roi.${subj[$s]}.${run}.${plvl}.${label[$l]}.txt \
		> ${ETC}/roi.avg.${subj[$s]}.${run}.${plvl}.${label[$l]}.txt
	
	
		intensity=( $( awk '{print $2}' ${ETC}/roi.avg.${subj[$s]}.${run}.${plvl}.${label[$l]}.txt ) )
		voxel=( $( awk '{print $3}' ${ETC}/roi.avg.${subj[$s]}.${run}.${plvl}.${label[$l]}.txt | cut -c 2-4 ) )	
		
		header_print () # Prints Ref Subj Run Dprime Condition Hemisphere ROI Intensity	voxels
		{
			echo -e "Ref\tSubject\tRun\tDprime\tCondition\tHemisphere\tROI\tIntensity\tVoxels"
		}
	
	
	
	
		long_roi () # Prints <Ref> <Subject> <Run> <dPrime> <Condition> <Hemisphere> <ROI> <Intensity> <Voxel>
		{
			for (( i = 0; i < ${#intensity[*]}; i++ )); do

				if [[ $i -le 35 ]]; then
					h=0
				else
					h=1
				fi
					 #Ref  #Subject #Run	#dPrime		#Condition 	 # Hemisphere   # ROI	  #Intensity		 #Voxel
				echo -e "${ref}\t${subj[$s]}\t${run}\t${dprime}\t${label[$l]}\t${hemi[$h]}\t${roi[$i]}\t${intensity[$i]}\t${voxel[$i]}"
				
			done
		}
	
	
		case ${subj[$s]} in
			TS001 )
			
				header_print > ${REVIEW}/Long.ROI.txt
				long_roi >> ${REVIEW}/Long.ROI.txt
				;;
			TS0[01][0-9] )
		
				long_roi >> ${REVIEW}/Long.ROI.txt
				;;
		esac
	done
done

exit