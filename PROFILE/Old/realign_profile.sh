####################################################################################################
#
# This list specifies variables specifc to the TAP study
####################################################################################################
#
####################################################################################################
# Sourcing the exp_profile.sh so our variables get passed to the shell properly
. $DRIVR/exp_profile.sh
####################################################################################################
# These are path variables that will be specified in the individual program scripts

home_dir=${TAP}
anova_dir=${TAP}/ANOVA/${run}
fsl_dir=${TAP}/FSL/${run}
subj_dir=${TAP}/${subj}
orig_dir=${subj_dir}/Orig
anat_dir=${subj_dir}/struc
run_dir=${TAP}/${subj}/${run}
####################################################################################################
#
# FSE Preprocessing parameters

nfs=154 #number of functional scans
nas=26 #number of anatomical slices
tr=3500 #the GAM
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
# I had to include spgr variables because the tap study uses different parameters for that scan

xspgr=`expr ${nasspgr} - 1`
yspgr=`echo "scale=2; ${xspgr} * ${thickspgr}"| bc`
zspgr=`echo "scale=2; ${yspgr}/2"| bc`
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`
####################################################################################################
# Condition name decision maker

if [ "${run}" = "SP1" ]; then
	cond1=animal
	cond2=food
elif [ "${run}" = "TP1" ]; then
	cond1=old
	cond2=new
else
	cond1=male
	cond2=female
fi
####################################################################################################
# Names for files. Naming hierachy should follow this pattern: subj, run, mod, cond, brik
# Indentation is for readability

subrun=${subj}_${run}
subcond=${subj}_${run}_${cond}
submod=${subj}_${run}_${cond}_${mod}
		runcond=${run}_${cond}
			runmod=${run}_${cond}_${mod}
					condmod=${cond}_${mod}
subrunmod=${subj}_${run}_${mod}
spgr=${subj}_spgr
fse=${subj}_fse

