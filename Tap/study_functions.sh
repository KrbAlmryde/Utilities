#!/bin/bash
#================================================================================
#	Program Name: study_functions.bash
#		  Author: Kyle Almryde
#			Date: 03/28/2012
#
#	 Description: This script contains functions designed to perform every step
#				  of analysis for the TAP study, including reconstruction,
#				  preprocessing, and analysis.
#
#
#
#	Deficiencies: Currently functions in this script require positional arguments
#				  However there is at present no check to ensure that the
#				  required arguments are properly defined. This is a necessary
#				  remediation that will keep many of processes these functions
#				  control from breaking.
#
#				  At present this script has exceeded over 2,000 lines of code
#				  It will be necessary in the near future to break the script
#				  apart into smaller sections. At present I have not made a
#				  decision about how I want to implement this.
#
#		  UPDATE: I can use positional parameters as options and a big case
#				  statement to serperate out the various study specific
#				  functions and/or scripts.
#
#				  For example
#				  ./study_functions -tap prep -l
#
#
#================================================================================
#================================================================================
#								START OF MAIN
#
#				Functions following are complete or are in working development
#================================================================================
#================================================================================

# take note of the AFNI version
date=$(echo `afni -ver` | awk '{print $6,$7,$8}' | sed 's/]//g')

# check that the current AFNI version is recent enough

afni_history -check_date ${date}

if [[ $? -ne 0 ]]; then
	echo "** this script requires newer AFNI binaries (than "$(date +"%B %d %Y")
	sudo @update.afni.binaries -defaults
fi


function tap_start ()
{
	cd /Volumes/Data/COMPLETE/TAP; pwd; ls -l

	echo blah blah

	subj_list=(`ls -d TS*`)

	run_list=( SP1 SP2 TP1 TP2 )


	DBOX=/Users/kylealmryde/Dropbox/TAP


	source $UTL/eprime_functions.sh
	source $UTL/anova_functions.sh

	function dbox ()
	{
		local infile=$1
		local tail=$2

		3dcopy ${infile}+${tail} ${DBOX}/${infile}.${tail}.nii

	}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							SETUP Functions
# Includes functions for setting up subject directory, unpack Pfiles,
# and renaming efiles
#
# The current list of functions under this heading :
#					setup_subjdir
#					setup_rename_anat
#					setup_spiral_unpack **incomplete**
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	#------------------------------------------------------------------------
	#		Function setup_subjdir
	#
	#		Purpose:   Builds subject folder
	#  mkdir -p {SP1,SP2,TP1,TP2}/{Orig,{Group,Performance,Dprime}/{ROI,Thresh,NIFTI,tmp}}
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
	function setup_subjdir ()
	{
		local subj
		subj=$1

		echo "Building top level...."
		mkdir -p /Volumes/Data/TAP/${subj}/{Orig,Struc,{Behav,Prep,GLM}/{SP1,SP2,TP1,TP2}/IRESP}
		echo -n "Entering "
		cd /Volumes/Data/TAP/${subj}/Orig ; pwd

		echo "${subj} folder is ready to be filled"
	}




	#------------------------------------------------------------------------
	#		Function setup_rename_anat
	#
	#		Purpose:
	#
	#
	#
	#
	#		  Input:   e12345s2
	#				   ^^^^^^ MRI exam number
	#				   e12345s2
	#				         ^^ Series number (ordered by scan performed)
	#
	#		 Output:   e12345s2i001
	#				           ^^^^ Image number (ranges from 1-26, or 1-164)
	#
	#------------------------------------------------------------------------

	function setup_rename_anat ()
	{
		local subj image exam series fname
		local ORIG

		subj=$1
		series=$2
		ORIG=/Volumes/Data/TAP/${subj}/Orig
		exam=$(basename $(ls ${ORIG}/e* ) | grep -m 1 'e*' | cut -d s -f1)
		efile=${exam}${series}
		image=1

		cd ${ORIG}

		while [[ $image -le 99 ]]; do

			fname="${efile}i${image}"

			if [[ ! -f ${fname} ]]; then
				echo "${ORIG} Missing efiles! Are you sure you unpacked them?"
				echo "efiles take the form e1234s5i6"
				echo "exiting program, make sure files have been unpacked"
				break
			fi

			echo "renaming image $image"

			if [[ $image -le 9 ]]; then
				mv ${fname} "${efile}i00${image}"
			else
				mv ${fname} "${efile}i0${image}"
			fi

			((image++))

		done

	}



#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							Reconstruction Functions
# Includes functions building the EPAN, FSE, and SPGR images, as well as for
# coregistering the SPGR to the FSE and warping to Talairach space
#
# The current list of functions under this heading :
#					build_epan
#					build_fse
#					build_spgr
#					build_struc2stand
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	function build_epan ()
	{
		#------------------------------------------------------------------------
		#		Function   	build_epan
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

		local subj run nfs nas thick z1 z2 fov z halffov
		local PREP ORIG STIM

		subj=$1; run=$2; nfs=$3
		tr=3500 	# repetition time in miliseevs

		nas=26 		# number of functional slices

		thick=5 	# Z-slice thickness for functional and FSE

		z1=I 		# Slice acquisition direction for functional and FSE
		z2=S

		fov=240 	# field of view for functional and FSE

		z=$(echo "scale=2; ((nas=$nas-1) * ${thick})/2" | bc)
					# Size of z dimension in functional and FSE image
					# (25 * 5)/2 = 62.00

		halffov=$(echo "scale=2; ${fov}/2"| bc)
					# Field of View of functional and FSE divided by 2
					# 240/2 = 120.00

		ORIG=/Volumes/Data/TAP/${subj}/Orig
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
		STIM=/Volumes/Data/TAP/STIM

		if [[ ! -e ${PREP}/${subj}.${run}.epan+orig.HEAD ]]; then
			to3d \
				-epan \
				-prefix ${subj}.${run}.epan \
				-session ${PREP} \
				-2swap \
				-text_outliers \
				-save_outliers ${PREP}/${subj}.${run}.outliers.txt \
				-xFOV ${halffov}R-L \
				-yFOV ${halffov}A-P \
				-zSLAB ${z}${z1}-${z}${z2} \
				-time:tz ${nfs} ${nas} ${tr} \
				@${STIM}/offsets.1D \
				${ORIG}/${run}.*

			3dToutcount \
				${PREP}/${subj}.${run}.epan+orig \
				> ${PREP}/${subj}.${run}.epan.outs.txt

			1dplot \
				-jpeg ${PREP}/${subj}.${run}.epan.outs \
				${PREP}/${subj}.${run}.epan.outs.txt

		else

			echo "${subj}.${run}.tcat+orig already exists!!"

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

		local subj nas thick z1 z2 fov z halffov

		subj=$1
		nas=26 		# number of functional slices
		thick=5 	# Z-slice thickness for functional and FSE
		z1=I 		# Slice acquisition direction for functional and FSE
		z2=S
		fov=240 	# field of view for functional and FSE
		z=$(echo "scale=2; ((nas=$nas-1) * ${thick})/2" | bc)
					# Size of z dimension in functional and FSE image
					# (25 * 5)/2 = 62.00

		halffov=$(echo "scale=2; ${fov}/2"| bc)
					# Field of View of functional and FSE divided by 2
					# 240/2 = 125.00

		ORIG=/Volumes/Data/TAP/${subj}/Orig
		STRUC=/Volumes/Data/TAP/${subj}/Struc

		if [[ ! -e ${STRUC}/${subj}.fse+orig.HEAD ]]; then
			to3d \
				-fse \
				-prefix ${subj}.fse \
				-session ${STRUC} \
				-xFOV ${halffov}R-L \
				-yFOV ${halffov}A-P \
				-zSLAB ${z}${z1}-${z}${z2} \
				${ORIG}/e????s[23]i*
		else

			echo "${subj}.fse+orig already exists!!"

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

		nasspgr=164 # number of anatomical slices

		thickspgr=1 # Z-slice thickness for SPGR

		z1spgr=L
		z2spgr=R 	# Slice acquisition direction for SPGR

		fovspgr=256 # field of view for SPGR

		zspgr=$(echo "scale=2; ((nasspgr=$nasspgr-1) * ${thickspgr})/2"| bc)
					# Size of z dimension in the Structural SPGR image
					# (163 * 1)/2 = 81
		anatfov=$(echo "scale=2; ${fovspgr}/2"| bc)
					# Field of View of structural FSE divided by 2
					# 256/2 = 128.00


		ORIG=/Volumes/Data/TAP/${subj}/Orig

		STRUC=/Volumes/Data/TAP/${subj}/Struc

		if [[ ! -e ${STRUC}/${subj}.spgr+orig.HEAD ]]; then

			to3d \
				-spgr \
				-prefix ${subj}.spgr \
				-session ${STRUC} \
				-xFOV ${anatfov}A-P \
				-yFOV ${anatfov}S-I \
				-zSLAB ${zspgr}${z1spgr}-${zspgr}${z2spgr} \
				${ORIG}/e????s[789]i*
		else

			echo "${subj}.spgr+orig already exists!!"

		fi
	}



	function build_struc2stand ()
	{
		#------------------------------------------------------------------------
		#		Function	align_struc2stand
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

		local subj
		local STRUC

		subj=$1
		STRUC=/Volumes/Data/TAP/${subj}/Struc

		if [[ ! -e ${STRUC}/${subj}.spgr.standard+tlrc.HEAD ]]; then

			cd ${STRUC}

			align_epi_anat.py \
				-dset1to2 -cmass cmass \
				-dset1 ${subj}.spgr+orig \
				-dset2 ${subj}.fse+orig \
				-cost lpa -suffix .cmass

			3dSkullStrip \
				-input ${subj}.spgr.cmass+orig \
				-prefix ${subj}.spgr.standard

			@auto_tlrc \
				-no_ss -suffix NONE \
				-base TT_N27+tlrc \
				-input ${subj}.spgr.standard+orig

			3drefit -anat ${subj}.spgr.standard+tlrc

		else

			echo "${subj}.spgr.standard+tlrc.HEAD already exists!!"

		fi
	}



	function build_groupStruc ()
	{
		#------------------------------------------------------------------------
		#		Function	build_groupStruc
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

		local subj i max
		local STRUC ANAT

		max=${#subj_list[*]}
		ANAT=/Volumes/Data/TAP/ANAT

		# remove old anatomical buckets, if they exist.
		if [[ ${ANAT}/TT_tap*.anat.*+tlrc.HEAD != TT_tap${max}.*+tlrc.HEAD ]]; then

			rm TT_tap*.anat.*+tlrc.HEAD
			rm TT_tap*.anat.*+tlrc.BRIK

		fi


		# iterate over each subject, adding each anatomical image to a group bucket
		for (( i = 0; i < ${#subj_list[*]}; i++ )); do

			subj=${subj_list[$i]}
			STRUC=/Volumes/Data/TAP/${subj}/Struc

			if [[ ! -e ${ANAT}/TT_tap${max}.anat.stand+tlrc ]]; then

				# construct the bucket file containing each subjects standard spgr
				3dbucket \
					-aglueto ${ANAT}/TT_tap${max}.anat.stand+tlrc \
					${STRUC}/${subj}.spgr.standard+tlrc

				# construct the bucket file containing each subjects fse
				3dbucket \
					-aglueto ${ANAT}/TT_tap${max}.anat.fse+orig \
					${STRUC}/${subj}.fse+orig

				# label each subbrik of the spgr bucket with the appropriate subject number
				3drefit \
					-sublabel $i ${subj} \
					${ANAT}/TT_tap${max}.anat.stand+tlrc

				# Do the same for the fse bucket
				3drefit \
					-sublabel $i ${subj} \
					${ANAT}/TT_tap${max}.anat.fse+orig
			fi

		done

		# create a group averaged anatomical image to use are the template
		3dTstat \
			-mean -median -stdev \
			-prefix ${ANAT}/TT_tap${max}.anat.stats \
			${ANAT}/TT_tap${max}.anat.stand+tlrc

	}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#							Preprocessing Functions
#
# Includes functions for each preprocessing step in the TAP pipeline
#
# The current list of functions under this heading include :
#					prep_tcat
#					prep_despike
#					prep_tshift
#					prep_volreg
#					prep_smoothing
#					prep_masking
#					prep_scale
#
# Note: Each step should be performed in the order listed above as they are
# 		dependant on the previous for the proper input.
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	function prep_restart ()
	{
		local subj run
		local prep

		run=$1

		for (( i = 14; i < ${#subj_list}; i++ )); do

			subj=${subj_list[$i]}
			PREP=/Volumes/Data/TAP/${subj}/Prep/${run}

			rm ${PREP}/*+orig*
			rm ${PREP}/*+tlrc*
			rm ${PREP}/*.1D
			rm ${PREP}/*.txt
		done
	}




	function prep_tcat ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_tcat
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

		local subj run trunc
		local PREP

		subj=$1; run=$2; trunc=$3
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}

		if [[ ! -e ${PREP}/${subj}.${run}.tcat+orig.HEAD ]]; then

			3dTcat \
				-verb \
				-prefix ${PREP}/${subj}.${run}.tcat \
				${PREP}/${subj}.${run}.epan+orig'['${trunc}'..$]'

			3dToutcount \
				${PREP}/${subj}.${run}.tcat+orig \
				> ${PREP}/${subj}.${run}.tcat.outs.1D

			1dplot \
				-jpeg ${PREP}/${subj}.${run}.tcat.outs \
				${PREP}/${subj}.${run}.tcat.outs.1D


			echo "slices truncated = ${trunc}" > ${PREP}/${subj}.${run}.log.txt

		else

			echo "${subj}.${run}.tcat+orig already exists!!"

		fi
	}




	function prep_despike ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_despike
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

		local subj run
		local PREP

		subj=$1; run=$2
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}

		if [[ ! -e ${PREP}/${subj}.${run}.despike+orig.HEAD ]]; then

			3dDespike \
				-prefix ${PREP}/${subj}.${run}.despike \
				${PREP}/${subj}.${run}.tcat+orig

			3dToutcount \
				${PREP}/${subj}.${run}.despike+orig \
				> ${PREP}/${subj}.${run}.despike.outs.1D

			1dplot \
				-jpeg ${PREP}/${subj}.${run}.despike.outs \
				${PREP}/${subj}.${run}.despike.outs.1D

		else

			echo "${subj}.${run}.despike already exists!!"

		fi
	}


	function prep_tshift ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_tshift
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

		local subj run
		local PREP

		subj=$1; run=$2
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}


		if [[ ! -e ${PREP}/${subj}.${run}.tshift+orig.HEAD ]]; then

			3dTshift \
				-verbose \
				-tzero 0 \
				-rlt+ \
				-quintic \
				-prefix ${PREP}/${subj}.${run}.tshift \
				${PREP}/${subj}.${run}.despike+orig

			3dToutcount \
				${PREP}/${subj}.${run}.tshift+orig \
				> ${PREP}/${subj}.${run}.tshift.outs.1D

			1dplot \
				-jpeg ${PREP}/${subj}.${run}.tshift.outs \
				${PREP}/${subj}.${run}.tshift.outs.1D

		else

			echo "${subj}.${run}.tshift+orig already exists!!"

		fi
	}


	function prep_volreg ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_volreg
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

		local subj run base
		local STRUC PREP GLM

		subj=$1; run=$2

		STRUC=/Volumes/Data/TAP/${subj}/Struc
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}

		if [[ ! -e ${PREP}/${subj}.${run}.vr.reg+tlrc.HEAD ]]; then

			cd ${PREP}

			base=$(cat -n ${subj}.${run}.tshift.outs.1D | sort -k2,2n \
					| head -1 | awk '{print $1-1}')

			echo "volume registered to = ${base}" >> ${subj}.${run}.log.txt

			align_epi_anat.py \
				-anat ${STRUC}/${subj}.spgr.standard+orig \
				-anat_has_skull no \
				-epi ${subj}.${run}.tshift+orig \
				-big_move \
				-epi_strip 3dAutomask \
				-epi_base ${base} \
				-epi2anat -suffix .reg  \
				 -volreg on -volreg_opts  \
						-verbose -verbose -zpad 4 \
						-1Dfile ${GLM}/${subj}.${run}.dfile.1D \
				-tlrc_apar ${STRUC}/${subj}.spgr.standard+tlrc

			3dcopy ${subj}.${run}.tshift.reg+orig \
					${subj}.${run}.vr.reg+orig

			3dcopy ${subj}.${run}.tshift_tlrc.reg+tlrc \
					${subj}.${run}.vr.reg+tlrc

			rm ${subj}.${run}.tshift.reg+orig.*
			rm ${subj}.${run}.tshift_tlrc.reg+tlrc.*


			3dToutcount \
				${subj}.${run}.vr.reg+orig \
				> ${subj}.${run}.vr.reg.outs.1D

			1dplot \
				-jpeg ${subj}.${run}.vr.reg.outs \
				${subj}.${run}.vr.reg.outs.1D

			3dToutcount \
				${subj}.${run}.vr.reg+tlrc \
				> ${subj}.${run}.vr.reg.outs.tlrc.1D

			1dplot \
				-jpeg ${subj}.${run}.vr.reg.outs.tlrc \
				${subj}.${run}.vr.reg.outs.tlrc.1D

			1dplot \
				-jpeg ${subj}.${run}.vr.reg \
				-volreg \
				-xlabel TIME \
				${GLM}/${subj}.${run}.dfile.1D

		else

			echo "${subj}.${run}.vr.reg+tlrc alread exist!!"

		fi
	}


	function prep_smoothing ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_smoothing
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

		local subj run filter
		local PREP

		subj=$1; run=$2; filter=$3
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}


		if [[ ! -e ${PREP}/${subj}.${run}.blur+tlrc.HEAD ]]; then

			3dBlurInMask \
				-preserve \
				-FWHM ${filter} \
				-automask \
				-prefix ${PREP}/${subj}.${run}.blur \
				${PREP}/${subj}.${run}.vr.reg+tlrc

			echo "Smoothing kernel = ${filter}mm" >> ${PREP}/${subj}.${run}.log.txt

		else

			echo "${subj}.${run}.blur+tlrc already exists!!"

		fi

	}



	function prep_masking ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_masking
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input: 6.0 mm filter should be used
		#
		#
		#		 Output:
		#
		#
		#------------------------------------------------------------------------

		local subj run
		local STRUC PREP GLM

		subj=$1; run=$2

		STRUC=/Volumes/Data/TAP/${subj}/Struc
		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
		ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks

		if [[ ! -e ${PREP}/${subj}.${run}.fullmask+tlrc.HEAD ]]; then

			3dAutomask \
				-prefix ${PREP}/${subj}.${run}.fullmask \
				${PREP}/${subj}.${run}.blur+tlrc

			3dresample \
				-master ${PREP}/${subj}.${run}.fullmask+tlrc \
				-prefix ${PREP}/${subj}.${run}.spgr.resam \
				-input ${STRUC}/${subj}.spgr.standard+tlrc

			3dcalc \
				-a ${PREP}/${subj}.${run}.spgr.resam+tlrc \
				-expr 'ispositive(a)' \
				-prefix ${PREP}/${subj}.${run}.spgr.mask

			3dABoverlap \
				-no_automask ${PREP}/${subj}.${run}.fullmask+tlrc \
				${PREP}/${subj}.${run}.spgr.mask+tlrc \
				2>&1 | tee -a ${PREP}/${subj}.${run}.mask.overlap.txt

			3dABoverlap \
				-no_automask \
				${ANOVAMask}/N27.mask+tlrc \
				${PREP}/${subj}.${run}.spgr.mask+tlrc \
				2>&1 | tee -a ${PREP}/${subj}.${run}.spgr.mask.overlap.txt

			echo "( ${subj}.${run} / N27 ) = \
				`cat ${PREP}/${subj}.${run}.spgr.mask.overlap.txt \
				| tail -1 | awk '{print $8}'`" \
				>> ${ANOVAMask}/N27.mask.overlap.txt

			cp ${PREP}/${subj}.${run}.fullmask+tlrc.* ${GLM}

		else

			echo "${subj}.${run}.fullmask+tlrc already exists!!"

		fi
	}



	function prep_scale ()
	{
		#------------------------------------------------------------------------
		#		Function   prep_scale
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

		local subj run
		local PREP GLM

		subj=$1; run=$2

		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}

		if [[ ! -f ${PREP}/${subj}.${run}.scale+tlrc.HEAD ]]; then

			3dTstat \
				-prefix ${PREP}/rm.${subj}.${run}.mean \
				${PREP}/${subj}.${run}.blur+tlrc

			3dcalc \
				-verbose \
				-float \
				-a ${PREP}/${subj}.${run}.blur+tlrc \
				-b ${PREP}/rm.${subj}.${run}.mean+tlrc \
				-c ${PREP}/${subj}.${run}.fullmask+tlrc \
				-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
				-prefix ${PREP}/${subj}.${run}.scale

			3dToutcount \
				${PREP}/${subj}.${run}.scale+tlrc \
				> ${PREP}/${subj}.${run}.scale.outs.1D

			1dplot \
				-jpeg ${PREP}/${subj}.${run}.scale.outs \
				${PREP}/${subj}.${run}.scale.outs.1D

			cp ${PREP}/${subj}.${run}.scale+tlrc.* ${GLM}

		else

			echo "${subj}.${run}.scale+tlrc already exists!!"

		fi
	}




	function prep_loop ()
	{
		for (( i = 0; i < ${#subj_list[*]}; i++ )); do

			run=$1
			subj=${subj_list[$i]}
			filter=4.0

			case $subj in
				TS01[5-8] )
					nfs=160
					trunc=10
					;;
				TS* )
					nfs=154
					trunc=4
					;;
			esac

			build_epan ${subj} ${run} ${nfs}
			prep_tcat ${subj} ${run} ${trunc}
			prep_despike ${subj} ${run}
			prep_tshift ${subj} ${run}
			prep_volreg ${subj} ${run}
			prep_smoothing ${subj} ${run} ${filter}
			prep_masking ${subj} ${run}
			prep_scale ${subj} ${run}

		done
	}


	function prep_ica ()
	{
		for (( i = 14; i < ${#subj_list}; i++ )); do

			run=$1
			subj=${subj_list[$i]}
			GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
			ICA=/Volumes/Data/TAP/ICA/FSL/${run}

			rm ${ICA}/${subj}.${run}.scale.nii
			3dcopy ${GLM}/${subj}.${run}.scale+tlrc ${ICA}/${subj}.${run}.scale.nii

		done

	}

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#						Regression Functions
#
# Includes functions for performing the GLM
#
# The current list of functions under this heading include :
#					regress_censor
#					regress_basic
#					regress_dprime
#					regress_OLD
#					regress_plot
#
# Note: Each step should be performed in the order listed above as they are
# 		dependant on the previous for the proper input.
#
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


	function regress_restart ()
	{
		local subj run i
		local GLM ANOVA IRESP ORIG

		for (( i = 0; i < ${#subj_list[*]}; i++ )); do

			run=$1
			type=$2
			subj=${subj_list[$i]}

			GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
			IRESP=/Volumes/Data/TAP/${subj}/GLM/${run}/IRESP
			ANOVA=/Volumes/Data/TAP/ANOVA/${run}
			ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig

			#echo "rm ${GLM}/*.${type}*"
			rm ${GLM}/*.${type}*
			rm ${ORIG}/*.${type}*

		done
	}


	function regress_censor ()
	{
		#----------------------------------------------------------------------------
		#		Function   regress_censor
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
		#----------------------------------------------------------------------------

		local subj run tR
		local PREP GLM


		subj=$1; run=$2; tR=3.5

		PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}

		# compute de-meaned motion parameters (for use in regression)
		1d_tool.py \
			-infile ${GLM}/${subj}.${run}.dfile.1D -set_nruns 1 \
			  -demean -write ${GLM}/motion.${subj}.${run}_demean.1D

		1dplot \
			-jpeg ${GLM}/motion.${subj}.${run}_demean \
			${GLM}/motion.${subj}.${run}_demean.1D

		# compute motion parameter derivatives (for use in regression)
		1d_tool.py \
			-infile ${GLM}/${subj}.${run}.dfile.1D \
			-set_nruns 1 -derivative -demean \
			-write ${GLM}/motion.${subj}.${run}_deriv.1D

		1dplot \
			-jpeg ${GLM}/motion.${subj}.${run}_deriv \
			${GLM}/motion.${subj}.${run}_deriv.1D

		# create censor file motion_${subj}_censor.1D, for censoring motion
		1d_tool.py -verb 2 \
			-infile ${GLM}/${subj}.${run}.dfile.1D \
			-set_nruns 1 -set_tr ${tR} \
			-show_censor_count -censor_prev_TR \
			-censor_motion .1 ${GLM}/motion.${subj}.${run}

		1dplot \
			-jpeg ${GLM}/motion.${subj}.${run}_enorm \
			${GLM}/motion.${subj}.${run}_enorm.1D


		1dplot \
			-jpeg ${GLM}/motion.${subj}.${run}_censor \
			${GLM}/motion.${subj}.${run}_censor.1D
	}


	function regress_convolve ()
	{
		#----------------------------------------------------------------------------
		#		Function   regress_convolve
		#
		#		Purpose:
		#
		#
		#
		#
		#		  Input: <subject> <run> <analysis type>
		#				    TS001   SP1    basic
		#
		#		 Output:
		#
		#
		#----------------------------------------------------------------------------

		local subj run type model ev1 ev2 fwhmx
		local GLM STIM IRESP ANOVA ORIG

		subj=$1; run=$2; type=$3; model=GAM
		stimfile=stim.${subj}.${run}

		STIM=/Volumes/Data/TAP/STIM
		ANOVA=/Volumes/Data/TAP/ANOVA/${run}
		ORIG=/Volumes/Data/TAP/ANOVA/${run}/Orig
		GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
		IRESP=/Volumes/Data/TAP/${subj}/GLM/${run}/IRESP

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
				SP[12] ) ev1=O_hits
					  ev2=O_miss   ;;
				TP1 ) ev1=HitRate
					  ev2=FaRate    ;;
			esac

		elif [[ $type == "OLD" ]]; then

			case $run in
				TP1 ) ev1=O_hits
					  ev2=O_miss ;;
				* ) echo "This is for SP1 only!!"
					exit 0 ;;
			esac

		elif [[ $type == "NEW" ]]; then

			case $run in
				TP1 ) ev1=N_hits
					  ev2=N_miss ;;
				* ) echo "This is for SP1 only!!"
					exit 0 ;;
			esac
		fi


		if [[ ! -e ${GLM}/${subj}.${run}.${model}.${type}.stats+tlrc.HEAD ]]; then

			3dDeconvolve \
				-polort A -GOFORIT 5 \
				-input ${GLM}/${subj}.${run}.scale+tlrc \
				-censor ${GLM}/motion.${subj}.${run}_censor.1D \
				-mask ${GLM}/${subj}.${run}.fullmask+tlrc \
				-num_stimts 8 -local_times \
				-stim_times 1 \
						${STIM}/${stimfile}.${ev1}.1D "${model}" \
						-stim_label 1 ${GLM}/${subj}.${run}.${model}.${ev1}.${type} \
				-stim_times 2 \
						${STIM}/${stimfile}.${ev2}.1D "${model}" \
						-stim_label 2 ${GLM}/${subj}.${run}.${model}.${ev2}.${type} \
				-stim_file 3 \
						${GLM}/${subj}.${run}.dfile.1D'[0]' \
						-stim_base 3 \
						-stim_label 3 roll \
				-stim_file 4 \
						${GLM}/${subj}.${run}.dfile.1D'[1]' \
						-stim_base 4 \
						-stim_label 4 pitch \
				-stim_file 5 \
						${GLM}/${subj}.${run}.dfile.1D'[2]' \
						-stim_base 5 \
						-stim_label 5 yaw \
				-stim_file 6 \
						${GLM}/${subj}.${run}.dfile.1D'[3]' \
						-stim_base 6 \
						-stim_label 6 dS \
				-stim_file 7 \
						${GLM}/${subj}.${run}.dfile.1D'[4]' \
						-stim_base 7 \
						-stim_label 7 dL \
				-stim_file 8 \
						${GLM}/${subj}.${run}.dfile.1D'[5]' \
						-stim_base 8 \
						-stim_label 8 dP \
				-xout \
					-x1D ${GLM}/${subj}.${run}.${model}.${type}.xmat.1D \
					-xjpeg ${GLM}/${subj}.${run}.${model}.${type}.xmat.jpg \
				-jobs 4 \
				-fout -tout \
				-TR_times 1 \
				-errts ${GLM}/${subj}.${run}.${model}.${type}.errts+tlrc \
				-fitts ${GLM}/${subj}.${run}.${model}.${type}.fitts+tlrc \
				-bucket ${GLM}/${subj}.${run}.${model}.${type}.stats+tlrc

			3dcopy ${GLM}/${subj}.${run}.${model}.${type}.stats+tlrc ${ORIG}/


			#-----------------------#
			#    Alpha Correction   #
			#-----------------------#
			function regress_alphcor ()
			{
				fwhmx=$(3dFWHMx \
						-dset ${GLM}/${subj}.${run}.${model}.${type}.errts+tlrc \
						-mask ${GLM}/${subj}.${run}.fullmask+tlrc \
						-combine -detrend)
				echo $fwhmx >> ${ANOVA}/${run}.${type}.FWHMx.txt


				3dClustSim \
					-both -NN 123 \
					-mask ${GLM}/${subj}.${run}.fullmask+tlrc \
					-fwhm "${fwhmx}" -prefix ${GLM}/ClustSim.${type}


				cd ${GLM}
				3drefit \
					-atrstring AFNI_CLUSTSIM_MASK file:ClustSim.${type}.mask \
					-atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.${type}.NN1.niml \
					-atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.${type}.NN2.niml \
					-atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.${type}.NN3.niml \
					${subj}.${run}.${model}.${type}.stats+tlrc
			}

			#-----------------------#
			#     Data Plotting     #
			#-----------------------#
			function regress_plot ()
			{
				1dcat \
					${GLM}/${subj}.${run}.${model}.${type}.xmat.1D'[5]' \
					> ${STIM}/Ideal/ideal.${subj}.${run}.${model}.${ev1}.${type}.1D

				1dcat \
					${GLM}/${subj}.${run}.${model}.${type}.xmat.1D'[6]' \
					> ${STIM}/Ideal/ideal.${subj}.${run}.${model}.${ev2}.${type}.1D

				1dplot \
					-sepscl \
					-censor_RGB red \
					-censor ${GLM}/motion.${subj}.${run}_censor.1D \
					-ynames polort0 polort1 polort2 polort3 polort4 \
							${ev1} ${ev2} roll pitch yaw ds dl dp \
					-jpeg ${GLM}/${subj}.${run}.${model}.${type}.Regressors-All \
					${GLM}/${subj}.${run}.${model}.${type}.xmat.1D'[0..$]'

				1dplot \
					-censor_RGB green \
					-ynames ${ev2} ${ev1} \
					-censor ${GLM}/motion.${subj}.${run}_censor.1D \
					-jpeg ${GLM}/${subj}.${run}.${model}.${type}.RegressofInterest \
					${GLM}/${subj}.${run}.${model}.${type}.xmat.1D'[6,5]'
			}

			regress_alphcor

			regress_plot

		else

			echo "${subj}.${run}.${model}.${type}.stats+tlrc already exists!!"
		fi

	}





	function regress_loop ()
	{
		for (( i = 0; i < ${#subj_list[*]}; i++ )); do

			run=$1
			type=$2
			subj=${subj_list[$i]}

#			regress_censor ${subj} ${run}
			regress_convolve ${subj} ${run} ${type}
#			regress_plot ${subj} ${run} ${type}



		done
	}



}


#================================================================================
#================================================================================
#							END OF MAIN
#
#				Functions following are incomplete or unused
#================================================================================
#================================================================================

