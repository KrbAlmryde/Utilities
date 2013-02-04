. $UTL/${1}_profile.sh
####################################################################################################
# 3dANOVA2 -type (k)=3  mixed efects model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor 1 - Voice Context (fixed, alevels) = (1) male, (2) female, (3) null
# Factor 2 - Subjects (random, blevels) = (1) TS1, (2) TS2, (TS3), ...., (11) TS11
####################################################################################################
echo "Let the ANOVA begin!"
cd ${anat_dir}
####################################################################################################
if [ ! -e SP2_ANOVA_${brik}+tlrc.HEAD ]; then
	3dANOVA2 -type 3 -alevels 3 -blevels 10 \
		-dset 1 1 TS1_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 1 TS1_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 1 TS1_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 2 TS2_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 2 TS2_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 2 TS2_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 3 TS3_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 3 TS3_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 3 TS3_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 4 TS4_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 4 TS4_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 4 TS4_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 5 TS5_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 5 TS5_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 5 TS5_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 6 TS6_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 6 TS6_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 6 TS6_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 7 TS8_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 7 TS8_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 7 TS8_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 8 TS9_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 8 TS9_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 8 TS9_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 9 TS10_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 9 TS10_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 9 TS10_SP2_null_peak${brik}_irf+tlrc \
		-dset 1 10 TS11_SP2_male_peak${brik}_irf+tlrc \
		-dset 2 10 TS11_SP2_female_peak${brik}_irf+tlrc \
		-dset 3 10 TS11_SP2_null_peak${brik}_irf+tlrc \
		-fa Voice_fstat_${brik} \
		-amean 1 mean_male_${brik} \
		-amean 2 mean_female_${brik} \
		-amean 3 mean_null_${brik} \
		-adiff 1 2 diff_MvsF_${brik} \
		-adiff 1 3 diff_MvsN_${brik} \
		-adiff 2 3 diff_FvsN_${brik} \
		-acontr 1 -1 0 contr_MvF_${brik} \
		-acontr 1 0 -1 contr_MvN_${brik} \
		-acontr 2 -1 -1 contr_MvFN_${brik} \
		-acontr -1 1 0 contr_FvM_${brik} \
		-acontr 0 1 -1 contr_FvN_${brik} \
		-acontr -1 2 -1 contr_FvMN_${brik} \
		-acontr -1 0 1 contr_NvM_${brik} \
		-acontr 0 -1 1 contr_NvF_${brik} \
		-acontr -1 -1 2 contr_NvMF_${brik} \
		-acontr 1 0 0 base_male_${brik} \
		-acontr 0 1 0 base_female_${brik} \
		-acontr 0 0 1 base_null_${brik} \
		-bucket SP2_ANOVA_${brik}
fi

cp ${runnm}_* ../Data
#rm ${runnm}.*
####################################################################################################
