#!/bin/bash


for subj in TS001 TS002 TS003 TS004 TS008; do	
	for run in SP1 TP2; do

		source /usr/local/utilities/DRIVR/tap_profile
		Study_Variables
		Condition Basic
		x=1

		cd $TEST_dir


		if [[ ! -e ${subj}.spgr.cmass+orig.HEAD ]]; then
			echo; echo =========== $subj.spgr CMASS ==============; echo
			align_epi_anat.py \
				-dset1to2 -cmass cmass \
				-dset1 ${subj}.spgr+orig \
				-dset2 ${subj}.fse+orig \
				-cost lpa -suffix .cmass

			3dSkullStrip \
				-input ${subj}.spgr.cmass+orig \
				-prefix ${subj}.spgr.standard
		fi

		if [[ ! -e ${subj}.spgr.standard+tlrc.HEAD ]]; then
			echo; echo =========== $subj.spgr TLRC ==============; echo
			@auto_tlrc \
				-no_ss -suffix NONE \
				-base TT_N27+tlrc \
				-input ${subj}.spgr.standard+orig

			3drefit -anat ${subj}.spgr.standard+tlrc
		fi


		if [[ ! -e ${subrun}.epan+orig.HEAD ]]; then

			if [[ ${z1} = S ]]; then
				z2=I
			elif [[ ${z1} = I ]]; then
				z2=S
			fi

			echo; echo =======================================
			echo =========== $subrun EPAN ==============; echo
			to3d \
				-epan \
				-prefix ${subrun}.epan \
				-session $TEST_dir \
				-2swap \
				-text_outliers \
				-save_outliers ${subrun}.offsets2.outliers.txt \
				-xFOV ${halffov}R-L \
				-yFOV ${halffov}A-P \
				-zSLAB ${z}${z1}-${z}${z2} \
				-time:tz ${nfs} ${nas} ${tr} \
				@${TEST_dir}/offsets2.1D ${ORIG_subj}/${run}.*
		fi


		if [[ ! -e ${subrun}.tcat+orig.HEAD ]]; then
			echo; echo =========== $subrun TCAT ==============; echo 
			3dTcat \
				-verb \
				-prefix ${subrun}.tcat+orig \
				${subrun}.epan+orig'[4..$]'

				3dToutcount \
					${subrun}.tcat+orig \
					> ${subrun}.tcat.outs.txt

				1dplot \
					-jpeg ${subrun}.tcat.outs \
					${subrun}.tcat.outs.txt
		fi


		if [[ ! -e ${subrun}.despike+orig.HEAD ]]; then

			echo; echo =========== $subrun DESPIKE ==============; echo

			3dDespike \
				-prefix ${subrun}.despike \
				-ssave ${subrun}.spikes \
				${subrun}.tcat+orig


			3dToutcount \
				${subrun}.despike+orig \
				> ${subrun}.despike.outs.txt

			1dplot \
				-jpeg ${subrun}.despike.outs \
				${subrun}.despike.outs.txt

		fi

		if [[ ! -e ${subrun}.tshift+orig.HEAD ]]; then

			echo; echo =========== $subrun TSHIFT ==============; echo
			3dTshift \
				-verbose \
				-tzero 0 \
				-rlt+ \
				-quintic \
				-prefix ${subrun}.tshift \
				${subrun}.despike+orig

			3dToutcount \
				${subrun}.tshift+orig \
				> ${subrun}.tshift.outs.txt

			1dplot \
				-jpeg ${subrun}.tshift.outs \
				${subrun}.tshift.outs.txt
		fi 



		if [[ ! -e ${subrun}.vr.reg+tlrc.HEAD ]]; then

			base=`cat -n ${subrun}.tshift.outs.txt | sort -k2,2n | head -1 | awk '{print $1-1}'`

			echo; echo =========== ${subrun} E2A ==============; echo
			align_epi_anat.py \
				-anat ${subj}.spgr.standard+orig \
				-anat_has_skull no \
				-epi ${subrun}.tshift+orig \
				-big_move \
				-epi_strip 3dAutomask \
				-epi_base ${base} \
				-epi2anat -suffix .reg  \
				 -volreg on -volreg_opts  \
						-verbose -verbose -zpad 4 \
						-1Dfile ${subrun}.dfile.1D \
				-tlrc_apar ${subj}.spgr.standard+tlrc

			3dcopy ${subrun}.tshift.reg+orig ${subrun}.vr.reg+orig
			3dcopy ${subrun}.tshift_tlrc.reg+tlrc ${subrun}.vr.reg+tlrc

			1dplot \
				-jpeg ${subrun}.vr.reg \
				-volreg \
				-xlabel TIME \
				${subrun}.dfile.1D
		fi

		if [[ ! -e ${subrun}.blur+tlrc.HEAD ]]; then
			echo; echo =========== $subrun BLUR==============; echo
			3dBlurInMask \
				-preserve \
				-FWHM 6.0 \
				-automask \
				-prefix ${subrun}.blur \
				${subrun}.vr.reg+tlrc
		fi

		if [[ ! -e ${subrun}.fullmask+tlrc.HEAD ]]; then
			echo; echo =========== $subrun MASKING ==============; echo
			3dAutomask \
				-prefix ${subrun}.fullmask \
				${subrun}.blur+tlrc

			3dresample \
				-master ${subrun}.fullmask+tlrc \
				-prefix ${subrun}.spgr.resam \
				-input ${subj}.spgr.standard+tlrc

			3dcalc \
				-a ${subrun}.spgr.resam+tlrc \
				-expr 'ispositive(a)' \
				-prefix ${subrun}.spgr.mask

			3dABoverlap \
				-no_automask ${subrun}.fullmask+tlrc \
				${subrun}.spgr.mask+tlrc \
				2>&1 | tee -a ${subrun}.mask.overlap.txt

			3dABoverlap \
				-no_automask \
				N27.mask+tlrc \
				${subrun}.spgr.mask+tlrc \
				2>&1 | tee -a ${subrun}.spgr.mask.overlap.txt

			echo "( ${subrun} / N27 ) = `cat ${subrun}.spgr.mask.overlap.txt | tail -1 | awk '{print $8}'`" >> N27.mask.overlap.txt
		fi

		if [[ ! -f ${subrun}.scale+tlrc.HEAD ]]; then 

			echo; echo =========== $subrun SCALE ==============; echo

			3dTstat \
				-prefix rm.${subrun}.mean ${subrun}.blur+tlrc

			3dcalc \
				-verbose \
				-a ${subrun}.blur+tlrc \
				-b rm.${subrun}.mean+tlrc \
				-c ${subrun}.fullmask+tlrc \
				-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
				-prefix ${subrun}.scale
		fi

		if [[ ! -f motion.${subrun}_censor.1D ]]; then

			echo; echo =========== $subrun ==============; echo

			1d_tool.py \
				-verb 2 \
				-infile ${subrun}.dfile.1D \
				-set_nruns 1 \
				-set_tr 3.5 \
				-show_censor_count \
				-censor_prev_TR \
				-censor_motion .1 \
				motion.${subrun}
		fi

		if [[ ! -e ${submod}.${Type}.stats+tlrc.HEAD ]]; then

			echo; echo =========== $subrun ${Type} REGRESS ==============; echo

			3dDeconvolve \
				-input ${subrun}.scale+tlrc \
				-polort A \
				-censor motion.${subrun}_censor.1D \
				-GOFORIT \
				-mask ${subrun}.fullmask+tlrc \
				-num_stimts 8 -local_times \
				-stim_times 1 \
							stim.${run}.${cond1}.1D "${model}" \
							-stim_label 1 ${submod}.${cond1}.${Type} \
				-stim_times 2 \
							stim.${run}.${cond2}.1D "${model}" \
							-stim_label 2 ${submod}.${cond2}.${Type} \
				-stim_file 3 \
							${subrun}.dfile.1D'[0]' \
							-stim_base 3 \
							-stim_label 3 roll \
				-stim_file 4 \
							${subrun}.dfile.1D'[1]' \
							-stim_base 4 \
							-stim_label 4 pitch \
				-stim_file 5 \
							${subrun}.dfile.1D'[2]' \
							-stim_base 5 \
							-stim_label 5 yaw \
				-stim_file 6 \
							${subrun}.dfile.1D'[3]' \
							-stim_base 6 \
							-stim_label 6 dS \
				-stim_file 7 \
							${subrun}.dfile.1D'[4]' \
							-stim_base 7 \
							-stim_label 7 dL \
				-stim_file 8 \
							${subrun}.dfile.1D'[5]' \
							-stim_base 8 \
							-stim_label 8 dP \
				-xout -x1D \
							${submod}.${Type}.xmat.1D \
							-xjpeg ${submod}.${Type}.xmat.jpg \
				-fout -tout \
				-errts ${submod}.${Type}.errts \
				-fitts ${submod}.${Type}.fitts \
				-bucket ${submod}.${Type}.stats
		fi

	done
done


<<-'TOKEN'

for sub1 in TS001 TS002 TS003 TS004 TS008; do
	for sub2 in TS002 TS003 TS004 TS008 TS001; do

		if [[ $sub1 != $sub2 ]]; then
			3dABoverlap \
				-no_automask ${sub1}.SP1.fullmask+tlrc \
				${sub2}.SP1.fullmask+tlrc \
				2>&1 | tee -a ${sub1}.${sub2}.SP1.mask.overlap.txt

			3dABoverlap \
				-no_automask ${sub1}.TP2.fullmask+tlrc \
				${sub2}.TP2.fullmask+tlrc \
				2>&1 | tee -a ${sub1}.${sub2}.TP2.mask.overlap.txt

			echo "SP1 ( ${sub2} / ${sub1} ) = `cat ${sub1}.${sub2}.SP1.mask.overlap.txt | tail -1 | awk '{print $8}'`" >> SP1.mask.overlap.txt
			echo "TP2 ( ${sub2} / ${sub1} ) = `cat ${sub1}.${sub2}.TP2.mask.overlap.txt | tail -1 | awk '{print $8}'`" >> TP2.mask.overlap.txt

		else
			echo "SKIP!"
		fi

	done
done




		if [[ ! -e ${subrun}.mask.extents+tlrc.HEAD ]]; then
			3dcalc \
				-a ${subrun}.blur+tlrc \
				-expr '1*a' \
				-prefix rm.${subrun}.all1

			3dTstat \
				-min \
				-prefix ${subrun}.mask.extents \
				rm.${subrun}.all1+tlrc
		fi






# create an all-1 dataset to mask the extents of the warp



${subrun}.vr.reg+tlrc


			# ================================= scale ==================================
			# scale each voxel time series to have a mean of 100
			# (be sure no negatives creep in)
			# (subject to a range of [0,200])

			3dTstat -prefix rm.${subrun}.mean+tlr ${subrun}.blur+tlrc

			3dcalc \
				-a ${subrun}.blur+tlrc \
				-b rm.${subrun}.mean+tlr \
				-c mask_epi_extents+tlrc \
				-expr 'c * min(200, a/b*100)*step(a)*step(b)' \
				-prefix ${subrun}.scale












			echo; echo =========== $subrun MASK==============; echo
			3dAutomask \
				-dilate 1 \
				-prefix ${subrun}.automask.nii \
				${subrun}.BaseVolReg.${base}.nii

			3dMean \
				-datum short \
				-prefix rm.mean.$subrun \
				${subrun}.automask

			3dcalc \
				-a rm.mean.$run.nii \
				-expr 'ispositive(a-0)' \
				-prefix ${subrun}.fullmask





	3dBlurInMask -preserve -FWHM 4.0 -automask \
					 -prefix pb03.$subj.r$run.blur \
					 pb02.$subj.r$run.volreg+tlrc
	end

	# ================================== mask ==================================
	# create 'full_mask' dataset (union mask)

		3dAutomask -dilate 1 -prefix rm.mask_r$run pb03.$subj.r$run.blur+tlrc


		3dresample \
			-master full_mask.$subj+tlrc \
			-prefix rm.resam.anat      \
			-input TS004.spgr_strip+tlrc

	# convert resampled anat brain to binary mask
		3dcalc \
			-a rm.resam.anat+tlrc -expr 'ispositive(a)' -prefix mask_anat.$subj

	# compute overlaps between anat and EPI masks
	3dABoverlap -no_automask full_mask.$subj+tlrc mask_anat.$subj+tlrc \
				|& tee out.mask_overlap.txt

	# ---- create group anatomy mask, mask_group+tlrc ----
	#      (resampled from tlrc base anat, TT_N27+tlrc)
	3dresample -master full_mask.$subj+tlrc -prefix ./rm.resam.group   \
			   -input /Volumes/Data/ETC/TT_N27+tlrc

	# convert resampled group brain to binary mask
	3dcalc -a rm.resam.group+tlrc -expr 'ispositive(a)' -prefix mask_group

	# ================================= scale ==================================
	# scale each voxel time series to have a mean of 100
	# (be sure no negatives creep in)
	# (subject to a range of [0,200])
	foreach run ( $runs )
		3dTstat -prefix rm.mean_r$run pb03.$subj.r$run.blur+tlrc
		3dcalc -a pb03.$subj.r$run.blur+tlrc -b rm.mean_r$run+tlrc \
			   -c mask_epi_extents+tlrc                            \
			   -expr 'c * min(200, a/b*100)*step(a)*step(b)'       \
			   -prefix pb04.$subj.r$run.scale
	end









		align_epi_anat.py -anat ${subj}.spgr.cmass+orig \
		-epi ${subrun}.tcat+orig \
		-epi_base ${base} \
		-child_epi ${subj}.SP2.XXX+orig.HEAD    \
		${subj}.TP1.XXX+orig.HEAD    \
		${subj}.TP2.XXX+orig.HEAD    \
		-epi2anat -suffix _altest  \
		-tshift on -tshift_opts \
				-verbose -tzero 0 \
				-rlt+ -quintic \
				@${TEST_dir}/offsets2.1D \
		 -volreg on -volreg_opts  \
				-verbose -verbose -zpad 4 \
				-base ${subrun}.tshift.nii'['${base}']' \
				-1Dfile ${subrun}.dfile.1D \
				-prefix ${subrun}.volreg.nii \
		-tlrc_apar ${subj}.spgr.cmass+tlrc
TOKEN
