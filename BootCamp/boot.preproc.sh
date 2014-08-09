#!/bin/bash
#================================================================================
#    Program Name: boot.preproc.sh
#          Author: YOUR NAME HERE
#            Date: 07/29/2014
#     Description: This program will perform the necessary preprocessing steps
#                  on the Bootcamp data using pure AFNI commands. This script
#                  will also introduce the basics shell scripting, which is
#                  crucial to learn in order to be effective users of AFNI.
#
#    Deficiencies: This program's primary purpose is to teach the author about
#                  using AFNI. Though the preprocessing steps being performed
#                  match those that are currently employed in the preprocessing
#                  pipeline used for the Actual Russian data, they may not be
#                  the best ways to perform that step.
#
#            What: Plante Lab AFNI WorkShop 07/2014
#             Who: Workshop presented by Kyle R. Almryde (The last hurrah!)
#             Why: Because Kyle is leaving and you need to learn his mad skilz
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


function SetupDirs () {
    #------------------------------------------------------------------------
    #
    #   Description: SetupDirs
    #
    #       Purpose: This function sets up the directory structure for the
    #                GLM analysis.
    #
    #         Input: None
    #
    #        Output: Output consists of a directory tree in the following format.
    #                   sub0##/
    #                       Run1/
    #                           1D/
    #                           Images/
    #                           Fitts/
    #                           Stats/
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------
    echo -e "Setting up Subject Data Analysis structure\n"
    mkdir -p ${BASE}/${sub}/${RUN}/{Prep,Glm/{1D,Images,Stats,Mask,Fitts,Errts}}
}


function base_reg ()
{
    #------------------------------------------------------------------------
    #
    #       Purpose:   This function reads an outlier file looking for a
    #                  pattern consisting of a single digit between 1 and 9
    #                  or a two digit number no greater than 19 and prints
    #                  the NUMBER line with which that value falls. That value
    #                  is then subtracted by 1 to account for AFNI's
    #                  zero-based counting preference. This allows us to acquire
    #                  a base volume to register our data with using 3dVolreg.
    #                  The line number is representative of the volume in the
    #                  dataset, and following the subtraction, fits AFNI's
    #                  conventions.
    #
    #         Input:   A list containing the outlier count for each volume of
    #                  a functional run
    #
    #        Output:   A single integer value representing the most stable
    #                  volume in the dataset, which will act as the base
    #                  volume during registration.
    #------------------------------------------------------------------------

    input1D=$1
    cat -n ${PREP}/${input1D}.txt | sort -k2,2n | head -1 | awk '{print $1-1}'
}


function BestVol
{                                              # Find best registration volume.
    #------------------------------------------------------------------------
    #
    #  Purpose:    Find best volume (smallest outlier value) for base realignment
    #              volume. By default, this uses the whole image (brain and nonbrain)
    #              when it looks for outliers
    #
    #    Input:    4d functional of the form runX_subXXX.nii.gz
    #
    #   Output:    The base realignment volume#
    #
    #------------------------------------------------------------------------
    echo -e "\n Searching for Best Volume!\n"
    input4d=$1                                                  # Generate outlier txt file
    3dToutcount ${PREP}/${input4d}.nii.gz > ${PREP}/${input4d}.outliers.txt     # Higher numbers are outliers.
    1dplot -jpeg ${PREP}/${input4d}.outliers ${PREP}/${input4d}.outliers.txt    # Graph the outliers

    # Sort outlier file, extract corresponding NUMBER LINE.
    # Pass NUMBER LINE to AWK.
    # Subtract 1 to account because AFNI numbers volumes from 0

    base_reg_num=$( base_reg ${input4d}.outliers )

    echo "${base_reg_num}" > ${PREP}/${input4d}_base_volume.volreg.txt    # Echo best volume > txt file
                                                                  # Extract base volume for realignment
    3dbucket \
        -prefix ${PREP}/${input4d}_basevolreg_${base_reg_num}.nii.gz \
        -fbuc ${PREP}/${input4d}.nii.gz"[${base_reg_num}]"   # Create best volume in Func

    echo
}


function VReg
{
    #########################################################################
    #       Command:   VReg
    #
    #       Purpose:   This program will perform the motion-correction and
    #                  volume registration of the functional data.
    #
    #                  The "-verbose -verbose" options provide copious amounts
    #                  of detail regarding what is being done to the data.
    #                  These options in and of themselves do not affect the
    #                  output in anyway other than to show you exactly what
    #                  is happening. The log file log.reg.nwy.txt contains
    #                  all of this information.
    #
    #                  The "-zpad 4" option Zeropads 4 voxels around the
    #                  edges of the image during rotation in order to assist
    #                  in the volume registration procedure. These edge values
    #                  are stripped off in the output.
    #
    #                  The "-base" option sets the base dataset and volume to
    #                  which the image is registered to. See the description
    #                  for the function "base_reg" for details on its selection
    #                  process. I chose to align the image to the initial
    #                  dataset run1_sub001.nii.gz because that represents the
    #                  data in its purest and least interpolated state. The
    #                  assumption being that as we process the data, we may
    #                  be subject to an interpolation error, which could give
    #                  us an inaccurate assumption about the state of that
    #                  volume.
    #
    #                  The "-1Dfile" outputs a 1D file containing the results
    #                  of the volume registration. This file produces the
    #                  Volume Registered graph, detailing graphically what
    #                  was done for each rotation and displacement.
    #
    #                  The -Fourier tells the program to use the best (but slowest)
    #                  interpolation. After despiking this will result in the best
    #                  possible reduction in the robust range.
    #
    #
    #         Input:   run1_sub001.nii.gz
    #                  run1_sub001.nii.gz
    #
    #        Output:   run1_sub001_volreg.nii
    #                  run1_sub001_volreg_dfile.1D
    #                  run1_sub001_volreg.jpeg
    #                  run1_sub001_volreg_outs.txt
    #
    #########################################################################
    echo -e "\n Starting Volume Registration and Motion Correction!\n"

    input4d=$1
    base_reg_num=$( base_reg ${input4d}.outliers )

    3dvolreg -zpad 4 \
        -base ${base_reg_num} \
        -1Dfile ${PREP}/${input4d}_volreg_dfile.1D \
        -maxdisp1D ${PREP}/${input4d}_mm.1D \
        -1Dmatrix_save ${PREP}/${input4d}_mat_aff12.1D                     \
        -prefix ${PREP}/${input4d}_volreg.nii.gz \
        -Fourier ${PREP}/${input4d}.nii.gz          # Read input dataset

    # Generate outlier file for new dataset
    3dToutcount \
    ${PREP}/${input4d}_volreg.nii.gz > ${PREP}/${input4d}_volreg_outs.txt

    # Generate graph of realignment
    1dplot \
        -jpeg ${PREP}/${input4d}_volreg \
        -volreg -xlabel TIME ${PREP}/${input4d}_volreg_dfile.1D

    # Generate another useful jpeg
    1dplot \
        -jpeg ${PREP}/${input4d}_volreg_outs \
        ${PREP}/${input4d}_volreg_outs.txt
}



function Spike
{
    #########################################################################
    #       Command:   3dDespike
    #
    #       Purpose:   This program removes spikes from the data and replaces
    #                  those spike values with something more pleasing to the
    #                  eye. Remove spikes from the data by fitting a smoothish
    #                  curve to the data. The -nomask option prevents automasking
    #                  during despiking. We will use a different mask later on
    #                  (generated from the skull stripped T1), so we don't
    #                  want to automask now.
    #
    #                  It is acknowleged in the Despike documentation that
    #                  this method may interfere with volume registration,
    #                  as some spikes may be related to head-motion. This is
    #                  why I choose not to select a base volume from the
    #                  Despiked data and instead choose the initial volume.
    #                  See further discussion in the 3dvolreg commentary. In
    #                  addition to the Despiked dataset, it also produces a
    #                  "spikes" dataset, which saves the spikiness measure
    #                  for each voxel. This information is saved for
    #                  diagnostic purposes, but otherwise has no influence
    #                  on later processing.
    #
    #         Input:   run1_sub001.nii.gz
    #
    #        Output:   run1_sub001_volreg_despike.nii
    #                  run1_sub001_volreg_spikes.nii
    #                  run1_sub001_volreg_despike_outs.txt
    #                  run1_sub001_volreg_despike_outs.jpeg
    #
    #########################################################################
    echo -e "\nDespiking post motion-corrected dataset!\n"
    input4d=$1                                  # Pass in 4d file to despike
    3dDespike -nomask \
        -prefix ${PREP}/${input4d}_despike.nii.gz \
        -ssave ${PREP}/${input4d}_spikes.nii.gz \
        -q ${PREP}/${input4d}.nii.gz

    3dToutcount \
        ${PREP}/${input4d}_despike.nii.gz > ${PREP}/${input4d}_despike_outs.txt

    1dplot -jpeg ${PREP}/${input4d}_despike_outs ${PREP}/${input4d}_despike_outs.txt
}


function Smooth
{
    #########################################################################
    #
    #       Purpose:   Apply a 5.0mm gaussian smoothing kernel. A 6mm
    #                  smoothing kernel was chosen in part because it was
    #                  larger than the z-voxel, and commonly cited in the
    #                  literature as an acceptable smoothing size.
    #
    #         Input:   run1_sub001_volreg_despike, 5.0
    #
    #        Output:   run1_sub001_blur.nii
    #
    #########################################################################
    echo -e "\n Smoothing image with ${2}mm filter!\n"
    input4d=$1                                  # Pass in 4d file to smooth
    blur=$2                                     # Pass in smoothing kernel size
    echo "blur is $2"
    3dmerge \
      -1blur_fwhm ${blur} \
      -doall \
      -prefix ${PREP}/${input4d}_${blur}mm.nii.gz \
      ${PREP}/${input4d}.nii.gz

}


function VolTrim
{
    #########################################################################
    #
    #       Purpose:   Remove the first 4 volumes
    #
    #         Input:   run1_sub001_volreg_despike_5mm, 4
    #
    #########################################################################
    echo -e "\nRemoving first $2 volumes from dataset!\n"
    input4d=$1
    trunc=$2

    if [[ $trunc -eq "" ]]; then
        trunc=6
    fi
    outnum=$(echo "scale=1; 182 - ${trunc}"| bc)
    3dTcat \
        -verb \
        -prefix ${PREP}/${input4d}_${outnum}tr.nii.gz \
        ${PREP}/${input4d}.nii.gz"[${trunc}..$]"
}


function RegressMotion ()
{
    #------------------------------------------------------------------------
    #
    #   Description: RegressMotion
    #
    #       Purpose: The purpose of this function is to  compute the de-meaned
    #                motion parameters and their derivatives for use within the
    #                regression analysis.
    #
    #         Input: run#_sub0##_dfile.1D
    #
    #                This file resides in the RealignDetails sub-directory of the
    #                Data/Archive/Iceword_RealignDetails subject directory.
    #
    #        Output: motion.run#_sub0##_demean.1D, motion.run#_sub0##_demean.jpeg
    #                motion.run#_sub0##_deriv.1D, motion.run#_sub0##_deriv.jpeg
    #
    #                This function produces 4 files, two 1D files containing the
    #                de-meaned motion parameters, motion parameters derivatives,
    #                and their respective graphical plots.
    #                Files are output to the GLM sub-directory of
    #                Analysis/WordBoundary1 subject directory.
    #
    #     Variables: input1D
    #
    #                This variable contains the input arguments. It makes the
    #                script a little more readable
    #
    #          NOTE: the "-select_rows {4..$}" option is effectively trimming
    #                the first 4 volumes from the file. This is OK because our
    #                images have had the those runs removed as well.
    #------------------------------------------------------------------------
    echo -e "\nRegressMotion has been called\n"

    input1D=${1}
    output1D=${input1D}

    # compute de-meaned motion parameters (for use in regression)
    1d_tool.py \
        -infile ${PREP}/${input1D}_volreg_dfile.1D \
        -select_rows {6..$}  -set_nruns 1 \
        -demean -write ${ID}/motion.${output1D}_demean.1D


    # compute motion parameter derivatives (for use in regression)
    1d_tool.py \
        -infile ${PREP}/${input1D}_volreg_dfile.1D \
        -select_rows {6..$}  -set_nruns 1 \
        -derivative -demean \
        -write ${ID}/motion.${output1D}_deriv.1D


    # Plot the de-meaned motion parameters
    1dplot \
        -jpeg ${IMAGES}/motion.${output1D}_demean \
        ${ID}/motion.${output1D}_demean.1D

    # Plot the motion parameter derivatives
    1dplot \
        -jpeg ${IMAGES}/motion.${output1D}_deriv \
        ${ID}/motion.${output1D}_deriv.1D

}


function DeConvolve ()
{
    #------------------------------------------------------------------------
    #
    #   Description: DeConvolve
    #
    #       Purpose: The purpose of this function is to compute a General
    #                Linear Model of neural activity related to language processing.
    #                Using AFNI's 3dDeconvolve neural recordings are deconvolved
    #                using predefined stimulus onsets coupled with demeaned motion
    #                parameters and their derivatives in order model implicit
    #                language acquisition.
    #
    #                Because the scanner was initiated manually via countdown
    #                and not through an automated execution signal, there is
    #                concern that stimulus timing may be off anywhere from 1
    #                to 7 seconds. In order to control for this, this deconvolution
    #                iterates 8 times, delaying the onset of the HRF by one
    #                second (starting at 0 seconds).
    #
    #                The last step will be to visualize the regression
    #                coefficients of the computed General Linear Model performed
    #                by AFNI's 3dDeconvolve.
    #
    #         Input: run#_sub0##_tshift_volreg_despike_mni_7mm_214tr.nii.gz
    #                run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_fullmask.nii.gz
    #                censor.cue_stim.1D
    #                stim.tone_block.1D
    #                stim.sent_block.1D
    #                motion.run#_sub0##_demean.1D
    #                motion.run#_sub0##_deriv.1D
    #
    #                This program takes as input several pieces of information.
    #                The first being a 4 dimensional fMRI dataset which has
    #                undergone preprocessing steps to correct for head motion,
    #                time displacement, noise correction, as well as warping to
    #                a standard template (in this instance, MNI)
    #
    #                Additionally, 5 time files are provided;
    #                The first being the censor file, which consists of timepoints
    #                related to the cue periods (18 in all) that should not be
    #                included in the analysis.
    #                The next two time files are the actual times (in seconds)
    #                the stimulus blocks occurred in the analysis, one for Tone
    #                and one for sentences respectively.
    #                The last two time files are the demeaned motion parameters
    #                and the motion derivatives respectively. These files are used
    #                as regressors in the model to account for any possible motion
    #                artifacts within the data.
    #
    #        Output: run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.xmat
    #                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.jpeg
    #                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.fitts.nii.gz
    #                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.errts.nii.gz
    #                run#_sub0##_tshift_volreg_despike_7mm_164tr_#sec_learnable.stats.nii.gz
    #
    #                run#_sub0##_#sec_sent_block_learnable.tone_block.1D
    #                run#_sub0##_#sec_sent_block_learnable.sent_block.1D
    #                run#_sub0##_#sec_sent_block_learnable.Regressors-All.jpeg
    #                run#_sub0##_#sec_sent_block_learnable.Regressors-Stim.jpeg
    #
    #       Details: Polort is automatically determined by the 3dDeconvolve too
    #                An Automask is generated automatically for use in the analysis
    #                Local times are used since they are local to the individual runs
    #                There are 14 stimulus time inputs, those include the two stimulus
    #                onset times (sent_block, tone_block), and the motion regressors
    #                provided by the files motion.run#_sub0##_demean.1D and
    #                motion.run#_sub0##_deriv.1D, each of which contains a column
    #                representing Roll, Pitch, Yaw, dS, dL, and dP.
    #                In order to take advantage of modern computing power and speed
    #                up the analysis, the option -jobs 4 enables the program to utilize
    #                4 processor cores. The program also produces a file with the
    #                error residuals and a fitts file which can be used to test how well
    #                the model fits with the actual data.
    #                The final bucket file contains the Full Fstat Beta weights,
    #                and T-statistic.
    #
    #     Variables: delay, input4d, output4d, model, input1D
    #
    #------------------------------------------------------------------------

    echo -e "\nDeConvolve has been called\n"  # This is will display a message in the terminal which will help to keep
                                                    # track of what function is being run.

    #-------------------------------------------------#
    #  Defining some variables before we get started  #
    #-------------------------------------------------#
    delay=$1
    input4d=$2                                          # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr
    model="WAV(18.0,${delay},4,6,0.2,2)"                # <= The modified Cox Special, values are in seconds
                                                        #    WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
    output4d=${input4d}_${delay}sec_${condition}        # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_#sec_##learnable

    input1D=( cue_stim.1D    tone_block.1D    sent_block.1D \
              "${runsub}_demean.1D[0]" "${runsub}_demean.1D[1]" \
              "${runsub}_demean.1D[2]" "${runsub}_demean.1D[3]" \
              "${runsub}_demean.1D[4]" "${runsub}_demean.1D[5]" \
              "${runsub}_deriv.1D[0]"  "${runsub}_deriv.1D[1]" \
              "${runsub}_deriv.1D[2]"  "${runsub}_deriv.1D[3]" \
              "${runsub}_deriv.1D[4]"  "${runsub}_deriv.1D[5]" )

    #-------------------------------------------------#
    #         On to the real processing, woo!         #
    #-------------------------------------------------#
    3dDeconvolve \
        -input ${PREP}/${input4d}.nii.gz \
        -polort A \
        -automask \
        -local_times \
        -num_stimts 14 \
                -censor ${STIM}/censor.${input1D[0]} \
        -stim_times 1 ${STIM}/stim.${input1D[1]} "${model}" \
                    -stim_label 1 Tone \
        -stim_times 2 ${STIM}/stim.${input1D[2]} "${model}" \
                    -stim_label 2 Sent \
        -stim_file 3 ${ID}/motion.${input1D[3]} \
                    -stim_base 3 \
                    -stim_label 3 roll_demean    \
        -stim_file 4 ${ID}/motion.${input1D[4]} \
                    -stim_base 4 \
                    -stim_label 4 pitch_demean  \
        -stim_file 5 ${ID}/motion.${input1D[5]} \
                    -stim_base 5 \
                    -stim_label 5 yaw_demean     \
        -stim_file 6 ${ID}/motion.${input1D[6]} \
                    -stim_base 6 \
                    -stim_label 6 dS_demean      \
        -stim_file 7 ${ID}/motion.${input1D[7]} \
                    -stim_base 7 \
                    -stim_label 7 dL_demean      \
        -stim_file 8 ${ID}/motion.${input1D[8]} \
                    -stim_base 8 \
                    -stim_label 8 dP_demean      \
        -stim_file 9 ${ID}/motion.${input1D[9]} \
                    -stim_base 9 \
                    -stim_label 9 roll_deriv     \
        -stim_file 10 ${ID}/motion.${input1D[10]} \
                    -stim_base 10 \
                    -stim_label 10 pitch_deriv \
        -stim_file 11 ${ID}/motion.${input1D[11]} \
                    -stim_base 11 \
                    -stim_label 11 yaw_deriv   \
        -stim_file 12 ${ID}/motion.${input1D[12]} \
                    -stim_base 12 \
                    -stim_label 12 dS_deriv    \
        -stim_file 13 ${ID}/motion.${input1D[13]} \
                    -stim_base 13 \
                    -stim_label 13 dL_deriv    \
        -stim_file 14 ${ID}/motion.${input1D[14]} \
                    -stim_base 14 \
                    -stim_label 14 dP_deriv    \
        -xout \
            -x1D ${ID}/${output4d}.xmat.1D \
            -xjpeg ${IMAGES}/${output4d}.xmat.jpg \
        -jobs 12 \
        -fout -tout \
        -errts ${ERRTS}/${output4d}.errts.nii.gz \
        -fitts ${FITTS}/${output4d}.fitts.nii.gz \
        -bucket ${STATS}/${output4d}.stats.nii.gz

    3dTcat \
        -prefix ${FITTS}/${output4d}.fitts_144tr.nii.gz \
        ${FITTS}/${output4d}.fitts.nii.gz"[2-10,13-21,24-32,35-43,46-54,57-65,68-76,79-87,90-98,101-109,112-120,123-131,134-142,145-153,156-164,167-175]"

    echo -e "\nPlotting GLM inputsand outputs!\n"

    1dcat \
        ${ID}/${output4d}.xmat.1D'[4]' \
        > ${FITTS}/ideal.${output4d}.tone_block.1D

    1dcat \
        ${ID}/${output4d}.xmat.1D'[5]' \
        > ${FITTS}/ideal.${output4d}.sent_block.1D

    1dplot \
        -sepscl \
        -censor_RGB red \
        -censor ${STIM}/censor.cue_stim.1D \
        -ynames baseline polort1 polort2 \
                polort3 tone_block sent_block \
                roll_demean pitch_demean yaw_demean \
                dS_demean dL_demean dP_demean \
                roll_deriv pitch_deriv yaw_deriv \
                dS_deriv dL_deriv dP_deriv \
        -jpeg ${IMAGES}/${output4d}.Regressors-All \
        ${ID}/${output4d}.xmat.1D'[0..$]'

    1dplot \
        -censor_RGB green \
        -ynames tone_block sent_block \
        -censor ${STIM}/censor.cue_stim.1D \
        -jpeg ${IMAGES}/${output4d}.Regressors-Stim \
        ${ID}/${output4d}.xmat.1D'[5,4]'
}


function HelpMessage () {
    #------------------------------------------------------------------------
    #
    #   Description: HelpMessage
    #
    #       Purpose: This function provides the user with the instruction for
    #                how to correctly execute this script. It will only be
    #                called in cases in which the user improperly executes the
    #                script. In such a situation, this function will display
    #                instruction on how to correctly execute this script as
    #                as well as what is considered acceptable input. It will
    #                then exit the script, at which time the user may try again.
    #
    #         Input: None
    #
    #        Output: A help message instructing the user on how to properly
    #                execute this script.
    #
    #     Variables: none
    #
    #------------------------------------------------------------------------
   echo -e "\t-----------------------------------------------------------------------"
   echo -e "\t+                 +++ No arguments provided! +++                      +"
   echo -e "\t+                                                                     +"
   echo -e "\t+          This program requires at least 1 OR 3 arguments.           +"
   echo -e "\t+                                                                     +"
   echo -e "\t+       NOTE: [words] in square brackets represent possible input.    +"
   echo -e "\t+             See below for available options.                        +"
   echo -e "\t+                                                                     +"
   echo -e "\t-----------------------------------------------------------------------"
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t   +        Subject ID code:   OPTIONAL      eg: sub100          +"
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t                                                                  "
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t   +      Scan Session number:   OPTIONAL    eg: 1 or run1       +"
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t                                                                  "
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t   +      Experimental condition:  REQUIRED     see below        +"
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t   +                                                             +"
   echo -e "\t   +  [learn]   or  [learnable]    For the Learnable Condtion    +"
   echo -e "\t   +  [unlearn] or  [unlearnable]  For the Unlearnable Condtion  +"
   echo -e "\t   +  [debug]   or  [test]         For testing purposes only     +"
   echo -e "\t   +                                                             +"
   echo -e "\t   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo -e "\t-----------------------------------------------------------------------"
   echo -e "\t+             Example command-line execution:                         +"
   echo -e "\t+                                                                     +"
   echo -e "\t+              bash boot.preproc.sh learn[able]                       +"
   echo -e "\t+                                    ^^^                              +"
   echo -e "\t+                          OR                                         +"
   echo -e "\t+                                                                     +"
   echo -e "\t+          bash boot.preproc.sh sub100 [run]1 learn[able]             +"
   echo -e "\t+                                ^^^      ^^  ^^^                     +"
   echo -e "\t+               +++ Please try again +++                              +"
   echo -e "\t-----------------------------------------------------------------------"
   echo
   exit 1
}



function Main ()
{
    #------------------------------------------------------------------------
    #
    #   Description: Main
    #
    #       Purpose: This function acts as the launching point of all other
    #                functions within this script. In addition to defining
    #                the path variables used to point to data within the
    #                various directories, it also controls the loop which
    #                iterates over experiment runs. Any operation the user
    #                wishes to be performed related to the analysis should
    #                be executed within this function.
    #
    #         Input: None
    #
    #        Output: None, see individual functions for output.
    #
    #------------------------------------------------------------------------

    echo -e "\nMain has been called\n"
    #-----------------------------------#
    # Assign  #
    #-----------------------------------#
    sub=$1
    run=${2#run} # In case the user enters 'run1' instead of just '1', this will delete the 'run' part
    condition=$3

    #-----------------------------------#
    # Define variable names for program #
    #-----------------------------------#
    runsub=run${run}_${sub}
    subImage4D=${runsub}_volreg_despike_mni_5mm_176tr   # Its long and ugly, so wrap it in a variable

    #---------------------------------------------#
    #   Define BASE pointer for data and results  #
    #---------------------------------------------#
    RUN=Run${run}
    BASE=/Exps/Data/BootCamp
    MNI=${BASE}/RESOURCES

    #-------------------------------------#
    # Define pointers for Functional data #
    #-------------------------------------#
    STRUC=${BASE}/${sub}/Struc
    PREP=${BASE}/${sub}/${RUN}/Prep
    GLM=${BASE}/${sub}/${RUN}/Glm

    #---------------------------------#
    # Define pointers for GLM results #
    #---------------------------------#
    STIM=${BASE}/RESOURCES/Stim
    ID=${GLM}/1D
    MASK=${GLM}/Mask
    IMAGES=${GLM}/Images
    STATS=${GLM}/Stats
    FITTS=${GLM}/Fitts
    ERRTS=${GLM}/Errts

    #--------------------#
    # Initiate functions #
    #--------------------#
    SetupDirs
    BestVol ${runsub}
    VReg ${runsub}
    Spike ${runsub}_volreg
    Smooth ${runsub}_volreg_despike 6.0
    VolTrim ${runsub}_volreg_despike_6.0mm
    RegressMotion ${runsub}

    for delay in {0..7}; do     # This is a loop which runs the deconvolution at each delay (in seconds) the result of which is 8 seperate processes run.
        DeConvolve ${delay} ${runsub}_volreg_despike_6.0mm_176tr
    done
    # regress_alphcor ${subImage4D} 2>&1 | tee ${GLM}/log_alphacor.txt

}



#================================================================================
#                              START OF MAIN
#================================================================================

if [[ $# -eq 3 ]]; then

    subj=$1 # This is a mandatory command-line variable which should be supplied
    run=$2
    cond=$3

    Main $subj $run $condition

elif [[ $# -eq 1 ]]; then

    cond=$1        # This is a command-line supplied variable which determines
                   # which experimental condition should be run. This value is
                   # important in that it determines which group of subjects should
                   # be run. If this variable is not supplied the program will
                   # exit with an error and provide the user with instructions
                   # for proper input and execution.

    case $cond in
    "learn"|"learnable"     )
                              cond="learnable"
                              subjList=( sub100 sub104 sub105 sub106
                                         sub109 sub116 sub117 sub145
                                         sub158 sub166 )

                              ;;

    "unlearn"|"unlearnable" )
                              cond="unlearnable"
                              subjList=( sub111 sub120 sub121 sub124
                                         sub129 sub132 sub133 sub144
                                         sub156 sub171 )

                              ;;

    "debug"|"test"          )
                              echo -e "Debugging session\n"
                              cond="debugging"
                              subjList=( sub100 sub111 )
                              ;;

    *                       )
                              HelpMessage
                              ;;
    esac

    for sub in ${subjList[*]}; do
        #-----------------------------------#
        # Define review and index variables #
        #-----------------------------------#
        for run in {1..4}; do
            Main $sub $run $cond
        done
    done

else
    HelpMessage
fi




#================================================================================
#                              END OF MAIN
#================================================================================

# function Warp
# {
#     echo -e "\nWarping data to standard space!\n"
#     cd ${STRUC}
#     input4d=$1
#     struct3d=$2
#     base_reg_num=$( base_reg ${input4d}.outliers )
#     # ================================= align ==================================
#     # if [[ ! -e  ]]; then
#     #     #statements
#     # fi
#     # echo -e "\n\tStep1: Aligning Anat to EPI\n"
#     # align_epi_anat.py -dset1to2 -cmass cmass -dset1 ${STRUC}/${struct3d}.nii.gz \
#     #         -dset2 ${PREP}/${input4d}_volreg_despike.nii.gz -cost lpa -suffix _cmass

#     # echo -e "\n\tStep2: Aligning EPI to Anat\n"
#     # # for e2a: compute anat alignment transformation to EPI registration base
#     # # (new anat will be intermediate, stripped, TS004.spgr_strip+orig)
#     # align_epi_anat.py -anat2epi -anat ${STRUC}/${struct3d}_cmass+orig              \
#     #        -save_orig_skullstrip ${struct3d}_brain -suffix _al_junk \
#     #        -epi ${PREP}/${input4d}_volreg_despike.nii.gz -epi_base ${base_reg_num}           \
#     #        -volreg off -tshift off

#     # ================================== tlrc ==================================
#     # warp anatomy to standard space
#     echo -e "\n\tStep3: warp anatomy to standard space\n"
#     @auto_tlrc \
#         -base ${MNI}/MNI152_T1_2mm.nii \
#         -input ${struct3d}_brain+orig \
#         -no_ss -suffix NONE


#     # ================================= volreg =================================
#     # align each dset to base volume, align to anat, warp to tlrc space

#     # verify that we have a +tlrc warp dataset
#     # if ( ! -f TS004.spgr_strip+tlrc.HEAD ) then
#     #     echo "** missing +tlrc warp dataset: TS004.spgr_strip+tlrc.HEAD"
#     #     exit
#     # endif

#     # create an all-1 dataset to mask the extents of the warp
#     3dcalc -a ${PREP}/${input4d}_volreg_despike.nii.gz -expr 1 -prefix ${PREP}/rm.epi.all1.nii.gz

#     # catenate volreg, epi2anat and tlrc transformations
#     cat_matvec -ONELINE                                               \
#                ${STRUC}/${struct3d}_brain+tlrc::WARP_DATA -I                    \
#                ${STRUC}/${struct3d}_cmass_al_junk_mat.aff12.1D -I                     \
#                ${PREP}/${input4d}_volreg_mat_aff12.1D > ${PREP}/${input4d}_volreg_mat.warp.aff12.1D

#     # apply catenated xform : volreg, epi2anat and tlrc
#     3dAllineate -base ${STRUC}/${struct3d}_brain+tlrc                 \
#                 -input ${PREP}/${input4d}_volreg_despike.nii.gz                   \
#                 -1Dmatrix_apply ${PREP}/${input4d}_volreg_mat.warp.aff12.1D               \
#                 -mast_dxyz 1                                        \
#                 -prefix ${PREP}/rm.epi.nomask.${input4d}

#     # warp the all-1 dataset for extents masking
#     3dAllineate -base ${STRUC}/${struct3d}_brain+tlrc                  \
#                 -input ${PREP}/rm.epi.all1.nii.gz                               \
#                 -1Dmatrix_apply ${PREP}/${input4d}_volreg_mat.warp.aff12.1D          \
#                 -mast_dxyz 1 -final NN -quiet                       \
#                 -prefix ${PREP}/rm.epi.${input4d}.nii.gz

#     # make an extents intersection mask of this run
#     3dTstat -min -prefix ${PREP}/rm.epi.min.${input4d} ${PREP}/rm.epi.1.${input4d}+tlrc

#     # # make a single file of registration params
#     # cat dfile.r??.1D > dfile.rall.1D

#     # # ----------------------------------------
#     # # create the extents mask: mask_epi_extents+tlrc
#     # # (this is a mask of voxels that have valid data at every TR)
#     # # (only 1 run, so just use 3dcopy to keep naming straight)
#     3dcopy ${PREP}/rm.epi.min.${input4d}+tlrc ${PREP}/mask_epi_extents

#     # # and apply the extents mask to the EPI data
#     # # (delete any time series with missing data)
#     # foreach run ( $runs )
#     3dcalc -a ${PREP}/rm.epi.nomask.${input4d}+tlrc -b ${PREP}/mask_epi_extents+tlrc       \
#            -expr 'a*b' -prefix ${PREP}/${input4d}_volreg_despike_mni

#     3dcopy ${PREP}/${input4d}_volreg_despike_mni+tlrc ${PREP}/${input4d}_volreg_despike_mni.nii.gz
#     # # create an anat_final dataset, aligned with stats
#     # 3dcopy TS004.spgr_strip+tlrc anat_final.$subj
# }