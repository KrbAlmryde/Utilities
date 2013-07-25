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
		-prefix $subj.$run.epan.nii \
		-text_outliers \
		-save_outliers $subj.$run.outs.txt \
		-xSLAB 12.60L-R \
		-ySLAB 12.60S-I \
		-zSLAB 10.50P-A \
		-time:zt 20 ${reps} 3000 @${RAT}/ETC/rat.offsets.1D \
		E*

	3dToutcount -save $subj.$run.outs.nii $subj.$run.epan.nii \
	| 1dplot -jpeg $subj.$run.outs -stdin $subj.$run.outs.nii

	mv $subj.$run.* $PREP/
}




#============================================================
#				 Registration
#============================================================

	#============================================================
	#				 Base registration
	#============================================================

	function base_reg ()
	{
		cat -n $subj.$run.tcat.outs.txt \
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
			-prefix $subj.$run.tcat.nii \
			$subj.$run.epan.nii'[20..$]'

		3dToutcount $subj.$run.tcat.nii > $subj.$run.tcat.outs.txt

		1dplot -jpeg $subj.$run.tcat.outs $subj.$run.tcat.outs.txt
	}



	#============================================================
	#				 Slice-timing correction
	#============================================================

	function rat_tshift ()
	{
		3dTshift \
			-verbose \
			-tzero 0 \
			-prefix $subj.$run.tshift.nii \
			$subj.$run.tcat.nii
	}




	#============================================================
	#				 Despiking
	#============================================================

	function rat_despike ()
	{
		3dDespike \
			-prefix $subj.$run.despike.nii \
			-ssave $subj.$run.spikes.nii \
			$subj.$run.tshift.nii

		3dToutcount $subj.$run.despike.nii > $subj.$run.despike.outs.txt

		1dplot -jpeg $subj.$run.despike.outs $subj.$run.despike.outs.txt
	}




	#============================================================
	#				 Volume Registration
	#============================================================

	function rat_volreg
	{
		if [[ ! -f $subj.$run.despike.nii ]]; then
			InputFile=tshift
		else
			InputFile=despike
		fi

		3dvolreg \
			-verbose \
			-zpad 1 \
			-base $subj.$run.tshift.nii[`base_reg`] \
			-1Dfile $subj.$run.dfile.1D \
			-prefix $subj.$run.volreg \
			$subj.$run.$InputFile.nii

		1dplot \
			-jpeg $subj.$run.volreg \
			-volreg \
			-xlabel TIME \
			$subj.$run.dfile.1D

		echo "base volume = `base_reg`" > $subj.$run.base.txt

		cp $subj.$run.dfile.1D $GLM/
		cp $subj.$run.volreg* $PCA/
		cp $subj.$run.volreg.nii $FSL/
	}




	#============================================================
	#				 Extract Base Volume
	#============================================================

	function rat_bucket ()
	{
		3dbucket \
			-prefix $subj.$run.BaseVolReg`base_reg`.nii \
			-fbuc $subj.$run.epan.nii[`base_reg`]
	}




	#============================================================
	#				 Masking
	#============================================================

	function rat_mask ()
	{
		3dAutomask \
			-dilate 1 \
			-prefix $subj.$run.automask.nii \
			$subj.$run.BaseVolReg`base_reg`.nii


		3dMean \
			-datum short \
			-prefix rm.mean.nii \
			$subj.$run.automask.nii


		3dcalc \
			-a rm.mean.nii \
			-expr 'ispositive(a-0)' \
			-prefix $subj.$run.fullmask.nii


		3dTstat \
			-prefix rm.$subj.$run.mean.nii \
			$subj.$run.volreg.nii


		rm rm.mean.nii
	}




	#============================================================
	#				 Scaling
	#============================================================

	function rat_scale ()
	{
	    if [[ ! -f $subj.$run.fullmask.edit.nii ]]; then
	        MaskFile=fullmask
	    else
	        MaskFile=fullmask.edit
	    fi


		3dcalc \
			-verbose \
			-float \
			-a $subj.$run.volreg.nii \
			-b rm.$subj.$run.mean.nii \
			-c $subj.$run.$MaskFile.nii \
			-expr 'c * min(200, a/b*100)' \
			-prefix $subj.$run.scale.nii.gz


		rm rm.$subj.$run.mean.nii


		cp $subj.$run.scale.nii.gz $GLM
		cp $subj.$run.$MaskFile.nii $GLM
		cp $subj.$run.$MaskFile.nii $PCA
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

	if [[ ! -f $subj.$run.fullmask.edit.nii ]]; then
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
		-reduce 1 $subj.$run.PCAr.nii\
		-mask $subj.$run.$MaskFile.nii \
		-prefix $subj.$run.PCA.nii \
		$subj.$run.volreg.nii
	
	cp $subj.$run.PCA*nii $ICA/
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
"Input:$subj.$run.$InputVol+orig
CompOutput:$subj.$run.$InputVol.ICA.$compNum.${func}_$Type.nii
MixOutput:$subj.$run.$InputVol.ICmat.$compNum.${func}_$Type.nii
NoComp:${compNum}
Func:${func}
Type:${Type} " \
> $parfile.txt

	3dICA.R $parfile.txt ICA.$subj.$run.$InputVol.log
	
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
