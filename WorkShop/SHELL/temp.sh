3dcalc -a leftBA13_sphere10+tlrc -b S20_voice_fvfw_norm_irf+tlrc -expr '(a*b)' \
	-prefix S20_v_fvfw_lBA45

3dmerge -dxyz=1 -1clust 1 -1123 -1thresh 2.262 -prefix mean_memboth_fa_T_out \
	mean_memboth_fa+tlrc'[1]'

3dclust -1Dformat -1noneg -1thresh 2.650 1 1321 FA_GAM2+tlrc > fa_g2.1D

whereami -coord_file fa_g2.1D'[1,2,3]' -tab -atlas TT_Daemon less > fa_g2_coord.txt

####################################################################################################foreach gam (1 2 3 4 5 6 7)
	foreach vari (FvM FvN MvF MvN NvF NvM)
		foreach mask (AI CAU CER CIN IFG IFG2 IFG3 MFG MFG2 MTG SFG SMG SOG STG THA)

		set results_dir = $images_home/Contrasts/$vari/roi
		# --------------------------------------------------
		# script setup
		3dcalc -a Masks/${mask}+tlrc -b Contrasts/$vari/contr_GAM${gam}_${vari}_0.05+tlrc \
			-expr '(a*b)' -prefix $results_dir/${mask}/${mask}_GAM${gam}_${vari}+tlrc
		# --------------------------------------------------
		# script setup
		3dclust 1 10 $results_dir/${mask}/${mask}_GAM${gam}_${vari}+tlrc'[0]' \
			> $results_dir/${mask}/${mask}_GAM${gam}_${vari}.txt
		# --------------------------------------------------
		# script setup
		whereami -tab -atlas TT_Daemon -coord_file \
			$results_dir/${mask}/${mask}_GAM${gam}_${vari}.txt'[13,14,15]' \
			> $results_dir/${mask}/${mask}_GAM${gam}_whereami_${vari}.txt
		# --------------------------------------------------
		end
	end
end
####################################################################################################

3dclust -1noneg -dxyz=1 -1thresh 2.160 1 1640 0.05/mean_GAM${value}_ff-mf-nf_0.05+tlrc \
	> 0.05/Cluster_GAM${value}_ff-mf-nf_0.05.txt 

whereami -tab -atlas TT_Daemon -coord_file 0.05/Cluster_GAM${value}_ff-mf-nf_0.05.txt'[1,2,3]' \
	> 0.05/WhereIam_GAM${value}_ff-mf-nf_cMASS_0.05.txt 


3dclust -1noneg -dxyz=1 -1thresh 2.282 1 1709 0.04/mean_GAM${value}_ff-mf-nf_0.04+tlrc \
	> 0.04/Cluster_GAM${value}_ff-mf-nf_0.04.txt 


whereami -tab -atlas TT_Daemon -coord_file 0.04/Cluster_GAM${value}_ff-mf-nf_0.04.txt'[1,2,3]' \
	> 0.04/WhereIam_GAM${value}_ff-mf-nf_cMASS_0.04.txt 

####################################################################################################

set t = $1 #task
set s = $2 #seed
set x = $3 #x
set y = $4 #y
set z = $5 #z
set H = /Volumes/Data/MRI-AttnMem/Anova #Home
set R = $H/Contrasts #Results
set C = ${t}_GAM${g}_${m}_${x}_${y}_${z} #Coordinates
set A = $H/Anova_GAM${g}_results #Anova

foreach v (FvM FvN FvMN MvF MvN  MvFN NvF NvM NvFM) #variation

	echo ""
	echo "This is the $0 script!" 
	echo "$H"
	echo "$R"
	echo "${t}_${g}_${m}_${x}_${y}_${z}_${v}"
	echo "${C}_${v}.txt"
	echo "temp1_${C}.txt"
	echo "cat ${C}_FvM.txt ${C}_FvN.txt ${C}_MvF.txt ${C}_MvN.txt ${C}_NvF.txt ${C}_NvM.txt \
			> temp1_${C}.txt"
	# --------------------------------------------------
	# script setup
	3dmaskdump -noijk -dbox ${x} ${y} ${z} ${R}/contr_GAM${g}_${v}_0.05+tlrc > \
		$R/roi/temp_${C}_${v}.txt
	# 3dmaskdump -noijk -dbox ${x} ${y} ${z} ${R}/base_GAM${g}_${v}_0.05+tlrc > \
	#	$R/roi/1.base_${C}_${v}.txt
	# 3dmaskdump -noijk -dbox ${x} ${y} ${z} ${R}/base2_GAM${g}_${v}_0.05+tlrc > \
	#	$R/roi/1.base2_${C}_${v}.txt
end
# --------------------------------------------------
# script setup
cd ${R}/roi
# --------------------------------------------------
# script setup
cat temp_${C}_FvM.txt temp_${C}_FvN.txt temp_${C}_FvMN.txt temp_${C}_MvF.txt temp_${C}_MvN.txt \
	temp_${C}_MvFN.txt temp_${C}_NvF.txt temp_${C}_NvM.txt temp_${C}_NvFM.txt > compile_${C}.txt
#cat 1.base2_${C}_FvM.txt 1.base2_${C}_FvN.txt 1.base2_${C}_FvMN.txt 1.base2_${C}_MvF.txt \
#	1.base2_${C}_MvN.txt 1.base2_${C}_MvFN.txt 1.base2_${C}_NvF.txt 1.base2_${C}_NvM.txt \
#	1.base2_${C}_NvFM.txt > 2.base_compile_${C}.txt
#cat 1.base2_${C}_FvM.txt 1.base2_${C}_FvN.txt 1.base2_${C}_FvMN.txt 1.base2_${C}_MvF.txt \
#	1.base2_${C}_MvN.txt 1.base2_${C}_MvFN.txt 1.base2_${C}_NvF.txt 1.base2_${C}_NvM.txt \
#	1.base2_${C}_NvFM.txt > 2.base2_compile_${C}.txt
# --------------------------------------------------
# script setup
awk '$1=$1' RS= compile_${C}.txt > trans_${C}.txt
awk -v OFS='\t' '$0=$0 {print "\t" $1,$2,$3,$4,$5,$6,$7,$8,$9}' trans_${C}.txt > ${C}.txt
cat ${C}.txt >> 1Contrasts.txt
# --------------------------------------------------
# script setup
#awk '$1=$1' RS= 2.base_compile_${C}.txt > 3.base_trans_${C}.txt
#awk -v OFS='\t' '$0=$0 {print "\t" $1,$2,$3,$4,$5,$6,$7,$8,$9}' 2.base_trans_${C}.txt > 4.base_${C}.txt
#cat 4.base_${C}.txt >> $R/base_Contrasts.txt
# --------------------------------------------------
# script setup
#awk '$1=$1' RS= 2.base2_compile_${C}.txt > 3.base2_trans_${C}.txt
#awk -v OFS='\t' '$0=$0 {print "\t" $1,$2,$3,$4,$5,$6,$7,$8,$9}' 2.base2_trans_${C}.txt > 4.base2_${C}.txt
#cat 4.base2_${C}.txt >> $R/base2_Contrasts.txt
# 
# 
# --------------------------------------------------
# script setup
#echo "rm temp*"
#rm temp*
# --------------------------------------------------
# script setup
#echo "mv Contrast_${C}.txt ../"
#mv awk_temp3_${C}.txt ../

./Contrastive FF 1 AI -31 -21 8
./Contrastive FF 2 AI -40 -13 -1
./Contrastive FF 3 AI -40 -16 -2
./Contrastive FF 4 AI -40 -19 -3
####################################################################################################

set images_home = /Volumes/Data/MRI-AttnMem/Anova
set C = $images_home/Compare

foreach g (1 2 3 4 5 6 7)
	foreach mask (AI CAU CER CIN IFG IFG2 IFG3 MFG MFG2 MTG SFG SMG SOG STG THA) 

		3dcalc -a nf/roi/${mask}_GAM${g}_nf+tlrc -b ff/roi/${mask}_GAM${g}_ff+tlrc -c \
			mf/roi/${mask}_GAM${g}_mf+tlrc -expr '(a-(b+c))' -prefix ${C}/${mask}_GAM${g}_NvFM+tlrc
		3dcalc -a ff/roi/${mask}_GAM${g}_ff+tlrc -b mf/roi/${mask}_GAM${g}_mf+tlrc -c \
			nf/roi/${mask}_GAM${g}_nf+tlrc -expr '(a-(b+c))' -prefix ${C}/${mask}_GAM${g}_FvMN+tlrc
	end
end
####################################################################################################

echo "./MeanMasking"
set images_home = /Volumes/Data/MRI-AttnMem/Anova
foreach task (ff mf nf)
	foreach gam (1 2 3 4 5 6 7)
		foreach mask (AI CAU CER CIN IFG IFG2 IFG3 MFG MFG2 MTG SFG SMG SOG STG THA) 
			set results_dir = $images_home/${task}/roi
			# --------------------------------------------------
			# Apply Mask to Data
			echo "masking ${mask}_GAM${gam}_${task}"
			3dcalc -a Masks/${mask}+tlrc -b ${task}/mean_GAM${gam}_${task}_0.05+tlrc \
				-expr '(a*b)' -prefix $results_dir/${mask}_GAM${gam}_${task}+tlrc
			# --------------------------------------------------
			# Clusterize data
			echo "Clusterize!"
			3dclust -1noneg 1 10 $results_dir/${mask}_GAM${gam}_${task}+tlrc'[0]' > \
				$results_dir/${mask}_GAM${gam}_${task}.txt

			echo "Print it"
			cat $results_dir/${mask}_GAM${gam}_${task}.txt | colrm 10 73 | sed '/^#/d' | tr -s \
				'[:space:]' | awk -v OFS='\t' '$1=$1' | head -2 > \
				$results_dir/${mask}_GAM${gam}_${task}.txt
				
			echo "where am i?"
			whereami -tab -atlas TT_Daemon -coord_file \
				$results_dir/${mask}_GAM${gam}_${task}.txt'[4,5,6]' | sed -n '/TT_Daemon/p' | \
				awk -v OFS='\t' '$1=$1 {print $2,$4,$5,$6}'| head -4 \
				> $results_dir/${mask}_GAM${gam}_${task}_whereami.txt
			# --------------------------------------------------
		end
	end
end
####################################################################################################

3dclust -1tindex 8 -1dindex 8 0 0 ${subj}_${type}_fvfw_lBA45+tlrc \
	> 01_BA45/${subj}_${type}_fvfw_lBA45.txt

####################################################################################################

3dcalc -a Masks/leftBA13_sphere10+tlrc -b Data/${subj}_${run}_fvfw_norm_irf+tlrc -expr '(a*b)' \
	-prefix DataSpheres/${subj}_${type}_fvfw_lBA13

####################################################################################################

# The purpose of this script is to threshold to a p = 0.05 at a corrected voxel 1640
echo "Follow this command line format: ./Threshold"
foreach g (1 2 3 4 5 6 7) #gam
	set H = /Volumes/Data/MRI-AttnMem/Anova #Home
	set C = $H/Contrasts #Contrasts
	set A = $H/Anova_GAM${g}_results #Anova
	# foreach mask (AI CAU CER CIN IFG IFG2 IFG3 MFG MFG2 MTG SFG SMG SOG STG THA)
	# --------------------------------------------------
	# Perform 3dmerge on mean conditions
	# echo "mean_GAM${g}_${t}_0.05"
	# 3dmerge -1noneg -dxyz=1 -1clust 1 -1640 -1thresh 2.160 -prefix ${t}/mean_GAM${g}_${t}_0.05 \
	#	$A/mean_GAM${g}_${t}+tlrc
	# --------------------------------------------------
	#Preform 3dmerge on base-line subtracted conditions
	#echo "base_${g}_${t}_0.05"
	#3dmerge -1noneg -dxyz=1 -1clust 1 -1640 -1thresh 2.160 -prefix ${t}/base_GAM${g}_${t}_0.05 \
	#	$A/base_GAM${g}_${t}+tlrc
# --------------------------------------------------
# Preform 3dmerge on contrast conditions
# echo "contr_GAM${g}_${v}_0.05+tlrc"
	foreach v (FvM FvN FvMN MvF MvN  MvFN NvF NvM NvFM) #variation
		3dmerge -dxyz=1 -1clust 1 -1640 -1thresh 2.160 -prefix ${C}/contr_GAM${g}_${v}_0.05+tlrc \
			$A/contr_GAM${g}_${v}+tlrc
# # --------------------------------------------------
#end
	end
end
####################################################################################################

3dClustSim -nxyz 161 191 151 -dxyz 1 1 1 -NN 1 -nodec -both -prefix CS.tap

// Ok set up an if statement that links cluster size to p-value i.e. if $clust = 1640; then; plvl=05; fi 
// 		3dclust -1noneg 1 $clust ${runmod}.mean.${cond1}+tlrc > ${runmod}.mean.${cond1}.${plvl}.txt 
// Also to further condense my code, Ill have to think about how to rename these variables....
// perhaps ${runmod}.mean.${cond1} could become ${runmean}.${cond1}
// ${runmean}.${cond1} & ${runmean}.${cond2}
// ${runbase}.${cond1} & ${runbase}.${cond2} 
// ${rundiff}.${cond1v2} & ${rundiff}.${cond2v1}
// ${runcontr}.${cond1v2} or ${runcontr}.${cond2v1}


3dclust -1noneg 1 ${clust} ${runmean}.${cond1}+tlrc > ${runmean}.${cond1}.${plvl}.txt 




