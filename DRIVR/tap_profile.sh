#===============================================================================
# This list defines variables and functions specifc to the TAP study. 
#===============================================================================

#-----------------------------------
#	  Subject Dependant Arguments
#-----------------------------------

	#----------------------------------------------------------------------------
	#			Name:  subj_list, subj
	#	
	#		Purpose:   This list variable stores the subject numbers which will 
	#				   be cycled through a loop.
	#				   
	#				   The conterpart to this variable is called 'subj' which will
	#				   contain a single element of the list
	#				   By default subj is defined as TS001
	#				   
	#----------------------------------------------------------------------------
	
	subj_list=`echo TS001 TS002 TS003 TS004 TS005 TS006 TS007 TS008 \
					TS009 TS010 TS011 TS012 TS013 TS014 TS015`

#	subj_list=`echo TS015`			

	#----------------------------------------------------------------------------
	#			Name:  run_list, run
	#	
	#		Purpose:   This list variable stores the run numbers which will 
	#				   be cycled through a loop.
	#				   
	#				   The conterpart to this variable is called 'run' which will
	#				   contain a single element of the list
	#				   By default run is defined as SP1
	#				   
	#----------------------------------------------------------------------------
	
	run_list=`echo SP1 SP2 TP1 TP2`
	

	#----------------------------------------------------------------------------
	#		Function:  Study_Variables
	#	
	#		Purpose:   This function defines the TAP specific variables, 
	#				   including path names for both top level and subject level
	#				   directories. In addition, it includes definitions for 
	#				   file names. 
	#
	#		  Input:   none
	#				   
	#		 Output:   none
	#
	#		  Usage:   This function is intended to be called within the various
	#				   pre-processing and analysis functions. 
	#----------------------------------------------------------------------------

	function Study_Variables ()
	{
		#----------------------------------
		#	 Subject Level Directories
		#----------------------------------
		SUBJ_dir=/Volumes/Data/TAP/${subj}
		SUBJ_orig=/Volumes/Data/TAP/${subj}/Orig
		SUBJ_struc=/Volumes/Data/TAP/${subj}/Struc
		SUBJ_test=/Volumes/Data/TAP/${subj}/Test
		SUBJ_prep=/Volumes/Data/TAP/${subj}/Prep/${run}
		SUBJ_petc=/Volumes/Data/TAP/${subj}/Prep/etc
		SUBJ_glm=/Volumes/Data/TAP/${subj}/GLM/${run}
		SUBJ_getc=/Volumes/Data/TAP/${subj}/GLM/etc
		SUBJ_func=/Volumes/Data/TAP/${subj}/GLM/${run}/FUNC
		SUBJ_reml=/Volumes/Data/TAP/${subj}/GLM/${run}/REML
		SUBJ_iresp=/Volumes/Data/TAP/${subj}/GLM/${run}/IRESP
		SUBJ_model=/Volumes/Data/TAP/${subj}/GLM/${run}/MODEL

		#----------------------------------
		#	 Group Level Directories
		#----------------------------------

		ANOVA_run=/Volumes/Data/TAP/ANOVA/${run}
		ANOVA_orig=/Volumes/Data/TAP/ANOVA/${run}/Orig
		GLM_run=/Volumes/Data/TAP/GLM/${run}
		GLM_etc=/Volumes/Data/TAP/GLM/etc
		GLM_func=/Volumes/Data/TAP/GLM/${run}/FUNC
		GLM_reml=/Volumes/Data/TAP/GLM/${run}/REML
		GLM_iresp=/Volumes/Data/TAP/GLM/${run}/IRESP
		GLM_model=/Volumes/Data/TAP/GLM/${run}/MODEL
	
		#----------------------------------
		#	 Filename Arguments
		#----------------------------------
		subrun=${subj}.${run}
		submod=${subj}.${run}.${model}
		
		subcond=${subj}.${run}.${model}.${cond}
		subcond1=${subj}.${run}.${model}.${cond1}
		subcond2=${subj}.${run}.${model}.${cond2}
		subcond3=${subj}.${run}.${model}.${cond3}
		subcond4=${subj}.${run}.${model}.${cond4}
	
		runmod=${run}.${model}
		runmean=${run}.${model}.mean
		runcontr=${run}.${model}.contr
		runcond1=${run}.${model}.${cond1}
		runcond2=${run}.${model}.${cond2}
		runcond3=${run}.${model}.${cond3}
		runcond4=${run}.${model}.${cond4}
	}


#----------------------------------
#	   Top Level Directory Paths
#----------------------------------
HOME_dir=/Volumes/Data/TAP
BEHAV_dir=/Volumes/Data/TAP/BEHAV
GLM_dir=/Volumes/Data/TAP/GLM/
ANOVA_dir=/Volumes/Data/TAP/ANOVA/
ANOVA_mask=/Volumes/Data/TAP/ANOVA/Masks
ICA_dir=/Volumes/Data/TAP/ICA/
ICA_pca=/Volumes/Data/TAP/ICA/PCA/
ICA_fsl=/Volumes/Data/TAP/ICA/FSL/
REVIEW_dir=/Volumes/Data/TAP/REVIEW
STIM_dir=/Volumes/Data/TAP/STIM
TEST_dir=/Volumes/Data/TAP/TEST
ETC_dir=/Volumes/Data/TAP/ETC




	

#----------------------------------
# Reconstruction Specific Arguments
#----------------------------------

tr=3500 	# repetition time in miliseconds
tR=3.5		# repetition time in seconds

nas=26 		# number of functional slices
nasspgr=164 # number of anatomical slices

thick=5 	# Z-slice thickness for functional and FSE
thickspgr=1 # Z-slice thickness for SPGR

z1=I 		# Slice acquisition direction for functional and FSE
z1spgr=L 	# Slice acquisition direction for SPGR

fov=240 	# field of view for functional and FSE
fovspgr=256 # field of view for SPGR

z=`echo "scale=2; ((nas=$nas-1) * ${thick})/2" | bc`
			# Size of z dimension in functional and FSE image
			# (25 * 5)/2 = 62.00
			
zspgr=`echo "scale=2; ((nasspgr=$nasspgr-1) * ${thickspgr})/2"| bc`
			# Size of z dimension in the Structural SPGR image
			# (163 * 1)/2 = 81

halffov=`echo "scale=2; ${fov}/2"| bc`
			# Field of View of functional and FSE divided by 2
			# 240/2 = 125.00 
			
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`
			# Field of View of structural FSE divided by 2
			# 256/2 = 128.00 

#----------------------------------
# Pre-processing Arguments
#----------------------------------

	#----------------------------------------------------------------------------
	#		Function Truncate
	#	
	#		Purpose:   This function determines the number of functional scans
	#				   to be removed by the AFNI program 3dTcat. That value is
	#				   static (4) unless the number of subjects exceeds 14, in
	#				   which case the value changes to 9 functional scans
	#
	#				   'trunc' contains the number of scans to be
	#				   removed.
	#				   'rfs' represents the slices remaining following the 
	#				   truncation. It is intened for documentation and debugging
	#				   purposes
	#
	#		  Input:   none
	#				   
	#		 Output:   4 or 9 depending on the number of subjects
	#				   
	#		  Usage:   This function is intended to be called within the various
	#				   pre-processing and analysis functions. 
	#----------------------------------------------------------------------------
	
	function Truncate ()
	{
		if [[ $subj = TS015 ]]; then
			nfs=160
			trunc=9
		else
			nfs=154
			trunc=4
		fi
	
		((rfs=$nfs-$trunc))		# The remaining number of slices left
	}




#----------------------------------
# Regression Arguments
#----------------------------------

model=GAM			# This represents the model to be used in the regression
					# analysis


	#----------------------------------------------------------------------------
	#		Function condition_Basic
	#	
	#		Purpose:   This function determines which conditions should be used
	#				   in the analysis. 
	#
	#		  Input:   This function requires the User to specify the 'Type' of 
	#				   conditions to be used. 
	#				   Available options are [Basic]/[b] or [Dprime]/[dp]
	#
	#				   NOTE: If no option is provided, 'Type' is set to [Basic]
	#				   by default
	#				   
	#		 Output:   Output will be the appropriate conditions stored in their
	#				   corresponding variable, which is $run dependant. 
	# 
	#				   The variables cond_list and contr_list are list objects 
	#				   which would supply a loop construct with args 'cond' and 
	#				   'contr' respectively. They have limited  implementation 
	#				   at this time. 
	#
	#----------------------------------------------------------------------------
	
	function Condition ()
	{
		local Type=$1
		
		if [[ -z $Type ]]; then
			Type=Basic
		fi
	
		case $Type in
			Basic | b )
				case $run in
					SP1 )
						cond1=animal
						cond2=food
						cond_list=`echo animal food`
						;;
					SP2 )
						cond1=female
						cond2=male
						cond_list=`echo female male`
						;;
					TP1 )
						cond1=old
						cond2=new
						cond_list=`echo old new`
						;;
					TP2 )
						cond1=female
						cond2=male
						cond_list=`echo female male`
						;;
				esac
				
				cond1v2=${cond1}.vs.${cond2}
				cond2v1=${cond2}.vs.${cond1}
				contr_list=`echo ${cond1}.vs.${cond2} ${cond2}.vs.${cond1}`
			;;
			
			Dprime | dp )
				case $run in
					SP1 )
						cond1=old.hits
						cond2=old.miss
						cond_list=`echo old.hits old.miss`
						;;
					SP2 )
						cond1=af.Female.hits
						cond2=af.Female.miss
						cond3=af.Male.hits
						cond4=af.Male.miss
						cond_list=`echo af.Female.hits af.Female.miss \
										af.Male.hits af.Male.miss`
						;;
					TP1 )
						cond1=Animal.mf.hits
						cond2=Animal.mf.miss
						cond3=Food.mf.hits
						cond4=Food.mf.miss
						cond_list=`echo Animal.mf.hits Animal.mf.miss \
										Food.mf.hits Food.mf.miss`
						;;
					TP2 )
						cond1=af.Female.hits
						cond2=af.Female.miss
						cond3=af.Male.hits
						cond4=af.Male.miss
						cond_list=`echo af.Female.hits af.Female.miss \
										af.Male.hits af.Male.miss`
						;;
				esac
				
				cond1v2=${cond1}.vs.${cond2}
				cond2v1=${cond2}.vs.${cond1}
				cond3v4=${cond3}.vs.${cond4}
				cond4v3=${cond4}.vs.${cond3}
				contr_list=`echo ${cond1}.vs.${cond2} ${cond2}.vs.${cond1} \
							${cond3}.vs.${cond4} ${cond4}.vs.${cond3}`
			;;
			
		esac
	}
	

#----------------------------------
# ANOVA & ICA Arguments
#----------------------------------

plvl=05			# This may become a function eventually, kept for compatibility.
thr=2.160		# Currently set to default values.





#----------------------------------
# Loop Functions
#----------------------------------

	#----------------------------------------------------------------------------
	#		Function Loop_Subj
	#	
	#		Purpose:   This function is a FOR loop which iterates over the 
	#				   $subj_list. 
	#
	#		  Input:   This function requires at least One parameter argument,
	#				   up to Five, in the form of a function, else the loop will
	#				   terminate. 
	#
	#				   If supplied functions require arguments themselves, they 
	#				   should be provided in quotes e.g. 
	#
	#						   loop_SubjRun "register_smoothing 6.0"
	#
	#		 Output:   $subj variable is the default output, additional
	#				   output is based on the supplied functions
	#
	#----------------------------------------------------------------------------

	function Loop_Subj () 
	{
		func1=$1
		func2=$2
		func3=$3
		func4=$4
		func5=$5
		
		if [[ -z $func1 ]]; then
			echo Arguments Required! Exiting....
			exit 0
		fi
		
		for subj in $subj_list; do 
				$func1
				$func2
				$func3
				$func4
				$func5
		done
	}




	#----------------------------------------------------------------------------
	#		Function Loop_SubjRun
	#	
	#		Purpose:   This function is a double nested FOR loop which iterates 
	#				   over the $subj_list and $run_list respectively. 
	#
	#		  Input:   This function requires at least One parameter argument,
	#				   up to Five, in the form of a function, else the loop will
	#				   terminate. 
	#
	#				   If supplied functions require arguments themselves, they 
	#				   should be provided in quotes e.g. 
	#
	#						   loop_SubjRun "register_smoothing 6.0"
	#
	#		 Output:   $subj & $run variables are the default output, additional
	#				   output is based on the supplied functions
	#
	#----------------------------------------------------------------------------
	
	function Loop_SubjRun () 
	{
		func1=$1
		func2=$2
		func3=$3
		func4=$4
		func5=$5
		func6=$6
		func7=$7
		func8=$8
		
		if [[ -z $func1 ]]; then
			echo Loop_SubjRun requires Arguments! Exiting....
			exit 0
		fi
		
		for subj in $subj_list; do 
			for run in $run_list; do
				$func1
				$func2
				$func3
				$func4
				$func5
				$func6
				$func7
				$func8
			done
		done
	}




	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function Loop_SubjRunCond
	#	
	#		Purpose:   This function is a triple nested FOR loop which iterates 
	#				   over the $subj_list, $run_list, and $cond_list 
	#				   respectively.
	#
	#		  Input:   This function requires at least One parameter argument,
	#				   up to Five, in the form of a function, else the loop will
	#				   terminate. 
	#
	#				   If supplied functions require arguments themselves, they 
	#				   should be provided in quotes e.g. 
	#
	#						   loop_SubjRun "register_smoothing 6.0"
	#
	#		 Output:   $subj & $run variables are the default output, additional
	#				   output is based on the supplied functions
	#
	#----------------------------------------------------------------------------
	
	function Loop_SubjRunCond () 
	{ 
		Condition $1
		
		func1=$2
		func2=$3
		func3=$4
		func4=$5
		func5=$6
		func6=$7
		func7=$8
		func8=$9
	
		for subj in $subj_list; do 
			for run in $run_list; do 
				for cond in $cond_list; do
					$func1
					$func2
					$func3
					$func4
					$func5
					$func6
					$func7
					$func8
				done
			done
		done
	}



	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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

	function Review_preproc ()
	{
		local step=$1
		Study_Variables

		cd $REVIEW_dir
			rm $subrun.*

		cd $SUBJ_prep
			cp $subrun.${step}+* $REVIEW_dir

		cd $SUBJ_struc
			cp $subj.spgr.standard+* $REVIEW_dir
		
	}






	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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
	
	function Restart_reconstruc ()
	{
		Study_Variables
		
		cd $SUBJ_orig
			rm $subrun.epan.nii
			
#		cd $STRUC_dir			
#			rm $subj.fse*
#			rm $subj.spgr*

		cd $HOME_dir
			rm log.Low.reconstruct.txt
			rm log.Low.1.txt
	}





	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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
	
	function Restart_preproc ()
	{
		Study_Variables

		cd $SUBJ_petc
			rm $subrun.*
			rm $subrun.*.outs*
			rm motion.${subrun}*

		cd $SUBJ_prep
#			rm *
			rm log.*
			rm *overlap*
#			rm $subrun.*
#			rm $subrun.log.txt
			rm rm.*.nii
		cd $SUBJ_petc
			rm *
			
		cd $HOME_dir
			rm log.Low.preproc.txt
			rm log.Low.2.txt
	}




	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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
	
	function Restart_GLM ()
	{
		Study_Variables
		
		cd $HOME_dir
			rm log.Low.regress.txt
			rm log.Low.restart.txt
		
		cd $SUBJ_getc
			rm *
		
		cd $SUBJ_glm
			rm *
		
		cd $SUBJ_func
			rm *
			
		cd $SUBJ_iresp
			rm *
		
		cd $SUBJ_reml
			rm *
			
		cd $SUBJ_model
			rm *
	}



	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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

	function Restart_Coreg ()
	{
		Study_Variables
		
		cd $HOME_dir
			rm log.Low.Coreg.txt
			rm log.Low.restart.txt
		
		cd $STRUC_subj
			rm ${subj}.spgr_*

		cd $GLM_subj
			rm *..* 
			rm *tlrc.HEAD
			rm *tlrc.BRIK
			
		cd $FUNC_glm
			rm *tlrc.HEAD
			rm *tlrc.BRIK
			mv *orig.HEAD $GLM_subj
			mv *orig.BRIK $GLM_subj
			
		cd $IRESP_glm
			rm *tlrc.HEAD
			rm *tlrc.BRIK
			mv *orig.HEAD $GLM_subj
			mv *orig.BRIK $GLM_subj
		
		cd $REML_glm
			rm *tlrc.HEAD
			rm *tlrc.BRIK
			mv *orig.HEAD $GLM_subj
			mv *orig.BRIK $GLM_subj
	}



	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function 
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

	function Restart_Anova ()
	{
		Study_Variables
		
		cd $HOME_dir
			rm log.High.anova
			rm log.High.restart
		
		cd ${ANOVA_run}
			rm IRF.*
			rm beta.*
			rm *.nii
			rm ss*.3danova*
		
		cd $ANOVA_orig
			mv * ../
	}
