. $PROFILE/${1}_profile.sh

# cd ${func_dir}/${run}
# echo "working"
# echo "${func_dir}/${run}"
# cp ${runsub}.nii.gz ${ICA_dir}/${cond}/${run}
# echo "${ICA_dir}/${cond}/${run}"

cond=Learnable
mkdir ${ICA_dir}/${cond}/${run}/MODEL
mkdir ${ICA_dir}/${cond}/${run}/MODEL/FEAT
mkdir ${ICA_dir}/${cond}/${run}/MODEL/MELODIC

cond=Unlearnable
mkdir ${ICA_dir}/${cond}/${run}/MODEL
mkdir ${ICA_dir}/${cond}/${run}/MODEL/FEAT
mkdir ${ICA_dir}/${cond}/${run}/MODEL/MELODIC

####################################################################################################








echo "its working"
echo""

# cd $subj_dir
# rm -r SP1 SP2 TP1 TP2
# 	mkdir Prep GLM
# 	mv struc Struc
# cd $prep_dir
# 	mkdir etc
#cd $glm_dir
# 	rmdir IDEAL
#	mv IRF IRESP
#	mkdir REML
#	mkdir MODEL
#	mkdir FUNC
# cd $anat_dir
# 	mkdir etc
#cd $orig_dir
#	mv ???.* ../Prep
