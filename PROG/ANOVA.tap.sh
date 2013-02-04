. $PROFILE/${1}_profile.sh
####################################################################################################
# 3dANOVA2 -type (k)=3  mixed efects model  (A fixed, B random)
# This is an ANOVA of a 3x11 mixed factorial design study
# Factor A - Semantic/Voice/Familiarity/Recollection
# 		(fixed, alevels) = (1) animal/male/old, (2) food/female/new, (3) null
# Factor B - Subjects (random, blevels) = (1) TS1, (2) TS2, (TS3), ...., (14) TS14
####################################################################################################
# Notes: TS7 has been removed from the analysis due to a problem with run 3 (TP1)
####################################################################################################
cd ${anova_dir}
####################################################################################################
if [ ! -e ${subcond1}.peak+tlrc.HEAD -a ! -e ${subcond2}.peak+tlrc.HEAD ]; then
	echo "ANOVA has already been performed!"
	echo ""
else
####################################################################################################
echo "--------------------------------- ANOVA_tap.sh ---------------------------------"
echo "------------------------- ${run}: ${alevel1} ${alevel2} ------------------------"
echo ""
####################################################################################################
	3dANOVA2 -type 3 -alevels 2 -blevels 14 \
	-dset 1 1 TS001.${runcond1}.peak+tlrc \
	-dset 2 1 TS001.${runcond2}.peak+tlrc \
	-dset 1 2 TS002.${runcond1}.peak+tlrc \
	-dset 2 2 TS002.${runcond2}.peak+tlrc \
	-dset 1 3 TS003.${runcond1}.peak+tlrc \
	-dset 2 3 TS003.${runcond2}.peak+tlrc \
	-dset 1 4 TS004.${runcond1}.peak+tlrc \
	-dset 2 4 TS004.${runcond2}.peak+tlrc \
	-dset 1 5 TS005.${runcond1}.peak+tlrc \
	-dset 2 5 TS005.${runcond2}.peak+tlrc \
	-dset 1 6 TS006.${runcond1}.peak+tlrc \
	-dset 2 6 TS006.${runcond2}.peak+tlrc \
	-dset 1 7 TS007.${runcond1}.peak+tlrc \
	-dset 2 7 TS007.${runcond2}.peak+tlrc \
	-dset 1 8 TS008.${runcond1}.peak+tlrc \
	-dset 2 8 TS008.${runcond2}.peak+tlrc \
	-dset 1 9 TS009.${runcond1}.peak+tlrc \
	-dset 2 9 TS009.${runcond2}.peak+tlrc \
	-dset 1 10 TS010.${runcond1}.peak+tlrc \
	-dset 2 10 TS010.${runcond2}.peak+tlrc \
	-dset 1 11 TS011.${runcond1}.peak+tlrc \
	-dset 2 11 TS011.${runcond2}.peak+tlrc \
	-dset 1 12 TS012.${runcond1}.peak+tlrc \
	-dset 2 12 TS012.${runcond2}.peak+tlrc \
	-dset 1 13 TS013.${runcond1}.peak+tlrc \
	-dset 2 13 TS013.${runcond2}.peak+tlrc \
	-dset 1 14 TS014.${runcond1}.peak+tlrc \
	-dset 2 14 TS014.${runcond2}.peak+tlrc \
	-amean 1 ${runmod}.mean.${alevel1} \
	-amean 2 ${runmod}.mean.${alevel2} \
	-acontr 1 -1 ${runmod}.contr.${alevel1}.vs.${alevel2} \
	-acontr -1 1 ${runmod}.contr.${alevel2}.vs.${alevel1}
####################################################################################################
	mv TS0*.${runcond1}.peak+tlrc.* ${anova_dir}/etc/
	mv TS0*.${runcond2}.peak+tlrc.* ${anova_dir}/etc/
####################################################################################################
fi
