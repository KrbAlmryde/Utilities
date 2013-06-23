. $UTL/${1}_profile.sh
####################################################################################################
# 3dANOVA2 -type (k)=3  mixed efects model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor 1 - Familiarity Categories (fixed, alevels) = (1) old, (2) new, (3) null
# Factor 2 - Subjects (random, blevels) = (1) TS1, (2) TS2, (TS3), ...., (11) TS11
####################################################################################################
echo "Let the ANOVA begin!"
cd ${anat_dir}
####################################################################################################
if [ ! -e TP1_ANOVA_${brik}+tlrc.HEAD ]; then
	3dANOVA2 -type 3 -alevels 3 -blevels 10 \
		-dset 1 1 TS1_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 1 TS1_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 1 TS1_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 2 TS2_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 2 TS2_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 2 TS2_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 3 TS3_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 3 TS3_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 3 TS3_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 4 TS4_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 4 TS4_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 4 TS4_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 5 TS5_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 5 TS5_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 5 TS5_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 6 TS6_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 6 TS6_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 6 TS6_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 7 TS8_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 7 TS8_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 7 TS8_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 8 TS9_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 8 TS9_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 8 TS9_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 9 TS10_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 9 TS10_TP1_new_peak${brik}_irf+tlrc \
		-dset 3 9 TS10_TP1_null_peak${brik}_irf+tlrc \
		-dset 1 10 TS11_TP1_old_peak${brik}_irf+tlrc \
		-dset 2 10 TS11_TP1_new_peak${brik}_irf+tlrc \
		 -dset 3 10 TS11_TP1_null_peak${brik}_irf+tlrc \
		-fa Familiarity_fstat_${brik} \
		-amean 1 mean_old_${brik} \
		-amean 2 mean_new_${brik} \
		-amean 3 mean_null_${brik} \
		-adiff 1 2 diff_OvsNw_${brik} \
		-adiff 1 3 diff_OvsN_${brik} \
		-adiff 2 3 diff_NwvsN_${brik} \
		-acontr 1 -1 0 contr_OvNw_${brik} \
		-acontr 1 0 -1 contr_OvN_${brik} \
		-acontr 2 -1 -1 contr_OvNwN_${brik} \
		-acontr -1 1 0 contr_NwvO_${brik} \
		-acontr 0 1 -1 contr_NwvN_${brik} \
		-acontr -1 2 -1 contr_NwvON_${brik} \
		-acontr -1 0 1 contr_NvO_${brik} \
		-acontr 0 -1 1 contr_NvNw_${brik} \
		-acontr -1 -1 2 contr_NvONw_${brik} \
		-acontr 1 0 0 base_old_${brik} \
		-acontr 0 1 0 base_new_${brik} \
		-acontr 0 0 1 base_null_${brik} \
		-bucket TP1_ANOVA_${brik}
fi

cp ${runnm}_* ../Data
#rm ${runnm}.*
####################################################################################################
