#!/bin/sh

: <<COMMENTBLOCK

###############################################################################
AUTHOR:			Kyle Almryde University of Arizona 
DATE CREATED:	02/21/2012
----------------------------  DEPENDENCIES	-----------------------------------
The script is dependent on 'profiles' found in /usr/local/tools/REF/PROFILES.
(e.g., img_profile.sh, subject_profile.sh and project specific profiles). The
profiles define variable names. All project specific profiles source the
subject_profile.sh which sources img_profile.sh

Run this from the Subject's main directory.
===============================================================================
----------------------------  PURPOSE  ----------------------------------------
-Find best volume in a run (the volume with the smallest outlier value). 
-Produce 3dDespiked version of the run. 
-Do volume realignment to the "best volume".
-Store txt files, graphs and misc files in RunX/RealignDetails 
-log_realign.txt: Compare min, max, mean and sd of original, despiked, 
volume_registered and despiked_volume_registered images.

===============================================================================
----------------------------  INPUT	 ------------------------------------------
Must be run in a directory with a 4d volume named runX_subXXX.nii.gz

===============================================================================
----------------------------  OUTPUT  -----------------------------------------
-A directory RunX/RealignDetails to hold graphs and text files.
-log_realign.txt to compare min, max, mean and sd of 4d volumes that have been 
	processed differently
-volume_registered and despiked_volume_registered nii.gz images.
===============================================================================
----------------------------  OPTIONS  ----------------------------------------
-With no arguments, this script will run Main which creates all of the files 
and directories for each run.
-With an argument you can run any function: Main, CleanUp or LogAll are the 
primary choices, but BestVol, CheckDone, LogStats, MkRealignLog, Spike or 
VReg are other alternatives (each of these is documented in the script)
-The argument Main is no different than running with no arguments 
(Main is the default). 
-CleanUp will remove all the directories and files that Main created. 
-LogAll creates log_realign.txt without redoing all the dataset maniupulation.
###############################################################################

COMMENTBLOCK

#==============================================================================

source plante_profile.sh                        # Define paths and variables

###############################################################################
########################## DEFINE FUNCTIONS ###################################
: <<COMMENTBLOCK

Function:   BestVol
Purpose:    Find best volume (smallest outlier value) for base realignment 
            volume. By default, this uses the whole image (brain and nonbrain)
            when it looks for outliers
Input:      4d functional of the form runX_subXXX.nii.gz 
Output:     the base realignment volume: runX_subXXX_basevolreg_##.nii.gz, 
            a txt file containing the volume #: runX_subXXX.outliers.txt
             
COMMENTBLOCK

function BestVol                                # Find best registration volume. 
{
                                                # Generate outlier txt file
    3dToutcount ${runsub}.nii.gz \
    > ${RD}/${runsub}.outliers.txt              # Higher numbers are outliers. 
                    
    
    1dplot -jpeg ${RD}/${runsub}.outliers \
    ${RD}/${runsub}.outliers.txt                # Graph the outliers
    
    # Sort outlier file, extract corresponding NUMBER LINE. 
    # Pass NUMBER LINE to AWK.
    # Subtract 1 to account because AFNI numbers volumes from 0 
    
    base_reg_num=`cat -n ${RD}/${runsub}.outliers.txt | sort -k2,2n | head -1 | awk '{print $1-1}'`
    
    echo "${base_reg_num}" \
    > ${RD}/${runsub}_base_volume.volreg.txt    # Echo best volume > txt file
                                                # Extract base volume for realignment       
    3dbucket \
        -prefix ${FUNC}/${runsub}_basevolreg_${base_reg_num}.nii.gz \
        -fbuc ${runsub}.nii.gz[${base_reg_num}] # Create best volume in Func
}   


#==============================================================================
: <<COMMENTBLOCK

Function:   CheckDone
Purpose:    Determine whether prepf2.sh has already been Run.  Runs it if not, else skips it
Input:      Looks for RealignDetails in each RunX  
Output:     None.  

COMMENTBLOCK
              
function CheckDone
{
     if [ ! -d RealignDetails ]; then            # If RealignDetails exists, we are done. 
             mkdir RealignDetails
         else                                    # Else mkdir RealignDetails, define variable            
             echo "RealignDetails exists" 
             echo "Moving to different run"
             continue     
     fi    
}
 
#==============================================================================
: <<COMMENTBLOCK

Function:   CleanAll
Purpose:    Remove files generated by prepf2.  Don't ask.

COMMENTBLOCK
              
function CleanAll
{
	# Call RmIf to remove dirs and files if they exist
	echo "Removing files and dirs created by prepf2.sh"
    RmIf *volreg* RealignDetails ${FUNC}/log_realign.txt ${FUNC}/run${num}_*volreg*
}
 
#==============================================================================
: <<COMMENTBLOCK

Function:   Clean
Purpose:    Remove files generated by prepf2.  Ask for each Run.

COMMENTBLOCK
              
function Clean
{
    echo "Are you sure you want to remove the results of prepf2.sh?"
    echo "yes or no"
    read answer
    if [ "$answer" = "no" ]; then
        echo "exiting without deleting"
        continue
    fi
	# Call RmIf to remove dirs and files if they exist
    RmIf *volreg* RealignDetails ${FUNC}/log_realign.txt ${FUNC}/run${num}_*volreg*
}

#==============================================================================
: <<COMMENTBLOCK

Function:   HelpMessage
Purpose:    Print relevant help message

COMMENTBLOCK
              
function HelpMessage 
{
    echo "prepf2.sh Main creates despiked and registered data and a stats log." 
    echo "prepf2.sh Clean politely asks & removes files created by prepf2.sh."
    echo "prepf2.sh CleanAll removes files created by prepf2.sh with no questions." 
    echo "prepf2.sh LogAll runs just the logging."
    echo "================================ "
    exit 1
}

#==============================================================================
: <<COMMENTBLOCK

Function:   LogAll
Purpose:    Run the relevant log functions
Input:      Any dataset we want stats from 
Output:     realign_log.txt

COMMENTBLOCK
              
function LogAll
{
    MkRealignLog                                # Create log file
    echo "Running stats. Be patient."
    LogStats ${runsub}                          # Stats on original dataset
    LogStats ${RD}/${runsub}_tshift             # Stats for tshifted dataset
    LogStats ${RD}/${runsub}_tshift_volreg      # Stats for realigned dataset
    LogStats ${RD}/${runsub}_tshift_volreg_despike    # Stats for realigned despiked dataset 
    LogStats ${RD}/${runsub}_tshift_volreg_despike_7mm    # Stats for smoothed dataset   
    LogStats ${runsub}_tshift_volreg_despike_7mm_164tr    # Stats for trimmed dataset  
}
    
#==============================================================================
: <<COMMENTBLOCK

Function:   LogStats
Purpose:    Add statistics to Func/log_realign.txt
            for each requested dataset
Input:      dataset
Output:     Func/log_realign.txt entries

COMMENTBLOCK

function LogStats
{
    input4d=$1                                  # Pass in dataset to log
    input4d_stem=`basename -s .nii.gz ${input4d}`   
                                                # Get -r robust_min & max; 
                                                # -m mean; -s sd    
    for image in ${input4d}; do                         
        realign_stats=`fslstats ${image} -r -m -s`  
        echo ${input4d_stem} \
        ${realign_stats} >> \
        ${FUNC}/log_realign.txt                 # Put the values in log_realign.txt
    done
}
        
#==============================================================================
: <<COMMENTBLOCK

Function:   MkRealignLog
Purpose:    If the log file does not exist,
            create it and put in the header row
Input:      none 
Output:     Func/log_realign.txt

COMMENTBLOCK
                          
function MkRealignLog
{
    if [ ! -e ${FUNC}/log_realign.txt ]; then 
        touch ${FUNC}/log_realign.txt
        echo "image robust_min robust_max mean sd" \
        >> ${FUNC}/log_realign.txt
    fi
}

#==============================================================================
: <<COMMENTBLOCK

Function:   Reorient
Purpose:    Make sure all images are displayed in the correct orientation in FSL,
            because afni seems to loose orientation info FSL wants in the nifti header.
            In theory, this doesn't hurt to run on images that are already correct,
            however, I have now seen some file corruptions that may result from this.
            I have taken it out of the main processing line.
Input:      *.nii.gz images 
Output:     same names, correctly oriented 

COMMENTBLOCK
              
function Reorient
{

echo "reorienting ${runsub}" 
fslreorient2std ${runsub} ${runsub} 
echo "reorienting ${RD}/${runsub}_tshift"              
fslreorient2std ${RD}/${runsub}_tshift ${RD}/${runsub}_tshift  
echo "reorienting ${RD}/${runsub}_tshift_volreg"
fslreorient2std ${RD}/${runsub}_tshift_volreg ${RD}/${runsub}_tshift_volreg 
echo "reorienting ${RD}/${runsub}_tshift_volreg_despike"
fslreorient2std ${RD}/${runsub}_tshift_volreg_despike ${RD}/${runsub}_tshift_volreg_despike 
echo "reorienting ${RD}/${runsub}_tshift_volreg_despike_7mm"
fslreorient2std ${RD}/${runsub}_tshift_volreg_despike_7mm ${RD}/${runsub}_tshift_volreg_despike_7mm   
echo

}

#==============================================================================
: <<COMMENTBLOCK

Function:   Smooth
Purpose:    smooth to 7mm
Input:      tshift_volreg_despike data
Output:     tshift_volreg_despike_7mm

COMMENTBLOCK
              
function Smooth
{
    input4d=$1                                  # Pass in 4d file to despike
    input4d_stem=`basename -s .nii.gz ${input4d}` 
    3dmerge \
			-1blur_fwhm 7.0 \
			-doall \
			-prefix ${RD}/${input4d_stem}_7mm.nii.gz \
			${RD}/${input4d_stem}.nii.gz 

}
    
#==============================================================================
: <<COMMENTBLOCK

Function:   Spike
Purpose:    Remove spikes from the data by fitting a smoothish curve to the data.
            -nomask prevents automasking during despiking. We will use a different
            mask later on (generated from the skull stripped T1), so we don't 
            want to automask now. Despiking may negatively affect volreg, and so 
            should be done after volreg.
Input:      runX_subXXX.nii.gz
Output:     runX_subXXX_despike.nii.gz
            runX_subXXX_spikes.nii.gz
            runX_subXXX_despike_outs.txt
            runX_subXXX_despike_outs.jpeg

COMMENTBLOCK
              
function Spike
{
    input4d=$1                                  # Pass in 4d file to despike
    input4d_stem=`basename -s .nii.gz ${input4d}` 
    3dDespike -nomask \
        -prefix ${RD}/${input4d_stem}_despike.nii.gz \
        -ssave ${RD}/${input4d_stem}_spikes.nii.gz \
        -q ${input4d} 
    
    3dToutcount \
        ${RD}/${input4d_stem}_despike.nii.gz \
        > ${RD}/${input4d_stem}_despike_outs.txt
    
    1dplot -jpeg ${RD}/${input4d_stem}_despike_outs \
        ${RD}/${input4d_stem}_despike_outs.txt
}

#==============================================================================
: <<COMMENTBLOCK

Function:   SliceTiming
Purpose:    Run 3dTshift to temporally align the slices in each volume to the 
            middle slice using seplus.  Uses Fourier interpolation by default.
Input:      input image before volreg 
Output:     image ready to run volreg

COMMENTBLOCK
              
function SliceTiming
{
    input4d=$1                                  # Pass in 4d file to despike
    input4d_stem=`basename -s .nii.gz ${input4d}`
    3dTshift -tpattern seqplus -prefix \
    ${RD}/${input4d_stem}_tshift.nii.gz ${input4d}
}
#==============================================================================
: <<COMMENTBLOCK

Function:   VolTrim
Purpose:    Remove the intial 4 volumes from the image
Input:      smoothed image (*7mm)
Output:     7mm_164tr.nii

COMMENTBLOCK
              
function VolTrim
{
    input4d=$1                                          # Pass in 4d file to trim
    input4d_stem=`basename -s .nii.gz ${input4d}`
    fslroi ${input4d} ${input4d_stem}_164tr 4 -1    # Trim off first 4 volumes
    gunzip ${input4d_stem}_164tr.nii.gz
}
    
#==============================================================================
: <<COMMENTBLOCK
                 
Function:   VReg
                
Purpose:    3dvolreg motion-corrects 4d functional datasets. "-base" sets
            the volume to realign the functional run to. The function "BestVol" 
            (above) creates base_reg_num to fill in the volume number.
            -Fourier tells the program to use the best (but slowest) interpolation.
            After despiking this will result in the best possible reduction in 
            the robust range.

  Input:    A dataset to be realigned

 Output:    -The realigned dataset: *_volreg.nii.gz 
            -txt file of motion parameters: *_dfile.1D  
            columns are: roll pitch yaw dS  dL  dP
            -*_mm.1D maximum displacement of each subbrick
            based on noninterior voxels. 
            -graph of realignment: *_volreg.jpeg
            *_volreg_outs.txt
           
COMMENTBLOCK

function VReg 
{
    input4d=$1 
    input4d_stem=`basename -s .nii.gz ${input4d}`
    3dvolreg -zpad 4 \
        -base ${input4d}[${base_reg_num}] \
        -1Dfile ${RD}/${input4d_stem}_dfile.1D \
        -maxdisp1D  ${RD}/${input4d_stem}_mm.1D \
        -prefix ${RD}/${input4d_stem}_volreg.nii.gz \
        -Fourier ${input4d}                     # Read input dataset
    
                                                # Generate outlier file for new dataset
    3dToutcount \
    ${RD}/${input4d_stem}_volreg.nii.gz > \
    ${RD}/${input4d_stem}_volreg_outs.txt
                                                # Generate graph of realignment
    1dplot -jpeg \
    ${RD}/${input4d_stem}_volreg \
    -volreg -xlabel TIME ${RD}/${input4d_stem}_dfile.1D
                                                # Generate another useful jpeg
    1dplot -jpeg \
    ${RD}/${input4d_stem}_volreg_outs \
    ${RD}/${input4d_stem}_volreg_outs.txt
}       
#==============================================================================
: <<COMMENTBLOCK

Function:   Main
Purpose:    Run all the functions that do realignment, despiking and logging
Input:      runX_subXXX.nii.gz 
Output:     *.nii.gz, txt and jpg files

COMMENTBLOCK
              
function Main
{

    # Call functions #
    CheckDone                                                 # If RealignDetails exists, move on
    BestVol                                                   # Find the best base volume for realignment
    SliceTiming ${runsub}.nii.gz                              # Run afni slice timing
    VReg ${RD}/${runsub}_tshift.nii.gz                        # Realign tshifted dataset
    Spike ${RD}/${runsub}_tshift_volreg.nii.gz                # Then despike it
    Smooth ${RD}/${runsub}_tshift_volreg_despike.nii.gz       # Then smooth it to 7mm, and move it up a level
    VolTrim ${RD}/${runsub}_tshift_volreg_despike_7mm.nii.gz  #Remove first 4 volumes
    LogAll                                                    # Create and populate realign_log.txt
    
}
    
############################  END FUNCTION DEFINITIONS  #######################
###############################################################################


while getopts h options 2> /dev/null; do        # Setup -h flag. redirect errors
    case $options in                                # In case someone invokes -h 
        h) HelpMessage;;                                # Run the help message function
       \?) echo "only h is a valid flag" 1>&2;;          # If bad options are passed, print message
    esac
done

shift $(( $OPTIND -1))                          # Index option count, so they aren't treated as args
optnum=$(( $OPTIND -1))                         # optnums hold # of options passed in

for num in 1 2 3; do                            # For each Run 1 2 3 
	echo "    "
	echo "==================="
    echo "Run${num}"
    Run=Run${num}                               # Define the Run directory as a variable    
    runsub=run${num}_${SUBJECT}                 # Define 4d dataset as a variable
    RD=RealignDetails                           # Define RealignDetails directory as a variable     
    
    cd ${FUNC}/${Run}                           # cd into the Run directory

    if [ ${optnum} -lt 1 -a $# -lt 1 ]          # If no options or args
        then
            dothis=Main                        # Default to running Main 
        else
            dothis=$1                           # Run CleanUp, LogAll or any other function as indicated
    fi
    
    $dothis                                     # Main OR Cleanup Or LogAll
    
    cd ${SUBJECTDIR}                            # cd up for the next run
done        

MyLog                                           # Log that this script has been run

