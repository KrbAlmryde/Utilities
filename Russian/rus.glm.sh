#!/bin/bash
#================================================================================
#    Program Name: rus.glm.sh
#          Author: Kyle Reese Almryde
#            Date: 11/7/2013
#
#     Description: Performs a general linear model on the russian single subject
#                  data
#
#
#    Deficiencies:
#
#
#
#
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


function updateReviewList() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Updates the reviewList by adding the supplied dataset to the
    #           reviewList array.
    #
    #    Input: a 3D or 4D dataset
    #
    #------------------------------------------------------------------------
    local astr="$1[*]"
    local arr=(${!astr})
    local index=${#arr[*]}

    for ((input4D=2;input4D<=$#;input4D++)); do
        eval $1[index]=${!input4D}
        ((index++))
    done

    arr=(${!astr})
    
    echo -e "REVIEWLIST has ${#arr[*]} elements!"

} # End of updateReviewList



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
    echo -e "Setting up Subject Data Analysis structure\n"
    mkdir -p /Volumes/Data/Exps/Analysis/Russian/GLM/${sub}/${RUN}/{1D,Images,Stats,Mask,Fitts,Errts}
    mkdir -p /Volumes/Data/Exps/Analysis/Russian/TTEST/{RESULTS,${sub}/${RUN}}
}


#------------------------------------------------------------------------
#
#   Description: regress_masking
#
#       Purpose: Generate a mask to be used in the GLM anlysis
#
#         Input: run#_sub###_volreg_despike_mni_5mm_176tr.nii.gz
#
#        Output: fullmask_run#_sub###_volreg_despike_mni_5mm_176tr.nii.gz
#
#     Variables: input4d, fwhmx, condition, STATS, FUNC
#
#------------------------------------------------------------------------
function regress_masking () {
    echo -e "Computing automask for regression\n"
    input4d=$1
    fullmask=fullmask_${input4d}

    3dAutomask \
        -prefix ${MASK}/${fullmask}.nii.gz ${FUNC}/${input4d}.nii.gz
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
    output1D=${input1D}

    # compute de-meaned motion parameters (for use in regression)
    1d_tool.py \
        -infile ${FUNC}/${input1D}_dfile.1D \
        -select_rows {6..$}  -set_nruns 1 \
        -demean -write ${ID}/motion.${output1D}_demean.1D


    # compute motion parameter derivatives (for use in regression)
    1d_tool.py \
        -infile ${FUNC}/${input1D}_dfile.1D \
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
    model="WAV(18.0,${delay},4,6,0.2,2)"                # <= The modified Cox Special, values are in seconds
                                                        #    WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
    output4d=${input4d}_${delay}sec_${condition}        # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_#sec_##learnable
    fullmask=fullmask_${input4d}                        # <= run#_sub0##_tshift_volreg_despike_mni_7mm_214tr_fullmask
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
        -input ${FUNC}/${input4d}.nii.gz \
        -polort A \
        -mask ${MASK}/${fullmask}.nii.gz \
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
            -xjpeg ${IM}/${output4d}.xmat.jpg \
        -jobs 12 \
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
    input4d=${2}_${delay}sec_${condition}

    1dcat \
        ${ID}/${input4d}.xmat.1D'[4]' \
        > ${FITTS}/ideal.${input4d}.tone_block.1D

    1dcat \
        ${ID}/${input4d}.xmat.1D'[5]' \
        > ${FITTS}/ideal.${input4d}.sent_block.1D

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
        -jpeg ${IMAGES}/${input4d}.Regressors-All \
        ${ID}/${input4d}.xmat.1D'[0..$]'

    1dplot \
        -censor_RGB green \
        -ynames tone_block sent_block \
        -censor ${STIM}/censor.cue_stim.1D \
        -jpeg ${IMAGES}/${input4d}.Regressors-Stim \
        ${ID}/${input4d}.xmat.1D'[5,4]'
}



#------------------------------------------------------------------------
#
#   Description: regress_alphcor
#
#       Purpose: Computes the required alpha cluster correction value
#                using 3dClustSim. It them maps the clustering information
#                to the image to make clusterizing a little easier.
#
#------------------------------------------------------------------------

function regress_alphcor () {

    echo -e "\nregress_alphcor has been called\n"

    prev=$(pwd); cd ${STATS}
    for delay in {0..7}; do
        fullmask=fullmask_${1} 
        input4d=${1}_${delay}sec_${condition}

        fwhmx=$(3dFWHMx \
                -dset ${ERRTS}/${input4d}.errts.nii.gz \
                -mask ${MASK}/${fullmask}.nii.gz \
                -combine -detrend)

        echo ${fwhmx} >> ${GLM}/${RUN}.FWHMx.txt

        3dClustSim \
            -fwhm "${fwhmx}" \
            -both -NN 123 \
            -pthr 0.05 0.01 \
            -nxyz 91 109 91 \
            -dxyz 2.0 2.0 2.0 \
            -mask ${MASK}/${fullmask}.nii.gz \
            -prefix ${STATS}/ClustSim.${condition}


        3drefit \
            -atrstring AFNI_CLUSTSIM_MASK file:ClustSim.${condition}.mask \
            -atrstring AFNI_CLUSTSIM_NN1  file:ClustSim.${condition}.NN1.niml \
            -atrstring AFNI_CLUSTSIM_NN2  file:ClustSim.${condition}.NN2.niml \
            -atrstring AFNI_CLUSTSIM_NN3  file:ClustSim.${condition}.NN3.niml \
            ${input4d}.stats.nii.gz

        rm ClustSim.${condition}.*
        
    done
    cd $prev
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
    input3D=${2}_${delay}sec_${condition}.stats
    output3D=${2}_${delay}sec_${condition}

    3dBucket \
        -prefix ${TTEST}/${output3D}_ToneStats.nii.gz \
        -fbuc ${STATS}/${input3D}.nii.gz'[1-3]'

    3dBucket \
        -prefix ${TTEST}/${output3D}_SentStats.nii.gz \
        -fbuc ${STATS}/${input3D}.nii.gz'[4-6]'

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

function HelpMessage () {
   echo "-----------------------------------------------------------------------"
   echo "+                 +++ No arguments provided! +++                      +"
   echo "+                                                                     +"
   echo "+             This program requires at least 1 arguments.             +"
   echo "+                                                                     +"
   echo "+       NOTE: [words] in square brackets represent possible input.    +"
   echo "+             See below for available options.                        +"
   echo "+                                                                     +"
   echo "-----------------------------------------------------------------------"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                Experimental condition                       +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "   +                                                             +"
   echo "   +  [learn]   or  [learnable]    For the Learnable Condtion    +"
   echo "   +  [unlearn] or  [unlearnable]  For the Unlearnable Condtion  +"
   echo "   +  [debug]   or  [test]         For testing purposes only     +"
   echo "   +                                                             +"
   echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
   echo "-----------------------------------------------------------------------"
   echo "+                Example command-line execution:                      +"
   echo "+                                                                     +"
   echo "+                    bash wb1.glm.sh learn                            +"
   echo "+                                                                     +"
   echo "+                  +++ Please try again +++                           +"
   echo "-----------------------------------------------------------------------"

   exit 1
}

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


function Review_Main() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Review the EPI data via 'afni' and 'plugout_drive'. Allows for
    #           a general overview of single subject 
    #
    #    Input: 
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    echo -e "\nMain has been called\n"

    condition=$1        # This is a command-line supplied variable which determines
                        # which experimental condition should be run. This value is
                        # important in that it determines which group of subjects should
                        # be run. If this variable is not supplied the program will
                        # exit with an error and provide the user with instructions
                        # for proper input and execution.

    range=$2

    case $condition in
    "learn"|"learnable"     )
                              condition="learnable"
                              subjList=( sub100 sub104 sub105 sub106
                                         sub109 sub116 sub117 sub145
                                         sub158 sub159 sub160 sub161
                                         sub166                       )

                              ;;

    "unlearn"|"unlearnable" )
                              condition="unlearnable"
                              subjList=( sub111 sub120 sub121 sub124
                                         sub129 sub132 sub133 sub144
                                         sub156 sub163 sub164 sub171  )

                              ;;

    "debug"|"test"          )
                              echo -e "Debugging session\n"
                              condition="debugging"
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
        REVIEWLIST=()

        for i in {1..4}; do

            #---------------------------------------------#
            # Define Global pointers for data and results #
            #---------------------------------------------#
            DATA=/Volumes/Data/Exps/Data/Russian
            ANALYSIS=/Volumes/Data/Exps/Analysis/Russian

            #-----------------------------------#
            # Define variable names for program #
            #-----------------------------------#
            runsub=run${i}_${sub}
            subImage4D=${runsub}_volreg_despike_mni_5mm_176tr   # Its long and ugly, so wrap it in a variable

            #-------------------------------------#
            # Define pointers for Functional data #
            #-------------------------------------#
            RUN=Run$i 
            FUNC=${DATA}/${sub}/Func/${RUN}

            #---------------------------------#
            # Define pointers for GLM results #
            #---------------------------------#
            BASE=${ANALYSIS}/GLM
            GLM=${BASE}/${sub}/${RUN}
            MASK=${GLM}/Mask
            STATS=${GLM}/Stats
            FITTS=${GLM}/Fitts
            ERRTS=${GLM}/Errts

            #---------------------------#
            # Define pointers for TTEST #
            #---------------------------#
            TTEST=${ANALYSIS}/TTEST/${sub}/${RUN}

            mkdir -p ${GLM}/REVIEW

            case $range in
                "all" ) 
                    updateReviewList REVIEWLIST \
                        "${FUNC}/${input4d}.nii.gz" \
                        "${MASK}/${fullmask}.nii.gz"
                    for delay in {0..7}; do
                        updateReviewList REVIEWLIST \
                            ${ERRTS}/${subImage4D}_${delay}sec_${condition}.errts.nii.gz \
                            ${FITTS}/${subImage4D}_${delay}sec_${condition}.fitts.nii.gz \
                            ${STATS}/${subImage4D}_${delay}sec_${condition}.stats.nii.gz \
                            ${TTEST}/${subImage4D}_${delay}sec_${condition}_ToneStats.nii.gz \
                            ${TTEST}/${subImage4D}_${delay}sec_${condition}_SentStats.nii.gz
                    done
                ;;
            
                * )
                    for delay in {0..7}; do
                        updateReviewList REVIEWLIST \
                            ${TTEST}/${subImage4D}_${delay}sec_${condition}_ToneStats.nii.gz \
                            ${TTEST}/${subImage4D}_${delay}sec_${condition}_SentStats.nii.gz
                    done
                ;;
            esac


            for dset in ${REVIEWLIST[*]}; do
                3dcopy $dset ${GLM}/REVIEW/`basename $dset`
            done
            
            # ------------------------------------------------------
            # verify that the input data exists

            if [[ ! -f ${REVIEWLIST[0]} ]]; then
                echo -e "\n** missing data to review!! (e.g. ${REVIEWLIST[0]})"
                exit
            else 
                echo -e "\nReviewing ${#REVIEWLIST[*]} Files!" 
                echo -e "${REVIEWLIST[*]}\n"
            fi

            # ------------------------------------------------------
            # start afni is listening mode, and take a brief nap

            afni -yesplugouts

            sleep 5

            # ------------------------------------------------------
            # tell afni to load the first dataset and open windows

            plugout_drive                                  \
                -com "SWITCH_UNDERLAY MNI_2mm.nii" \
                -com "OPEN_WINDOW sagittalimage            \
                                  geom=300x300+420+400"    \
                -com "OPEN_WINDOW axialimage               \
                                  geom=300x300+720+400"    \
                -com "OPEN_WINDOW sagittalgraph            \
                                  geom=400x300+0+400"      \
                -quit

            sleep 2    # give afni time to open the windows


            # ------------------------------------------------------
            # process each dataset using video mode
            for dset in ${REVIEWLIST[*]}; do
                echo -e "\nWe are now in ${GLM}/REVIEW!"

                cd ${GLM}/REVIEW
                image=$(basename $dset)
                plugout_drive                        \
                    -com "SWITCH_FUNCTION ${image}" \
                    -com "SET_PBAR_SIGN +" \
                    -com "SET_THRESHNEW A 0.05 *p" \
                    -com "OPEN_WINDOW sagittalgraph  \
                                      keypress=a     \
                                      keypress=v"    \
                    -quit

                sleep 2    # wait for plugout_drive output

                echo ""
                echo "++ now viewing $dset, hit enter to continue"
                read    # wait for user to hit enter
            done

            # ------------------------------------------------------
            # stop video mode when the user is done

            plugout_drive -com "OPEN_WINDOW sagittalgraph keypress=s" -quit


            sleep 2    # wait for plugout_drive output

            echo ""
            echo "data review for ${subrun} complete"

            kill afni
            rm ${GLM}/REVIEW/${subImage4D}*
            rmdir ${GLM}/REVIEW
        done
    done


} # End of Review_Main


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

    condition=$1        # This is a command-line supplied variable which determines
                        # which experimental condition should be run. This value is
                        # important in that it determines which group of subjects should
                        # be run. If this variable is not supplied the program will
                        # exit with an error and provide the user with instructions
                        # for proper input and execution.

    case $condition in
    "learn"|"learnable"     )
                              condition="learnable"
                              subjList=( sub100 sub104 sub105 sub106
                                         sub109 sub116 sub117 sub145
                                         sub158 sub159 sub160 sub161
                                         sub166                       )

                              ;;

    "unlearn"|"unlearnable" )
                              condition="unlearnable"
                              subjList=( sub111 sub120 sub121 sub124
                                         sub129 sub132 sub133 sub144
                                         sub156 sub163 sub164 sub171  )

                              ;;

    "debug"|"test"          )
                              echo -e "Debugging session\n"
                              condition="debugging"
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
        for i in {1..4}; do

            #---------------------------------------------#
            # Define Global pointers for data and results #
            #---------------------------------------------#
            DATA=/Volumes/Data/Exps/Data/Russian
            ANALYSIS=/Volumes/Data/Exps/Analysis/Russian

            #-----------------------------------#
            # Define variable names for program #
            #-----------------------------------#
            runsub=run${i}_${sub}
            subImage4D=${runsub}_volreg_despike_mni_5mm_176tr   # Its long and ugly, so wrap it in a variable

            #-------------------------------------#
            # Define pointers for Functional data #
            #-------------------------------------#
            RUN=Run$i
            FUNC=${DATA}/${sub}/Func/${RUN}

            #---------------------------------#
            # Define pointers for GLM results #
            #---------------------------------#
            BASE=${ANALYSIS}/GLM
            STIM=${BASE}/STIM
            GLM=${BASE}/${sub}/${RUN}
            ID=${GLM}/1D
            MASK=${GLM}/Mask
            IMAGES=${GLM}/Images
            STATS=${GLM}/Stats
            FITTS=${GLM}/Fitts
            ERRTS=${GLM}/Errts

            #---------------------------#
            # Define pointers for TTEST #
            #---------------------------#
            TTEST=${ANALYSIS}/TTEST/${sub}/${RUN}

            #--------------------#
            # Initiate functions #
            #--------------------#
            # sub171 has not be preprocessed yet, so we will skip it for now.
            if [[ $sub != "sub171" ]]; then

                setup_subjdir
                regress_motion ${runsub} 2>&1 | tee -a ${GLM}/log_motion.txt
                regress_masking ${subImage4D} 2>&1 | tee -a ${GLM}/log_mask.txt

                for delay in {0..7}; do     # This is a loop which runs the deconvolution at each delay (in seconds) the result of which is 8 seperate processes run.
                    regress_convolve ${delay} ${subImage4D} 2>&1 | tee -a ${GLM}/log_convolve.txt
                    regress_plot ${delay} ${subImage4D} 2>&1 | tee -a ${GLM}/log_plot.txt
                    group_bucket_stats ${delay} ${subImage4D} 2>&1 | tee ${TTEST}/log_bucket.txt
                done
                # regress_alphcor ${subImage4D} 2>&1 | tee ${GLM}/log_alphacor.txt
            fi
        done
    done

    # When we have finished the analysis, Review the data!
    Review_Main $condition
}



#================================================================================
#                              START OF MAIN
#================================================================================

opt=$1  # This is an optional command-line variable which should be supplied
        # in for testing purposes only. The only available operation should
        # be "test"
cond=$2

range=$3

# Check whether Test_Main should or Main should be run
case $opt in
    "test" )
        Test_Main 2>&1 | tee /Volumes/Data/Exps/Analysis/Russian/GLM/log.TEST.txt
        ;;
  "review" )
        Review_Main $cond >&1 | tee /Volumes/Data/Exps/Analysis/Russian/GLM/log.REIVEW.txt
        ;;
      * )
        Main $opt 2>&1 | sudo tee -a /Volumes/Data/Exps/Analysis/Russian/GLM/log.GLM.txt
        ;;
esac



#================================================================================
#                              END OF MAIN
#================================================================================

