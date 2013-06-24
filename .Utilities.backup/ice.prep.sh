#!/bin/bash
#================================================================================
#	Program Name: ice.setup.sh
#		  Author: Kyle Reese Almryde
#			Date: September 7th, 2012
#
#	 Description: This script will construct the directory structure for the 
#                 Iceword project, as well as input 
#                 
#                 
#                 
#                 
#                 
#                 
#          Notes: 
#                 
#	Deficiencies: 
#
#================================================================================
#                             VARIABLE DEFINITIONS
#================================================================================

operation=$1

#---------------------------------#
#       Directory Pointers        #
#---------------------------------#
ICE=/Volumes/Data/Iceword
OLDICE=/Volumes/Data/ETC/ICEWORD

#---------------------------------#
#       Function Variables        #
#---------------------------------#
tr=2400 	# repetition time in milliseconds
nfs=218     # number of functional scans
nas=22 		# number of functional slices
fov=220 	# field of view for functional and FSE
thick=6 	# Z-slice thickness for functional and FSE
z=63.00     
hfov=110.00


#---------------------------------#
#         Array Variables         #
#---------------------------------#
subnum=( sub001 sub002 sub003
		 sub004 sub005 sub006 
		 sub007 sub008 sub009 
		 sub010 sub011 sub012 
		 sub013 sub014 sub015 
		 sub016 sub017 sub018 sub019 )

mrinum=( E24545 E24810 E24811 
		 E24812 E25018 E25019 
		 E25112 E25113 E25114 
		 E25877 E25878 E25879 
		 E3151  E3885  E3987  
		 E4025  E4091  E4429  E4430 )


#================================================================================
#                            FUNCTION DEFINITIONS 
#================================================================================


#------------------------------------------------------------------------
#
#	Description: setup_ice
#                
#		Purpose: Build the directory structure of the new Iceword project
#                and copy over any required files needed to start 
#                processing. 
#
#		  Input: none
#                
#		 Output: Complex directory system with embeded files
#                
#	  Variables: subnum == array of subject numbers
#                mrinum == array of MRI experiement numbers, order within
#                          the array corresponds with the subnum array
#                
#------------------------------------------------------------------------

function setup_ice ()
{
	
	mkdir -p ${ICE}/${subnum[i]}/{Access,Func/{Run${num}/Raw,RealignDetails},Morph/{Seg,Raw},Pictures,RealignDetails,Reg,SubjectROIs}

	cp -n ${OLDICE}/${mrinum[i]}/${run}/P* ${ICE}/${subnum[i]}/Func/Run${num}/Raw/

	enum=`echo ${mrinum[i]} | sed -e 's/E//'`

	if [[ -e ${OLDICE}/${mrinum[i]}/struct/spgr/${mrinum[i]}S* ]]; then
		cp -n ${OLDICE}/${mrinum[i]}/struct/spgr/${mrinum[i]}S* ${ICE}/${subnum[i]}/Morph/Raw/
		cp -n ${OLDICE}/${mrinum[i]}/struct/fse/${mrinum[i]}S* ${ICE}/${subnum[i]}/Morph/Raw/
	else
		cp -n ${OLDICE}/${mrinum[i]}/struct/spgr/${enum}* ${ICE}/${subnum[i]}/Morph/Raw/
		cp -n ${OLDICE}/${mrinum[i]}/struct/fse/${enum}* ${ICE}/${subnum[i]}/Morph/Raw/

	fi

	echo ${mrinum[i]} | sed -e 's/E//' > ${ICE}/${subnum[i]}/MRNUM.txt
}


#------------------------------------------------------------------------
#
#	Description: setup_pfile
#                
#		Purpose: Unpack Pfiles
#                
#		  Input: 
#                
#		 Output:   
#                
#	  Variables: 
#                
#------------------------------------------------------------------------

function get_info() {
	echo -e "S${i} Run${num}\n" >> ${ICE}/Report_Run${num}.txt
	3dinfo \
		/Volumes/Data/ETC/ICEWORD/S${i}/combos/prelim/S${i}-reg-run${num}+orig \
		>> ${ICE}/Report_Run${num}.txt
}



#------------------------------------------------------------------------
#
#	Description: build_epan
#                
#		Purpose: This will construct the epan files from the raw unpacked
#                p-files. In addition it will ensure the data is in the
#                correct orientation
#                
#		  Input: 
#                
#		 Output:   
#                
#	  Variables: tr=2400 == repetition time
#                nfs=218 == number of functional scans
#                nas=22  == number of functional slices
#                fov=220 == field of view
#                thick=6 == z-slice thickness
#                
#                
#                
#------------------------------------------------------------------------

function build_epan ()
{
	if [[ ! -e ${FUNC}/${run}_${subj}.nii.gz ]]; then
	
		echo "${RAW}/run${num}."
		cd ${RAW}
		to3d -epan -2swap -prefix ${run}_${subnum[i]}.nii.gz -session ${FUNC} \
			-2swap -text_outliers -save_outliers ${FUNC}/${run}_${subj}_outliers.txt \
			-xFOV 120R-L -yFOV 120A-P -zSLAB 63S-63I -time:tz 218 22 2400 \
			seqminus run${num}.\*
	else

		echo "${run}_${subj}.nii.gz already exists!!"

	fi
}

function build_fse ()
{
	#------------------------------------------------------------------------
	#		Function   	build_fse
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
	cd ${MORPH}/Raw/
	
	if [[ ! -e ${MORPH}/Raw/${mrinum[i]}S[23]I* ]]; then
		input=`echo ${mrinum[i]} | sed -e 's/E//'`.[23].1.
	else
		input=${mrinum[i]}S[23]I
	fi
	
	
	if [[ ! -e ${MORPH}/${subj}_fse.nii.gz ]]; then
		to3d \
			-fse \
			-prefix ${subj}_fse.nii.gz \
			-session ${MORPH} \
			-xFOV 120R-L \
			-yFOV 120A-P \
			-zSLAB 63S-63I \
			${input}*
	else
		echo "${subj}_fse.nii.gz already exists!!"

	fi

}


function build_spgr ()
{
	#------------------------------------------------------------------------
	#		Function   build_spgr
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

	local subj nasspgr thickspgr z1spgr z2spgr fovspgr zspgr anatfov
	local ORIG STRUC

	subj=$1

	cd ${MORPH}/Raw/
	if [[ ! -e ${MORPH}/Raw/${mrinum[i]}S[45]I* ]]; then
		input=`echo ${mrinum[i]} | sed -e 's/E//'`.[45].1.
	else
		input=${mrinum[i]}S[45]I
	fi

	if [[ ! -e ${MORPH}/${subnum[i]}_spgr.nii.gz ]]; then
		to3d \
			-spgr \
			-prefix ${subnum[i]}_spgr.nii.gz \
			-session ${MORPH} \
			-xFOV 125.05A-P \
			-yFOV 125.052S-I \
			-zSLAB 92.25L-92.25R \
			${input}*
	else
		echo "${subnum[i]}_spgr.nii.gz already exists!!"
	fi
}

#------------------------------------------------------------------------
#
#	Description: Main
#                
#		Purpose: Main execution method, contains the loop which iterates
#                over the runs. It also sets some pointers
#		  Input: 
#                
#		 Output:   
#                
#	  Variables: 
#                
#------------------------------------------------------------------------

function Main ()
{
	num=$1
	operation=$2

	for (( i = 0; i < ${#subnum[*]}+1; i++ )); do
	#---------------------------------#
	#       Directory Pointers        #
	#---------------------------------#
		MORPH=${ICE}/${subnum[i]}/Morph
		FUNC=${ICE}/${subnum[i]}/Func/Run${num}
		RAW=${FUNC}/Raw
		RD=${FUNC}/${Run}/RealignDetails
		

	#---------------------------------#
	#       Function Variables        #
	#---------------------------------#
		run=run${num}
		#pfile=$(basename $(ls ${RAW}/P*))


	#---------------------------------#
	#       Begin Function Calls      #
	#---------------------------------#

		case $operation in
			"setup" )
					# setup_ice
					get_info
				;;
			"build" )
					  # build_epan
					  build_fse
					  build_spgr
				;;
		esac
	done
		
}


#================================================================================
#                                START OF MAIN
#================================================================================


for run in {1..3}; do

	Main $run $operation

done

