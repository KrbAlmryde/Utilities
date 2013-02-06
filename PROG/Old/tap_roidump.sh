#!/bin/bash
#================================================================================
#	Program Name: tap_roidump.bash
#		  Author: Kyle Reese Almryde
#			Date: June 07 2012
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


run=$1
type=$2
plvl=0.05

atlas=( CA_N27_ML TT_Daemon )
subnum=( $(basename $(ls -d /Volumes/Data/TAP/TS*)) )


ANAT=/Volumes/Data/TAP/ANAT
ANOVA=/Volumes/Data/TAP/ANOVA/${run}
ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res
ROI=/Volumes/Data/TAP/ANOVA/${run}/ROI/${plvl}
THRESH=/Volumes/Data/TAP/ANOVA/${run}/Thresh/${plvl}
REVIEW=/Volumes/Data/TAP/REVIEW/ANOVA/${run}/


x=( $(awk '{print $1}' ${run}.${type}.coords.txt) )
y=( $(awk '{print $2}' ${run}.${type}.coords.txt) )
z=( $(awk '{print $3}' ${run}.${type}.coords.txt) )



#------------------------------------------------------------------------
#	roi_drop: Uses 3dMaskdump to drop XYZ coords to 
#	usage: roi_drop <x> <y> <z>
#------------------------------------------------------------------------

roi_drop ()
{
	local x=$1
	local y=$2
	local z=$3
	
	for (( i = 0; i < ${#subnum[*]}; i++ )); do
		echo -ne "${subnum[i]} "
		3dMaskdump \
			-quiet -noijk -xyz \
			-dbox $x $y $z \
			${ORIG}/${subnum[i]}.${run}.GAM.${type}.stats+tlrc'[1,4]' \
		| awk '{print '${subnum[i]}', $4, $5}'
	done
}


#------------------------------------------------------------------------
#	whereami_strip: Use whereami to identify regions of interest
#	usage: whereami_strip <x> <y> <z>
#------------------------------------------------------------------------

whereami_strip ()
{
	local x=$1
	local y=$2
	local z=$3
	
	for (( i = 0; i < ${#subnum[*]}; i++ )); do
		whereami \
			-lpi -atlas ${atlas} $x $y $z \
		| egrep -C1 "^Atlas ${atlas}: Macro Labels \(N27\)$" \
		| egrep '^   Focus point|Within . mm' \
		| colrm 1 16 \
		| awk -v OFS='\t' '{print $1,$2" "$3" "$4}'
	done
}


#------------------------------------------------------------------------
#	
#	
#------------------------------------------------------------------------



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							 START OF MAIN
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++



if [ -f ${run}.${type}.report.txt ]; then

	echo "${run}.${type}.report.txt already exists! Removing..."

	rm ${run}.${type}.report.txt
	rm ${run}.${type}.roi_stats.txt
	rm ${run}.${type}.whereami.txt

else

	for (( j = 0; j < ${#x[*]}; j++ )); do
		roi_drop ${x[j]} ${y[j]} ${z[j]}         >> ${run}.${type}.roi_stats.txt
		whereami_strip ${x[j]} ${y[j]} ${z[j]}   >> ${run}.${type}.whereami.txt
	done
	
	paste \
		${run}.${type}.whereami.txt \
		${run}.${type}.roi_stats.txt \
		> ${run}.${type}.report.txt

	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	echo -e "Side\tRegion of Interest\t        Subject  X   Y   Z   Hits     Miss"
	echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	cat ${run}.${type}.report.txt

fi


