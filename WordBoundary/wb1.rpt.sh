#!/bin/bash
#================================================================================
#	Program Name:  wb1.rpt.sh
#		  Author: Kyle Reese Almryde
#			Date: September 5th, 2012
#
#	 Description: Perform ANOVA on supplied data
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
#                            FUNCTION DEFINITIONS
#===============================================================================

#------------------------------------------------------------------------
#
#	Description: setup_reportDir
#
#		Purpose: Builds local directory structure so we can place files
#
#		  Input: none
#
#		 Output: none
#
#	  Variables: $RUN - run1 run2 run3
#
#------------------------------------------------------------------------

function setup_reportDir ()
{
	mkdir -p /Volumes/Data/WB1/ANOVA/Report/${RUN[r]}/etc
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#================================================================================
#                   Begin extracting Group ROI Stats
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#================================================================================

#------------------------------------------------------------------------
#	grp_roiReport: Executes the subj_noNeg, tTest_clusterCoords, and whereamiReport
#              functions under one umbrella. Supply list of ROIs to report
#	usage: roiReport <ROIs[1,2]>
#------------------------------------------------------------------------


#------------------------------------------------------------------------
#	tTest_clusterCoords: Uses 3dclust to generate a cluster report of a supplied
#                        region of interest, the output of which will be fed into
#                        the whereamiReport
#   input: tTest_${input3dMask}.nii
#	usage: tTest_clusterCoords ${input3dMask}
#------------------------------------------------------------------------

tTest_clusterCoords ()
{
	for (( m = 0; m < ${#input3dMask[*]}; m++ )); do
		3dclust \
			-orient RPI -1noneg -nosum \
			-1dindex 0 -1tindex 1 -1thresh 2.131 \
			-1Dformat 2 0 \
			${TTEST}/tTest_${input3dMask[m]}_sent.nii \
		| tail +12 \
		| awk -v OFS='\t' '{print "tTest", "'${RUN[r]}'", "'${condition}'", "'${event}'", "'${hemi[m]}'", "'${region[m]}'", $1, $11 }' \
		| sed '/#\*\*/d'

	done
}



#------------------------------------------------------------------------
#
#	Description: grp_roiReport
#
#		Purpose:
#
#		  Input:
#
#		 Output:
#
#	  Variables:
#
#------------------------------------------------------------------------

function grp_roiReport ()
{
	echo -e "\n \t###### grp_roiReport ######\n"
	# remove any existing files

	# 3dclust -orient RPI -1noneg -nosum -1dindex 0 -1tindex 1 -1thresh 2.131 -1Dformat 2 0
	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#               Begin extracting Group ROI Stats                         #
	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	tTest_clusterCoords >> ${REPORT}/etc/${RUN[r]}.${condition}.grp_roi_stats.1D

	echo -e "ID\tRun\tCondition\tEvent\tSide\tROI\tVolume\tT-Mean" > \
		${REPORT}/${RUN[r]}.${condition}.GroupReport.1D

	cat ${REPORT}/etc/${RUN[r]}.${condition}.grp_roi_stats.1D >> \
		${REPORT}/${RUN[r]}.${condition}.GroupReport.1D

	subl ${REPORT}/${RUN[r]}.${condition}.GroupReport.1D
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#               Begin extracting Subject ROI Stats
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#------------------------------------------------------------------------
#	subj_noNeg: Uses 3dcalc to create a filtered functional image of a region
#              of interest. Input is a region of interest mask
#	usage: subj_noNeg <region of interest>
#------------------------------------------------------------------------

subj_noNeg ()
{
	for (( i=0, a=0, b=1; i < ${#subj_list[*]}; i++, a+=2, b+=2 )); do
		echo -e "\n \t${subj_list[i]} subj_noNeg \n"
		3dmerge \
			-1noneg \
			-prefix ${COMBO}/etc/${subj_list[i]}_${RUN[r]}_${condition}_sent_NoNeg.nii \
			${COMBO}/${RUN[r]}_${condition}_sent_ComboStat+tlrc'['${a}','${b}']'
	done
}

#------------------------------------------------------------------------
#	subj_roiStat: Uses 3dMaskdump to drop XYZ coords to
#	usage: subj_roiStat <x> <y> <z>
#------------------------------------------------------------------------

subj_roiStat ()
{
	for (( i=0; i < ${#subj_list[*]}; i++)); do
		for (( m = 0; m < ${#input3dMask[*]}; m++ )); do
			3dmaskave \
				-sigma \
				-mask ${MASK}/${input3dMask[m]}.nii \
				${COMBO}/etc/${subj_list[i]}_${RUN[r]}_${condition}_sent_NoNeg.nii \
			| tr '\n' ' ' \
			| awk -v OFS='\t' '{print "'${subj_list[i]}'", "'${RUN[r]}'", "'${condition}'", "'${event}'", "'${hemi[m]}'", "'${region[m]}'", $3, $1, $2}'
		done
	done
}

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#               Begin extracting Group ROI Stats                         #
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#------------------------------------------------------------------------
#	subjectReport: Uses 3dMaskdump to drop XYZ coords to
#	usage: subjectReport
#------------------------------------------------------------------------

subjectReport ()
{
	echo -e "\n \t###### subjectReport ######\n"

	for (( i=0; i < ${#subj_list[*]}; i++ )); do
		#subj_noNeg
		subj_roiStat >> ${REPORT}/etc/${RUN[r]}.${condition}.rm.subj_stats.1D
	done


	echo -e "ID\tRun\tCondition\tEvent\tSide\tROI\tVolume\tT-Mean\tT-Stdev" > ${REPORT}/${RUN[r]}.${condition}.Subject_Report.1D

	cat ${REPORT}/etc/${RUN[r]}.${condition}.rm.subj_stats.1D | sed 's/\[//g' > ${REPORT}/etc/${RUN[r]}.${condition}.subj_stats.1D
	rm ${REPORT}/etc/${RUN[r]}.${condition}.rm.subj_stats.1D


	cat ${REPORT}/etc/${RUN[r]}.${condition}.subj_stats.1D >> \
		${REPORT}/${RUN[r]}.${condition}.Subject_Report.1D

	subl ${REPORT}/${RUN[r]}.${condition}.Subject_Report.1D # This calls up Sublime Text 2 so we can look at the finished product
}



#------------------------------------------------------------------------
#
#	Description: Complete_Report
#
#		Purpose:
#
#		  Input:
#
#		 Output:
#
#	  Variables:
#
#------------------------------------------------------------------------

function Complete_Report ()
{
	echo -e "ID\tRun\tCondition\tEvent\tSide\tROI\tVolume\tT-Mean\tT-Stdev" > \
		${REPORT}/${RUN[r]}.${condition}.Complete_Report.1D

	cat ${REPORT}/etc/${RUN[r]}.${condition}.subj_stats.1D \
		${REPORT}/etc/${RUN[r]}.${condition}.grp_roi_stats.1D \
		>> ${REPORT}/${RUN[r]}.${condition}.Complete_Report.1D

	subl ${REPORT}/${RUN[r]}.${condition}.Complete_Report.1D	# So I can see it.
}



	#------------------------------------------------------------------------
	#
	#	Description: MAIN
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

	function MAIN ()
	{
		for (( r = 0; r < ${#RUN[*]}; r++ )); do
			#----------------------------------#
			# Define pointers for Group report #
			#----------------------------------#
			COMBO=/Volumes/Data/WB1/ANOVA/Combo/${RUN[r]}
			MASK=/Volumes/Data/WB1/ANOVA/Mask/${RUN[r]}
			MERG=/Volumes/Data/WB1/ANOVA/Merge/${RUN[r]}
			TTEST=/Volumes/Data/WB1/ANOVA/tTest/${RUN[r]}
			REPORT=//Volumes/Data/WB1/ANOVA/Report/${RUN[r]}

			#-----------------------------------#
			# Define variables for Group report
			#-----------------------------------#
			plvl=05
			event=sent
			thresh=$(ccalc -expr "fitt_p2t(0.${plvl}000,15)")
			input3dMask=($(basename $(ls ${MASK}/*.nii ) | cut -d . -f1))
			hemi=($(basename $(ls ${MASK}/*.nii ) | cut -d . -f1 | cut -d _ -f3))
			region=($(basename $(ls ${MASK}/*.nii ) | cut -d . -f1 | cut -d _ -f4))
			#--------------------#
			# Initiate functions #
			#--------------------#
			grp_roiReport
			subjectReport
			Complete_Report

		done
	}

#================================================================================
#                                START OF MAIN
#================================================================================

condition=$1 			# This is a command-line supplied variable which determines
						# which experimental condition should be run. This value is
						# important in that it determines which group of subjects should
						# be run. If this variable is not supplied the program will
						# exit with an error and provide the user with instructions
						# for proper input and execution.

operation=$2    # This command-line supplied variable is optional. If it is left


RUN=( Run1 Run2 Run3 )


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




MAIN


#================================================================================
#                              END OF MAIN
#================================================================================

exit

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
	   echo "+                     bash wb1.rpt.sh learn                           +"
	   echo "+                                                                     +"
	   echo "+                  +++ Please try again +++                           +"
	   echo "-----------------------------------------------------------------------"

	   exit 1
	}