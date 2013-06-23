#!/usr/bin/env tcsh
echo "Attention and Memory 4: A New Hope"
echo "(version 1.0, February 2, 2011)"
echo "Command line conforms to following: ./NewHope s# anat Base#"
echo "./NewHope s1 spgr 46"
# execute via : tcsh -x S#-run-script |& tee output.S#-run-script
# --------------------------------------------------
# script setup  s5 s6 s7 s8 s9 s10 s11 s12 s13 s14 s15 s16 s17

set images_home = /Volumes/Data/AttnMem

echo "The Time has come the Walrus said"

set subj = $1

echo "Assigning Variables"

set anat = $2

#set anatomy file type = spgr OR fse_Auto

#set base = 42
set base = $3

echo "Setting Directory Paths"

# assign anchor directory name
set subj_dir = $images_home/${subj}

# assign output directory name
set results_dir = $subj_dir/${subj}_results

# assign group directory name
set group_dir = $images_home/Anova

# verify that the results directory does not yet exist
if ( -d $results_dir ) then 
    echo output dir "${subj}_results" already exists
   
   exit
 
  endif

echo "Enter ${subj} directory"
# change directories to subject directory
cd $subj_dir

echo "Making $results_dir directory"
# create results and group analysis directory
mkdir $results_dir

echo "Enter $results_dir directory"
#change directory to results
cd $results_dir

echo "Making Data directory"
#create data storage directory
mkdir $results_dir/00_Data

echo "Anatomical"
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/00_Data
echo "mem1 Epan"
cp $subj_dir/mem1/${subj}_mem1* $results_dir/00_Data
echo "mem2 Epan"
cp $subj_dir/mem2/${subj}_mem2* $results_dir/00_Data
echo "Stimulus onset time files"
cp $images_home/Utilities/*.txt $results_dir/00_Data
echo "Tr.1D"
cp $images_home/Utilities/*.1D $results_dir/00_Data



mkdir $results_dir/01_Tcat
echo "Down the Rabbit hole we go"

#-------------------------------------------------------
echo "align each dset to the base volume"

3dTcat -prefix 01_Tcat/${subj}_mem1_tcat 00_Data/${subj}_mem1_epan+orig'[2..234]'
3dTcat -prefix 01_Tcat/${subj}_mem2_tcat 00_Data/${subj}_mem2_epan+orig'[3..221]'

mkdir $results_dir/02_OutCount
#-------------------------------------------------------
echo "run 3dToutcount and 3dTshift for the BRIK and HEAD Files of Run1 and Run2"

3dToutcount -automask 01_Tcat/${subj}_mem1_tcat+orig > 02_OutCount/precount_${subj}_mem1.1D
3dToutcount -automask 01_Tcat/${subj}_mem2_tcat+orig > 02_OutCount/precount_${subj}_mem2.1D

1dplot -one -jpeg mem1_precount 02_OutCount/precount_${subj}_mem1.1D
1dplot -one -jpeg mem2_precount 02_OutCount/precount_${subj}_mem2.1D

3dTshift -tzero 0 -rlt+ -quintic -prefix 02_OutCount/${subj}_mem1_tshift 01_Tcat/${subj}_mem1_tcat+orig
3dTshift -tzero 0 -rlt+ -quintic -prefix 02_OutCount/${subj}_mem2_tshift 01_Tcat/${subj}_mem2_tcat+orig
 
3dToutcount -automask 02_OutCount/${subj}_mem1_tshift+orig > 02_OutCount/postcount_${subj}_mem1.1D
3dToutcount -automask 02_OutCount/${subj}_mem2_tshift+orig > 02_OutCount/postcount_${subj}_mem2.1D
 
1dplot -one -jpeg mem1_postcount 02_OutCount/postcount_${subj}_mem1.1D
1dplot -one -jpeg mem2_postcount 02_OutCount/postcount_${subj}_mem2.1D

mkdir $results_dir/03_VolReg
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/03_VolReg
#-------------------------------------------------------
echo "align each dset to the base volume"

    3dvolreg -verbose -zpad 1 -base 01_Tcat/${subj}_mem1_tcat+orig"[${base}]"  \
             -1Dfile 03_VolReg/dfile_${subj}_mem1.1D -prefix 03_VolReg/${subj}_mem1_volreg  \
             -cubic                                                  \
             01_Tcat/${subj}_mem1_tcat+orig

    3dvolreg -verbose -zpad 1 -base 01_Tcat/${subj}_mem2_tcat+orig"[${base}]"  \
             -1Dfile 03_VolReg/dfile_${subj}_mem2.1D -prefix 03_VolReg/${subj}_mem2_volreg  \
             -cubic                                                  \
             01_Tcat/${subj}_mem2_tcat+orig

echo "make a single file of registration params"

cat 03_VolReg/dfile_${subj}_mem2.1D 03_VolReg/dfile_${subj}_mem1.1D > 03_VolReg/${subj}.1D

mkdir $results_dir/04_Merge
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/04_Merge
#-------------------------------------------------------
echo "blur each volume"

    3dmerge -1blur_fwhm 8.0 -doall -prefix 04_Merge/${subj}_mem1_blur   \
            03_VolReg/${subj}_mem1_volreg+orig

    3dmerge -1blur_fwhm 8.0 -doall -prefix 04_Merge/${subj}_mem2_blur   \
            03_VolReg/${subj}_mem2_volreg+orig

mkdir $results_dir/05_Automask
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/05_Automask
#-------------------------------------------------------
echo "create 'full_mask' dataset (union mask)"

    3dAutomask -prefix 05_Automask/${subj}_mem1_automask 04_Merge/${subj}_mem1_blur+orig
    3dAutomask -prefix 05_Automask/${subj}_mem2_automask 04_Merge/${subj}_mem2_blur+orig

mkdir $results_dir/06_Norm
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/06_Norm
#-------------------------------------------------------
echo "scale each voxel time series to have a mean of 100 (subject to maximum value of 200)"

    3dTstat -prefix 06_Norm/${subj}_mem1_mean 04_Merge/${subj}_mem1_blur+orig
    3dcalc -a 04_Merge/${subj}_mem1_blur+orig -b 06_Norm/${subj}_mem1_mean+orig  \
           -c 05_Automask/${subj}_mem1_automask+orig                              \
           -expr "(a/b * 100) * c"                        \
           -prefix 06_Norm/${subj}_mem1_norm

    3dTstat -prefix 06_Norm/${subj}_mem2_mean 04_Merge/${subj}_mem2_blur+orig
    3dcalc -a 04_Merge/${subj}_mem2_blur+orig -b 06_Norm/${subj}_mem2_mean+orig  \
           -c 05_Automask/${subj}_mem2_automask+orig                              \
           -expr "(a/b * 100) * c"                        \
           -prefix 06_Norm/${subj}_mem2_norm

mkdir $results_dir/07_Concatenation
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/07_Concatenation
#-------------------------------------------------------
echo "Apply 3dTcat to Concatenate memory runs in order of Mem2 and Mem1 respectively"

	3dTcat -prefix 07_Concatenation/${subj}_norm 06_Norm/${subj}_mem2_norm+orig 06_Norm/${subj}_mem1_norm+orig
	
	3dToutcount -automask 02_OutCount/${subj}_norm+orig > 02_OutCount/postcount_${subj}_norm.1D
	
#-------------------------------------------------------
echo "create 'full_mask' dataset (union mask) of newly concatenated file"

    3dAutomask -prefix 05_Automask/${subj}_automask 07_Concatenation/${subj}_norm+orig
    
    mkdir $results_dir/08_Deconvolve
	cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/08_Deconvolve
#-------------------------------------------------------
#run the regression analysis
echo "Deconvolution!"

echo "GAM 1"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(3.35,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam1            \
    -stim_times 2 00_Data/FF.txt 'GAM(3.35,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam1            \
    -stim_times 3 00_Data/NF.txt 'GAM(3.35,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam1            \
    -stim_times 4 00_Data/MA.txt 'GAM(3.35,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam1            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM1_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM1_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM1_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM1_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM1_stats

echo "GAM 2"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(6.7,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam2            \
    -stim_times 2 00_Data/FF.txt 'GAM(6.7,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam2            \
    -stim_times 3 00_Data/NF.txt 'GAM(6.7,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam2            \
    -stim_times 4 00_Data/MA.txt 'GAM(6.7,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam2            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM2_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM2_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM2_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM2_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM2_stats

echo "GAM 3"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(10.05,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam3            \
    -stim_times 2 00_Data/FF.txt 'GAM(10.05,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam3            \
    -stim_times 3 00_Data/NF.txt 'GAM(10.05,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam3            \
    -stim_times 4 00_Data/MA.txt 'GAM(10.05,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam3            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM3_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM3_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM3_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM3_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM3_stats

echo "GAM 4"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(13.4,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam4            \
    -stim_times 2 00_Data/FF.txt 'GAM(13.4,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam4            \
    -stim_times 3 00_Data/NF.txt 'GAM(13.4,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam4            \
    -stim_times 4 00_Data/MA.txt 'GAM(13.4,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam4            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM4_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM4_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM4_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM4_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM4_stats

echo "GAM 5"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(16.75,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam5            \
    -stim_times 2 00_Data/FF.txt 'GAM(16.75,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam5            \
    -stim_times 3 00_Data/NF.txt 'GAM(16.75,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam5            \
    -stim_times 4 00_Data/MA.txt 'GAM(16.75,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam5            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM5_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM5_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM5_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM5_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM5_stats
    
echo "GAM 6"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(25.2,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam6            \
    -stim_times 2 00_Data/FF.txt 'GAM(25.2,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam6            \
    -stim_times 3 00_Data/NF.txt 'GAM(25.2,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam6            \
    -stim_times 4 00_Data/MA.txt 'GAM(25.2,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam6            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM6_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM6_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM6_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM6_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM6_stats    
    
echo "GAM 7"

3dDeconvolve -input 07_Concatenation/${subj}_norm+orig.HEAD    		\
    -mask 05_Automask/${subj}_automask+orig                                        \
    #-censor stimuli/censorConCat.1D				 \
    -num_stimts 10                                    \
    -global_times \
    -stim_times 1 00_Data/MF.txt 'GAM(23.45,0.547)'         \
    -stim_label 1 08_Deconvolve/mf_gam7            \
    -stim_times 2 00_Data/FF.txt 'GAM(23.45,0.547)'         \
    -stim_label 2 08_Deconvolve/ff_gam7            \
    -stim_times 3 00_Data/NF.txt 'GAM(23.45,0.547)'         \
    -stim_label 3 08_Deconvolve/nf_gam7            \
    -stim_times 4 00_Data/MA.txt 'GAM(23.45,0.547)'         \
    -stim_label 4 08_Deconvolve/ma_gam7            \
    -stim_file 5 03_VolReg/${subj}.1D'[0]' -stim_base 5 -stim_label 5 07_Deconvolve/roll    \
    -stim_file 6 03_VolReg/${subj}.1D'[1]' -stim_base 6 -stim_label 6 07_Deconvolve/pitch   \
    -stim_file 7 03_VolReg/${subj}.1D'[2]' -stim_base 7 -stim_label 7 07_Deconvolve/yaw  \
    -stim_file 8 03_VolReg/${subj}.1D'[3]' -stim_base 8 -stim_label 8 07_Deconvolve/dS   \
    -stim_file 9 03_VolReg/${subj}.1D'[4]' -stim_base 9 -stim_label 9 07_Deconvolve/dL   \
    -stim_file 10 03_VolReg/${subj}.1D'[5]' -stim_base 10 -stim_label 10 07_Deconvolve/dP   \
    -iresp 1 08_Deconvolve/${subj}_GAM7_mf_norm_irf \
    -iresp 2 08_Deconvolve/${subj}_GAM7_ff_norm_irf \
    -iresp 3 08_Deconvolve/${subj}_GAM7_nf_norm_irf \
    -iresp 4 08_Deconvolve/${subj}_GAM7_ma_norm_irf \
    -full_first -fout -tout -nobout -polort 7		 \
    -concat 00_Data/TR.1D							 \
    -progress 1000									 \
    -bucket 08_Deconvolve/${subj}_GAM7_stats    
    
echo "create an all_runs dataset to match the fitts, errts, etc."

# 3dTcat -prefix 08_Deconvolve/${subj}_GAM0_all_runs 07_Concatenation/${subj}_GAM0_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM1_all_runs 07_Concatenation/${subj}_GAM1_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM2_all_runs 07_Concatenation/${subj}_GAM2_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM3_all_runs 07_Concatenation/${subj}_GAM3_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM4_all_runs 07_Concatenation/${subj}_GAM4_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM5_all_runs 07_Concatenation/${subj}_GAM5_norm+orig.HEAD
# 3dTcat -prefix 08_Deconvolve/${subj}_GAM6_all_runs 07_Concatenation/${subj}_GAM6_norm+orig.HEAD

mkdir $results_dir/09_AnovaPrep
cp $subj_dir/struct/Tal/${subj}_${anat}+orig* $results_dir/09_AnovaPrep
#-------------------------------------------------------
# Extract sub-brick data

3dbucket -prefix 09_AnovaPrep/${subj}_GAM1_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM1_ma_norm_irf+orig'[1]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM1_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM1_ff_norm_irf+orig'[1]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM1_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM1_mf_norm_irf+orig'[1]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM1_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM1_nf_norm_irf+orig'[1]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM2_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM2_ma_norm_irf+orig'[2]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM2_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM2_ff_norm_irf+orig'[2]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM2_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM2_mf_norm_irf+orig'[2]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM2_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM2_nf_norm_irf+orig'[2]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM3_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM3_ma_norm_irf+orig'[3]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM3_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM3_ff_norm_irf+orig'[3]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM3_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM3_mf_norm_irf+orig'[3]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM3_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM3_nf_norm_irf+orig'[3]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM4_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM4_ma_norm_irf+orig'[4]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM4_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM4_ff_norm_irf+orig'[4]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM4_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM4_mf_norm_irf+orig'[4]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM4_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM4_nf_norm_irf+orig'[4]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM5_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM5_ma_norm_irf+orig'[5]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM5_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM5_ff_norm_irf+orig'[5]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM5_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM5_mf_norm_irf+orig'[5]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM5_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM5_nf_norm_irf+orig'[5]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM6_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM6_ma_norm_irf+orig'[6]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM6_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM6_ff_norm_irf+orig'[6]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM6_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM6_mf_norm_irf+orig'[6]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM6_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM6_nf_norm_irf+orig'[6]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM7_ma_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM7_ma_norm_irf+orig'[7]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM7_ff_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM7_ff_norm_irf+orig'[7]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM7_mf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM7_mf_norm_irf+orig'[7]'
3dbucket -prefix 09_AnovaPrep/${subj}_GAM7_nf_peak_irf+orig -fbuc 08_Deconvolve/${subj}_GAM7_nf_norm_irf+orig'[7]'
end

#-------------------------------------------------------
# Warp datasets to Talairach space
echo "Warp datasets to Talairach space"

# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM0_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM0_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM0_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM0_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM1_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM1_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM1_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM1_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM2_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM2_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM2_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM2_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM3_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM3_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM3_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM3_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM4_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM4_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM4_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM4_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM5_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM5_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM5_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM5_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM6_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM6_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM6_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM6_nf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM7_ma_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM7_ff_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM7_mf_peak_irf+orig
# adwarp -apar 00_Data/${subj}_${anat}+tlrc -dpar 09_AnovaPrep/${subj}_GAM7_nf_peak_irf+orig
# 
# cp $results_dir/09_AnovaPrep/*tlrc* $group_dir

echo "Our Motto"
echo "We've suffered so you wont have to!"
echo "Because we put the RE in RESEARCH"
echo "Its not Rocket science, its BRAIN science!"

