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



function setup_ice () {
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

	mkdir -p ${ICE}/${subnum[i]}/{Access,Func/Run${num}/RealignDetails,Morph/Seg,Pictures,Reg,SubjectROIs}

	enum=`echo ${mrinum[i]} | sed -e 's/E//'`

	echo ${mrinum[i]} | sed -e 's/E//' > ${ICE}/${subnum[i]}/MRNUM.txt
}



function get_info () {
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
	echo -e "S${i} Run${num}\n" >> ${ICE}/Report_Run${num}.txt
	3dinfo \
		/Volumes/Data/ETC/ICEWORD/S${i}/combos/prelim/S${i}-reg-${run}+orig \
		>> ${ICE}/Report_Run${num}.txt
}



function populate_dirs () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Copy files from old dir and place them in the new ice_word
    #           folder. Files to be grabbed are the functional and anatomical
    #           images.
    #
    #    Input: None
    #
    #   Output: None
    #
    #------------------------------------------------------------------------

    enum=`echo ${mrinum[i]} | sed -e 's/E//'`

    echo "${subnum[i]}, ${run}";
    echo `ls  ${OLDICE}/${mrinum[i]}/struct/spgr/S*`

    if [[ -e ${OLDICE}/${mrinum[i]}/struct/spgr/S*spgr+orig.BRIK ]]; then
        cp -n ${OLDICE}/${mrinum[i]}/struct/spgr/S*spgr+orig* ${ICE}/${subnum[i]}/Morph/
    else
        echo "Missing ${subnum[i]} SPGR!!"
    fi


    if [[ -e ${OLDICE}/${mrinum[i]}/struct/fse/S*fse+orig.BRIK ]]; then
        cp -n ${OLDICE}/${mrinum[i]}/struct/fse/S*fse+orig* ${ICE}/${subnum[i]}/Morph/
    else
        echo "Missing ${subnum[i]} FSE!!"
    fi


    if [[ -e ${OLDICE}/${mrinum[i]}/combos/prelim/S*reg-${run}+orig.BRIK ]]; then
        cp -n ${OLDICE}/${mrinum[i]}/combos/prelim/S*reg-${run}+orig* ${ICE}/${subnum[i]}/Func/Run${num}/

    elif [[ -e ${OLDICE}/${mrinum[i]}/combos/prelim/S*${run}-reg+orig.BRIK ]]; then
        cp -n ${OLDICE}/${mrinum[i]}/combos/prelim/S*${run}-reg+orig* ${ICE}/${subnum[i]}/Func/Run${num}/
    else
        echo "Missing ${subnum[i]} Functional Image!!"
    fi

} # End of populate_dirs




function Main () {
    #------------------------------------------------------------------------
    #
    #	Description: Main
    #
    #		Purpose: Main execution method, contains the loop which iterates
    #                over the runs. It also sets some pointers
    #
    #		  Input: run -- The scan number
    #                operation -- The specific analysis operation desired
    #
    #		 Output: Varies by operation
    #
    #------------------------------------------------------------------------

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
					setup_ice
                ;;
            "build" )
					populate_dirs
                ;;
		esac
	done

}


#================================================================================
#                                START OF MAIN
#================================================================================


for run in {1..4}; do

	Main $run $operation

done

