#!/usr/bin/env tcsh
echo "The New, The Improved, Stroop Script"
echo "This script was designed to Tread water where no one has tread before."
echo "(version 1.0, May 22, 2009)"

# execute via : tcsh -x S#-run-script |& tee output.S#-run-script

# --------------------------------------------------
# script setup


set images_home = /Network/Servers/reckless.convert.slhs.arizona.edu/Volumes/NetUsers/rita/Stroop

echo "Count Down Begins"

if ( $#argv > 0 ) then  
    set subj = $argv[1] 
else                    
# specify subject = S19
set subj = $1

endif

echo "Assigning Variables"

#set run = voice/word      
set run = $2      

#set base = 42
set base = $3

echo "Setting Directory Paths"

# assign anchor directory name
set subj_dir = $images_home/${subj}

# assign output directory name
set results_dir = $subj_dir/${subj}_${run}_results

# assign group directory name
set group_dir = $images_home/AnovaData/00_Prep

# verify that the results directory does not yet exist
if ( -d $results_dir ) then 
    echo output dir "${subj}_${run}_results" already exists
   
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

cp $subj_dir/run1_${run}/${subj}_${run}* $results_dir/00_Data
cp $subj_dir/run2_${run}/${subj}_${run}* $results_dir/00_Data
cp $subj_dir/struct/Tal/*spgr* $results_dir/00_Data

mkdir $results_dir/01_Tcat
#-------------------------------------------------------
echo "apply 3dTcat to copy input dsets to results dir, while removing the first 4 TRs"

3dTcat -prefix 01_Tcat/${subj}_${run}_tcat 00_Data/${subj}_${run}_epan+orig'[4..$]'

mkdir $results_dir/02_VolReg
#-------------------------------------------------------
echo "align each dset to the base volume"

    3dvolreg -verbose -zpad 1 -base 01_Tcat/${subj}_${run}_tcat+orig"[${base}]"  \
             -1Dfile 02_VolReg/dfile_${subj}_${run}_1D -prefix 02_VolReg/${subj}_${run}_volreg  \
             -cubic                                                  \
             01_Tcat/${subj}_${run}_tcat+orig


#make a single file of registration params
cat 02_VolReg/dfile_${subj}_${run}_1D > 02_VolReg/${subj}_${run}_1D

mkdir $results_dir/03_Merge
#-------------------------------------------------------
echo "blur each volume"

    3dmerge -1blur_fwhm 8.0 -doall -prefix 03_Merge/${subj}_${run}_blur   \
            02_VolReg/${subj}_${run}_volreg+orig

mkdir $results_dir/04_Automask
#-------------------------------------------------------
echo "create 'full_mask' dataset (union mask)"

    3dAutomask -prefix 04_Automask/${subj}_${run}_automask 03_Merge/${subj}_${run}_blur+orig

mkdir $results_dir/05_Norm
#-------------------------------------------------------
echo "scale each voxel time series to have a mean of 100 (subject to maximum value of 200)"

    3dTstat -prefix 05_Norm/${subj}_${run}_mean 03_Merge/${subj}_${run}_blur+orig
    3dcalc -a 03_Merge/${subj}_${run}_blur+orig -b 05_Norm/${subj}_${run}_mean+orig  \
           -c 04_Automask/${subj}_${run}_automask+orig                              \
           -expr 'c * min(200, a/b*100)'                        \
           -prefix 05_Norm/${subj}_${run}_norm

mkdir $results_dir/06_Deconvolve
#-------------------------------------------------------
#run the regression analysis
echo "Deconvolution!"

3dDeconvolve -input 05_Norm/${subj}_${run}_norm+orig.HEAD                     \
    -polort 5                                                          \
    -mask 04_Automask/${subj}_${run}_automask+orig                                        \
    -num_stimts 7                                                     \
   -stim_times 1 00_Data/${subj}_${run}_mvfw_res.txt 'GAM'                  \
   -stim_label 1 06_Deconvolve/${subj}_${run}_mvfw_res                                       \
   -stim_times 2 00_Data/${subj}_${run}_fvmw_res.txt 'GAM'                  \
   -stim_label 2 06_Deconvolve/${subj}_${run}_fvmw_res                                       \
   -stim_times 3 00_Data/${subj}_${run}_mvmw_res.txt 'GAM'                  \
   -stim_label 3 06_Deconvolve/${subj}_${run}_mvmw_res                                       \
   -stim_times 4 00_Data/${subj}_${run}_mvnw_res.txt 'GAM'                  \
   -stim_label 4 06_Deconvolve/${subj}_${run}_mvnw_res                                       \
   -stim_times 5 00_Data/${subj}_${run}_fvnw_res.txt 'GAM'                 \
   -stim_label 5 06_Deconvolve/${subj}_${run}_fvnw_res                                      \
   -stim_times 6 00_Data/${subj}_${run}_fvfw_res.txt 'GAM'                 \
   -stim_label 6 06_Deconvolve/${subj}_${run}_fvfw_res                                      \
   -stim_times 7 00_Data/${subj}_${run}_null_res.txt 'GAM'                  \
   -stim_label 7 06_Deconvolve/${subj}_${run}_null_res                                       \
#    -stim_file 8 dfile.$run.1D'[0]' -stim_base 8 -stim_label 8 roll    \
#    -stim_file 9 dfile.$run.1D'[1]' -stim_base 9 -stim_label 9 pitch   \
#    -stim_file 10 dfile.$run.1D'[2]' -stim_base 10 -stim_label 10 yaw  \
#    -stim_file 11 dfile.$run.1D'[3]' -stim_base 11 -stim_label 11 dS   \
#    -stim_file 12 dfile.$run.1D'[4]' -stim_base 12 -stim_label 12 dL   \
#    -stim_file 13 dfile.$run.1D'[5]' -stim_base 13 -stim_label 13 dP   \
   -iresp 1 06_Deconvolve/${subj}_${run}_mvfw_norm_irf -TR_times 0.575 \
   -iresp 2 06_Deconvolve/${subj}_${run}_fvmw_norm_irf -TR_times 0.575 \
   -iresp 3 06_Deconvolve/${subj}_${run}_mvmw_norm_irf -TR_times 0.575 \
   -iresp 4 06_Deconvolve/${subj}_${run}_mvnw_norm_irf -TR_times 0.575 \
   -iresp 5 06_Deconvolve/${subj}_${run}_fvnw_norm_irf -TR_times 0.575 \
   -iresp 6 06_Deconvolve/${subj}_${run}_fvfw_norm_irf -TR_times 0.575 \
   -iresp 7 06_Deconvolve/${subj}_${run}_null_norm_irf -TR_times 0.575 \
#    -num_glt 6	\
#    -glt_label 1 mvfw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_mvfw_res - ${subj}_${run}_null_res'	\
#    -glt_label 2 fvmw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_fvmw_res - ${subj}_${run}_null_res'	\
#    -glt_label 3 mvmw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_mvmw_res - ${subj}_${run}_null_res'	\
#    -glt_label 4 mvmw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_fvnw_res - ${subj}_${run}_null_res'	\
#    -glt_label 5 fvnw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_fvfw_res - ${subj}_${run}_null_res'	\
#    -glt_label 6 fvfw_vs_null	\
#    -gltsym 'SYM: + ${subj}_${run}_fvfw_res - ${subj}_${run}_null_res'	\
   -fout -tout -x1D 06_Deconvolve/X.xmat.1D -xjpeg 06_Deconvolve/X.jpg                            \
   -fitts 06_Deconvolve/${subj}_${run}_fitts                                                \
   -bucket 06_Deconvolve/${subj}_${run}_stats


#create an all_runs dataset to match the fitts, errts, etc.

3dTcat -prefix 06_Deconvolve/${subj}_${run}_all_runs 05_Norm/${subj}_${run}_norm+orig.HEAD

#create ideal files for each stim run
1dcat 06_Deconvolve/X.xmat.1D'[6]' > 06_Deconvolve/ideal_mvfw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[7]' > 06_Deconvolve/ideal_fvmw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[8]' > 06_Deconvolve/ideal_mvmw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[9]' > 06_Deconvolve/ideal_mvnw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[10]' > 06_Deconvolve/ideal_fvnw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[11]' > 06_Deconvolve/ideal_fvfw-${run}-res.1D
1dcat 06_Deconvolve/X.xmat.1D'[12]' > 06_Deconvolve/ideal_null-${run}-res.1D

mkdir $results_dir/07_AnovaPrep
#-------------------------------------------------------


# Extract sub-brick data information

3dbucket -prefix 07_AnovaPrep/${subj}_${run}_mvfw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_mvfw_norm_irf+orig'[8]'
3dbucket -prefix 07_AnovaPrep/${subj}_${run}_fvmw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_fvmw_norm_irf+orig'[8]'
3dbucket -prefix 07_AnovaPrep/${subj}_${run}_mvmw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_mvmw_norm_irf+orig'[8]'
3dbucket -prefix 07_AnovaPrep/${subj}_${run}_mvnw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_mvnw_norm_irf+orig'[8]'
3dbucket -prefix 07_AnovaPrep/${subj}_${run}_fvnw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_fvnw_norm_irf+orig'[8]'
3dbucket -prefix 07_AnovaPrep/${subj}_${run}_fvfw_peak_irf -fbuc 06_Deconvolve/${subj}_${run}_fvfw_norm_irf+orig'[8]'

#-------------------------------------------------------
# Warp datasets to Talairach space
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_mvfw_peak_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_fvmw_peak_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_mvmw_peak_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_mvnw_peak_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_fvnw_peak_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_AnovaPrep/${subj}_${run}_fvfw_peak_irf+orig

mv $results_dir/07_AnovaPrep/*tlrc* $group_dir

echo "Our Motto"
echo "We've suffered so you wont have to!"
echo "Besides..."
echo "Its not Rocket science, its BRAIN science!"

end