#!/bin/bash


#============================================================
#				 Setup stuff
#============================================================

source rat_functions         # source the rat functions

subj=$1
run=$2


if [[ -z $subj && -z $run ]]; then
    echo -n "Which Subject? (e.g r002):     "
    	read subj                     # rat 002
    echo -n "Which Run? (TX, CRT): "
        read run                      # TX or CRT we are working with the treatment rat
elif [[ -z $subj ]]; then
    echo -n "Which Subject? (e.g r002): "
        read subj                     # rat 002
elif [[ -z $run ]]; then
    echo -n "Which Run? (TX, CRT): "
        read run                      # TX or CRT we are working with the treatment rat
fi




HOME=/Volumes/Data/Rat
ORIG=/Volumes/Data/Rat/$subj/ORIG
PREP=/Volumes/Data/Rat/$subj/Prep/$run
GLM=/Volumes/Data/Rat/$subj/GLM/$run
ICA=/Volumes/Data/Rat/$subj/ICA/$run
PCA=/Volumes/Data/Rat/$subj/ICA/$run/PCA
FSL=/Volumes/Data/Rat/$subj/ICA/$run/FSL
#============================================================
#				 START OF MAIN
#============================================================

echo "our subject is $subj"
echo "our run is $run"
echo "we are currently in..."; pwd


#cd $ORIG

 #   reconstruct_fse 2>&1 | tee -a ${PREP}/log1.reconstruct_fse.txt

  #  reconstruct_epi 420 2>&1 | tee -a ${PREP}/log2.reconstruct_epi.txt

#   restart_reconstruc


#cd $PREP

 #    rat_tcat 2>&1 | tee -a ${PREP}/log3.rat_tcat.txt

  #   rat_tshift 2>&1 | tee -a ${PREP}/log4.rat_tshift.txt

   #  rat_despike 2>&1 | tee -a ${PREP}/log5.rat_despike.txt

#     rat_volreg 2>&1 | tee -a ${PREP}/log6.rat_volreg.txt

   #  rat_bucket 2>&1 | tee -a ${PREP}/log7.rat_bucket.txt

   #  rat_mask 2>&1 | tee -a ${PREP}/log8.rat_mask.txt

   #  rat_scale 2>&1 | tee -a ${PREP}/log9.rat_scale.txt

#    restart_prep

#cd $GLM     # Onset, Duration, HRF

 #   regress_combo 2>&1 | tee -a ${GLM}/log1.regress_combo.txt

  #  regress_WAV 54 366 0.5 2>&1 | tee -a ${GLM}/log2.regress_WAV.txt

   # regress_WAV 570 468 0.5 2>&1 | tee -a ${GLM}/log3.regress_WAV.txt

    #regress_WAV 1038 162 0.5 2>&1 | tee -a ${GLM}/log4.regress_WAV.txt

#	  restart_regression

cd $ICA
    
    rat_PCA 2>&1 | tee -a ${ICA}/log1.rat_PCA.txt
    
    rat_ICA 2>&1 | tee -a ${ICA}/log2.rat_ICA.txt
    
