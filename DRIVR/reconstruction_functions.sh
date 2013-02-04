#================================================================================
#						+++ Reconstruction Functions +++
#================================================================================
#----------------------------------
# 		Utility Functions
#--------------------------------------------------------------------------------
# The following functions act as 'Utility' functions. They perform simple,
# repeatable operations specific to the Reconstruction step. They have been
# indented to assist in readability and identification of their role within this
# program. Most of the arguments contained within these functions are supplied
# by the experiment profile.
#--------------------------------------------------------------------------------

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




	#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	#----------------------------------------------------------------------------
	#		Function Outcount_func
	#
	#		Purpose:   This function will take the name of the file (e.g.
	#				   despike, tcat, tshift, etc) as input, and perform
	#				   3dToutcount to identify outliers time-points, then plot
	#				   the results using 1dplot
	#
	#		  Input:   The prefix name of the pre-processing step e.g. tshift
	#				   'outcount_plot tshift'
	#
	#		 Output:   ${subrun}.${step}.outs.txt, ${subrun}.${step}.outs.jpeg
	#
	#	  Variables:   proc, tail, infile
	#
	#----------------------------------------------------------------------------

	function Outcount_recon ()
	{
		Study_Variables; cd $SUBJ_prep
		
		local proc=$1
	
		3dToutcount \
			${subrun}.${proc}+orig \
			> $subrun.$proc.outs.txt
	
		1dplot \
			-jpeg $subrun.$proc.outs \
			$subrun.$proc.outs.txt
	}


#--------------------------------------------------------------------------------
# The following functions do the majority of the work
#--------------------------------------------------------------------------------

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#--------------------------------------------------------------------------------
#		Function Reconstruct_epan
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
#--------------------------------------------------------------------------------

function Reconstruct_epan ()
{
	Study_Variables; Truncate
	cd $SUBJ_orig
    
    if [[ ! -e ${SUBJ_prep}/${subrun}.epan+orig.HEAD ]]; then
		
		Zslice_func

		echo; echo =========== $subrun ==============; echo

		to3d \
			-epan \
			-prefix ${subrun}.epan \
			-session $SUBJ_prep \
			-2swap \
			-text_outliers \
			-save_outliers ${subrun}.outliers.txt \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			-time:tz ${nfs} ${nas} ${tr} \
			@${STIM_dir}/offsets.1D ${run}.*

		Outcount_recon epan

	else

		echo;echo ${subrun}.epan already exists!

	fi 2>&1 | tee -a $SUBJ_prep/log.epan.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#--------------------------------------------------------------------------------
#		Function Reconstruct_fse
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
#--------------------------------------------------------------------------------

function Reconstruct_fse ()
{
	Study_Variables; cd $SUBJ_struc
	
	if [[ ! -e ${subj}.fse+orig.HEAD ]]; then

		Zslice_func

		to3d \
			-fse \
			-prefix ${subj}.fse \
			-session $SUBJ_struc \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			${SUBJ_orig}/e????s[23]i*

	else
		
		echo;echo ${subj}.fse "already exists!"
		
	fi 2>&1 | tee -a $SUBJ_struc/log.FSE.txt
}




#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#--------------------------------------------------------------------------------
#		Function Reconstruc_spgr
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
#--------------------------------------------------------------------------------

function Reconstruct_spgr ()
{
	Study_Variables; cd $SUBJ_struc
	
	if [[ ! -e ${subj}.spgr+orig.HEAD ]]; then

		Zslice_spgr

		to3d \
			-spgr \
			-prefix ${subj}.spgr \
			-session $SUBJ_struc \
			-xFOV ${anatfov}A-P \
			-yFOV ${anatfov}S-I \
			-zSLAB ${zspgr}${z1spgr}-${zspgr}${z2spgr} \
			${SUBJ_orig}/e????s[789]i*

	else
		
		echo ${subj}.spgr "already exists!"
		
	fi 2>&1 | tee -a $SUBJ_struc/log.SPGR.txt
}




