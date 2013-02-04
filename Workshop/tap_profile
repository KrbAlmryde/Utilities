####################################################################################################
#
# This list specifies variables specifc to the TAP study
####################################################################################################
#
# Sourcing the exp_profile so our variables get passed to the shell properly

. $UTL/exp_profile

echo "tap_profile has been sourced"
echo ""

####################################################################################################
#
# These are path variables that will be specified in the individual program scripts

home_dir=${TAP}
subj_dir=${TAP}/${subj}
orig_dir=${TAP}/${subj}/Orig
anat_dir=${subj_dir}/struc
func_dir=${TAP}/${subj}/${run}

####################################################################################################
#
# Names for files

runnm=${subj}_${run}
condnm=${subj}_${run}_${cond}
spgr=${subj}_spgr
fse=${subj}_fse
####################################################################################################
#
# Preprocessing parameters

exp=tap
nfs=154 #number of functional scans
nas=26 #number of anatomical slices
tr=3500 #the TR
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
# Spgr specific parameters

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
#
# For calculating xyz sizes for functional reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
# The bourne shell is crummy for doing arithmatic, so here I call bc to handle decimal points
#

#
#

####################################################################################################
#
# For calculating xyz sizes for functional reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV

