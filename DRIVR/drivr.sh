#!/bin/bash
#================================================================================
#	Program Name:  drivr.bash
#		  Author:  Kyle Almryde
#			Date:  02/27/2012
#
#	 Description:  The purpose of this program is to act as an operator hub which
#				   calls multiple independant processes to be run through a list
#				   of subjects, runs, and whatever else you wish in order to
#				   manage and manipulate large volumes of data.
#
#
#		   Input:  $1 parameter argument represents the experiment profile tag
#				   e.g. 'tap'
#
#				   $2 parameter argument represents the Analysis type, e.g. 'Low'
#
#				   $3 parameter argument represents the processing step you wish
#				   to perform, e.g. 'preproc'
#
#		  Output:  If parameter arguments
#
#
#
#
#	Deficiencies:  None, this program meets specifications.
#
#
# set -n	# Uncomment to check command syntax without any execution
# set -x	# Uncomment to debug this script
#
#================================================================================
#						++++ Script SetUp ++++
#================================================================================


# take note of the AFNI version
afni -ver

# check that the current AFNI version is recent enough
afni_history -check_date 9 Mar 2012

if [[ $status ]]; then
	echo "** this script requires newer AFNI binaries (than 9 Mar 2012)"
	echo "   (consider: @update.afni.binaries -defaults)"
	exit
fi


#-----------------------------
# Script Variables
#-----------------------------
study=$1				# This variable defines the Experiment code which will
						# point the shell towards the right functions to call.
						# It will also instantiate the various experiment
						# specific variables.

analysis=$2				# This variable determines which Analysis type to perform
						# on the current experiment data

step=$3					# This determines which Step within the analysis the user
						# would like to perform.


#----------------------------
# Source program functions
#----------------------------
source ${DRIVR}/${study}_profile
source ${DRIVR}/reconstruction_functions
source ${DRIVR}/preprocessing_functions
source ${DRIVR}/regression_functions
source ${DRIVR}/coregistration_functions
source ${DRIVR}/ANOVA_functions
#source ${DRIVR}/testing_functions
#source ${DRIVR}/ICA_functions

#-----------------------
# Usage Check
#-----------------------

if [[ -z $study ]]; then

	cat <<options

    -----------------------------------------------------------------------
    +                 +++ No arguments provided! ++                       +
    +                                                                     +
    +         This program requires at least 3 arguments.                 +
    +         Expected commandline input:                                 +
    +                                                                     +
    +              bash drivr.bash tap Low Reconstruct                    +
    +                                                                     +
    +       NOTE: [words] in square brackets represent possible input.    +
    +       See below for available options.                              +
    +                                                                     +
    -----------------------------------------------------------------------
                ++++++++++++++++++++++++++++++++++++++++++++
                +     << arg 1 >>  Experiment tag          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +                                          +
                +  [tap] Transfer Appropriate Processing   +
                +  [rat] fMRI response to Migrane in Rats  +
                +  [wb1] Word Boundry                      +
                +                                          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +     << arg 2 >>  Analysis type           +
                ++++++++++++++++++++++++++++++++++++++++++++
                +                                          +
                +  [low]  Low-Level preprocessing analysis +
                +  [high] High-Level statistical analysis  +
                +                                          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +     << arg 3 >>  Step procedure          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +                                          +
                +  If [low] option selected:               +
                +                                          +
                +  [reconstruct]  Reconstructing Data      +
                +  [preproc]      Preprocessing steps      +
                +  [regress]      Regression analysis      +
                +  [coreg]        Coregistration of Data   +
                +                                          +
                +------------------------------------------+
                +                                          +
                +  If [high] option selected:              +
                +                                          +
                +  [anova]    Perform Analysis of Variance +
                +  [ica]      Perform ICA                  +
                +                                          +
                ++++++++++++++++++++++++++++++++++++++++++++
options

	exit 0


elif [[ -z $analysis ]]; then

	cat <<options

    -----------------------------------------------------------------------
    +                 +++ Missing Analysis type! +++                      +
    +                                                                     +
    +         This program requires at least 3 arguments.                 +
    +         Expected commandline input:                                 +
    +                                                                     +
    +              bash drivr.bash $study <arg2> <arg3>                      +
    +                                                                     +
    +       NOTE: [words] in square brackets represent possible input.    +
    +       See below for available options.                              +
    +                                                                     +
    -----------------------------------------------------------------------
                ++++++++++++++++++++++++++++++++++++++++++++
                +     << arg 2 >>  Analysis type           +
                ++++++++++++++++++++++++++++++++++++++++++++
                +                                          +
                +  [low]  Low-Level preprocessing analysis +
                +  [high] High-Level statistical analysis  +
                +                                          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +     << arg 3 >>  Step procedure          +
                ++++++++++++++++++++++++++++++++++++++++++++
                +                                          +
                +  If [low] option selected:               +
                +                                          +
                +  [reconstruct]  Reconstructing Data      +
                +  [preproc]      Preprocessing steps      +
                +  [regress]      Regression analysis      +
                +  [coreg]        Coregistration of Data   +
                +                                          +
                +------------------------------------------+
                +                                          +
                +  If [high] option selected:              +
                +                                          +
                +  [anova]    Perform Analysis of Variance +
                +  [ica]      Perform ICA                  +
                 +                                          +
                ++++++++++++++++++++++++++++++++++++++++++++
options

	echo -n "Please choose an Analysis type: "; read analysis
	echo -n "And a Step procedure: "; read step

fi

#================================================================================
#						++++ START OF MAIN ++++
#================================================================================
cd $HOME_dir

case $analysis in
#++++++++++++++++++++++++++++++++++++++++++++++++++++
	low )			## Low Level Analysis ##
#++++++++++++++++++++++++++++++++++++++++++++++++++++

		case $step in
		#----------------------------------
		#	   Reconstruction
		#----------------------------------
			1 | reconstruct )
					Loop_Subj \
						Reconstruct_fse \
						Reconstruct_spgr \
						Coreg_spgr2fse \
						Coreg_spgr2tlrc

					Loop_SubjRun \
						Reconstruct_epan
			;;
		#----------------------------------
		#      	  Pre-Processing
		#----------------------------------
			2 | preproc )
					Loop_SubjRun \
						"Review_preproc epan"
#						Preproc_tcat \
#						Preproc_despike \
#						Preproc_tshift \
#						Preproc_volreg2stand \
#						"Preproc_smoothing 6.0" \
#						Preproc_masking \
#						Preproc_scale
			;;
		#----------------------------------
		#        Regression Analysis
		#----------------------------------
			3 | regress )
					Loop_SubjRun \
						"Regress_${study} Dprime"
#						"Regress_FWHMxyz Basic" \
#						Regress_censor \
#						"Regress_${study} Basic" \

#						"Regress_Plot Basic" \
#						"Regress_FWHMx Dprime"


#						"Regress_REML Basic" \


#						"Regress_Plot Dprime" \
#						"Regress_REML Dprime" \

			;;
		#----------------------------------
		#        Coregistration
		#----------------------------------
			4 | coreg )
					Loop_Subj \
						Coreg_spgr2fse \
						Coreg_spgr2tlrc

					Loop_SubjRun \
						"Coreg__WarpFUNC Basic" \
						"Coreg__WarpIRF Basic" \
						"Coreg__WarpREML Basic"
#						"Coreg__WarpFUNC Dprime" \
#						"Coreg__WarpIRF Dprime" \
#						"Coreg__WarpREML Dprime" \
#						"Coreg__CleanUp Basic" \
#						"Coreg__CleanUp Dprime"

#						"Coreg__WarpBucketStats Basic" \
#						"Coreg__WarpBucketStats Dprime"
			;;
		#----------------------------------
		#        Low-Level Restart
		#----------------------------------
			5 | restart )
					Loop_SubjRun \
						Restart_preproc
#						Restart_Coreg \
#						Restart_GLM \
#						 \
#						Restart_reconstruc
			;;

		esac 2>&1 | tee -a $HOME_dir/log.Low.${step}.txt
	;;
#++++++++++++++++++++++++++++++++++++++++++++++++++++
	high )		## High Level Analysis ##
#++++++++++++++++++++++++++++++++++++++++++++++++++++
		case $step in
		#----------------------------------
		#       Analysis of Variance
		#----------------------------------
			1 | anova )
					Loop_SubjRun \
						"Anova_${study} Basic" \

#						"Anova_CleanUp Basic" \
#						"Anova_CleanUp Dprime"

#						"Anova_${study} Dprime" \
#						"Anova_AFNItoNIFTI Basic" \
#						"Anova_AFNItoNIFTI Dprime" \

#						"Anova_AlphaCorr Dprime" \
#						"Anova_AlphaCorr Basic" \
			;;
		#----------------------------------
		#  Independent Component Analysis
		#----------------------------------
			2 | ica )
					Loop_SubjRun \
						ICA_pca \
						ICA_ica
			;;
		#----------------------------------
		#        High-Level Restart
		#----------------------------------
			3 | restart )
					Loop_SubjRun \
						Restart_Anova
			;;

		esac 2>&1 | tee -a $HOME_dir/log.High.${step}.txt
	;;
#++++++++++++++++++++++++++++++++++++++++++++++++++++
	test )		## Testing Zone ##
#++++++++++++++++++++++++++++++++++++++++++++++++++++
		case $step in
		#----------------------------------
		#	   Reconstruction
		#----------------------------------
			1 | reconstruct )
					Loop_SubjRun \
						Reconstruct_Noffsets \
			;;
		#----------------------------------
		#      	  Pre-Processing
		#----------------------------------
			2 | preproc )
					Loop_SubjRun \
						Test_tshif \

			;;
		esac
	;;
esac
#===========================================================================
#						++ END OF MAIN ++
#===========================================================================
cd $HOME_dir
exit 0
