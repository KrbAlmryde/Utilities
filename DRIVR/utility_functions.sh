#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function jaccard_index
#				   
#		Originally written by Dianne Patterson 11/9/2011 
# 		Based on a dice_kappa calculation by Matt Petoe 11/2/2011
#	
#		Purpose:   This function uses the fsl toolbox and "bc" to calculate 
#				   the Jaccard Index and distance statistics for two binary 
#				   masks. The Jaccard Index measures the similarity between 
#				   two binary masks, and the Jaccard Distance calculates the  
#				   dissimilarity between those two images. 
#				   
#				   Note: The scale=6 variable sets the number of decimal
#				   places to use. See the link below for more information 
#				   about Jaccard Index.
#				   
#				   http://en.wikipedia.org/wiki/Jaccard_index
#
#		  Input:   
#				   
#
#		 Output:   
#				   
#				   
#----------------------------------------------------------------------------

function jaccard_index () 
{

	local roi1=$1 
	local roi2=$2

	local total_voxels1
	local total_voxels2
	local intersect_voxels
	local union_voxels
	local jaccard_index
	local jaccard_distance
			
	total_voxels1=`fslstats ${roi1} -V | awk '{printf $1 "\n"}'`
	total_voxels2=`fslstats ${roi2} -V | awk '{printf $1 "\n"}'`
	intersect_voxels=`fslstats ${roi1} -k ${roi2} -V | awk '{printf $1 "\n"}'`

	fslmaths ${roi1} -add ${roi2} -bin union
	union_voxels=`fslstats union -V | awk '{printf $1 "\n"}'`
	jaccard_index=`echo "scale=6; ${intersect_voxels}/${union_voxels}" | bc`
	jaccard_distance=`echo "scale=6; 1-(${intersect_voxels}/${union_voxels})" | bc`
	touch jaccard.txt
	echo "${roi1} ${roi2} ${jaccard_index} ${jaccard_distance}" >>${subrun}.jaccard.txt

	echo "total voxels ${roi1} is ${total_voxels1}" 
	echo "total voxels ${roi2} is ${total_voxels2}" 
	echo "intersect voxels are ${intersect_voxels}"
	echo "Jaccard distance is ${jaccard_distance}"
	echo "union voxels are ${union_voxels}" 
	echo "Jaccard index is ${jaccard_index}"
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function whereami_strip
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

function whereami_strip ()
{
	cat $1.txt \
		| colrm 10 73 		\
		| sed '/^#/d' 				\
		| tr -s '[:space:]' 		\
		| awk -v OFS='\t' '$1=$1' 	\
		| head -2 > $1.strip.txt

	whereami \
		-tab -atlas TT_Daemon 						\
		-coord_file $1.strip.txt'[4,5,6]' 				\
		| sed -n '/TT_Daemon/p' 						\
		| awk -v OFS='\t' '$1=$1 {print $2,$4,$5,$6}'	\
		| head -4 > $1.whereami.txt
}



	#----------------------------------------------------------------------------
	#		Function Mask_check
	#
	#		Purpose:   This function checks the current directory for the mask 
	# 				   file, and returns the 'maskfile' variable
	#
	#		  Input:   None; This function checks the directory only
	#
	#
	#		 Output:   'maskfile' variable. If ${subrun}.fullmask.edit.nii exists
	#					in the current direcotry, maskfile=fullmask.edit, 
	#					otherwise maskfile=fullmask.edit
	#
	#----------------------------------------------------------------------------
	
	function Mask_check ()
	{
		echo; echo "=========== Mask_check"; echo
		
		if [[ ! -e ${subrun}.fullmask.edit.nii ]]; then
			maskfile=fullmask
		else
			maskfile=fullmask.edit
		fi
	}
	

	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function zslice_func
	#
	#		Purpose:   This function determines the Z-slice direction. This
	#				   orientation will affect Reconstruction of the functional
	#				   data in addition to the FSE.
	#
	#		  Input:   Input is defined in the experiment profile
	#
	#
	#		 Output:   None, variable $z2 is defined based on the conditions of
	#				   $z1
	#
	#----------------------------------------------------------------------------
	
	function Zslice_func ()
	{
		if [[ ${z1} = S ]]; then
			z2=I
		elif [[ ${z1} = I ]]; then
			z2=S
		fi
	}
	
	
	
	
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function zslice_spgr
	#
	#		Purpose:   This function determines the Z-slice direction for the
	#				   structural image file (spgr). This orientation will affect
	#				   Reconstruction of the structural SPGR.
	#
	#		  Input:   Input is defined in the experiment profile
	#
	#
	#		 Output:   None, variable $z2spgr is defined based on the conditions
	#				   of $z1spgr
	#
	#----------------------------------------------------------------------------
	
	function Zslice_spgr ()
	{
		if [[ ${z1spgr} = R ]];then
			z2spgr=L
		elif [[ ${z1spgr} = L ]];	then
			z2spgr=R
		fi
	}




	#----------------------------------------------------------------------------
	#		Function Base_Reg
	#
	#		Purpose:   This function reads an outlier file looking for the lowest
	#				   integer prints the NUMBER line - (x) to account for time
	#				   shifting and AFNI's zero-based counting preference. This
	#				   allows us to acquire a base volume to Register our data to
	#				   using 3dVolreg. The line number is representative of the
	#				   volume in the dataset, and following the subtraction, fits
	#				   with AFNI's conventions.
	#
	#				   The variable (x) is supplied by the variable 'trunc' +1.
	#				   It represents the number of volumes truncated +1 to
	#				   account for 0-based counting.
	#				   See the ${experiment}_profile for information regarding
	#				   how 'trunc' is defined.
	#
	#		  Input:   A list containing the outlier count for each volume of
	#				   a functional run
	#
	#		 Output:   A single integer value representing the most stable
	#				   volume in the dataset, which will act as the base
	#				   volume during registration.
	#----------------------------------------------------------------------------
	
	function xBase_Reg ()
	{
		Study_Variables
		Truncate
	
		((x=$trunc+1))
		base=`cat -n \
			$ETC_prep/${subrun}.epan.outs.txt \
			| sort -k2,2n \
			| head -1 \
			| awk '{print $1-'$x'}'`
	}
	
	
	
	
	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function Outcount_Plot
	#
	#		Purpose:   This function will take the name of the file (e.g.
	#				   despike, tcat, tshift, etc) as input, and perform
	#				   3dToutcount to identify outliers time-points, then plot
	#				   the results using 1dplot
	#
	#		  Input:   The prefix name of the pre-processing step e.g. tshift
	#				   'Outcount_Plot tshift'
	#
	#		 Output:   ${subrun}.${step}.outs.txt, ${subrun}.${step}.outs.jpeg
	#
	#	  Variables:   proc, tail, infile
	#
	#----------------------------------------------------------------------------
	
	function Outcount_Plot ()
	{
		Study_Variables; cd $PREP_subj
	
		local proc=$1
	
		case $proc in
			scale )
				tail=nii.gz ;;
			* )
				tail=nii ;;
		esac
	
		local infile=$subrun.${proc}.${tail}
	
		3dToutcount \
			$infile \
			> $subrun.$proc.outs.txt
	
		1dplot \
			-jpeg $subrun.$proc.outs \
			$subrun.$proc.outs.txt
		
		mv $subrun.$proc.outs.* ${ETC_prep}
	}
	
	

