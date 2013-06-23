. $UTL/${1}_profile.sh
####################################################################################################
# 3dANOVA2 -type (k)=3  mixed efects model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor 1 - Semantic (fixed, alevels) = (1) animal, (2) food, (3) null
# Factor 2 - Subjects (random, blevels) = (1) TS1, (2) TS2, (TS3), ...., (11) TS11
####################################################################################################
echo "Let the ANOVA begin!"
cd ${anat_dir}
####################################################################################################
if [ ! -e ${run}_ANOVA_${brik}+tlrc.HEAD ]; then
####################################################################################################
	if [ "${run}" = "SP1" ]; then
		alevel1=animal
		alevel2=food
		alevel3=null
	elif [ "${run}" = "TP1" ]; then
		alevel1=old
		alevel2=new
		alevel3=null
	else
		alevel1=male
		alevel2=female
		alevel3=null
####################################################################################################
		3dANOVA2 -type 3 -alevels 3 -blevels 10 \
			-dset 1 1 TS1_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 1 TS1_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 1 TS1_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 2 TS2_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 2 TS2_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 2 TS2_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 3 TS3_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 3 TS3_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 3 TS3_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 4 TS4_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 4 TS4_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 4 TS4_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 5 TS5_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 5 TS5_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 5 TS5_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 6 TS6_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 6 TS6_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 6 TS6_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 7 TS8_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 7 TS8_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 7 TS8_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 8 TS9_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 8 TS9_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 8 TS9_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 9 TS10_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 9 TS10_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 9 TS10_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-dset 1 10 TS11_SP1_${alevel1}_peak${brik}_irf+tlrc \
			-dset 2 10 TS11_SP1_${alevel2}_peak${brik}_irf+tlrc \
			-dset 3 10 TS11_SP1_${alevel3}_peak${brik}_irf+tlrc \
			-fa Semantic_fstat_${brik} \
			-amean 1 mean_${alevel1}_${brik} \
			-amean 2 mean_${alevel2}_${brik} \
			-amean 3 mean_${alevel3}_${brik} \
			-adiff 1 2 diff_AvsF_${brik} \
			-adiff 1 3 diff_AvsN_${brik} \
			-adiff 2 3 diff_FvsN_${brik} \
			-acontr 1 -1 0 contr_AvF_${brik} \
			-acontr 1 0 -1 contr_AvN_${brik} \
			-acontr 2 -1 -1 contr_AvFN_${brik} \
			-acontr -1 1 0 contr_FvA_${brik} \
			-acontr 0 1 -1 contr_FvN_${brik} \
			-acontr -1 2 -1 contr_FvAN_${brik} \
			-acontr -1 0 1 contr_NvA_${brik} \
			-acontr 0 -1 1 contr_NvF_${brik} \
			-acontr -1 -1 2 contr_NvAF_${brik} \
			-acontr 1 0 0 base_${alevel1}_${brik} \
			-acontr 0 1 0 base_${alevel2}_${brik} \
			-acontr 0 0 1 base_${alevel3}_${brik} \
			-bucket ${run}_ANOVA_${brik}
	fi
fi
cp ${runnm}_* ../Data
#rm ${runnm}.*
####################################################################################################

