function Zslice_func ()
{
	if [[ ${z1} = S ]]; then
		z2=I
	elif [[ ${z1} = I ]]; then
		z2=S
	fi
}



function Outcount_func ()
{
	Study_Variables; cd $TEST_dir
	
	local proc=$1
	
	case $proc in
		offsets1.epan )
			tail=nii ;;
		offsets2.epan )
			tail=nii ;;
		seqminus.epan )
			tail=nii ;;
	esac

	local infile=$subrun.${proc}.${tail}

	3dToutcount \
		$infile \
		> $subrun.$proc.outs.txt

	1dplot \
		-jpeg $subrun.$proc.outs \
		$subrun.$proc.outs.txt
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




function Reconstruct_offsets1 ()
{
	Study_Variables; cd $TEST_dir

	for pipe in seqminus offsets1 offsets2; do
		if [[ ! -e ${subrun}.offsets1.epan.nii ]]; then
			echo; echo =========== $subrun ==============; echo
			
			3dtstat
			
			Outcount_func offsets1.epan
		fi 
	done 2>&1 | tee -a ${TEST_dir}/log.${subrun}.offsets1.epan.txt
}

