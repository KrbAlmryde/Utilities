#===============================================================================
#
#				Pre-Processing Functions !!
#		Functions defined elsewhere:
#					Study_Variables 	see ${study}_profile 60
#					Truncate			see ${study}_profile 147
#
#
#
#
#===============================================================================


#--------------------------------------------------------------------------------
# The following functions act as 'Utility' functions. They perform simple,
# repeatable operations specific to the Reconstruction step. They have been
# indented to assist in readability and identification of their role within this
# program. Most of the arguments contained within these functions are supplied
# by the experiment profile.
#--------------------------------------------------------------------------------


	#----------------------------------------------------------------------------
	#		Function Echo_progress
	#
	#		Purpose:  This function declares the step currently being performed
	#				  in the analysis pipeline
	#
	#
	#
	#		  Input:  The name of the current step being performed. 
	#
	#
	#		 Output:  =========== $subrun $step ============== padded by newlines
	#
	#
	#----------------------------------------------------------------------------
	
	function Echo_progress ()
	{
		Study_Variables
		local step=$1
		
		echo
		echo "=========== $subrun $step =============="
		echo
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

	function Base_Reg ()
	{
		Study_Variables
		#Truncate
		#((x=$trunc+1))

		local x=1
		base=`cat -n \
			${SUBJ_petc}/${subrun}.tshift.outs.txt \
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
	#	  Variables:   infile, tail
	#
	#----------------------------------------------------------------------------

	function Outcount_Plot ()
	{
		Study_Variables
	
		local infile=$1
		local tail
		
		case $infile in
			epan )
				tail=orig ;;
			tcat )
				tail=orig ;;
			despike )
				tail=orig ;;
			tshift )
				tail=orig ;;
			vr.reg )
				tail=orig ;;
			blur )
				tail=tlrc ;;
			scale )
				tail=tlrc ;;
		esac
	
		3dToutcount \
			${subrun}.${infile}+${tail} \
			> ${SUBJ_petc}/${subrun}.${infile}.outs.txt
	
		1dplot \
			-jpeg ${SUBJ_petc}/${subrun}.${infile}.outs \
			${SUBJ_petc}/${subrun}.${infile}.outs.txt
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
	#		 Output:   'maskfile' variable. If ${subrun}.fullmask.edit exists
	#					in the current direcotry, maskfile=fullmask.edit, 
	#					otherwise maskfile=fullmask.edit
	#
	#----------------------------------------------------------------------------
	
	function Mask_check ()
	{
		if [[ ! -f ${SUBJ_prep}/${subrun}.fullmask.edit+orig.HEAD ]]; then
			maskfile=fullmask
		else
			maskfile=fullmask.edit
		fi
	}




#----------------------------------
# Pre-processing Functions
#----------------------------------

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_tcat
#
#		Purpose:   This function will remove
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

function Preproc_tcat ()
{

	Study_Variables; Truncate
	Echo_progress TCAT

	cd ${SUBJ_prep}

	if [[ ! -e ${SUBJ_prep}/${subrun}.tcat+orig.HEAD ]]; then
			
		3dTcat \
			-verb \
			-prefix ${subrun}.tcat \
			${subrun}.epan+orig'['${trunc}'..$]'
	
		echo "slices truncated = ${trunc}" > ${subrun}.log.txt
		echo "remaining slices = ${rfs}" >> ${subrun}.log.txt
	
		Outcount_Plot tcat
	else 

		echo "${subrun}.tcat+orig already exists!!"

	fi 2>&1 | tee -a ${SUBJ_prep}/log.tcat.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_despike
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

function Preproc_despike ()
{
	Study_Variables 
	Echo_progress DESPIKE
	
	if [[ ! -e ${SUBJ_prep}/${subrun}.despike+orig.HEAD ]]; then
		
		cd $SUBJ_prep
		
		3dDespike \
			-prefix ${subrun}.despike \
			-ssave ${subrun}.spikes \
			${subrun}.tcat+orig
	
		Outcount_Plot despike
	else 

		echo "${subrun}.despike+orig already exists!!"

	fi 2>&1 | tee -a $SUBJ_prep/log.despike.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_Tshift
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

function Preproc_tshift ()
{
	Study_Variables
	Echo_progress TSHIFT
	
	if [[ ! -e ${SUBJ_prep}/${subrun}.tshift+orig.HEAD ]]; then
		
		cd ${SUBJ_prep}
		
		3dTshift \
			-verbose \
			-tzero 0 \
			-rlt+ \
			-quintic \
			-prefix ${subrun}.tshift \
			${subrun}.despike+orig
	
		Outcount_Plot tshift
		
	fi 2>&1 | tee -a $SUBJ_prep/log.tshift.txt
}




#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_volreg2stand
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

function Preproc_volreg2stand ()
{
	Study_Variables; Base_Reg
	Echo_progress REGISTER
	
	if [[ ! -e ${subrun}.vr.reg+tlrc.HEAD ]]; then
	
		cd $SUBJ_prep
		
		align_epi_anat.py \
			-anat ${SUBJ_struc}/${subj}.spgr.standard+orig \
			-anat_has_skull no \
			-epi ${subrun}.tshift+orig \
			-big_move \
			-epi_strip 3dAutomask \
			-epi_base ${base} \
			-epi2anat -suffix .reg  \
			 -volreg on -volreg_opts  \
					-verbose -verbose -zpad 4 \
					-1Dfile ${SUBJ_glm}/${subrun}.dfile.1D \
			-tlrc_apar ${SUBJ_struc}/${subj}.spgr.standard+tlrc
		
		3dcopy ${subrun}.tshift.reg+orig ${subrun}.vr.reg+orig
		3dcopy ${subrun}.tshift_tlrc.reg+tlrc ${subrun}.vr.reg+tlrc

		rm ${subrun}.tshift.reg+orig.* ${subrun}.tshift_tlrc.reg+tlrc.*


		Outcount_Plot vr.reg
		
		1dplot \
			-jpeg ${subrun}.vr.reg \
			-volreg \
			-xlabel TIME \
			${SUBJ_glm}/${subrun}.dfile.1D
			

fi 2>&1 | tee -a $SUBJ_prep/log.registration.txt

}


#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_volreg
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

function Preproc_volreg ()
{
	Study_Variables; Base_Reg
	Echo_progress VOLREG
	
	if [[ ! -e ${SUBJ_prep}/${subrun}.volreg+orig.HEAD ]]; then
		
		cd ${SUBJ_prep}
		
		3dvolreg \
			-verbose \
			-verbose \
			-zpad 4 \
			-base ${subrun}.tshift'['${base}']' \
			-1Dfile ${SUBJ_glm}/${subrun}.dfile.1D \
			-prefix ${subrun}.volreg \
			-cubic ${subrun}.tshift+orig
	
		echo "base volume = ${base}" >> ${subrun}.log.txt

		
		1dplot \
			-jpeg ${subrun}.volreg \
			-volreg \
			-xlabel TIME \
			${SUBJ_glm}/${subrun}.dfile.1D
	
		Outcount_Plot volreg
	
		cp ${subrun}.dfile.1D ${SUBJ_glm}
		mv ${subrun}.volreg.jpg $ETC_prep
		mv ${subrun}.dfile.1D $ETC_prep
		
	fi 2>&1 | tee -a $SUBJ_prep/log.volreg.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_smoothing
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

function Preproc_smoothing ()
{
	Study_Variables; Base_Reg
	Echo_progress SMOOTHING

	local filter=$1

	if [[ ! -e ${SUBJ_prep}/${subrun}.blur+tlrc.HEAD ]]; then

		cd ${SUBJ_prep}

		3dBlurInMask \
			-preserve \
			-FWHM ${filter} \
			-automask \
			-prefix ${subrun}.blur \
			${subrun}.vr.reg+tlrc

		3dbucket \
			-prefix ${subrun}.BaseVolReg.${base} \
			-fbuc ${subrun}.blur+tlrc'['${base}']'

		Outcount_Plot blur	

		echo "Gaussian filter = ${filter}" >> ${subrun}.log.txt

	fi 2>&1 | tee -a $SUBJ_prep/log.smoothing.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_masking
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

function Preproc_masking ()
{
	Study_Variables; Base_Reg
	Echo_progress MASKING

	if [[ ! -e ${SUBJ_prep}/${subrun}.fullmask+tlrc.HEAD ]]; then
	
		cd ${SUBJ_prep}
	
		3dAutomask \
			-prefix ${subrun}.fullmask \
			${subrun}.blur+tlrc
	
		3dresample \
			-master ${subrun}.fullmask+tlrc \
			-prefix ${SUBJ_prep}/${subrun}.spgr.resam \
			-input ${SUBJ_struc}/${subj}.spgr.standard+tlrc
	
		3dcalc \
			-a ${subrun}.spgr.resam+tlrc \
			-expr 'ispositive(a)' \
			-prefix ${subrun}.spgr.mask
	
		3dABoverlap \
			-no_automask ${subrun}.fullmask+tlrc \
			${subrun}.spgr.mask+tlrc \
			2>&1 | tee -a ${SUBJ_prep}/${subrun}.mask.overlap.txt
	
		3dABoverlap \
			-no_automask \
			${ANOVA_mask}/N27.mask+tlrc \
			${subrun}.spgr.mask+tlrc \
			2>&1 | tee -a ${SUBJ_petc}/${subrun}.spgr.mask.overlap.txt
	
		echo "( ${subrun} / N27 ) = \
			`cat ${SUBJ_petc}/${subrun}.spgr.mask.overlap.txt \
			| tail -1 | awk '{print $8}'`" \
			>> ${ANOVA_mask}/N27.mask.overlap.txt
	
		cp ${subrun}.fullmask+tlrc.* ${SUBJ_glm}
	
	fi 2>&1 | tee -a $SUBJ_prep/log.masking.txt
}


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#----------------------------------------------------------------------------
#		Function Preproc_scale
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

function Preproc_scale ()
{
	Study_Variables; Base_Reg; Mask_check
	Echo_progress SCALE

	if [[ ! -f ${SUBJ_prep}/${subrun}.scale+tlrc.HEAD ]]; then 
		
		cd $SUBJ_prep

		3dTstat \
			-prefix rm.${subrun}.mean ${subrun}.blur+tlrc
	
		3dcalc \
			-verbose \
			-float \
			-a ${subrun}.blur+tlrc \
			-b rm.${subrun}.mean+tlrc \
			-c ${subrun}.${maskfile}+tlrc \
			-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
			-prefix ${subrun}.scale
	
		Outcount_Plot scale
		
		cp ${subrun}.scale+tlrc.* ${SUBJ_glm}
		
	fi 2>&1 | tee -a $SUBJ_prep/log.scale.txt
}




