. $DRIVR/exp_profile.sh
####################################################################################################
								########### START OF MAIN ############
####################################################################################################
# This list specifies variables specifc to the RAT study. Sections include those designated for
# path specific variables, as well as name specific variables
####################################################################################################
# FSE Preprocessing parameters
####################################################################################################

fse=${subj}.fse
nfs= #number of functional scans
nas= #number of anatomical slices
tr= #the GAM
thick= #Z-slice thickness
z1= #Slice acquisition direction
fov= #field of view
####################################################################################################
# Spgr Preprocessing parameters
####################################################################################################

spgr=${subj}.spgr
nasspgr= #number of anatomical slices
thickspgr= #Z-slice thickness
z1spgr= #Slice acquisition direction
fovspgr=128 #field of view for spgr
####################################################################################################
# These are path variables that will be specified in the individual program scripts
####################################################################################################

 home_dir=${RAT}
 ANAT_dir=${RAT}/Anatomical
BEHAV_dir=${RAT}/BehavData
   ICA_dir=${RAT}/ICA/${run}
   GLM_dir=${RAT}/GLM
ANOVA_dir=${RAT}/ANOVA/${run}
 mask_dir=${RAT}/ANOVA/Masks
  subj_dir=${RAT}/${subj}
  orig_dir=${RAT}/${subj}/Orig
  anat_dir=${RAT}/${subj}/Struc
  prep_dir=${RAT}/${subj}/Prep
   glm_dir=${RAT}/${subj}/GLM
  test_dir=${RAT}/${subj}/Test
####################################################################################################
# These are item variables describing the Conditions and Model
####################################################################################################

	mod=GAM
  cond1=TruePos
  cond2=TrueNeg
  cond3=FalsePos
  cond4=FalseNeg
cond1v2=${cond1}.vs.${cond2}
cond2v1=${cond2}.vs.${cond1}
####################################################################################################
# Names for files. Naming hierachy should follow this pattern: subj, run, mod, cond, brik
# Indentation is for readability
####################################################################################################

  subrun=${subj}.${run}
  submod=${subj}.${run}.${mod}
subcond1=${subj}.${run}.${mod}.${cond1}
subcond2=${subj}.${run}.${mod}.${cond2}

  runmod=${run}.${mod}
runcond1=${run}.${mod}.${cond1}
runcond2=${run}.${mod}.${cond2}
 runmean=${run}.${mod}.mean
runcontr=${run}.${mod}.contr
####################################################################################################
# ANOVA and Group-specific variables
####################################################################################################

if [ "${clust}" = "1640" ]; then
	plvl=05; thr=2.160
fi
####################################################################################################
# For calculating xyz sizes for functional and structural (fse) reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
####################################################################################################

x=`expr ${nas} - 1`
y=`echo "scale=2; ${x} * ${thick}"| bc`
z=`echo "scale=2; ${y}/2"| bc`
halffov=`echo "scale=2; ${fov}/2"| bc`
####################################################################################################
# For calculating xyz sizes for structural reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
# I had to include spgr variables because the RAT study uses different parameters for that scan
####################################################################################################

xspgr=`expr ${nasspgr} - 1`
yspgr=`echo "scale=2; ${xspgr} * ${thickspgr}"| bc`
zspgr=`echo "scale=2; ${yspgr}/2"| bc`
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`
####################################################################################################
