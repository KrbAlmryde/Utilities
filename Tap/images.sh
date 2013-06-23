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

run=$1
type=$2
plvl=0.05
atlas=CA_N27_ML


IMAGES=/Volumes/Data/TAP/IMAGES
ETC=/Volumes/Data/TAP/IMAGES/etc
ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
LORES=/Volumes/Data/TAP/ANOVA/Masks/Low-Res


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
		* ) echo "This is for SP2 only!!"
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
		TP1 ) ev1=O_hits
			  ev2=O_miss ;;
		* ) echo "This is for TP1 only!!"
			exit 0 ;;
	esac

fi

subnum=( TS006 TS016 TS008 TS014 TS010 TS012 TS011 TS002 \
		 TS013 TS003 TS017 TS001 TS004 TS005 TS015 TS007 )

dprime=( 1.028666 1.083259 1.111902 1.46564 \
         1.521242 1.577299 1.668948 1.709233 \
         1.721465 1.729138 1.836605 1.860254 \
         1.921941 2.030891 2.032949 2.079602 )

name=( mean_${ev1} mean_${ev2} )
label=( mean.${run}.${ev1} mean.${run}.${ev2} )

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                         Function Definition
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#       Diplay functions for SUMA model
#------------------------------------------------------------------------
#   sumaDisplay: Creates a combined ROI mask which is used to create a 
#                filtered map for the purposes of displaying activation
#                on a suma surface image.
#	usage: roi_drop <x> <y> <z>
#
#   Code is depreciated.
#------------------------------------------------------------------------

sumaDisplay ()
{
	echo "Depreciated code, modify first!"; exit 0

	local roi=$1 # ROIs, ROIs1, ROIs2 are appropriate options

	declare -a region=(`cat /Volumes/Data/TAP/${roi}.txt`) 

	if [[ ! -e ${HIRES}/suma.mask.8.HiRes+tlrc.HEAD ]]; then 
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

		3dfractionize \
			-template ${IMAGES}/OLD_Encode_Retrieval+tlrc \
			-input ${HIRES}/suma.mask.$i.HiRes+tlrc \
			-clip 0.3 -preserve \
			-prefix ${IMAGES}/suma.mask.$i.LoRes+tlrc

		3dcalc \
			-a ${IMAGES}/OLD_Encode_Retrieval+tlrc \
			-b ${IMAGES}/suma.mask.$i.LoRes+tlrc \
			-expr 'a * step(b)' \
			-prefix ${IMAGES}/encode_retrive2+tlrc

	else
		rm ${HIRES}/suma.mask.*.HiRes+tlrc.*
	fi
}


#------------------------------------------------------------------------
#	calcMask: Uses 3dcalc to create a filtered functional image of a region
#              of interest. Input is a region of interest mask
#	usage: calcMask <region of interest>
#------------------------------------------------------------------------

calcMask () 
{	
	local roi=$1
	
	for (( l = 0; l < ${#label[*]}; l++ )); do
		3dcalc \
			-a ${IMAGES}/merge.${type}.${label[l]}+tlrc \
			-b ${LORES}/mask.LowRes.${roi}+tlrc \
			-expr 'a * b' \
			-prefix ${ETC}/roi.${type}.${label[l]}.${roi}+tlrc
	done
}


#------------------------------------------------------------------------
#	clusterCoords: Uses 3dclust to generate a cluster report of a supplied
#                  region of interest, the output of which will be fed into
#                  the whereamiReport
#	usage: clusterCoords <region of interest>
#------------------------------------------------------------------------

clusterCoords () 
{
	local roi=$1

	for (( l=0; l<${#label[*]}; l++ )); do           
		3dclust -orient LPI -1noneg -nosum -1Dformat -dxyz=1 1.01 0 \
			${ETC}/roi.${type}.${label[l]}.${roi}+tlrc \
		| tail +13 \
		| awk -v OFS='\t' '{print $14, $15, $16, $13, $1, "'${name[l]}'", "'$run'"}' \
		| sed '/#\*\*/d'
	done
}


#------------------------------------------------------------------------
#	whereamiReport: Uses whereami to identify the region of interest from
#                   from the supplied coordinates. It limits the output to
#                   the bare minimum in tabular format for input to a 
#                   spreadsheet.
#	usage: whereamiReport [ <coordinate_file> || <x> <y> <z> ]
#------------------------------------------------------------------------

whereamiReport ()
{
	if [[ -z $2 && -z $3 ]]; then

		local roi_coord=$1
		
		whereami \
			-lpi -ok_1D_text -atlas ${atlas} \
			-coord_file ${IMAGES}/${roi_coord}'[0,1,2]' \
		| egrep -C1 '^Atlas CA_N27_ML: Macro Labels \(N27\)$' \
		| egrep '^   Focus point|Within . mm' \
		| colrm 1 16 \
		| awk -v OFS='\t' '{print $1,$2" "$3" "$4}'
	
	else
		
		local x=$1
		local y=$2
		local z=$3
		local cond=$4
		
		for (( i = 0; i < ${#subnum[*]}; i++ )); do
			echo -ne "$cond\t"
			whereami \
				-lpi -ok_1D_text -atlas ${atlas} $x $y $z \
			| egrep -C1 '^Atlas CA_N27_ML: Macro Labels \(N27\)$' \
			| egrep '^   Focus point|Within . mm' \
			| colrm 1 16 \
			| awk -v OFS='\t' '{print $1,$2" "$3" "$4}'
		done
	
	fi
}


#------------------------------------------------------------------------
#	roiDrop: Uses 3dMaskdump to drop XYZ coords to 
#	usage: roiDrop <x> <y> <z>
#------------------------------------------------------------------------

roiDrop ()
{
	local x=$1
	local y=$2
	local z=$3

	for (( i = 0; i < ${#subnum[*]}; i++ )); do
		echo -ne "${subnum[i]} "
		3dmaskave \
			-quiet \
			-nball $x $y $z 5 \
			${ORIG}/${subnum[i]}.${run}.GAM.${type}.stats+tlrc'[2,5]' \
		| tr '\n' ' ' \
		| awk -v OFS='\t' '{print '${subnum[i]}', '${dprime[i]}', $1, $2}'
	done
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#             The proceeding functions are used in the 
#             following functions. Dont be confused!!
# 
#              calcMask
#              clusterCoords
#              whereamiReport
#              roiDrop
# 
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++





#------------------------------------------------------------------------
#	roiReport: Executes the calcMask, clusterCoords, and whereamiReport
#              functions under one umbrella. Supply list of ROIs to report
#	usage: roiReport <ROIs[1,2]> 
#------------------------------------------------------------------------

roiReport ()
{
	local roi=$1 # ROIs ROIs1 ROIs2
	declare -a region=(`cat /Volumes/Data/TAP/${roi}.txt`) 

	# remove any existing files
	rm ${ETC}/roi.${type}.* 
	rm ${IMAGES}/${run}.${type}.roi_coord.1D
	rm ${IMAGES}/${run}.${type}.whereami.1D

	for (( r=0; r<${#region[*]}; r++ )); do
		calcMask ${region[r]} 		# filter thresholded image through mask
		clusterCoords ${region[r]} >> ${IMAGES}/${run}.${type}.roi_coord.1D
	done

	whereamiReport \
		${run}.${type}.roi_coord.1D \
		> ${IMAGES}/${run}.${type}.whereami.1D


	echo -e "Side\tRegion of Interest\tX\tY\tZ\tT-Max\tVolume\tCondition\tRun" \
		> ${IMAGES}/${run}.${type}.report.1D

	paste \
		${IMAGES}/${run}.${type}.whereami.1D \
		${IMAGES}/${run}.${type}.roi_coord.1D \
		> ${IMAGES}/${run}.${type}.tmp.1D

	cat ${IMAGES}/${run}.${type}.tmp.1D >> ${IMAGES}/${run}.${type}.report.1D
	rm ${IMAGES}/${run}.${type}.tmp.1D

	edit ${IMAGES}/${run}.${type}.report.1D
}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#          Subject functions for extracting ROIs 
#------------------------------------------------------------------------
#	subjectReport: Uses 3dMaskdump to drop XYZ coords to 
#	usage: subjectReport
#------------------------------------------------------------------------

subjectReport ()
{
	local x=( $(awk -F '\t' '{print $3}' ${IMAGES}/${run}.${type}.report.1D) )
	local y=( $(awk -F '\t' '{print $4}' ${IMAGES}/${run}.${type}.report.1D) )
	local z=( $(awk -F '\t' '{print $5}' ${IMAGES}/${run}.${type}.report.1D) )
	local cond=( $(awk -F '\t' '{print $8}' ${IMAGES}/${run}.${type}.report.1D) )

	# remove existing files
	rm ${IMAGES}/${run}.${type}.subj_stats.1D
	rm ${IMAGES}/${run}.${type}.subj_whereami.1D
	
	
	for (( j = 1; j < ${#x[*]}; j++ )); do
		roiDrop ${x[j]} ${y[j]} ${z[j]} \
			>> ${IMAGES}/${run}.${type}.subj_stats.1D

		whereamiReport ${x[j]} ${y[j]} ${z[j]} ${cond[j]} \
			>> ${IMAGES}/${run}.${type}.subj_whereami.1D
	done


	paste \
		${IMAGES}/${run}.${type}.subj_whereami.1D \
		${IMAGES}/${run}.${type}.subj_stats.1D \
	| awk \
		-v OFS='\t' \
		-F '\t' '{print $4, $1, $2, $3, $5, $6, $7}' \
	| perl \
		-pe 's/(^TS006.*$)/\nSubject\tCondition\tSide\tRegion of Interest\tDprime\tHits\tMiss\n$1/' \
	> ${IMAGES}/${run}.${type}.Subject_Report.1D

	subl ${IMAGES}/${run}.${type}.Subject_Report.1D # This calls up Sublime Text 2 so we can look at the finished product
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#                           START OF MAIN
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

cat <<_

	Select which operation you would like to perform on the current data
	
	1 | diplay )  Use for generating Suma display
	2 | report )  Use to create region of interest report from group data
	3 | subject ) Use to create report of activation for single subjects
_

read operation

cat <<_

	Which ROI list would you like to use? 

	1 | ROIs )  Short list of regions of interest
	2 | ROIs1 ) Longer list of regions of interest
	3 | ROIs2 ) BIG list of regions of interest
_

read roi

case $roi in
	1 ) roi=ROIs    ;;
	2 ) roi=ROIs1   ;;
	3 ) roi=ROIs2   ;;
	* ) roi=$roi    ;;
esac


case $operation in
	1 | diplay ) sumaDisplay $roi     ;; # Use for generating Suma display
	2 | report )  roiReport $roi      ;; # Use to create region of interest report from group data
	3 | subject ) subjectReport		  ;; # Use to create report of activation for single subjects
esac



