#!/bin/bash
#================================================================================
#	Program Name: wb1.glm.sh
#		  Author: Kyle Reese Almryde
#			Date: August 01 2012
#
#	 Description: This script is designed to perform a GLM analysis on the 
#                 Word Boundary Laterality data. 
#
#	Deficiencies: Currently there is an issue with AFNI's 3dClustSim tool, which
#                 renders the function 'regress_alphacor' unusable. This issue is
#                 presently beyond my control. Until I can find a solution to the
#                 issue, that process has to be skipped. Otherwise, this program
#                 meets specifications.
#                
# set -n	# Uncomment to check command syntax without any execution
# set -x	# Uncomment to debug this script
#================================================================================
#                            FUNCTION DEFINITIONS 
#================================================================================
	

	#------------------------------------------------------------------------
	#
	#	Description: set_subjdir
	#                
	#		Purpose: This function sets up the directory structure for the 
	#                GLM analysis. 
	#                
	#		  Input: None
	#                
	#		 Output: Output consists of a directory tree in the following format.
	#                	sub0##/
	#                		Glm/
	#	                		Run1/
	#           					1D/
	#           					Images/
	#                				Fitts/
	#                				Stats/
	#                
	#	  Variables: None
	#                
	#------------------------------------------------------------------------

	function setup_subjdir ()
	{
		mkdir -p /Volumes/Data/WB1/${subj}/Glm/${RUN[r]}/{1D,Images,Stats,Fitts}
	}




	#------------------------------------------------------------------------
	#
	#	Description: regress_motion
	#                
	#		Purpose: The purpose of this function is to  compute the de-meaned
	#                motion parameters and their derivatives for use within the
	#                regression analysis.
	#
	#		  Input: run#_sub0##_dfile.1D
	#
	#                This file resides in the RealignDetails sub-directory of the
	#                Data/WordBoundary1 subject directory.
	#                
	#		 Output: motion.run#_sub0##_demean.1D, motion.run#_sub0##_demean.jpeg
	#                motion.run#_sub0##_deriv.1D, motion.run#_sub0##_deriv.jpeg
	#
	#                This function produces 4 files, two 1D files containing the
	#                de-meaned motion parameters, motion parameters derivatives,
	#                and their respective graphical plots. 
	#                Files are output to the GLM sub-directory of 
	#                Analysis/WordBoundary1 subject directory. 
	#
	#	  Variables: input1D
	#                
	#                This variable contains the input arguments. It makes the
	#                script a little more readable
	#                				  
	#------------------------------------------------------------------------

	function regress_motion ()
	{
		echo -e "\nregress_motion has been called\n"
		input1D=$1

		# compute de-meaned motion parameters (for use in regression)
		1d_tool.py \
			-infile ${RD}/${input1D}_tshift_dfile.1D \
			-select_rows {4..$} -set_nruns 1 \
			 -demean -write ${ID}/motion.${input1D}_demean.1D


		# compute motion parameter derivatives (for use in regression)
		1d_tool.py \
			-infile ${RD}/${input1D}_tshift_dfile.1D \
			-select_rows {4..$} -set_nruns 1 \
			-derivative -demean \
			-write ${ID}/motion.${input1D}_deriv.1D


		# Plot the de-meaned motion parameters
		1dplot \
			-jpeg ${IM}/motion.${input1D}_demean \
			${ID}/motion.${input1D}_demean.1D

		# Plot the motion parameter derivatives
		1dplot \
			-jpeg ${IM}/motion.${input1D}_deriv \
			${ID}/motion.${input1D}_deriv.1D

	}



	#------------------------------------------------------------------------
	#
	#	Description: regress_convolve
	#                
	#		Purpose: The purpose of this function is to compute a General
	#                Linear Model of neural activity related to language processing.
	#                Using AFNI's 3dDeconvolve neural recordings are deconvolved  
	#                using predefined stimulus onsets coupled with demeaned motion
	#                parameters and their derivatives in order model implicit
	#                language acquisition.
	#                
	#                Because the scanner was initiated manually via countdown 
	#                and not through an automated execution signal, there is
	#                concern that stimulus timing may be off anywhere from 1
	#                to 7 seconds. In order to control for this, this deconvolution
	#                iterates 8 times, delaying the onset of the HRF by one 
	#                second (starting at 0 seconds).
	#                
	#		  Input: run#_sub0##_tshift_volreg_despike_mni_7mm_164tr.nii
	#                censor.cue_stim.1D
	#                stim.tone_block.1D
	#                stim.sent_block.1D
	#                motion.run#_sub0##_demean.1D
	#                motion.run#_sub0##_deriv.1D
	#                
	#                This program takes as input several pieces of information.  
	#                The first being a 4 dimensional fMRI dataset which has  
	#                undergone preprocessing steps to correct for head motion,
	#                time displacement, noise correction, as well as warping to
	#                a standard template (in this instance, MNI)
	#                
	#                Additionally, 5 time files are provided; 
	#                The first being the censor file, which consists of timepoints
	#                related to the cue periods (18 in all) that should not be 
	#                included in the analysis. 
	#                The next two time files are the actual times (in seconds) 
	#                the stimulus blocks occurred in the analysis, one for Tone
	#                and one for sentences respectively. 
	#                The last two time files are the demeaned motion parameters 
	#                and the motion derivatives respectively. These files are used
	#                as regressors in the model to account for any possible motion
	#                artifacts within the data. 
	#
	#		 Output: run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.xmat
	#                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.jpeg
	#                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.fitts.nii.gz
	#                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.errts.nii.gz
	#                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.stats.nii.gz
	#                
	#       Details: Polort is automatically determined by the 3dDeconvolve too
	#                An Automask is generated automatically for use in the analysis
	#                Local times are used since they are local to the individual runs
	#                There are 14 stimulus time inputs, those include the two stimulus
	#                onset times (sent_block, tone_block), and the motion regressors
	#                provided by the files motion.run#_sub0##_demean.1D and 
	#                motion.run#_sub0##_deriv.1D, each of which contains a column 
	#                representing Roll, Pitch, Yaw, dS, dL, and dP. 
	#                In order to take advantage of modern computing power and speed
	#                up the analysis, the option -jobs 4 enables the program to utilize
	#                4 processor cores. The program also produces a file with the 
	#                error residuals and a fitts file which can be used to test how well
	#                the model fits with the actual data. 
	#                The final bucket file contains the Full Fstat Beta weights, 
	#                and T-statistic.
	#                
	#	  Variables: delay, input4d, output4d, model, input1D
	#                
	#------------------------------------------------------------------------
		
	function regress_convolve ()
	{
		echo -e "\nregress_convolve has been called\n"			# This is will display a message in the terminal which will help to keep
																# track of what function is being run. 

		for delay in {0..7}; do 								# This is a loop which runs the deconvolution at each delay (in seconds)
																# the result of which is 8 seperate processes run.

			#-------------------------------------------------#
			#  Defining some variables before we get started  #
			#-------------------------------------------------#
			input4d=$1  										# <= run#_sub0##_tshift_volreg_despike_mni_7mm_164tr
			model="WAV(18.2,${delay},4,6,0.2,2)"				# <= The modified Cox Special, values are in seconds
																#    WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
			output4d=${input4d}_${delay}sec_${condition}		# <= run#_sub0##_tshift_volreg_despike_mni_7mm_164tr_#sec_
			
			input1D=( cue_stim.1D tone_block.1D sent_block.1D \
					  ${runsub[r]}_demean.1D\'[0]\' ${runsub[r]}_demean.1D\'[1]\' \
					  ${runsub[r]}_demean.1D\'[2]\' ${runsub[r]}_demean.1D\'[3]\' \
					  ${runsub[r]}_demean.1D\'[4]\' ${runsub[r]}_demean.1D\'[5]\' \
					  ${runsub[r]}_deriv.1D\'[0]\'  ${runsub[r]}_deriv.1D\'[1]\' \
					  ${runsub[r]}_deriv.1D\'[2]\'  ${runsub[r]}_deriv.1D\'[3]\' \
					  ${runsub[r]}_deriv.1D\'[4]\'  ${runsub[r]}_deriv.1D\'[5]\' )
			
			#-------------------------------------------------#
			#         On to the real processing, woo!         #
			#-------------------------------------------------#
			3drefit -TR 2.6 ${FUNC}/${input4d}.nii		# Files were rewritten to have a TR of 1 second,
														# so I used 3drefit to correct the header, and 
														# change the TR to 2.6 seconds before it goes into 
														# 3dDeconvolve

			3dDeconvolve \
				-input ${FUNC}/${input4d}.nii \
					-polort A \
					-automask \
					-local_times \
				-num_stimts 14 \
						-censor ${STIM}/censor.${input1D[0]} \
				-stim_times 1 \
						${STIM}/stim.${input1D[1]} "${model}" \
							-stim_label 1 \
								${condition}_${input1D[1]} \
				-stim_times 2 \
						${STIM}/stim.${input1D[2]} "${model}" \
							-stim_label 2 \
								${condition}_${input1D[2]} \
				-stim_file 3 \
						${ID}/motion.${input1D[3]} \
							-stim_base 3 \
							-stim_label 3 roll_demean    \
				-stim_file 4 \
						${ID}/motion.${input1D[4]} \
							-stim_base 4 \
							-stim_label 4 pitch_demean  \
				-stim_file 5 \
						${ID}/motion.${input1D[5]} \
							-stim_base 5 \
							-stim_label 5 yaw_demean     \
				-stim_file 6 \
						${ID}/motion.${input1D[6]} \
							-stim_base 6 \
							-stim_label 6 dS_demean      \
				-stim_file 7 \
						${ID}/motion.${input1D[7]} \
							-stim_base 7 \
							-stim_label 7 dL_demean      \
				-stim_file 8 \
						${ID}/motion.${input1D[8]} \
							-stim_base 8 \
							-stim_label 8 dP_demean      \
				-stim_file 9 \
						${ID}/motion.${input1D[9]} \
							-stim_base 9 \
							-stim_label 9 roll_deriv     \
				-stim_file 10 \
						${ID}/motion.${input1D[10]} \
							-stim_base 10 \
							-stim_label 10 pitch_deriv \
				-stim_file 11 \
						${ID}/motion.${input1D[11]} \
							-stim_base 11 \
							-stim_label 11 yaw_deriv   \
				-stim_file 12 \
						${ID}/motion.${input1D[12]} \
							-stim_base 12 \
							-stim_label 12 dS_deriv    \
				-stim_file 13 \
						${ID}/motion.${input1D[13]} \
							-stim_base 13 \
							-stim_label 13 dL_deriv    \
				-stim_file 14 \
						${ID}/motion.${input1D[14]} \
							-stim_base 14 \
							-stim_label 14 dP_deriv    \
				-xout \
					-x1D ${ID}/${output4d}.xmat.1D \
					-xjpeg ${IM}/${output4d}.xmat.jpg \
				-jobs 4 \
				-fout -bout -tout \
				-errts ${FITTS}/${output4d}.errts.nii.gz \
				-fitts ${FITTS}/${output4d}.fitts.nii.gz \
				-bucket ${STATS}/${output4d}.stats.nii.gz

		done
	}



	#------------------------------------------------------------------------
	#
	#	Description: regress_plot
	#                
	#		Purpose: The purpose of this function is to visualize the regression
	#                coefficients of the computed General Linear Model performed
	#                by AFNI's 3dDeconvolve.  
	#                
	#		  Input: run#_sub0##_#sec_sent_block_learnable.xmat.1D
	#                
	#                This program takes as input a 1 dimensional x-matrix file 
	#                which consists of the regression analysis' model coefficients.
	#                This file is output by the program 3dDeconvolve. 
	#                
	#		 Output: run#_sub0##_#sec_sent_block_learnable.tone_block.1D
	#                run#_sub0##_#sec_sent_block_learnable.sent_block.1D
	#                run#_sub0##_#sec_sent_block_learnable.Regressors-All.jpeg  
	#                run#_sub0##_#sec_sent_block_learnable.Regressors-Stim.jpeg
	#                
	#	  Variables: delay, input4d, ID, IM, STIM
	#
	#          Note: This function is run within the regress_convolve function,
	#                which supplies the appropriate input.
	#                
	#------------------------------------------------------------------------

	function regress_plot ()
	{
		echo -e "\nregress_plot has been called\n"
		
		for delay in {0..7}; do
			
			input4d=${1}_${delay}sec_${condition}

			1dcat \
				${ID}/${input4d}.xmat.1D'[4]' \
				> ${FITTS}/ideal.${input4d}.tone_block.1D
		
			1dcat \
				${ID}/${input4d}.xmat.1D'[5]' \
				> ${FITTS}/ideal.${input4d}.sent_block.1D
		
			1dplot \
				-sepscl \
				-censor_RGB red \
				-censor ${STIM}/censor.cue_stim.1D \
				-ynames baseline polort1 polort2 \
						polort3 tone_block sent_block \
						roll_demean pitch_demean yaw_demean \
						dS_demean dL_demean dP_demean \
						roll_deriv pitch_deriv yaw_deriv \
						dS_deriv dL_deriv dP_deriv \
				-jpeg ${IM}/${input4d}.Regressors-All \
				${ID}/${input4d}.xmat.1D'[0..$]'

			1dplot \
				-censor_RGB green \
				-ynames tone_block sent_block \
				-censor ${STIM}/censor.cue_stim.1D \
				-jpeg ${IM}/${input4d}.Regressors-Stim \
				${ID}/${input4d}.xmat.1D'[5,4]'
		done
	}
	


	#------------------------------------------------------------------------
	#
	#	Description: regress_alphcor
	#                
	#		Purpose: a
	#                
	#		  Input: a
	#                
	#		 Output: a  
	#                
	#	  Variables: input4d, fwhmx, condition, STATS, FUNC
	#                
	#------------------------------------------------------------------------

	function regress_alphcor ()
	{
		for delay in {0..7}; do
			
			input4d=${1}_${delay}sec_${condition}

			fwhmx=$(3dFWHMx \
					-dset ${FITTS}/${input4d}.errts.nii.gz \
					-mask ${FUNC}/${input4d}.fullmask.nii.gz \
					-combine -detrend)

			echo ${fwhmx} >> ${STIM}/${RUN[r]}_${condition}.FWHMx.txt
			
			
			3dClustSim \
				-both -NN 123 \
				-mask ${FUNC}/${runsub[r]}.fullmask.nii.gz \
				-fwhm "${fwhmx}" -prefix ${STATS}/ClustSim.${condition}
			
			
			cd ${STATS}
			3drefit \
				-atrstring AFNI_CLUSTSIM_MASK file:ClustSim.${condition}.mask \
				-atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.${condition}.NN1.niml \
				-atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.${condition}.NN2.niml \
				-atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.${condition}.NN3.niml \
				${input4d}.stats.nii.gz
		done
	}
	



	#------------------------------------------------------------------------
	#
	#	Description: Test_Main
	#                
	#		Purpose: This function tests the variables within the script to
	#                ensure they are expanding correctly within the scope of
	#                the individual functions. It does not contribute to the
	#                analysis in anyway beyond debugging this script. 
	#                
	#		  Input: None
	#                
	#		 Output: Various statements are printed to the terminal displaying
	#                the current values of the variables provided within
	#                
	#	  Variables: Too many to list, currently all variables defined within
	#                this script.   
	#                             
	#------------------------------------------------------------------------

	function Test_Main () 
	{
		input4d=$1
		input1D=( cue_stim.1D tone_block.1D sent_block.1D \
			  ${runsub[r]}_demean.1D\'[0]\' ${runsub[r]}_demean.1D\'[1]\' \
			  ${runsub[r]}_demean.1D\'[2]\' ${runsub[r]}_demean.1D\'[3]\' \
			  ${runsub[r]}_demean.1D\'[4]\' ${runsub[r]}_demean.1D\'[5]\' \
			  ${runsub[r]}_deriv.1D\'[0]\'  ${runsub[r]}_deriv.1D\'[1]\' \
			  ${runsub[r]}_deriv.1D\'[2]\'  ${runsub[r]}_deriv.1D\'[3]\' \
			  ${runsub[r]}_deriv.1D\'[4]\'  ${runsub[r]}_deriv.1D\'[5]\' )

		echo "============================Begin Testing============================"
		echo "Subject = ${subj} "
		echo "runsub[r] = ${runsub[r]}"
		echo "condition = ${condition}"
		echo "RUN = ${RUN[r]} "
		echo -e "\n File Names ============================\n"	
		echo "censor.${input1D[0]}"
		echo "stim.${input1D[1]} "
		echo "stim.${input1D[2]}"
		echo "motion.${input1D[3]} "
		echo "motion.${input1D[4]} "
		echo "motion.${input1D[5]} "
		echo "motion.${input1D[6]} "
		echo "motion.${input1D[7]} "
		echo "motion.${input1D[8]} "
		echo "motion.${input1D[9]} "
		echo "motion.${input1D[10]} "
		echo "motion.${input1D[11]} "
		echo "motion.${input1D[12]} "
		echo "motion.${input1D[13]} "
		echo "motion.${input1D[14]} "
		echo -e "\nPath Names  ============================\n"	
		echo "Func dir = ${FUNC}"
		echo "RD dir = ${RD}"
		echo "GLM dir = ${GLM}"
		echo "STIM dir = ${STIM}"
		echo "ID dir = ${ID}"

		for delay in {0..7}; do
			
			output4d=${input4d}_${delay}sec_${condition}
			model="WAV(18.2,${delay},4,6,0.2,2)"
				
			echo -e "\nVariable Names  ============================\n"	
			echo "delay = ${delay}"
			echo "model = ${model}"
			echo "input4d = ${input4d}"
			echo "output4d = ${output4d}"

		done

		echo -e "\n \n"
	}



	#------------------------------------------------------------------------
	#
	#	Description: Main
	#                
	#		Purpose: This function acts as the launching point of all other 
	#                functions within this script. In addition to defining 
	#                the path variables used to point to data within the 
	#                various directories, it also controls the loop which 
	#                iterates over experiment runs. Any operation the user
	#                wishes to be performed related to the analysis should 
	#                be executed within this function. 
	#                
	#		  Input: sub0##
	#                Primary input to this function is the subject number,
	#                which is supplied via a loop in the execution body of
	#                this script. 
	#                
	#		 Output: None, see individual functions for output. 
	#                
	#	  Variables: subj, RUN, runsub, FUNC, RD, STIM, GLM, ID, IM, STATS, FITTS
	#                
	#------------------------------------------------------------------------

	function Main ()
	{
		echo -e "\nMain has been called\n"
		subj=$1
		RUN=( Run1 Run2 Run3 )	
		runsub=( run1_${subj} run2_${subj} run3_${subj} )	
		
		for (( r = 0; r < ${#RUN[*]}; r++ )); do
			#-------------------------------------#
			# Define pointers for Functional data #
			#-------------------------------------#
			FUNC=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}
			RD=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}/RealignDetails

			#---------------------------------#
			# Define pointers for GLM results #
			#---------------------------------#
			STIM=/Volumes/Data/WB1/GLM/STIM
			GLM=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}
			ID=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/1D
			IM=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/Images
			STATS=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/Stats
			FITTS=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/Fitts

			#--------------------#
			# Initiate functions #
			#--------------------#
			setup_subjdir 	
			regress_motion ${runsub[r]}
			regress_convolve ${runsub[r]}_tshift_volreg_despike_mni_7mm_164tr
			regress_plot ${runsub[r]}_tshift_volreg_despike_mni_7mm_164tr
			# regress_alphcor ${runsub[r]}_tshift_volreg_despike_mni_7mm_164tr

			# Test_Main ${runsub[r]}_tshift_volreg_despike_7mm_164tr

		done
	}



	#------------------------------------------------------------------------
	#
	#	Description: HelpMessage
	#                
	#		Purpose: This function provides the user with the instruction for 
	#                how to correctly execute this script. It will only be 
	#                called in cases in which the user improperly executes the 
	#                script. In such a situation, this function will display 
	#                instruction on how to correctly execute this script as
	#                as well as what is considered acceptable input. It will
	#                then exit the script, at which time the user may try again.
	#                
	#		  Input: None
	#                
	#		 Output: A help message instructing the user on how to properly 
	#                execute this script.
	#                
	#	  Variables: none
	#                
	#------------------------------------------------------------------------

	function HelpMessage ()
	{
	   echo "-----------------------------------------------------------------------"
	   echo "+                 +++ No arguments provided! +++                      +"
	   echo "+                                                                     +"
	   echo "+             This program requires at least 1 arguments.             +"
	   echo "+                                                                     +"
	   echo "+       NOTE: [words] in square brackets represent possible input.    +"
	   echo "+             See below for available options.                        +"
	   echo "+                                                                     +"
	   echo "-----------------------------------------------------------------------"
	   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	   echo "   +                Experimental condition                       +"
	   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	   echo "   +                                                             +"
	   echo "   +  [learn]   or  [learnable]    For the Learnable Condtion    +"
	   echo "   +  [unlearn] or  [unlearnable]  For the Unlearnable Condtion  +"
	   echo "   +  [debug]   or  [test]         For testing purposes only     +"
	   echo "   +                                                             +"
	   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
	   echo "-----------------------------------------------------------------------"
	   echo "+                Example command-line execution:                      +"
	   echo "+                                                                     +"
	   echo "+                    bash wb1.glm.sh learn                            +"
	   echo "+                                                                     +"
	   echo "+                  +++ Please try again +++                           +"
	   echo "-----------------------------------------------------------------------"
	   
	   exit 1
	}

#================================================================================
#                              START OF MAIN
#================================================================================

condition=$1 			# This is a command-line supplied variable which determines
						# which experimental condition should be run. This value is 
						# important in that it determines which group of subjects should
						# be run. If this variable is not supplied the program will
						# exit with an error and provide the user with instructions
						# for proper input and execution. 

case $condition in 		
"learn"|"learnable"     ) 
						  condition="learnable"
						  subj_list=( sub013 sub016 sub019 sub021 \
									  sub023 sub027 sub028 sub033 \
								   	  sub035 sub039 sub046 sub050 \
								   	  sub057 sub067 sub069 sub073 ) 
						  ;;

"unlearn"|"unlearnable" ) 
						  condition="unlearnable"
						  subj_list=( sub009 sub011 sub012 sub018 \
									  sub022 sub030 sub031 sub032 \
									  sub038 sub045 sub047 sub048 \
									  sub049 sub051 sub059 sub060 )
						  ;;

"debug"|"test"          ) 
					 	  condition="debugging"
						  subj_list=( sub009 sub013 )
					 	  ;;

*                       ) 
						  HelpMessage
						  ;;
esac


for (( s = 0; s < ${#subj_list[*]}; s++ )); do

	Main ${subj_list[s]}

done

#================================================================================
#                              END OF MAIN
#================================================================================

# Notes:
# 	This data is linked and as such has different path names, below are the differences
# 	between machines.

# 	On Hagar the path names are:
# 		FUNC=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}
# 		RD=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}/RealignDetails
		
# 		STIM=/Volumes/Data/WB1/GLM/STIM
# 		GLM=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}
# 		ID=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/Ideal

# 	On Auk the path names are: 
# 		FUNC=/Exps/Data/WordBoundary1/${subj}/Func/${RUN[r]}
# 		RD=/Exps/Data/WordBoundary1/${subj}/Func/${RUN[r]}/RealignDetails
		
# 		STIM=/Exps/Analysis/WordBoundary1/STIM
# 		GLM=/Exps/Analysis/WordBoundary1/${subj}/Glm/${RUN[r]}
# 		ID=/Exps/Analysis/WordBoundary1/${subj}/Glm/${RUN[r]}/Ideal




