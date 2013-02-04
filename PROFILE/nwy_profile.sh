####################################################################################################
#
# This list specifies variables specifc to the NORWAY study
####################################################################################################
#
####################################################################################################
# Sourcing the exp_profile.sh so our variables get passed to the shell properly
. $DRIVR/exp_profile.sh
####################################################################################################
# These are path variables that will be specified in the individual program scripts

home_dir=${NORWAY}
ANOVA_dir=${NORWAY}/ANOVA/${run}
ICA_dir=${NORWAY}/ICA
GLM_dir=${NORWAY}/GLM
ANAT_dir=${NORWAY}/Anatomical
subj_dir=${NORWAY}/${subj}
func_dir=${subj_dir}/Func/${run}
morph_dir=${subj_dir}/Morph
dti_dir=${subj_dir}/DTI
####################################################################################################
#
# FSE Preprocessing parameters

nfs=168 #number of functional scans
nas=26 #number of anatomical slices
tr=2.6 #the repetition time
thick=5 #Z-slice thickness
z1=I #Slice acquisition direction
fov=240 #field of view
####################################################################################################
#
# For calculating xyz sizes for functional and structural (fse) reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV

x=`expr ${nas} - 1`
y=`echo "scale=2; ${x} * ${thick}"| bc`
z=`echo "scale=2; ${y}/2"| bc`
halffov=`echo "scale=2; ${fov}/2"| bc`
####################################################################################################
#
# Spgr Preprocessing parameters

nasspgr=164 #number of anatomical slices
thickspgr=1 #Z-slice thickness
z1spgr=L #Slice acquisition direction
fovspgr=256 #field of view for spgr
####################################################################################################
#
# For calculating xyz sizes for structural reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
# I had to include spgr variables because the NORWAY study uses different parameters for that scan

xspgr=`expr ${nasspgr} - 1`
yspgr=`echo "scale=2; ${xspgr} * ${thickspgr}"| bc`
zspgr=`echo "scale=2; ${yspgr}/2"| bc`
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`
####################################################################################################
# Condition name decision maker

if [ "${subj}" = "sub013" -a "sub016" -a "sub019" -a "sub021" -a "sub023" -a "sub027" \
	-a "sub028" -a "sub033" -a "sub039" -a "sub046" -a "sub050" ]; then

	cond=Learnable

else

	cond=Unlearnable
fi
####################################################################################################
# Deconvolution; Hemodynamic Response Model specific variables
####################################################################################################
# For the default WAV and GAM models
if [ "${hrm}" = "WAV" ]; then
	mod=WAV
elif [ "${hrm}" = "GAM" ]; then
	mod=GAM
fi
####################################################################################################
# Names for files. Naming hierachy should follow this pattern: subj, run, mod, cond, brik
# Indentation is for readability


runsub=${run}_${subj}

subrun=${subj}.${run}
submod=${subrun}.${mod}
subcond1=${submod}.${cond1}
subcond2=${submod}.${cond2}
runcond1=${run}.${mod}.${cond1}
runcond2=${run}.${mod}.${cond2}
spgr=${subj}.spgr
fse=${subj}.fse
####################################################################################################
# ANOVA specific variables

factorB=Subjects
alevel1=$cond1
alevel2=$cond2

if [ "${run}" = "SP1" ]; then
	factorA=Semantic
elif [ "${run}" = "TP1" ]; then
	factorA=Familiarity
elif [ "${run}" = "SP2" ]; then
	factorA=Voice
else
	factorA=Recollection
fi
####################################################################################################
