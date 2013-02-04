#===============================================================================
#===============================================================================
#	Program Name: rat_functions
#		  Author: Kyle Almryde
#			Date: 02/29/2012
#
#	 Description: The purpose of this program is to
#
#
#
#	Deficiencies: None; this program meets specifications.
#
#===============================================================================
#===============================================================================




#============================================================
#				 Reconstruction of anatomical dataset
#============================================================

function reconstruct_fse ()
{
	cd ${subj}_${run}_anat/

	to3d -fse \
		-prefix $subj.${run}.fse.nii \
		-xSLAB 12.750L-R \
		-ySLAB 12.750S-I \
		-zSLAB 10.50P-A \
		E*

	mv $subj.${run}.fse.nii $PREP/
}




#============================================================
#				 Reconstruction of functional dataset
#============================================================

function reconstruct_epi ()
{
	reps=$1

	if [[ -z $1 ]]; then
		echo -n "How many repetitions? eg 420, 50 "
		read reps						# the number of repetitions in the volume
	fi

	cd ${subj}_${run}_E${reps}/

	to3d -epan \
		-prefix ${subrun}.epan.nii \
		-text_outliers \
		-save_outliers ${subrun}.outs.txt \
		-xSLAB 12.60L-R \
		-ySLAB 12.60S-I \
		-zSLAB 10.50P-A \
		-time:zt 20 ${reps} 3000 @${RAT}/ETC/rat.offsets.1D \
		E*

	3dToutcount -save ${subrun}.outs.nii ${subrun}.epan.nii \
	| 1dplot -jpeg ${subrun}.outs -stdin ${subrun}.outs.nii

	mv ${subrun}.* $PREP/
}




#============================================================
#				 Registration
#============================================================

	#============================================================
	#				 Base registration
	#============================================================

	function base_reg ()
	{
		cat -n ${subrun}.tcat.outs.txt \
		| sort -k2,2n \
		| head -1 \
		| awk '{print $1-1}'
	}




	#============================================================
	#				 Slice-timing correction
	#============================================================

	function rat_tcat ()
	{
		3dTcat \
			-verb \
			-prefix ${subrun}.tcat.nii \
			${subrun}.epan.nii'[4..$]'

		3dToutcount ${subrun}.tcat.nii > ${subrun}.tcat.outs.txt

		1dplot -jpeg ${subrun}.tcat.outs ${subrun}.tcat.outs.txt
	}



	#============================================================
	#				 Slice-timing correction
	#============================================================

	function rat_tshift ()
	{
		3dTshift \
			-verbose \
			-tzero 0 \
			-prefix ${subrun}.tshift.nii \
			${subrun}.tcat.nii
	}




	#============================================================
	#				 Despiking
	#============================================================

	function rat_despike ()
	{
		3dDespike \
			-prefix ${subrun}.despike.nii \
			-ssave ${subrun}.spikes.nii \
			${subrun}.tshift.nii

		3dToutcount ${subrun}.despike.nii > ${subrun}.despike.outs.txt

		1dplot -jpeg ${subrun}.despike.outs ${subrun}.despike.outs.txt
	}




	#============================================================
	#				 Volume Registration
	#============================================================

	function rat_volreg
	{
		if [[ ! -f ${subrun}.despike.nii ]]; then
			InputFile=tshift
		else
			InputFile=despike
		fi

		3dvolreg \
			-verbose \
			-zpad 1 \
			-base ${subrun}.tshift.nii[`base_reg`] \
			-1Dfile ${subrun}.dfile.1D \
			-prefix ${subrun}.volreg \
			${subrun}.$InputFile.nii

		1dplot \
			-jpeg ${subrun}.volreg \
			-volreg \
			-xlabel TIME \
			${subrun}.dfile.1D

		echo "base volume = `base_reg`" > ${subrun}.base.txt

		cp ${subrun}.dfile.1D $GLM/
		cp ${subrun}.volreg* $PCA/
		cp ${subrun}.volreg.nii $FSL/
	}




	#============================================================
	#				 Extract Base Volume
	#============================================================

	function rat_bucket ()
	{
		3dbucket \
			-prefix ${subrun}.BaseVolReg`base_reg`.nii \
			-fbuc ${subrun}.epan.nii[`base_reg`]
	}




	#============================================================
	#				 Masking
	#============================================================

	function rat_mask ()
	{
		3dAutomask \
			-dilate 1 \
			-prefix ${subrun}.automask.nii \
			${subrun}.BaseVolReg`base_reg`.nii


		3dMean \
			-datum short \
			-prefix rm.mean.nii \
			${subrun}.automask.nii


		3dcalc \
			-a rm.mean.nii \
			-expr 'ispositive(a-0)' \
			-prefix ${subrun}.fullmask.nii


		3dTstat \
			-prefix rm.${subrun}.mean.nii \
			${subrun}.volreg.nii


		rm rm.mean.nii
	}




	#============================================================
	#				 Scaling
	#============================================================

	function rat_scale ()
	{
		if [[ ! -f ${subrun}.fullmask.edit.nii ]]; then
			MaskFile=fullmask
		else
			MaskFile=fullmask.edit
		fi


		3dcalc \
			-verbose \
			-float \
			-a ${subrun}.volreg.nii \
			-b rm.${subrun}.mean.nii \
			-c ${subrun}.$MaskFile.nii \
			-expr 'c * min(200, a/b*100)' \
			-prefix ${subrun}.scale.nii.gz


		rm rm.${subrun}.mean.nii


		cp ${subrun}.scale.nii.gz $GLM
		cp ${subrun}.$MaskFile.nii $GLM
		cp ${subrun}.$MaskFile.nii $PCA
	}





#============================================================
#				 High-Level Analysis
#============================================================
#		Utility Functions for High-Level Analysis
#============================================================

function regress_paramCheck ()
{
	eV=$1
	dur=$2
	hrm=$3

	if [[ -z $eV && -z $dur && -z $hrm ]]; then
		echo -n "What is your eV? (eg 39, 39-163): "
			read eV
		echo -n "What is your duration?: "
			read dur
		echo -n "What is your HRM?: "
			read hrm
	elif [[ -z $eV ]]; then
		echo -n "What is your eV? (eg 39, 39-163): "
			read eV
	elif [[ -z $dur ]]; then
		echo -n "What is your duration?: "
			read dur
	elif [[ -z $hrm ]]; then
		echo -n "What is your HRM?: "
			read hrm
	fi

}

function ICA_parmCheck ()
{
	InputVol=$1
	compNum=$2
	func=$3
	Type=$4

	if [[ -z $InputVol && -z $compNum && -z $func && -z $Type ]]; then
		echo -n "What is your input file? (e.g. volreg, scale, PCA, PCAr, etc): "
			read InputVol
		echo -n "How many components would you like? (e.g. 10, 20, 50, 150): "
			read compNum
		echo -n "Function? (logcosh or exp): "
			read func
		echo -n "What Type of analysis? (parallel or deflation): "
			read Type
	elif [[ -z $InputVol ]]; then
		echo -n "What is your input file? (e.g. volreg, scale, PCA, PCAr, etc): "
			read InputVol
	elif [[ -z $compNum ]]; then
		echo -n "How many components would you like?: "
			read compNum
	elif [[ -z $func ]]; then
		echo -n "Function? (logcosh or exp): "
			read func
	elif [[ -z $Type ]]; then
		echo -n "What Type of analysis? (parallel or deflation): "
			read Type
	fi
}





#============================================================
#				 PCA Analysis
#============================================================

function rat_PCA ()
{
	cd $PCA

	if [[ ! -f ${subrun}.fullmask.edit.nii ]]; then
		MaskFile=fullmask
	else
		MaskFile=fullmask.edit
	fi


	3dpc \
		-verb \
		-float \
		-dmean \
		-vnorm \
		-pcsave 50 \
		-reduce 1 ${subrun}.PCAr.nii\
		-mask ${subrun}.$MaskFile.nii \
		-prefix ${subrun}.PCA.nii \
		${subrun}.volreg.nii

	cp ${subrun}.PCA*nii $ICA/
}




#============================================================
#				 ICA Analysis
#============================================================

function rat_ICA ()
{
	ICA_parmCheck $1 $2 $3 $4

	parfile=par.$InputVol.${compNum}.${func}.$Type

	cd $ICA

echo \
"Input:${subrun}.$InputVol+orig
CompOutput:${subrun}.$InputVol.ICA.$compNum.${func}_$Type.nii
MixOutput:${subrun}.$InputVol.ICmat.$compNum.${func}_$Type.nii
NoComp:${compNum}
Func:${func}
Type:${Type} " \
> $parfile.txt

	3dICA.R $parfile.txt ICA.${subrun}.$InputVol.log

}




#============================================================
#				 Cleanup regression
#============================================================

function cleanup_regression ()
{
	mv *.func.nii
	mv *Motion*
	mv *-All*
	mv *$hrm.1D
	mv *irf*
	mv *.REML*
	mv *xmat.jpg*
	mv *Model*
	mv rat.200.$hrm.fitt.nii
	mv rat.200.$hrm.errts.nii
}




#============================================================
#				 Reconstruction of anatomical dataset
#============================================================


function restart_reconstruc ()
{
	echo "Removing reconstruction files..."

	rm *.fse.nii
	rm *.epan.nii
	rm log[1-2].reconstruc*
}


function restart_prep ()
{
	echo "Removing preprocessing files..."

	rm *.tcat.nii
	rm .*spike*
	rm *.ou[t][ts].*
	rm *.tshift.nii
	rm *.volreg.nii
	rm *.[Bb]ase*
	rm *.mean.nii
	rm *.*mask.nii
	rm *.scale.nii.gz
	rm log[3-9].rat_*.txt


	rm *.1D

}


function restart_regression ()
{
	echo "Removing regression files..."
}
