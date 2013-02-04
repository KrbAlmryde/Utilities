#################################################################################
#	Program Name: wb1.reg.sh
#		  Author: Kyle Almryde
#			Date: 02/21/2012
#
#	 Description: The purpose of this program is to correct for subject-related
#				  head motion, volume-registration, and basic preprocessing. This
#				  program will produce several graphs displaying the state of the
#				  functional data over the course of the timeseries. It is meant 
#				  to prepare the data for input into FSL's MELODIC program. 
#				  
#				  This program does not perform slice-timing correction, 
#				  volume concatenation or truncation, or any type of high level 
#				  statistical analyses.
#				  Therefore it is imperitive that the user be aware that the data
#				  output from this program must be corrected for slice-timing and
#				  scanner equilibration (removal of the first n volumes). 
#				  
#				  Some of the output from this program is for documentation and 
#				  diagnostic purposes. They serve no functional role in the 
#				  preprocessing steps beyond that function. 
#				  
#				  The program 3dToutcount and 1dplot are used frequently in this
#				  program, they serve as documentation and diagnostic tools, save
#				  where noted in the block notations. Their presences within the
#				  program is completely optional, though highly recommended. 
#				  
#				  A Note about the documentation style of this program; I precede
#				  all processing code with a block comment. That block comment
#				  will contain the name of the afni program being used, a 
#				  description of its intended purpose, any notes about why certain
#				  options were selected over others, and the expected input and
#				  intended output. 
#				  
#	Deficiencies: None; this program meets specifications.
#
#################################################################################



while read sub; do			# The loop to iterate over subjects
	while read run; do		# The loop to iterate over run
	
		#########################################################################
		# # # # # # # # # # # # # # # Start of Main # # # # # # # # # # # # # # #
		#########################################################################
		
		runsub=${run}_${sub}
		
		cd /Volumes/Data/WordBoundary1/${sub}/Func/${run}/
		
		#########################################################################
		#		Function base_reg
		#	
		#		Purpose:   This function reads an outlier file looking for a
		#				   pattern consisting of a single digit between 1 and 9
		#				   or a two digit number no greater than 19 and prints
		#				   the NUMBER line with which that value falls. That value
		#				   is then subtracted by 1 to account for AFNI's 
		#				   zero-based counting preference. This allows us to acquire
		#				   a base volume to register our data with using 3dVolreg.
		#				   The line number is representative of the volume in the
		#				   dataset, and following the subtraction, fits AFNI's
		#				   conventions. 
		#
		#		  Input:   A list containing the outlier count for each volume of
		#				   a functional run
		#
		#		 Output:   A single integer value representing the most stable
		#				   volume in the dataset, which will act as the base
		#				   volume during registration. 
		#########################################################################
		
		function base_reg ()
		{
		 cat -n ${runsub}.outliers.txt | sort -k2,2n | head -1 | awk '{print $1-1}'
		}
		
		
		
		
		#########################################################################
		#		Command:   3dToutcount, 1dplot
		#
		#		Purpose:   This program calculates the outlier count of a 
		#				   functional run. It generates a list of integers 
		#				   representing each volume within a functional dataset.
		#				   It should be said that "outliers" is a bit of a mis
		#				   nomer, not every volume is going to be an outlier
		#				   obviously...but it will identify those volumes which
		#				   are suspicious.
		#				   
		#				   The program 1dplot gives us a graphical representation
		#				   of this count.
		#
		#		  Input:   sub1_run1.nii.gz
		#
		#		 Output:   sub1_run1.outliers.jpeg
		#				   sub1_run1.outliers.txt
		#
		#		   Note:   These command options are repeated for every block of 
		#				   code as a means of documentation as well as to provide
		#				   a graphical overview of whats happening to the data
		#				   at each step. Only the first instance of this command
		#				   is used to determine processing. (see 3dvolreg below)
		#########################################################################
		
		3dToutcount ${runsub}.nii.gz > ${runsub}.outliers.txt 
		
		1dplot -jpeg ${runsub}.outliers ${runsub}.outliers.txt 
		
		
		
		
		#########################################################################
		#		Command:   3dDespike
		#
		#		Purpose:   This program removes spikes from the data and replaces
		#				   those spike values with something more pleasing to the
		#				   eye. I used pretty basic operations here as I still
		#				   dont quite understand what 3dDespike is replacing the
		#				   spikes with. That being said, it has a remarkable way
		#				   of turning an unusable volume or two (at least in terms
		#				   of spikiness) into something that is at least visually
		#				   more appealing, and hopefully useful. 
		#				   
		#				   It is acknowleged in the Despike documentation that 
		#				   this method may interfere with volume registration, 
		#				   as some spikes may be related to head-motion. This is
		#				   why I choose not to select a base volume from the 
		#				   Despiked data and instead choose the initial volume. 
		#				   See further discussion in the 3dvolreg commentary. In 
		#				   addition to the Despiked dataset, it also produces a
		#				   "spikes" dataset, which saves the spikiness measure 
		#				   for each voxel. This information is saved for 
		#				   diagnostic purposes, but otherwise has no influence 
		#				   on later processing. 
		#
		#		  Input:   run1_sub001.nii.gz
		#
		#		 Output:   run1_sub001_despike.nii
		#				   run1_sub001_spikes.nii
		#				   run1_sub001_despike_outs.txt
		#				   run1_sub001_despike_outs.jpeg
		#
		#########################################################################
		
		3dDespike \
			-prefix ${runsub}_despike.nii \
			-ssave ${runsub}_spikes.nii \
			${runsub}.nii.gz
		
		3dToutcount ${runsub}_despike.nii > ${runsub}_despike_outs.txt
		
		1dplot -jpeg ${runsub}_despike_outs ${runsub}_despike_outs.txt
		
		
		
		
		#########################################################################
		#		Command:   3dvolreg
		#
		#		Purpose:   This program will perform the motion-correction and 
		#				   volume registration of the functional data. 
		#				   
		#				   The "-verbose -verbose" options provide copious amounts
		#				   of detail regarding what is being done to the data. 
		#				   These options in and of themselves do not affect the 
		#				   output in anyway other than to show you exactly what 
		#				   is happening. The log file log.reg.nwy.txt contains
		#				   all of this information. 
		#				   
		#				   The "-zpad 4" option Zeropads 4 voxels around the 
		#				   edges of the image during rotation in order to assist 
		#				   in the volume registration procedure. These edge values
		#				   are stripped off in the output.
		#				   
		#				   The "-base" option sets the base dataset and volume to
		#				   which the image is registered to. See the description
		#				   for the function "base_reg" for details on its selection
		#				   process. I chose to align the image to the initial 
		#				   dataset run1_sub001.nii.gz because that represents the
		#				   data in its purest and least interpolated state. The
		#				   assumption being that as we process the data, we may 
		#				   be subject to an interpolation error, which could give
		#				   us an inaccurate assumption about the state of that
		#				   volume.
		#				   
		#				   The "-1Dfile" outputs a 1D file containing the results
		#				   of the volume registration. This file produces the 
		#				   Volume Registered graph, detailing graphically what
		#				   was done for each rotation and displacement. 
		#				   
		#				   The "-cubic" option performs a cubic polynomial
		#				   interpolation. Ill be quite honest, I have no idea
		#				   what that really means, there are several options
		#				   avaiable, including Fourier, heptic, and quintic
		#				   interpolation methods. The way I understand it, these
		#				   options have more to do with processing speed than 
		#				   anything else. Not to mention, it gets the job done. 
		#				   Elena seemed to have a better understanding of this than
		#				   I did, so it may be good to ask her for more details. 
		#				   Should you want to change this, simply replace "-cubic"
		#				   with "-quintic", "-heptic", or "-Fourier". 
		#				   
		#
		#		  Input:   run1_sub001_despike.nii
		#				   run1_sub001.nii.gz
		#
		#		 Output:   run1_sub001_volreg.nii
		#				   run1_sub001_dfile.1D
		#				   run1_sub001_volreg.jpeg
		#				   run1_sub001_volreg_outs.txt
		#
		#########################################################################
		
		3dvolreg -verbose -verbose -zpad 4 \
			-base ${runsub}.nii.gz[`base_reg`] \
			-1Dfile ${runsub}_dfile.1D \
			-prefix ${runsub}_volreg.nii \
			-cubic ${runsub}_despike.nii
		
		echo "base volume = `base_reg`" > ${runsub}_base_volume.volreg.txt
		
		3dToutcount ${runsub}_volreg.nii > ${runsub}_volreg_outs.txt
		
		1dplot -jpeg ${runsub}_volreg -volreg -xlabel TIME ${runsub}_dfile.1D
		
		1dplot -jpeg ${runsub}_volreg_outs ${runsub}_volreg_outs.txt
		
		
		
		
		#########################################################################
		#		Command:   3dBucket
		#
		#		Purpose:   Extract the base volume used to co-register the image
		#				   in 3dVolreg. 
		#
		#		  Input:   run1_sub001.nii
		#
		#		 Output:   run1_sub001_baseVolreg86.nii
		#
		#########################################################################
		
		3dbucket \
			-prefix ${runsub}_BaseVolReg`base_reg`.nii.gz \
			-fbuc ${runsub}.nii.gz[`base_reg`]
		
		mv ${runsub}_BaseVolReg`base_reg`.nii.gz ../
		
		
		#########################################################################
		#		Command:   3dmerge
		#
		#		Purpose:   Apply a 6.0mm gaussian smoothing kernel. A 6mm
		#				   smoothing kernel was chosen in part because it was
		#				   larger than the z-voxel, and commonly cited in the 
		#				   literature as an acceptable smoothing size. 
		#
		#		  Input:   run1_sub001_volreg.nii
		#
		#		 Output:   run1_sub001_blur.nii
		#
		#########################################################################
		
		3dmerge \
			-1blur_fwhm 6.0 \
			-doall \
			-prefix ${runsub}_blur.nii \
			${runsub}_volreg.nii
		
		
		
		
		#########################################################################
		#		Command:   3dAutomask
		#
		#		Purpose:   This program will automatically generate a mask of the
		#				   cortical and sub-cortical Gray and White matter. This
		#				   is done to ensure that only activation within the brain
		#				   is analyzed. This mask is based on the smoothed/blurred 
		#				   functional data
		#
		#		  Input:   sub1_run1_blur.nii
		#
		#		 Output:   sub1_run1_automask.nii
		#
		#########################################################################
		
		3dAutomask -prefix ${runsub}_automask.nii ${runsub}_blur.nii
		
		
		
		
		#########################################################################
		#		Command:   3dTstat, 3dCalc
		#
		#		Purpose:   The purpose of this block is to perform scaling of the
		#				   functional data before entering it into higher level
		#				   analysis, such as an ICA. 
		#				   
		#				   The 3dTstat command by default computes the mean 
		#				   activation for each voxel across the entire volume,
		#				   resulting in a single volume dataset containing the
		#				   mean intensitity of each voxel.
		#				   
		#				   The 3dCalc command calculates the scaled dataset. The
		#				   options included within the command pertain to the 
		#				   amount of computation that is directed to stdout (-verbose)
		#				   and does not affect the computation. The -float option
		#				   promotes primitive data types hi-precision floats, which
		#				   are necessary if we wish to accurately scale the functional
		#				   data. The expression used to calulate the scale is is 
		#				   described below:
		#							c * min(200, a/b*100)
		#
		#		  Input:   sub1_run1_blur.nii(a), sub1_run1_mean.nii(b), 
		#				   sub1_run1_automask.nii(c)
		#
		#		 Output:   sub1_run1_scale.nii
		#
		#########################################################################
		
		3dTstat -prefix ${runsub}_mean.nii ${runsub}_blur.nii
		
		3dcalc -verbose -float \
			-a ${runsub}_blur.nii \
			-b ${runsub}_mean.nii \
			-c ${runsub}_automask.nii \
			-expr 'c * min(200, a/b*100)' \
			-prefix ${runsub}_scale.nii.gz
		
		3dToutcount ${runsub}_scale.nii.gz > ${runsub}_scale.txt
		
		1dplot -jpeg ${runsub}_scale ${runsub}_scale.txt
		
		
		
		
		#########################################################################
		#		Command:   1d_tool.py
		#
		#		Purpose:   This program determines which volumes within a 
		#				   functional dataset should be censored based on the 
		#				   results of the motion-correction. It utilizes an 
		#				   algorithm based on the norm of the Euclidiean distance
		#				   and TR to determine which volumes should be removed
		#				   from the analysis. The threshold for what should be 
		#				   removed and what should be retained is arbitrary and
		#				   can be adjusted by the user. I chose a value of ".1"
		#				   because it had the strongest agreement with what I 
		#				   would consider a volume needing censoring looked like.
		#				   
		#				   Its primary purpose to be fed in the AFNI program 
		#				   3dDeconvolve, and so may have little use for the 
		#				   purpose of the current experiment. That being said, 
		#				   its here if you need it. 
		#
		#		  Input:   run1_sub001_dfile.1D (output from 3dvolreg)
		#
		#		 Output:   motion_run1_sub001_censor.1D
		#				   motion_run1_sub001_CENSOR.txt
		#				   motion_run1_sub001_enorm.1D
		#
		#########################################################################
		
		1d_tool.py -verb 2 -infile ${runsub}_dfile.1D \
			-set_nruns 1 -set_tr 2.6 \
			-show_censor_count \
			-censor_prev_TR \
			-censor_motion .1 \
			motion_${runsub}
		
		
		
		
	done <$LST/lst_run_wb1.txt
done <$LST/lst_subj_wb1.txt




