#!/bin/bash
#================================================================================
#   Program Name: ice.glm.sh
#         Author: Kyle Reese Almryde
#           Date: August 01 2012
#
#    Description: This script is designed to perform a GLM analysis on the
#                 Iceword data.
#
#        Updates: Tue 04/23/2013 @ 01:51:35 PM
#                 In the past there was an issue with performing 3dClustSim. It
#                 has since been resolved via a patch from the folks at AFNI
#
#   Deficiencies: None, this program meets specification
#
# set -n    # Uncomment to check command syntax without any execution
# set -x    # Uncomment to debug this script
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


#------------------------------------------------------------------------
#
#   Description: set_subjdir
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

function setup_subjdir () {
    mkdir -p /Volumes/Data/Iceword/GLM/${sub}/${RUN}/{1D,Images,Stats,Fitts,Errts}
    mkdir -p /Volumes/Data/Iceword/ANOVA/{RESULTS/${RUN},${sub}/${RUN}}
}



#------------------------------------------------------------------------
#
#   Description: regress_masking
#
#       Purpose: Generate a mask to be used in the GLM anlysis
#
#         Input: run#_sub0##_tshift_volreg_despike_mni_7mm_214tr.nii.gz
#
#        Output: fullmask_run#_sub0##_tshift_volreg_despike_mni_7mm_214tr.nii.gz
#
#     Variables: input4d, fwhmx, condition, STATS, FUNC
#
#------------------------------------------------------------------------
function regress_masking () {

    input4d=$1
    fullmask=fullmask_${input4d}

    3dAutomask \
        -prefix ${GLM}/${fullmask}.nii.gz ${FUNC}/${input4d}.nii.gz
}



#------------------------------------------------------------------------
#
#   Description: regress_motion
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

function regress_motion () {
    echo -e "\nregress_motion has been called\n"

    input1D=${1}
    output1D=${1}

    # compute de-meaned motion parameters (for use in regression)
    1d_tool.py \
        -infile ${ARCHIVE}/${input1D}_tshift_dfile.1D \
        -select_rows {4..$}  -set_nruns 1 \
        -demean -write ${ID}/motion.${output1D}_demean.1D


    # compute motion parameter derivatives (for use in regression)
    1d_tool.py \
        -infile ${ARCHIVE}/${input1D}_tshift_dfile.1D \
        -select_rows {4..$}  -set_nruns 1 \
        -derivative -demean \
        -write ${ID}/motion.${output1D}_deriv.1D


    # Plot the de-meaned motion parameters
    1dplot \
        -jpeg ${IM}/motion.${output1D}_demean \
        ${ID}/motion.${output1D}_demean.1D

    # Plot the motion parameter derivatives
    1dplot \
        -jpeg ${IM}/motion.${output1D}_deriv \
        ${ID}/motion.${output1D}_deriv.1D

}



#------------------------------------------------------------------------
#
#   Description: regress_convolve
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

function regress_convolve () {
    echo -e "\nregress_convolve has been called\n"  # This is will display a message in the terminal which will help to keep
                                                    # track of what function is being run.

    #-------------------------------------------------#
    #  Defining some variables before we get started  #
    #-------------------------------------------------#
    delay=$1
    input4d=$2                                          # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr
    model="WAV(21.6,${delay},4,6,0.2,2)"                # <= The modified Cox Special, values are in seconds
                                                        #    WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
    output4d=${input4d}_${delay}sec                     # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_#sec
    fullmask=fullmask_${input4d}                        # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_fullmas
    input1D=( censor.cue_stim.1D stim.listen_block.1D \
              stim.response_block.1D stim.control_block.1D \
              motion.${runsub}_demean.1D'[0]' motion.${runsub}_demean.1D'[1]' \
              motion.${runsub}_demean.1D'[2]' motion.${runsub}_demean.1D'[3]' \
              motion.${runsub}_demean.1D'[4]' motion.${runsub}_demean.1D'[5]' \
              motion.${runsub}_deriv.1D'[0]'  motion.${runsub}_deriv.1D'[1]' \
              motion.${runsub}_deriv.1D'[2]'  motion.${runsub}_deriv.1D'[3]' \
              motion.${runsub}_deriv.1D'[4]'  motion.${runsub}_deriv.1D'[5]' )

    #-------------------------------------------------#
    #         On to the real processing, woo!         #
    #-------------------------------------------------#

    3dDeconvolve \
        -input ${FUNC}/${input4d}.nii.gz \
        -polort A \
        -mask ${GLM}/${fullmask}.nii.gz \
        -local_times \
        -num_stimts 15 \
            -censor ${STIM}/${input1D[0]} \
        -stim_times 1 \
                ${STIM}/${input1D[1]} "${model}" \
                -stim_label 1 ${input1D[1]} \
        -stim_times 2 \
                ${STIM}/${input1D[2]} "${model}" \
                -stim_label 2 ${input1D[2]} \
        -stim_times 3 \
                ${STIM}/${input1D[3]} "${model}" \
                -stim_label 3 ${input1D[3]} \
        -stim_file 4 \
                ${ID}/${input1D[4]} \
                -stim_base 4 \
                -stim_label 4 roll_demean    \
        -stim_file 5 \
                ${ID}/${input1D[5]} \
                -stim_base 5 \
                -stim_label 5 pitch_demean  \
        -stim_file 6 \
                ${ID}/${input1D[6]} \
                -stim_base 6 \
                -stim_label 6 yaw_demean     \
        -stim_file 7 \
                ${ID}/${input1D[7]} \
                -stim_base 7 \
                -stim_label 7 dS_demean      \
        -stim_file 8 \
                ${ID}/${input1D[8]} \
                -stim_base 8 \
                -stim_label 8 dL_demean      \
        -stim_file 9 \
                ${ID}/${input1D[9]} \
                -stim_base 9 \
                -stim_label 9 dP_demean      \
        -stim_file 10 \
                ${ID}/${input1D[10]} \
                -stim_base 10 \
                -stim_label 10 roll_deriv     \
        -stim_file 11 \
                ${ID}/${input1D[11]} \
                -stim_base 11 \
                -stim_label 11 pitch_deriv \
        -stim_file 12 \
                ${ID}/${input1D[12]} \
                -stim_base 12 \
                -stim_label 12 yaw_deriv   \
        -stim_file 13 \
                ${ID}/${input1D[13]} \
                -stim_base 13 \
                -stim_label 13 dS_deriv    \
        -stim_file 14 \
                ${ID}/${input1D[14]} \
                -stim_base 14 \
                -stim_label 14 dL_deriv    \
        -stim_file 15 \
                ${ID}/${input1D[15]} \
                -stim_base 15 \
                -stim_label 15 dP_deriv    \
        -xout \
            -x1D ${ID}/${output4d}.xmat.1D \
            -xjpeg ${IM}/${output4d}.xmat.jpg \
        -jobs 8 \
        -fout -tout \
        -errts ${ERRTS}/${output4d}.errts.nii.gz \
        -fitts ${FITTS}/${output4d}.fitts.nii.gz \
        -bucket ${STATS}/${output4d}.stats.nii.gz

}



#------------------------------------------------------------------------
#
#   Description: regress_plot
#
#       Purpose: The purpose of this function is to visualize the regression
#                coefficients of the computed General Linear Model performed
#                by AFNI's 3dDeconvolve.
#
#         Input: run#_sub0##_#sec_sent_block_learnable.xmat.1D
#
#                This program takes as input a 1 dimensional x-matrix file
#                which consists of the regression analysis' model coefficients.
#                This file is output by the program 3dDeconvolve.
#
#        Output: run#_sub0##_#sec_sent_block_learnable.tone_block.1D
#                run#_sub0##_#sec_sent_block_learnable.sent_block.1D
#                run#_sub0##_#sec_sent_block_learnable.Regressors-All.jpeg
#                run#_sub0##_#sec_sent_block_learnable.Regressors-Stim.jpeg
#
#     Variables: delay, input4d, ID, IM, STIM
#
#          Note: This function is run within the regress_convolve function,
#                which supplies the appropriate input.
#
#------------------------------------------------------------------------

function regress_plot () {

    echo -e "\nregress_plot has been called\n"

    delay=${1}
    input4d=${2}_${delay}sec

    1dcat \
        ${ID}/${input4d}.xmat.1D'[5]' \
        > ${ID}/ideal.${input4d}.listen_block.1D

    1dcat \
        ${ID}/${input4d}.xmat.1D'[6]' \
        > ${ID}/ideal.${input4d}.response_block.1D

    1dcat \
        ${ID}/${input4d}.xmat.1D'[7]' \
        > ${ID}/ideal.${input4d}.control_block.1D


    1dplot \
        -sepscl \
        -censor_RGB red \
        -censor ${STIM}/censor.cue_stim.1D \
        -ynames baseline polort1 polort2 \
                polort3 polort4 listen_block \
                response_block control_block  \
        -jpeg ${IM}/${input4d}.Regressors-All \
        ${ID}/${input4d}.xmat.1D'[0..$]'

    1dplot \
        -censor_RGB green \
        -ynames listen_block response_block control_block  \
        -censor ${STIM}/censor.cue_stim.1D \
        -jpeg ${IM}/${input4d}.Regressors-Stim \
        ${ID}/${input4d}.xmat.1D'[5,6,7]'

}



#------------------------------------------------------------------------
#
#   Description: regress_alphcor
#
#       Purpose: a
#
#         Input: a
#
#        Output: a
#
#     Variables: input4d, fwhmx, condition, STATS, FUNC
#
#------------------------------------------------------------------------

function regress_alphcor () {

    echo -e "\nregress_alphcor has been called\n"

    delay=${1}
    fullmask=fullmask_${2}
    input4d=${2}_${delay}sec

    if [[ ! -e ${ID}/ClustSim.NN1.1D ]]; then

        fwhmx=$(3dFWHMx \
                -dset ${ERRTS}/${input4d}.errts.nii.gz \
                -mask ${GLM}/${fullmask}.nii.gz \
                -combine -detrend)

        echo ${fwhmx} >> ${GLM}/${RUN}.FWHMx.txt


        3dClustSim \
            -both -NN 123 \
            -mask ${GLM}/${fullmask}.nii.gz \
            -fwhm "${fwhmx}" -prefix ${ID}/ClustSim

    fi

    cd ${ID}
    3drefit \
        -atrstring AFNI_CLUSTSIM_MASK file:ClustSim.mask \
        -atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.NN1.niml \
        -atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.NN2.niml \
        -atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.NN3.niml \
        ${STATS}/${input4d}.stats.nii.gz
}


#------------------------------------------------------------------------
#
#  Purpose: Bucket the conditions of interest into their own dataset
#           This will result in 3 bucket files per subject, per run. Each
#           bucket file will contain three pieces of information:
#           The Fstat, Coef, and Tstat
#
#    Input: input1D -- the individual dataset in question.
#
#   Output: sub0##_delay#_ListenStats.nii.gz
#           sub0##_delay#_ResponseStats.nii.gz
#           sub0##_delay#_ControlStats.nii.gz
#------------------------------------------------------------------------

function group_bucket_stats () {
    echo -e "\ngroup_bucket_stats has been called\n"

    delay=$1
    input1D=${2}_${delay}sec.stats
    output1D=${2}_${delay}sec

    3dBucket \
        -prefix ${ANOVA}/${output1D}_ListenStats.nii.gz \
        -fbuc ${STATS}/${input1D}.nii.gz'[1-3]'

    3dBucket \
        -prefix ${ANOVA}/${output1D}_ResponseStats.nii.gz \
        -fbuc ${STATS}/${input1D}.nii.gz'[4-6]'

    3dBucket \
        -prefix ${ANOVA}/${output1D}_ControlStats.nii.gz \
        -fbuc ${STATS}/${input1D}.nii.gz'[7-9]'

} # End of group_bucket_stats



#------------------------------------------------------------------------
#
#   Description: Test_Main
#
#       Purpose: This function tests the variables within the script to
#                ensure they are expanding correctly within the scope of
#                the individual functions. It does not contribute to the
#                analysis in anyway beyond debugging this script.
#                Hooray for Test Driven Development!
#
#         Input: None
#
#        Output: Various statements are printed to the terminal displaying
#                the current values of the variables provided within
#
#     Variables: Too many to list, currently all variables defined within
#                this script.
#
#------------------------------------------------------------------------

function Test_Main () {

    input4d=${runsub}_tshift_volreg_despike_mni_7mm_214tr

    input1D=( cue_stim.1D \
              listen_block.1D \
              control_block.1D \
              response_block.1D )

    echo "============================ Begin Testing============================"
    echo "Subject == $sub"
    echo "Scan == $scan"
    echo "RUNDIR == $RUN"
    echo "Subject = ${sub} "
    echo "runsub = ${runsub}"
    echo "RUN = ${RUN} "
    echo "1D array Size = ${#input1D[*]}"
    echo -e "\n============================ File Names ============================\n"
    echo "censor.${input1D[0]}"
    echo "stim.${input1D[1]} "
    echo "stim.${input1D[2]}"
    echo "stim.${input1D[3]} "
    echo -e "\n============================ Path Names  ============================\n"
    echo "Func dir = ${FUNC}"
    echo "GLM dir = ${GLM}"
    echo "STIM dir = ${STIM}"
    echo "ID dir = ${ID}"

    for delay in {0..7}; do

        output4d=${input4d}_${delay}sec
        model="WAV(18.2,${delay},4,6,0.2,2)"

        echo -e "\n============================ Variable Names  ============================\n"
        echo "delay = ${delay}"
        echo "model = ${model}"
        echo "input4d = ${input4d}"
        echo "output4d = ${output4d}"

    done

    echo -e "\n================================ End Testing ================================"
    echo -e "\n********************* Hooray For Test Driven Development **********************\n"
}



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

function HelpMessage ()
{
   echo "-----------------------------------------------------------------------"
   echo "+                 +++ No arguments provided! +++                      +"
   echo "+                                                                     +"
   echo "+             This program requires at least 1 arguments.             +"
   echo "+                                                                     +"
   echo "+       NOTE: [words] in square brackets represent optional input.    +"
   echo "+             See below for available options.                        +"
   echo "+                                                                     +"
   echo "-----------------------------------------------------------------------"
   echo "+                Example command-line execution:                      +"
   echo "+                                                                     +"
   echo "+                    bash ice.glm.sh [test]                           +"
   echo "+                                                                     +"
   echo "+                  +++ Please try again +++                           +"
   echo "-----------------------------------------------------------------------"

   exit 1
}



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

function Main ()
{
    echo -e "\nMain has been called\n"

    # The {5..19}-{1..4} is brace notation which acts as a nested for-loop
    # The '-' acts as a seperator which allows for easy substring operations when
    # assiging the variable names for the rest of the program.

    # for i in {5..19}-{1..4}; do
    for i in {6..19}-{1..4}; do

        #-----------------------------------#
        # Define variable names for program #
        #-----------------------------------#
        run=run${i#*-}
        sub=`printf "sub%03d" ${i%-*}`
        runsub=${run}_${sub}

        #-------------------------------------#
        # Define pointers for Functional data #
        #-------------------------------------#
        RUN=Run${i#*-}
        FUNC=/Volumes/Data/Iceword/${sub}/Func/${RUN}
        ARCHIVE=/Volumes/Data/Archive/Iceword_RealignDetails/${sub}/Func/${RUN}/RealignDetails

        #---------------------------------#
        # Define pointers for GLM results #
        #---------------------------------#
        BASE=/Volumes/Data/Iceword/GLM
        STIM=/Volumes/Data/Iceword/GLM/STIM
        GLM=/Volumes/Data/Iceword/GLM/${sub}/${RUN}
        ID=/Volumes/Data/Iceword/GLM/${sub}/${RUN}/1D
        IM=/Volumes/Data/Iceword/GLM/${sub}/${RUN}/Images
        STATS=/Volumes/Data/Iceword/GLM/${sub}/${RUN}/Stats
        FITTS=/Volumes/Data/Iceword/GLM/${sub}/${RUN}/Fitts
        ERRTS=/Volumes/Data/Iceword/GLM/${sub}/${RUN}/Errts

        #---------------------------#
        # Define pointers for ANOVA #
        #---------------------------#
        ANOVA=/Volumes/Data/Iceword/ANOVA/${sub}/${RUN}

        #--------------------#
        # Initiate functions #
        #--------------------#

        # We removed sub018 from the analysis, so dont perform any operations them.
        if [[ $sub != "sub018" ]]; then

            setup_subjdir
            regress_motion ${runsub} 2>&1 | tee -a ${GLM}/log_motion.txt
            regress_masking ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee -a ${GLM}/log_mask.txt

            for delay in {0..7}; do     # This is a loop which runs the deconvolution at each delay (in seconds) the result of which is 8 seperate processes run.
                regress_convolve ${delay} ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee -a ${GLM}/log_convolve.txt
                regress_plot ${delay} ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee -a ${GLM}/log_plot.txt
                regress_alphcor ${delay} ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee ${GLM}/log_alphacor.txt
                group_bucket_stats ${delay} ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee ${ANOVA}/log_bucket.txt
            done
        fi
    done
}



#================================================================================
#                              START OF MAIN
#================================================================================

opt=$1  # This is an optional command-line variable which should be supplied
        # in for testing purposes only. The only available operation should
        # "test"

# Check whether Test_Main should or Main should be run
case $opt in
    "test" )
        Test_Main 2>&1 | tee ${BASE}/log.TEST.txt
        ;;

      * )
        Main 2>&1 | tee -a ${BASE}/log_main.txt
        ;;
esac



#================================================================================
#                              END OF MAIN
#================================================================================
<<NOTE
This data is linked and as such has different path names, below are the differences
between machines.

On Hagar the path names are:
    FUNC=/Volumes/Data/Iceword/${sub}/Func/${RUN}

    STIM=/Volumes/Data/Iceword/GLM/STIM
    GLM=/Volumes/Data/Iceword/GLM/${sub}/Glm/${RUN}
    ID=/Volumes/Data/Iceword/GLM/${sub}/Glm/${RUN}/Ideal

On Auk the path names are:
    FUNC=/Exps/Data/Iceword/${sub}/Func/${RUN}

    STIM=/Exps/Analysis/Iceword/STIM
    GLM=/Exps/Analysis/Iceword/${sub}/Glm/${RUN}
    ID=/Exps/Analysis/WordBoundary1/${sub}/Glm/${RUN}/Ideal
NOTE
