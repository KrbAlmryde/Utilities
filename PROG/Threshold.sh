. $PROFILE/${1}_profile.sh
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
cd ${ANOVA_dir}
####################################################################################################
if [ -e  ${runmean}.${cond1}+tlrc.HEAD -a -e ${runcontr}.${cond1v2}+tlrc.HEAD ]; then
####################################################################################################
	echo "-------------------------------- Whole Brain Masking ----------------------------------"
	echo "------------------------------------- 3dcalc ----------------------------------------"
	echo "--------------------------- ${runmean} * Brain.Mask.nii ---------------------------"
	echo "------------------------ ${runmean}.${cond1}.$brik.nii --------------------------- "
	echo ""
####################################################################################################
# First we need to mask each ANOVA statistic (mean, base, contrasts) to make sure we only have
# activation INSIDE the brain, in this case, our standard TT_N27. We will do that using the
# 3dCalc command. In addition, we need to make sure that we do both the %change and Tstat, subbricks
# [0,1] respectively. We will call these files ${runmean}.${cond1}.$brik.nii. Then we want to move
# the orginal files to the "etc" the directory to clear things up a bit
####################################################################################################

	for brik in 0 1; do	 # This will iterate over the two briks so I dont have to double up the code

		3dcalc -prefix ${runmean}.${cond1}.$brik.nii -a ${runmean}.${cond1}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

		3dcalc -prefix ${runmean}.${cond2}.$brik.nii -a ${runmean}.${cond2}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

		3dcalc -prefix ${runmean}.${cond3}.$brik.nii -a ${runmean}.${cond3}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'
		
		3dcalc -prefix ${runmean}.${cond4}.$brik.nii -a ${runmean}.${cond4}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

		3dcalc -prefix ${runcontr}.${cond1v2}.$brik.nii -a ${runcontr}.${cond1v2}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

		3dcalc -prefix ${runcontr}.${cond2v1}.$brik.nii -a ${runcontr}.${cond2v1}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

		3dcalc -prefix ${runcontr}.${cond3v4}.$brik.nii -a ${runcontr}.${cond3v4}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'
		
		3dcalc -prefix ${runcontr}.${cond4v3}.$brik.nii -a ${runcontr}.${cond4v3}+tlrc[$brik] \
			-b ${mask_dir}/Brain.Mask.nii -expr 'a*b'

	done

#Then we want to move the orginal files to the "Orig" directory to clear things up a bit
	mv ${runmean}.${cond1}+tlrc* ${runmean}.${cond2}+tlrc* etc/Orig
	mv ${runcontr}.${cond1v2}+tlrc* ${runcontr}.${cond2v1}+tlrc* etc/Orig
	mv ${runmean}.${cond3}+tlrc* ${runmean}.${cond4}+tlrc* etc/Orig
	mv ${runcontr}.${cond3v4}+tlrc* ${runcontr}.${cond4v3}+tlrc* etc/Orig

####################################################################################################
	echo "------------------------------------- 3dbucket ----------------------------------------"
	echo "--------------- ${runmean}.${cond1}.0.nii + ${runmean}.${cond1}.1.nii ------------------"
	echo "------------------------- ${runmean}.${cond1}.clean.nii --------------------------- "
	echo ""
####################################################################################################
# The next step is to "Bucket" the newly masked files so that we can actually perform valid
# statistics on them.
####################################################################################################

	3dbucket -prefix ${runmean}.${cond1}.clean.nii -fbuc ${runmean}.${cond1}.0.nii \
		${runmean}.${cond1}.1.nii

	3dbucket -prefix ${runmean}.${cond2}.clean.nii -fbuc ${runmean}.${cond2}.0.nii \
		${runmean}.${cond2}.1.nii

	3dbucket -prefix ${runmean}.${cond3}.clean.nii -fbuc ${runmean}.${cond3}.0.nii \
		${runmean}.${cond3}.1.nii
	
	3dbucket -prefix ${runmean}.${cond4}.clean.nii -fbuc ${runmean}.${cond4}.0.nii \
		${runmean}.${cond4}.1.nii

	3dbucket -prefix ${runcontr}.${cond1v2}.clean.nii -fbuc ${runcontr}.${cond1v2}.0.nii \
		${runcontr}.${cond1v2}.1.nii

	3dbucket -prefix ${runcontr}.${cond2v1}.clean.nii -fbuc ${runcontr}.${cond2v1}.0.nii \
		${runcontr}.${cond2v1}.1.nii

	3dbucket -prefix ${runcontr}.${cond3v4}.clean.nii -fbuc ${runcontr}.${cond3v4}.0.nii \
		${runcontr}.${cond3v4}.1.nii
	
	3dbucket -prefix ${runcontr}.${cond4v3}.clean.nii -fbuc ${runcontr}.${cond4v3}.0.nii \
		${runcontr}.${cond4v3}.1.nii

	# Move the individual masked brik files to the "Clean" directory to clean things up a bit
	mv ${runmean}.${cond1}.?.nii ${runmean}.${cond2}.?.nii etc/Clean
	mv ${runcontr}.${cond1v2}.?.nii ${runcontr}.${cond2v1}.?.nii etc/Clean
	mv ${runmean}.${cond3}.?.nii ${runmean}.${cond4}.?.nii etc/Clean
	mv ${runcontr}.${cond3v4}.?.nii ${runcontr}.${cond4v3}.?.nii etc/Clean

####################################################################################################
	echo "------------------------------------- 3dmerge ----------------------------------------"
	echo "--------------- ${runmean}.${cond1}.clean.nii @ ${clust} ${plvl} ------------------"
	echo "------------------------- ${plvl}.${runmean} --------------------------- "
	echo ""
####################################################################################################
# The next step is to threshold the "clean" stats files so that we perform the 3dExtrema program
# On statistically significant data without having to worry about whether or not the clusters are
# significant or not. It will also make it easier to sort through all the data.
# NOTE: -1dindex j  = Uses sub-brick #j as the data source , and -1tindex k uses sub-brick #k as
# the threshold source.
####################################################################################################

	for brik in 0 1; do	 # This will iterate over the two briks so I dont have to double up the code

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runmean}.${cond1}.$brik.nii ${runmean}.${cond1}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runmean}.${cond2}.$brik.nii ${runmean}.${cond2}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runmean}.${cond3}.$brik.nii ${runmean}.${cond3}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runmean}.${cond4}.$brik.nii ${runmean}.${cond4}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runcontr}.${cond1v2}.$brik.nii ${runcontr}.${cond1v2}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runcontr}.${cond2v1}.$brik.nii ${runcontr}.${cond2v1}.clean.nii

		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runcontr}.${cond3v4}.$brik.nii ${runcontr}.${cond3v4}.clean.nii
		
		3dmerge -dxyz=1 -1clust 1 ${clust} -1thresh ${thr} -1dindex $brik -1tindex 1 \
			-prefix ${plvl}.${runcontr}.${cond4v3}.$brik.nii ${runcontr}.${cond4v3}.clean.nii

	done

# Move the individual masked brik files to the "etc" directory to clean things up a bit
	mv ${runmean}.*.clean.nii ${runcontr}.*.clean.nii etc/Clean
####################################################################################################
	echo "---------------------------------- 3dbucket ------------------------------------"
	echo "---- ${plvl}.${runmean}.${cond1}.0.nii + ${plvl}.${runmean}.${cond1}.1.nii -----"
	echo "---------------------- ${runmean}.${cond1}.${plvl}.nii -------------------------"
	echo ""
####################################################################################################
# Now we are going to bucket the newly thresholded files in order to maintain a clean directory
# and to maintain the statistics within the individual files
####################################################################################################

	3dbucket -prefix ${runmean}.${cond1}.${plvl}.nii -fbuc ${plvl}.${runmean}.${cond1}.0.nii \
		${plvl}.${runmean}.${cond1}.1.nii

	3dbucket -prefix ${runmean}.${cond2}.${plvl}.nii -fbuc ${plvl}.${runmean}.${cond2}.0.nii \
		${plvl}.${runmean}.${cond2}.1.nii

	3dbucket -prefix ${runmean}.${cond3}.${plvl}.nii -fbuc ${plvl}.${runmean}.${cond3}.0.nii \
		${plvl}.${runmean}.${cond3}.1.nii
	
	3dbucket -prefix ${runmean}.${cond4}.${plvl}.nii -fbuc ${plvl}.${runmean}.${cond4}.0.nii \
		${plvl}.${runmean}.${cond4}.1.nii

	3dbucket -prefix ${runcontr}.${cond1v2}.${plvl}.nii -fbuc ${plvl}.${runcontr}.${cond1v2}.0.nii \
		${plvl}.${runcontr}.${cond1v2}.1.nii

	3dbucket -prefix ${runcontr}.${cond2v1}.${plvl}.nii -fbuc ${plvl}.${runcontr}.${cond2v1}.0.nii \
		${plvl}.${runcontr}.${cond2v1}.1.nii

	3dbucket -prefix ${runcontr}.${cond3v4}.${plvl}.nii -fbuc ${plvl}.${runcontr}.${cond3v4}.0.nii \
		${plvl}.${runcontr}.${cond3v4}.1.nii
	
	3dbucket -prefix ${runcontr}.${cond4v3}.${plvl}.nii -fbuc ${plvl}.${runcontr}.${cond4v3}.0.nii \
		${plvl}.${runcontr}.${cond4v3}.1.nii


# Move the individual masked brik files to the "etc" directory to clean things up a bit
	mv ${plvl}.${runmean}.${cond1}.?.nii ${plvl}.${runmean}.${cond2}.?.nii etc/Threshold
	mv ${plvl}.${runcontr}.${cond1v2}.?.nii ${plvl}.${runcontr}.${cond2v1}.?.nii etc/Threshold
	mv ${plvl}.${runmean}.${cond3}.?.nii ${plvl}.${runmean}.${cond4}.?.nii etc/Threshold
	mv ${plvl}.${runcontr}.${cond3v4}.?.nii ${plvl}.${runcontr}.${cond4v3}.?.nii etc/Threshold
####################################################################################################
fi
