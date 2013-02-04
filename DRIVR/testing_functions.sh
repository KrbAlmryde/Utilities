function Zslice_func ()
{
	if [[ ${z1} = S ]]; then
		z2=I
	elif [[ ${z1} = I ]]; then
		z2=S
	fi
}




function Base_Reg_test ()
{
	Study_Variables
	Truncate

	((x=$trunc+1))
	base=`cat -n \
		$ETC_prep/${subrun}.epan.outs.txt \
		| sort -k2,2n \
		| head -1 \
		| awk '{print $1-'$x'}'`
}




function Outcount_Plot ()
{
	Study_Variables; cd $PREP_subj

	local proc=$1

	case $proc in
		scale )
			tail=nii.gz ;;
		* )
			tail=nii ;;
	esac

	local infile=$subrun.${proc}.${tail}

	3dToutcount \
		$infile \
		> $subrun.$proc.outs.txt

	1dplot \
		-jpeg $subrun.$proc.outs \
		$subrun.$proc.outs.txt
	
	mv $subrun.$proc.outs.* ${ETC_prep}
}




function Mask_check ()
{
	if [[ ! -f ${subrun}.fullmask.edit.nii ]]; then
		maskfile=fullmask
	else
		maskfile=fullmask.edit
	fi
}








function Test_Outfunc ()
{
	Study_Variables; cd $TEST_dir

	for pipe in offsets1 offsets2 seqminus; do
		3dToutcount \
			${subrun}.${pipe}.epan.nii \
			> ${subrun}.${pipe}.epan.outs.txt

		1dplot \
			-jpeg ${subrun}.${pipe}.epan.outs \
			${subrun}.${pipe}.epan.outs.txt
	done
}


function Reconstruct_offsets1 ()
{
	Study_Variables; cd $TEST_dir

	if [[ ! -e ${subrun}.offsets1.epan.nii ]]; then

		cd $ORIG_subj

		Zslice_func

		echo; echo =========== $subrun ==============; echo

		to3d \
			-epan \
			-prefix ${subrun}.offsets1.epan.nii \
			-2swap \
			-text_outliers \
			-save_outliers ${subrun}.offsets1.outliers.txt \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			-time:tz ${nfs} ${nas} ${tr} \
			@${TEST_dir}/offsets1.1D ${run}.*

		Outcount_func offsets1.epan

		cp ${subrun}.offsets1.epan.nii ${TEST_dir}

	fi 2>&1 | tee -a ${TEST_dir}/log.${subrun}.offsets1.epan.txt
}




function Reconstruct_offsets2 ()
{
	Study_Variables; cd $TEST_dir

	if [[ ! -e ${subrun}.offsets2.epan.nii ]]; then

		cd $ORIG_subj

		Zslice_func

		echo; echo =========== $subrun ==============; echo

		to3d \
			-epan \
			-prefix ${subrun}.offsets2.epan.nii \
			-2swap \
			-text_outliers \
			-save_outliers ${subrun}.offsets2.outliers.txt \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			-time:tz ${nfs} ${nas} ${tr} \
			@${TEST_dir}/offsets2.1D ${run}.*

		Outcount_func offsets2.epan

		cp ${subrun}.offsets2.epan.nii ${TEST_dir}

	fi 2>&1 | tee -a ${TEST_dir}/log.${subrun}.offsets2.epan.txt
}


function Reconstruct_seqminus ()
{
	Study_Variables; cd $TEST_dir

	if [[ ! -e ${subrun}.seqminus.epan.nii ]]; then

		cd $ORIG_subj

		Zslice_func

		echo; echo =========== $subrun ==============; echo

		to3d \
			-epan \
			-prefix ${subrun}.seqminus.epan.nii \
			-2swap \
			-text_outliers \
			-save_outliers ${subrun}.seqminus.outliers.txt \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			-time:tz ${nfs} ${nas} ${tr} \
			seqminus ${run}.*

		Outcount_func seqminus.epan

		cp ${subrun}.seqminus.epan.nii ${TEST_dir}

	fi 2>&1 | tee -a ${TEST_dir}/log.${subrun}.seqminus.epan.txt
}




function Test_tstat ()
{
	Study_Variables; cd ${TEST_dir}/Tshift

	for pipe in offsets1 offsets2 seqminus; do
		if [[ ! -e ${subrun}.${pipe}.tstat.nii ]]; then
	
			echo; echo =========== $subrun ==============; echo 
	
			3dtstat \
				-sum \
				-mean \
				-median \
				-prefix ${subrun}.${pipe}.tstat.nii \
				${subrun}.${pipe}.tshift.nii

			3dToutcount \
				${subrun}.${pipe}.tstat.nii'[0]' \
				> ${subrun}.${pipe}.tstat.outs0.txt
				
			3dToutcount \
				${subrun}.${pipe}.tstat.nii'[1]' \
				> ${subrun}.${pipe}.tstat.outs1.txt
				
			3dToutcount \
				${subrun}.${pipe}.tstat.nii'[2]' \
				> ${subrun}.${pipe}.tstat.outs2.txt
			
			1dplot \
				-jpeg ${subrun}.${pipe}.tstat.outs0 \
				${subrun}.${pipe}.tstat.outs0.txt

			1dplot \
				-jpeg ${subrun}.${pipe}.tstat.outs1 \
				${subrun}.${pipe}.tstat.outs1.txt

			1dplot \
				-jpeg ${subrun}.${pipe}.tstat.outs2 \
				${subrun}.${pipe}.tstat.outs2.txt

		fi 2>&1 | tee -a ${TEST_dir}/log.${subrun}.${pipe}.tstat.txt

	done
}




function Reconstruct_Noffsets ()
{
	Study_Variables; cd $TEST_dir

		cd $ORIG_subj

		Zslice_func

		echo; echo =========== $subrun ==============; echo

		to3d \
			-epan \
			-prefix ${subrun}.NOoffsets.epan \
			-session $TEST_dir \
			-2swap \
			-text_outliers \
			-save_outliers ${subrun}.offsets2.outliers.txt \
			-xFOV ${halffov}R-L \
			-yFOV ${halffov}A-P \
			-zSLAB ${z}${z1}-${z}${z2} \
			-time:tz ${nfs} ${nas} ${tr} \
			${run}.*

#		Outcount_func offsets2.epan

		cp ${subrun}.NOoffsets.epan+orig ${TEST_dir}
}



function Preproc_tcat ()
{
	Study_Variables; cd $TEST_dir
	Truncate

	if [[ ! -e ${subrun}.tcat+orig.HEAD ]]; then

		echo; echo =========== $subrun ==============; echo 

		3dTcat \
			-verb \
			-prefix ${subrun}.tcat.nii \
			${subrun}.epan.nii'['${trunc}'..$]'

		echo "slices truncated = ${trunc}" > ${subrun}.log.txt
		echo "remaining slices = ${rfs}" >> ${subrun}.log.txt

		Outcount_Plot tcat

	fi
}


function Preproc_despike ()
{
	Study_Variables; cd $TEST_dir

	if [[ ! -e ${subrun}.despike.nii ]]; then

		echo; echo =========== $subrun ==============; echo

		3dDespike \
			-prefix ${subrun}.despike.nii \
			-ssave ${subrun}.spikes.nii \
			${subrun}.tcat.nii

		Outcount_Plot despike

	fi
}


function Test_tshift ()
{
	Study_Variables; cd ${TEST_dir}
	
	for pipe in offsets1 offsets2 seqminus; do
		if [[ -e ${subrun}.${pipe}.epan.nii ]]; then
	
			echo; echo =========== $subrun ==============; echo 

		3dTshift \
			-verbose \
			-tzero 0 \
			-rlt+ \
			-quintic \
			-prefix ${subrun}.${pipe}.tshift.nii \
			${subrun}.${pipe}.epan.nii

		3dToutcount \
			${subrun}.${pipe}.tshift.nii \
			> ${subrun}.${pipe}.tshift.outs.txt
		
		1dplot \
			-jpeg ${subrun}.${pipe}.tshift.outs \
			${subrun}.${pipe}.tshift.outs.txt


		fi
	done
}



function Preproc_volreg ()
{
	Study_Variables; cd $PREP_subj
	Base_Reg

	if [[ ! -e ${subrun}.volreg.nii ]]; then

		echo; echo =========== $subrun ==============; echo

		3dvolreg \
			-verbose \
			-verbose \
			-zpad 4 \
			-base ${subrun}.tshift.nii'['${base}']' \
			-1Dfile ${subrun}.dfile.1D \
			-prefix ${subrun}.volreg.nii \
			-cubic ${subrun}.tshift.nii

		echo "base volume = ${base}" >> ${subrun}.log.txt


		1dplot \
			-jpeg ${subrun}.volreg \
			-volreg \
			-xlabel TIME \
			${subrun}.dfile.1D

		Outcount_Plot volreg

		cp ${subrun}.dfile.1D ${GLM_subj}
		mv ${subrun}.volreg.jpg $ETC_prep
		mv ${subrun}.dfile.1D $ETC_prep

	fi 2>&1 | tee -a $PREP_subj/log.volreg.txt
}



