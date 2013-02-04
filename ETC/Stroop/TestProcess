#!/usr/bin/env tcsh
echo "The New, The Improved, Stroop Script"
echo "This script was designed to tread where no script has tread before."
echo "(version 1.0, May 22, 2009)"
echo "Command line conforms to following: ./PreProcess Condition Base# Censor#"
# execute via : tcsh -x S#-run-script |& tee output.S#-run-script

# --------------------------------------------------
# script setup


set images_home = /Volumes/Maxtor/Data/Stroop

echo "Count Down Begins"

if ( $#argv > 0 ) then  
    set subj = $argv[1] 
else                    
# specify subject = S19
set subj = $1

endif

echo "Assigning Variables"

#set run = voice/word  followed by GAM value    
set run = $2      

#set base = 42
set base = $3

#set censoor = 0-50
set censor = $4

echo "Setting Directory Paths"

# assign anchor directory name
set subj_dir = $images_home/${subj}

# assign output directory name
set results_dir = $subj_dir/${subj}_${run}_TestProcess

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

cp $images_home/${run}* $results_dir/00_Data
cp $subj_dir/run1_${run}/${subj}_${run}* $results_dir/00_Data
cp $subj_dir/run1_${run}/${subj}_${run}_clean_tcat* $results_dir/00_Data
cp $images_home/${run}* $results_dir/00_Data
cp $subj_dir/run2_${run}/${subj}_${run}* $results_dir/00_Data
cp $subj_dir/run2_${run}/${subj}_${run}_clean_tcat* $results_dir/00_Data
cp $subj_dir/struct/Tal/*spgr* $results_dir/00_Data

mkdir $results_dir/01_Tcat
#-------------------------------------------------------
echo "apply 3dTcat to copy input dsets to results dir, while removing the first 4 TRs"

3dTcat -prefix 01_Tcat/${subj}_${run}_tcat 00_Data/${subj}_${run}_epan+orig'[4..$]'

mkdir $results_dir/02_Tshift

#-------------------------------------------------------
echo "run 3dToutcount on Tcat BRIK/HEAD files, then plot"

3dToutcount 01_Tcat/${subj}_${run}_tcat+orig > 02_Tshift/precount_${subj}_${run}.1D

#1dplot -one   02_Tshift/precount_${subj}_${run}.1D

#-------------------------------------------------------
echo "run 3dTshift and 3dToutcount for Tshift BRIK/HEAD File, then plot"

3dTshift -tzero 0 -rlt+ -quintic -prefix 02_Tshift/${subj}_${run}_tshift      \
             00_Data/${subj}_${run}_clean_tcat+orig

3dToutcount 02_Tshift/${subj}_${run}_tshift+orig > 02_Tshift/postcount_${subj}_${run}.1D

#1dplot -one 02_Tshift/postcount_${subj}_${run}.1D

mkdir $results_dir/03_VolReg
#-------------------------------------------------------
echo "align each dset to the base volume"

3dvolreg -verbose -zpad 1 -base 02_Tshift/${subj}_${run}_tshift+orig"[${base}]"  \
             -1Dfile 03_VolReg/dfile_${subj}_${run}_1D -prefix 03_VolReg/${subj}_${run}_volreg  \
             -cubic                                                  \
             02_Tshift/${subj}_${run}_tshift+orig					
             
#1dplot -sep -ynames roll pitch yaw dS dL dP -xlabel TIME 03_VolReg/dfile_${subj}_${run}_1D

mkdir $results_dir/04_Merge
#-------------------------------------------------------
echo "blur each volume"

    3dmerge -1blur_fwhm 6.0 -doall -prefix 04_Merge/${subj}_${run}_blur   \
            03_VolReg/${subj}_${run}_volreg+orig

mkdir $results_dir/05_Automask
#-------------------------------------------------------
echo "create 'full_mask' dataset (union mask)"

    3dAutomask -prefix 05_Automask/${subj}_${run}_automask 04_Merge/${subj}_${run}_blur+orig

mkdir $results_dir/06_Norm

#-------------------------------------------------------
echo "scale each voxel time series to have a mean of 100 (subject to maximum value of 200)"

    3dTstat -prefix 06_Norm/${subj}_${run}_mean 04_Merge/${subj}_${run}_blur+orig
    3dcalc -a 04_Merge/${subj}_${run}_blur+orig -b 06_Norm/${subj}_${run}_mean+orig  \
           -c 05_Automask/${subj}_${run}_automask+orig                              \
           -expr 'c * min(200, a/b*100)'                        \
           -prefix 06_Norm/${subj}_${run}_norm

#-------------------------------------------------------
echo "Perform 3dToutcount on Nomralized data BRIK/HEAD files, then plot"
	3dToutcount 06_Norm/${subj}_${run}_norm+orig > 06_Norm/Normalized_${subj}_${run}.1D
#	1dplot -one 06_Norm/Normalized_${subj}_${run}.1D

mkdir $results_dir/07_Deconvolve
#-------------------------------------------------------
#run the regression analysis
echo "Deconvolution!"

3dDeconvolve -input 06_Norm/${subj}_${run}_norm+orig.HEAD                     \
   -CENSORTR ${censor}					\
   -polort 5                                                          \
   -mask 05_Automask/${subj}_${run}_automask+orig                                        \
   -num_stimts 13                                                     \
   -local_times \
   -stim_times 1 00_Data/${run}_mvfw_stim.txt 'GAM'                  \
   -stim_label 1 07_Deconvolve/${subj}_${run}_mvfw                                       \
   -stim_times 2 00_Data/${run}_fvmw_stim.txt 'GAM'                  \
   -stim_label 2 07_Deconvolve/${subj}_${run}_fvmw                                       \
   -stim_times 3 00_Data/${run}_mvmw_stim.txt 'GAM'                  \
   -stim_label 3 07_Deconvolve/${subj}_${run}_mvmw                                       \
   -stim_times 4 00_Data/${run}_mvnw_stim.txt 'GAM'                  \
   -stim_label 4 07_Deconvolve/${subj}_${run}_mvnw                                       \
   -stim_times 5 00_Data/${run}_fvnw_stim.txt 'GAM'                 \
   -stim_label 5 07_Deconvolve/${subj}_${run}_fvnw                                      \
   -stim_times 6 00_Data/${run}_fvfw_stim.txt 'GAM'                 \
   -stim_label 6 07_Deconvolve/${subj}_${run}_fvfw                                      \
   -stim_times 7 00_Data/${run}_null_stim.txt 'GAM'                  \
   -stim_label 7 07_Deconvolve/${subj}_${run}_null                                       \
   -stim_file 8 03_VolReg/dfile_${subj}_${run}_1D'[0]' -stim_base 8 -stim_label 8 07_Deconvolve/roll    \
   -stim_file 9 03_VolReg/dfile_${subj}_${run}_1D'[1]' -stim_base 9 -stim_label 9 07_Deconvolve/pitch   \
   -stim_file 10 03_VolReg/dfile_${subj}_${run}_1D'[2]' -stim_base 10 -stim_label 10 07_Deconvolve/yaw  \
   -stim_file 11 03_VolReg/dfile_${subj}_${run}_1D'[3]' -stim_base 11 -stim_label 11 07_Deconvolve/dS   \
   -stim_file 12 03_VolReg/dfile_${subj}_${run}_1D'[4]' -stim_base 12 -stim_label 12 07_Deconvolve/dL   \
   -stim_file 13 03_VolReg/dfile_${subj}_${run}_1D'[5]' -stim_base 13 -stim_label 13 07_Deconvolve/dP   \
   -iresp 1 07_Deconvolve/${subj}_${run}_mvfw_norm_irf -TR_times 0.575 \
   -iresp 2 07_Deconvolve/${subj}_${run}_fvmw_norm_irf -TR_times 0.575 \
   -iresp 3 07_Deconvolve/${subj}_${run}_mvmw_norm_irf -TR_times 0.575 \
   -iresp 4 07_Deconvolve/${subj}_${run}_mvnw_norm_irf -TR_times 0.575 \
   -iresp 5 07_Deconvolve/${subj}_${run}_fvnw_norm_irf -TR_times 0.575 \
   -iresp 6 07_Deconvolve/${subj}_${run}_fvfw_norm_irf -TR_times 0.575 \
   -iresp 7 07_Deconvolve/${subj}_${run}_null_norm_irf -TR_times 0.575 \
   -tout -x1D 07_Deconvolve/X_matrix.1D -xjpeg 07_Deconvolve/X_matrix.jpg                            \
   -bucket 07_Deconvolve/${subj}_${run}_stats

mkdir $results_dir/08_AnovaPrep 
#-------------------------------------------------------
#-------------------------------------------------------
# Warp datasets to Talairach space

adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_mvfw_norm_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_fvmw_norm_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_mvmw_norm_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_mvnw_norm_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_fvnw_norm_irf+orig
adwarp -apar 00_Data/${subj}_spgr+tlrc -dpar 07_Deconvolve/${subj}_${run}_fvfw_norm_irf+orig

# Extract sub-brick data information

echo "Extracting sub-bricked data from bucket files"

3dbucket -prefix 08_AnovaPrep/${subj}_${run}_mvfw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_mvfw_norm_irf+tlrc'[8]'
3dbucket -prefix 08_AnovaPrep/${subj}_${run}_fvmw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_fvmw_norm_irf+tlrc'[8]'
3dbucket -prefix 08_AnovaPrep/${subj}_${run}_mvmw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_mvmw_norm_irf+tlrc'[8]'
3dbucket -prefix 08_AnovaPrep/${subj}_${run}_fvfw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_fvfw_norm_irf+tlrc'[8]'
3dbucket -prefix 08_AnovaPrep/${subj}_${run}_mvnw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_mvnw_norm_irf+tlrc'[8]'
3dbucket -prefix 08_AnovaPrep/${subj}_${run}_fvnw_peak_irf -fbuc 07_Deconvolve/${subj}_${run}_fvnw_norm_irf+tlrc'[8]'


#-------------------------------------------------------


mv $results_dir/08_AnovaPrep/*tlrc* $group_dir

echo "Our Motto"
echo "We've suffered so you wont have to!"
echo "Besides..."
echo "Its not Rocket science, its BRAIN science!"

end