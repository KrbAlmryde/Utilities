#!/usr/bin/env tcsh
echo "The Glorious ANOVA"
echo "(version 1.0, June 4th, 2009)"
echo "This Script was designed to Tread water where no one has tread before."
echo "The Command line reflects a form of the following"  
echo "./Anova group voice"
# --------------------------------------------------
# Script Setup


set images_home = /Network/Servers/reckless.convert.slhs.arizona.edu/Volumes/NetUsers/rita/Stroop/AnovaData

#set type = Group/Female/Male
set type = $1      

#set run = voice/word      
set run = $2      

echo "Setting Directory Paths"
# assign output directory name
set results_dir = $images_home/${type}_${run}_Anova_results

# verify that the results directory does not yet exist
if ( -d $results_dir ) then 
    echo output dir "${type}_${run}_Anova_results" already exists
   

  endif

echo "Making $results_dir directory"
# create results and group analysis directory
mkdir $results_dir

echo "Enter results directory"
#change directory to results
cd $results_dir

echo "Let the ANOVA begin!"

3dANOVA2 -type 3 -alevels 12 -blevels 7						\
-dset 1 1 $images_home/00_Prep/S20_voice_mvfw_peak_irf+tlrc	\
-dset 2 1 $images_home/00_Prep/S20_word_mvfw_peak_irf+tlrc	\
-dset 3 1 $images_home/00_Prep/S20_voice_fvmw_peak_irf+tlrc		\
-dset 4 1 $images_home/00_Prep/S20_word_fvmw_peak_irf+tlrc		\
-dset 5 1 $images_home/00_Prep/S20_voice_mvmw_peak_irf+tlrc		\
-dset 6 1 $images_home/00_Prep/S20_word_mvmw_peak_irf+tlrc		\
-dset 7 1 $images_home/00_Prep/S20_voice_mvnw_peak_irf+tlrc		\
-dset 8 1 $images_home/00_Prep/S20_word_mvnw_peak_irf+tlrc \
-dset 9 1 $images_home/00_Prep/S20_voice_fvnw_peak_irf+tlrc		\
-dset 10 1 $images_home/00_Prep/S20_word_fvnw_peak_irf+tlrc \
-dset 11 1 $images_home/00_Prep/S20_voice_fvfw_peak_irf+tlrc		\
-dset 12 1 $images_home/00_Prep/S20_word_fvfw_peak_irf+tlrc \
-dset 1 2 $images_home/00_Prep/S21_voice_mvfw_peak_irf+tlrc		\
-dset 2 2 $images_home/00_Prep/S21_word_mvfw_peak_irf+tlrc \
-dset 3 2 $images_home/00_Prep/S21_voice_fvmw_peak_irf+tlrc		\
-dset 4 2 $images_home_00_Prep/S21_word_fvmw_peak_irf+tlrc \
-dset 5 2 $images_home/00_Prep/S21_voice_mvmw_peak_irf+tlrc		\
-dset 6 2 $images_home/00_Prep/S21_word_mvmw_peak_irf+tlrc \
-dset 7 2 $images_home/00_Prep/S21_voice_mvnw_peak_irf+tlrc		\
-dset 8 2 $images_home/00_Prep/S21_word_mvnw_peak_irf+tlrc \
-dset 9 2 $images_home/00_Prep/S21_voice_fvnw_peak_irf+tlrc		\
-dset 10 2 $images_home/00_Prep/S21_word_fvnw_peak_irf+tlrc \
-dset 11 2 $images_home/00_Prep/S21_voice_fvfw_peak_irf+tlrc		\
-dset 12 2 $images_home/00_Prep/S21_word_fvfw_peak_irf+tlrc \
-dset 1 3 $images_home/00_Prep/S24_voice_mvfw_peak_irf+tlrc		\
-dset 2 3 $images_home/00_Prep/S24_word_mvfw_peak_irf+tlrc \
-dset 3 3 $images_home/00_Prep/S24_voice_fvmw_peak_irf+tlrc		\
-dset 4 3 $images_home/00_Prep/S24_word_fvmw_peak_irf+tlrc \
-dset 5 3 $images_home/00_Prep/S24_voice_mvmw_peak_irf+tlrc		\
-dset 6 3 $images_home/00_Prep/S24_word_mvmw_peak_irf+tlrc \
-dset 7 3 $images_home/00_Prep/S24_voice_mvnw_peak_irf+tlrc		\
-dset 8 3 $images_home/00_Prep/S24_word_mvnw_peak_irf+tlrc \
-dset 9 3 $images_home/00_Prep/S24_voice_fvnw_peak_irf+tlrc		\
-dset 10 3 $images_home/00_Prep/S24_word_fvnw_peak_irf+tlrc \
-dset 11 3 $images_home/00_Prep/S24_voice_fvfw_peak_irf+tlrc		\
-dset 12 3 $images_home/00_Prep/S24_word_fvfw_peak_irf+tlrc \
-dset 1 4 $images_home/00_Prep/S26_voice_mvfw_peak_irf+tlrc		\
-dset 2 4 $images_home/00_Prep/S26_word_mvfw_peak_irf+tlrc \
-dset 3 4 $images_home/00_Prep/S26_voice_fvmw_peak_irf+tlrc		\
-dset 4 4 $images_home/00_Prep/S26_word_fvmw_peak_irf+tlrc \
-dset 5 4 $images_home/00_Prep/S26_voice_mvmw_peak_irf+tlrc		\
-dset 6 4 $images_home/00_Prep/S26_word_mvmw_peak_irf+tlrc \
-dset 7 4 $images_home/00_Prep/S26_voice_mvnw_peak_irf+tlrc		\
-dset 8 4 $images_home/00_Prep/S26_word_mvnw_peak_irf+tlrc \
-dset 9 4 $images_home/00_Prep/S26_voice_fvnw_peak_irf+tlrc		\
-dset 10 4 $images_home/00_Prep/S26_word_fvnw_peak_irf+tlrc \
-dset 11 4 $images_home/00_Prep/S26_voice_fvfw_peak_irf+tlrc		\
-dset 12 4 $images_home/00_Prep/S26_word_fvfw_peak_irf+tlrc \
-dset 1 5 $images_home/00_Prep/S28_voice_mvfw_peak_irf+tlrc		\
-dset 2 5 $images_home/00_Prep/S28_word_mvfw_peak_irf+tlrc \
-dset 3 5 $images_home/00_Prep/S28_voice_fvmw_peak_irf+tlrc		\
-dset 4 5 $images_home/00_Prep/S28_word_fvmw_peak_irf+tlrc \
-dset 5 5 $images_home/00_Prep/S28_voice_mvmw_peak_irf+tlrc		\
-dset 6 5 $images_home/00_Prep/S28_word_mvmw_peak_irf+tlrc \
-dset 7 5 $images_home/00_Prep/S28_voice_mvnw_peak_irf+tlrc		\
-dset 8 5 $images_home/00_Prep/S28_word_mvnw_peak_irf+tlrc \
-dset 9 5 $images_home/00_Prep/S28_voice_fvnw_peak_irf+tlrc		\
-dset 10 5 $images_home/00_Prep/S28_word_fvnw_peak_irf+tlrc \
-dset 11 5 $images_home/00_Prep/S28_voice_fvfw_peak_irf+tlrc		\
-dset 12 5 $images_home/00_Prep/S28_word_fvfw_peak_irf+tlrc \
-dset 1 6 $images_home/00_Prep/S32_voice_mvfw_peak_irf+tlrc		\
-dset 2 6 $images_home/00_Prep/S32_word_mvfw_peak_irf+tlrc \
-dset 3 6 $images_home/00_Prep/S32_voice_fvmw_peak_irf+tlrc		\
-dset 4 6 $images_home/00_Prep/S32_word_fvmw_peak_irf+tlrc \
-dset 5 6 $images_home/00_Prep/S32_voice_mvmw_peak_irf+tlrc		\
-dset 6 6 $images_home/00_Prep/S32_word_mvmw_peak_irf+tlrc \
-dset 7 6 $images_home/00_Prep/S32_voice_mvnw_peak_irf+tlrc		\
-dset 8 6 $images_home/00_Prep/S32_word_mvnw_peak_irf+tlrc \
-dset 9 6 $images_home/00_Prep/S32_voice_fvnw_peak_irf+tlrc		\
-dset 10 6 $images_home/00_Prep/S32_word_fvnw_peak_irf+tlrc \
-dset 11 6 $images_home/00_Prep/S32_voice_fvfw_peak_irf+tlrc		\
-dset 12 6 $images_home/00_Prep/S32_word_fvfw_peak_irf+tlrc \
# -dset 1 7 $images_home/00_Prep/S35_voice_mvfw_peak_irf+tlrc		\
# -dset 2 7 $images_home/00_Prep/S35_voice_mvfw_peak_irf+tlrc\
# -dset 3 7 $images_home/00_Prep/S35_voice_fvmw_peak_irf+tlrc		\
# -dset 4 7 $images_home/00_Prep/S35_word_fvmw_peak_irf+tlrc \
# -dset 5 7 $images_home/00_Prep/S35_voice_mvmw_peak_irf+tlrc		\
# -dset 6 7 $images_home/00_Prep/S35_word_mvmw_peak_irf+tlrc \
# -dset 7 7 $images_home/00_Prep/S35_voice_mvnw_peak_irf+tlrc		\
# -dset 8 7 $images_home/00_Prep/S35_word_mvnw_peak_irf+tlrc \
# -dset 9 7 $images_home/00_Prep/S35_voice_fvnw_peak_irf+tlrc		\
# -dset 10 7 $images_home/00_Prep/S35_word_fvnw_peak_irf+tlrc \
# -dset 11 7 $images_home/00_Prep/S35_voice_fvfw_peak_irf+tlrc		\
# -dset 12 7 $images_home/00_Prep/S35_word_fvfw_peak_irf+tlrc \
-dset 1 7 $images_home/00_Prep/S40_voice_mvfw_peak_irf+tlrc		\
-dset 2 7 $images_home/00_Prep/S40_word_mvfw_peak_irf+tlrc \
-dset 3 7 $images_home/00_Prep/S40_voice_fvmw_peak_irf+tlrc		\
-dset 4 7 $images_home/00_Prep/S40_word_fvmw_peak_irf+tlrc \
-dset 5 7 $images_home/00_Prep/S40_voice_mvmw_peak_irf+tlrc		\
-dset 6 7 $images_home/00_Prep/S40_word_mvmw_peak_irf+tlrc \
-dset 7 7 $images_home/00_Prep/S40_voice_mvnw_peak_irf+tlrc		\
-dset 8 7 $images_home/00_Prep/S40_word_mvnw_peak_irf+tlrc \
-dset 9 7 $images_home/00_Prep/S40_voice_fvnw_peak_irf+tlrc		\
-dset 10 7 $images_home/00_Prep/S40_word_fvnw_peak_irf+tlrc \
-dset 11 7 $images_home/00_Prep/S40_voice_fvfw_peak_irf+tlrc		\
-dset 12 7 $images_home/00_Prep/S40_word_fvfw_peak_irf+tlrc \
-voxel 2000 							\
-fa Fstat_all 							\
-acontr 1 -1 1 -1 1 -1 1 -1 1 -1 1 -1 voicevsword 				\
-fa Fstat_mean   
	
	
       

