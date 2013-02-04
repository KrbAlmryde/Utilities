#===============================================================================
# This list specifies variables specifc to the TAP study. Sections include those designated for
# path specific variables, as well as name specific variables
#===============================================================================
# FSE Preprocessing parameters
#===============================================================================
fse=${subj}.fse
nfs=154 #number of functional scans
nas=26 #number of anatomical slices
TR=3500 #the GAM
tr=`echo "scale=1; ${TR}/1000" | bc`
thick=5 #Z-slice thickness
z1=I #Slice acquisition direction
fov=240 #field of view


#===============================================================================
# For calculating xyz sizes for functional and structural (fse) reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
#===============================================================================
x=`expr ${nas} - 1`
y=`echo "scale=2; ${x} * ${thick}"| bc`
z=`echo "scale=2; ${y}/2"| bc`
halffov=`echo "scale=2; ${fov}/2"| bc`


#===============================================================================
# Spgr Preprocessing parameters
#===============================================================================
spgr=${subj}.spgr
nasspgr=164 #number of anatomical slices
thickspgr=1 #Z-slice thickness
z1spgr=L #Slice acquisition direction
fovspgr=256 #field of view for spgr


#===============================================================================
# For calculating xyz sizes for structural reconstruction in to3d
# Calculate the zslab value ((nas-1)* thick)/2), yFOV
# I had to include spgr variables because the tap study uses different parameters for that scan
#===============================================================================
xspgr=`expr ${nasspgr} - 1`
yspgr=`echo "scale=2; ${xspgr} * ${thickspgr}"| bc`
zspgr=`echo "scale=2; ${yspgr}/2"| bc`
anatfov=`echo "scale=2; ${fovspgr}/2"| bc`


#----------------------------------
#	   Top Level Directories
#----------------------------------
HOME_dir=${TAP}
ANAT_dir=${TAP}/Anatomical
BEHAV_dir=${TAP}/BEHAV
ICA_dir=${TAP}/ICA/${run[$j]}
FSL_dir=${TAP}/ICA/FSL/${run[$j]}
PCA_dir=${TAP}/ICA/PCA/${run[$j]}
GLM_dir=${TAP}/GLM
ANOVA_dir=${TAP}/ANOVA/${run[$j]}
    mask_dir=${TAP}/ANOVA/Masks


#----------------------------------
#	 Subject Level Directories
#----------------------------------
subj_dir=${TAP}/${subj}
orig_dir=${TAP}/${subj}/Orig
anat_dir=${TAP}/${subj}/Struc
prep_dir=${TAP}/${subj}/Prep
glm_dir=${TAP}/${subj}/GLM
test_dir=${TAP}/${subj}/Test

#===============================================================================
# These are item variables describing the Conditions and Model
#===============================================================================
mod=GAM

function condition_Dprime ()
{
	if [[ ${run[$j]} = SP1 ]]; then
		cond1=old.hits
		cond2=old.miss
	elif [[ ${run[$j]} = SP2 ]]; then
		cond1=af.Female.hits
		cond2=af.Female.miss
		cond3=af.Male.hits
		cond4=af.Male.miss
	elif [[ ${run[$j]} = TP1 ]]; then
		cond1=Animal.mf.hits
		cond2=Animal.mf.miss
		cond3=Food.mf.hits
		cond4=Food.mf.miss
	elif [[ ${run[$j]} = TP2 ]]; then
		cond1=af.Female.hits
		cond2=af.Female.miss
		cond3=af.Male.hits
		cond4=af.Male.miss
	fi

	cond1v2=${cond1}.vs.${cond2}
	cond2v1=${cond2}.vs.${cond1}
	cond3v4=${cond3}.vs.${cond4}
	cond4v3=${cond4}.vs.${cond3}

	conditions=( $cond1 $cond2 $cond3 $cond4 )	
	contrasts=( $cond1v2 $cond2v1 $cond3v4 $cond4v3 )
}


function condition_basic1 ()
{
	if [[ ${run[$j]} = SP1 ]]; then
		cond1=animal
		cond2=food
	elif [[ ${run[$j]} = SP2 ]]; then
		cond1=female
		cond2=male
	elif [[ ${run[$j]} = TP1 ]]; then
		cond1=old
		cond2=new
	else
		cond1=female
		cond2=male
	fi
	
	cond1v2=${cond1}.vs.${cond2}
	cond2v1=${cond2}.vs.${cond1}
	
	conditions=( $cond1 $cond2 )
	contrasts=( $cond1v2 $cond2v1 )
}

function condition_basic ()
{
	if [[ ${run[$j]} = SP1 ]]; then
		cond=( animal food )
	elif [[ ${run[$j]} = SP2 ]]; then
		cond=( female male )
	elif [[ ${run[$j]} = TP1 ]]; then
		cond=( old new )
	else
		cond=( female male )
	fi

	contr[0]=${cond[0]}.vs.${cond[1]} 
	contr[1]=${cond[1]}.vs.${cond[0]}
	contr[2]=${cond[2]}.vs.${cond[3]} 
	contr[3]=${cond[3]}.vs.${cond[2]}
}



#===============================================================================
# Names for files. Naming hierachy should follow this pattern: subj, run, mod, cond, brik
# Indentation is for readability
#===============================================================================
subrun=${subj[$i]}.${run[$j]}
submod=${subrun}.${mod}
subcond=${subrun}.${mod}.${cond[$k]}
subcontr=${subrun}.${mod}.${contr[$l]}

subcond1=${subrun}.${mod}.${cond1}
subcond2=${subrun}.${mod}.${cond2}
subcond3=${subrun}.${mod}.${cond3}
subcond4=${subrun}.${mod}.${cond4}

runmod=${run[$j]}.${mod}
runmean=${run[$j]}.${mod}.mean
runcontr=${run[$j]}.${mod}.contr
runcond1=${run[$j]}.${mod}.${cond1}
runcond2=${run[$j]}.${mod}.${cond2}
runcond3=${run[$j]}.${mod}.${cond3}
runcond4=${run[$j]}.${mod}.${cond4}
#===============================================================================
# ANOVA and Group-specific variables
#===============================================================================

	plvl=05; thr=2.160

