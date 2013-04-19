#!/bin/bash
#================================================================================
#   Program Name: ice.glm.sh
#         Author: Kyle Reese Almryde
#           Date: August 01 2012
#
#    Description: This script is designed to perform a GLM analysis on the
#                 Iceword data.
#
#   Deficiencies: Currently there is an issue with AFNI's 3dClustSim tool, which
#                 renders the function 'regress_alphacor' unusable. This issue is
#                 presently beyond my control. Until I can find a solution to the
#                 issue, that process has to be skipped. Otherwise, this program
#                 meets specifications.
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
    mkdir -p /Volumes/Data/Iceword/GLM/${sub}/${RUN}/{1D,Images,Stats,Fitts}
    mkdir -p /Volumes/Data/Iceword/ANOVA/{RESULTS/${RUN},${sub}/${RUN}}
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

    for delay in {0..7}; do     # This is a loop which runs the deconvolution at each delay (in seconds)
                                # the result of which is 8 seperate processes run.

        #-------------------------------------------------#
        #  Defining some variables before we get started  #
        #-------------------------------------------------#
        input4d=$1                                          # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr
        model="WAV(21.6,${delay},4,6,0.2,2)"                # <= The modified Cox Special, values are in seconds
                                                            #    WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
        output4d=${input4d}_${delay}sec                     # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_#sec

        input1D=( cue_stim.1D \
                  listen_block.1D \
                  response_block.1D \
                  control_block.1D
                )

        #-------------------------------------------------#
        #         On to the real processing, woo!         #
        #-------------------------------------------------#

        3dDeconvolve \
            -input ${FUNC}/${input4d}.nii.gz \
            -polort A \
            -automask \
            -local_times \
            -num_stimts 3 \
                -censor ${STIM}/censor.${input1D[0]} \
            -stim_times 1 \
                    ${STIM}/stim.${input1D[1]} "${model}" \
                    -stim_label 1 ${input1D[1]} \
            -stim_times 2 \
                    ${STIM}/stim.${input1D[2]} "${model}" \
                    -stim_label 2 ${input1D[2]} \
            -stim_times 3 \
                    ${STIM}/stim.${input1D[3]} "${model}" \
                    -stim_label 3 ${input1D[3]} \
            -xout \
                -x1D ${ID}/${output4d}.xmat.1D \
                -xjpeg ${IM}/${output4d}.xmat.jpg \
            -jobs 4 \
            -fout -tout \
            -errts ${FITTS}/${output4d}.errts.nii.gz \
            -fitts ${FITTS}/${output4d}.fitts.nii.gz \
            -bucket ${STATS}/${output4d}.stats.nii.gz
    done
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

    for delay in {0..7}; do

        input4d=${1}_${delay}sec

        1dcat \
            ${ID}/${input4d}.xmat.1D'[5]' \
            > ${FITTS}/ideal.${input4d}.listen_block.1D

        1dcat \
            ${ID}/${input4d}.xmat.1D'[6]' \
            > ${FITTS}/ideal.${input4d}.response_block.1D

        1dcat \
            ${ID}/${input4d}.xmat.1D'[7]' \
            > ${FITTS}/ideal.${input4d}.control_block.1D


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
    done
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
function prep_masking () {

    local subj run
    local STRUC PREP GLM

    subj=$1; run=$2

    STRUC=/Volumes/Data/TAP/${subj}/Struc
    PREP=/Volumes/Data/TAP/${subj}/Prep/${run}
    GLM=/Volumes/Data/TAP/${subj}/GLM/${run}
    ANOVAMask=/Volumes/Data/TAP/ANOVA/Masks

    if [[ ! -e ${PREP}/${subj}.${run}.fullmask+tlrc.HEAD ]]; then

        3dAutomask \
            -prefix ${PREP}/${subj}.${run}.fullmask \
            ${PREP}/${subj}.${run}.blur+tlrc

        3dresample \
            -master ${PREP}/${subj}.${run}.fullmask+tlrc \
            -prefix ${PREP}/${subj}.${run}.spgr.resam \
            -input ${STRUC}/${subj}.spgr.standard+tlrc

        3dcalc \
            -a ${PREP}/${subj}.${run}.spgr.resam+tlrc \
            -expr 'ispositive(a)' \
            -prefix ${PREP}/${subj}.${run}.spgr.mask

        3dABoverlap \
            -no_automask ${PREP}/${subj}.${run}.fullmask+tlrc \
            ${PREP}/${subj}.${run}.spgr.mask+tlrc \
            2>&1 | tee -a ${PREP}/${subj}.${run}.mask.overlap.txt

        3dABoverlap \
            -no_automask \
            ${ANOVAMask}/N27.mask+tlrc \
            ${PREP}/${subj}.${run}.spgr.mask+tlrc \
            2>&1 | tee -a ${PREP}/${subj}.${run}.spgr.mask.overlap.txt

        echo "( ${subj}.${run} / N27 ) = \
            `cat ${PREP}/${subj}.${run}.spgr.mask.overlap.txt \
            | tail -1 | awk '{print $8}'`" \
            >> ${ANOVAMask}/N27.mask.overlap.txt

        cp ${PREP}/${subj}.${run}.fullmask+tlrc.* ${GLM}

    else

        echo "${subj}.${run}.fullmask+tlrc already exists!!"

    fi
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

    for delay in {0..7}; do

        input4d=${1}_${delay}sec

        fwhmx=$(3dFWHMx \
                -dset ${FITTS}/${input4d}.errts.nii.gz \
                -mask ${FUNC}/${input4d}.fullmask.nii.gz \
                -combine -detrend)

        echo ${fwhmx} >> ${STIM}/${RUN}.FWHMx.txt


        3dClustSim \
            -both -NN 123 \
            -mask ${FUNC}/${runsub}.fullmask.nii.gz \
            -fwhm "${fwhmx}" -prefix ${STATS}/ClustSim


        cd ${STATS}
        3drefit \
            -atrstring AFNI_CLUSTSIM_MASK file:ClustSim.mask \
            -atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.NN1.niml \
            -atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.NN2.niml \
            -atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.NN3.niml \
            ${input4d}.stats.nii.gz
    done
}


function group_bucket_stats () {
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
    for delay in {0..7}; do
        input1D=${1}_${delay}sec.stats
        output1D=${1}_${delay}sec

        3dBucket \
            -prefix ${ANOVA}/${output1D}_ListenStats.nii.gz \
            -fbuc ${STATS}/${input1D}.nii.gz'[11-13]'

        3dBucket \
            -prefix ${ANOVA}/${output1D}_ResponseStats.nii.gz \
            -fbuc ${STATS}/${input1D}.nii.gz'[14-16]'

        3dBucket \
            -prefix ${ANOVA}/${output1D}_ControlStats.nii.gz \
            -fbuc ${STATS}/${input1D}.nii.gz'[17-19]'
    done

} # End of group_bucket_stats




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



function check_outLog () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Check the log reports to make sure everything ran correctly
    #
    #------------------------------------------------------------------------

    echo "================================ $sub, $run ================================"
    grep "ERROR" ${GLM}/log.txt
    echo

} # End of


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
              response_block.1D
            )

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

    #--------------------#
    # Initiate functions #
    #--------------------#
    setup_subjdir
    regress_convolve ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee -a ${GLM}/log.txt
    regress_plot ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee -a ${GLM}/log.txt
    # regress_alphcor ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee ${GLM}/log.txt
    group_bucket_stats ${runsub}_tshift_volreg_despike_mni_7mm_214tr 2>&1 | tee ${ANOVA}/log.txt
}


#================================================================================
#                              START OF MAIN
#================================================================================

opt=$1  # This is an optional command-line variable which should be supplied
        # in for testing purposes only. The only available operation should
        # "test"



# The {5..19}-{1..4} is brace notation which acts as a nested for-loop
# The '-' acts as a seperator which allows for easy substring operations when
# assiging the variable names for the rest of the program.

for i in {5..19}-{1..4}; do

    #-----------------------------------#
    # Define variable names for program #
    #-----------------------------------#
    run=run${i#*-}
    RUN=Run${i#*-}
    sub=`printf "sub%03d" ${i%-*}`
    runsub=${run}_${sub}

    #-------------------------------------#
    # Define pointers for Functional data #
    #-------------------------------------#
    FUNC=/Volumes/Data/Iceword/${sub}/Func/${RUN}

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

    #---------------------------------#
    # Define pointers for GLM results #
    #---------------------------------#
    ANOVA=/Volumes/Data/Iceword/ANOVA/${sub}/${RUN}

    # We removed sub018 from the analysis, so dont perform any operations them.
    if [[ $sub != "sub018" ]]; then

        # Check whether Test_Main should or Main should be run
        case $opt in
            "test" )
                Test_Main 2>&1 | tee ${BASE}/log.TEST.txt
                ;;

            "check" )
                check_outLog
                ;;

              * )
                Main 2>&1 | tee -a ${BASE}/log.txt
                ;;
        esac
    fi

done

# regress_nodata

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
