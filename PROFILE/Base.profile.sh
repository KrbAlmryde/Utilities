#!/bin/bash
#================================================================================
#    Program Name: Base.profile.sh
#          Author: Kyle Reese Almryde
#            Date: 02/05/2013 @ 12:15:56 PM
#
#     Description: The base profile is intended to provide default functionality
#                  to the main call system. It defines generic coordination
#                  and usageMessage functions, as well as provide base path
#                  definitions to various locations in the system. It should be
#                  sourced by the call interface script.
#
#    Deficiencies: At the moment this script is still a work in progress. Expect
#                  bugs and erros until otherwise mentioned.
#
#================================================================================
#                                START OF MAIN
#================================================================================

echo "--------------------- Base.profile.sh has been sourced! ---------------------"
context=$1
#=================================
# Experiment Path Variables
#=================================
ATTNMEM="/Volumes/Data/ATTNMEM"
BEHAV="/Volumes/Data/BEHAV"
STROOP="/Volumes/Data/STROOP"
TAP="/Volumes/Data/TAP"
RAT="/Volumes/Data/RAT"
WORDBOUNDARY="/Volumes/Data/WordBoundary1"
WB1="/Volumes/Data/WB1"
ICE="/Volumes/Data/Iceword"

#===========================
# Script Path Variables
#===========================
UTL="/usr/local/Utilities"      #
DVR="${UTL}/DRIVR"              #
PFL="${UTL}/PROFILE"            #
LST="${UTL}/LST"                #
BLK="${UTL}/BLK"                #
PRG="${UTL}/PROG"               #
STM="${UTL}/STIM"               #

#===============================================================================
# Define a general experimental variables, specifically subject, run, and conditions
#===============================================================================

#===============================================================================
# Define Hemodynamic Response Model types into an array
#===============================================================================

model[0]='WAV'  # The cox special
model[1]='GAM'  # A common gamma variate model
model[2]='SPMG'
#===============================================================================
#
#===============================================================================

case $context in
    "attnmem" )
            BASE=$ATTNMEM
            ;;

    "behav" )
            BASE=$BEHAV
            ;;

    "stroop" )
            BASE=$STROOP
            ;;

    "tap" )
            BASE=$TAP
            ;;

    "dich" )
            BASE=$DICHOTIC
            ;;

    "rat" )
            BASE=$RAT
            ;;

    "sld" )
            BASE=$STROOPLD
            ;;

    "word" )
            BASE=$WORDBOUNDARY
            ;;

    "wb1" )
            BASE=$WORDBOUNDARY
            ;;
esac





#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


function check_status() {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function checks the status of the current build of afni
    #           and decides whether or not it needs to be updated. If the
    #           check returns 1, then afni is too old and needs to be updated
    #           at which point it will call @update.afni.binaries -defaults
    #
    #    Input: None
    #
    #   Output: None
    #
    #------------------------------------------------------------------------
    date=$(echo `afni -ver` | awk "{print $6,$7,$8}" | sed 's/]//g')

    echo -n "AFNI version "
    afni_history -check_date $date   # $(date +"%d %B %Y")

    if [[ $? -ne 0 ]]; then
        echo "** this script requires newer AFNI binaries (than "$(date +"%B %d %Y")
        sudo @update.afni.binaries -defaults
        exit

    else
        echo
    fi

} # End of check_status


function each() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Will iterate over each subject and run based on the context
    #           profile information provided. Subjects and Runs are defined
    #           within Context.
    #
    #    Input: A function, which will be context dependent in that the name
    #           of the function called must be defined within the context's
    #           namespace.
    #
    #   Output: Varies, dependant on the function called.
    #
    #------------------------------------------------------------------------

    local calledFunction=$1
    local SUBJECTS=$SUBJECTS
    local RUNS=$RUNS

    echo -e "Executing $calledFunction for each subject and run....\n"

    for subj in ${SUBJECTS[*]}; do
        for run in ${RUNS[*]}; do
            $calledFunction subj scan
        done
    done


} # End of each



function HelpMessage() {
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

    echo "-----------------------------------------------------------------------"
    echo "+            +++ Missing 1 or more required Arguments +++             +"
    echo "+                                                                     +"
    echo "+             This program requires at least 3 arguments              +"
    echo "+                                                                     +"
    echo "+      NOTE: [words] in square brackets represent possible input      +"
    echo "+                   See below for available options                   +"
    echo "+                                                                     +"
    echo "-----------------------------------------------------------------------"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "   +                Experimental condition                       +"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "   +                                                             +"
    echo "   +  [Ice]   or  [Iceword]    For the Learnable Condtion    +"
    echo "   +  [wb1] or  [WordBoundary]  For the Unlearnable Condtion  +"
    echo "   +  [debug]   or  [test]         For testing purposes only     +"
    echo "   +                                                             +"
    echo "   +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "-----------------------------------------------------------------------"
    echo "+                   Example command-line execution:                   +"
    echo "+                                                                     +"
    echo "+                 call Ice Preprocess {1..19}-{1..4}                  +"
    echo "+                                                                     +"
    echo "+                       +++ Please try again +++                      +"
    echo "-----------------------------------------------------------------------"

    exit 1

} # End of HelpMessage



function usageMessage() {
    #------------------------------------------------------------------------
    #
    #  Purpose:
    #
    #
    #       Input:
    #
    #    Output:
    #
    #------------------------------------------------------------------------

    echo "usageMessage: Nothing to see here..."

} # End of usageMessage

function usageMessage2() {
    #------------------------------------------------------------------------
    #
    #  Purpose:
    #
    #
    #       Input:
    #
    #    Output:
    #
    #------------------------------------------------------------------------

    echo "usageMessage2: Nothing to see here..."

} # End of usageMessage2






function check_execute {
    #------------------------------------------------------------------------
    #
    #  Purpose: Will check those programs and scripts which take a subject
    #           and scan id as parameters for execution.
    #
    #    Input: subj, scan -- The subject and scan Ids respectively
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    local cmd

    source ${PFL}/${context}.profile.sh

    # First check to see that there are the correct number of arguments,
    # if not display this usage message and exit the program.
    if [[ $# -lt 2 ]]; then
        usageMessage2

    # Otherwise check to see if there is a context specific operation, do this for a specific program
    elif [[ -e ${PROG}/${context}.${operation}.sh ]]; then
        cmd="${PROG}/${context}.${operation}.sh ${sub} ${scan}"

    # Next check to see if there is a context specific operation, do this for a specific Pipeline
    elif [[ -e ${BLOCK}/${context}.${operation}.sh ]]; then
        cmd="${BLOCK}/${context}.${operation}.sh ${sub} ${scan}"

    # If both of those options fail, check for a default program by that identifier
    elif [[ -e ${PROG}/${operation}.sh ]]; then
        cmd="${PROG}/${operation}.sh ${sub} ${scan}"

    # Then check for a default Pipeline under that name.
    elif [[ -e ${BLOCK}/${operation}.sh ]]; then
        cmd="${BLOCK}/${operation}.sh ${sub} ${scan}"

    else
        cmd="${operation} ${sub} ${scan}"
    fi

    . ${cmd} 2>&1 | tee -a ${CONTEXT}/log.${context}.${operation}.txt

} # End of check_execute_A()


function check_execute_B() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Will check those programs and scripts which take a subject
    #           and scan id as parameters for execution.
    #
    #    Input: scan -- The scan Ids respectively
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    scan=$1
    local cmd

    # First check to see that there are the correct number of arguments,
    # if not display this usage message and exit the program.
    if [[ $# -lt 2 ]]; then
        usageMessage2

    # Otherwise check to see if there is a context specific operation, do this for a specific program
    elif [[ -e ${PROG}/${context}.${operation}.sh ]]; then
        cmd="${PROG}/${context}.${operation}.sh ${scan}"

    # Next check to see if there is a context specific operation, do this for a specific Pipeline
    elif [[ -e ${BLOCK}/${context}.${operation}.sh ]]; then
        cmd="${BLOCK}/${context}.${operation}.sh ${scan}"

    # If both of those options fail, check for a default program by that identifier
    elif [[ -e ${PROG}/${operation}.sh ]]; then
        cmd="${PROG}/${operation}.sh ${scan}"

    # Then check for a default Pipeline under that name.
    elif [[ -e ${BLOCK}/${operation}.sh ]]; then
        cmd="${BLOCK}/${operation}.sh ${scan}"

    fi

    . ${cmd} 2>&1 | tee -a ${CONTEXT}/log.${context}.${operation}.txt

} # End of check_execute_A()








#===============================================================================
                                ########### Functions ############
#===============================================================================
# Source useful functions that can be used in my scripts. These functions are meant to make semi-
# regular processes easier to use and access
#===============================================================================
# This function reads an outlier file looking for the lowest integer then prints the NUMBER line
# - 5 to account for time shifting and AFNI's penchant for starting timeseries with 0 (which is
# annoying), then exits, which causes awk to print only 1 value. This allows us to acquire a base
# value to register our data to.

function base_reg() {
    cat -n ${prep_dir}/${subrun}.outliers.txt      \
        | sort -k2,2n                               \
        | head -1                                   \
        | awk '{print $1-5}'
}




#===============================================================================
# This function uses the fsl toolbox and "bc" to calculate the Jaccard Index and distance
# statistics for two binary masks. The Jaccard Index measures the similarity between two binary
# masks, and the Jaccard Distance calculates the dissimilarity between those two images.
# Note: The scale=6 variable sets the number of decimal places to use.
# See the link below for more information about Jaccard Index
# http://en.wikipedia.org/wiki/Jaccard_index
# Based on a dice_kappa calculation script written by Matt Petoe 11/2/2011
# Original script ritten by Dianne Patterson 11/9/2011
# Modified by Kyle Almryde 1/18/2012

function jaccard_index() {
    roi1=$1;
    roi2=$2

    total_voxels1=`fslstats ${roi1} -V | awk '{printf $1 "\n"}'`
    echo "total voxels ${roi1} is ${total_voxels1}"

    total_voxels2=`fslstats ${roi2} -V | awk '{printf $1 "\n"}'`
    echo "total voxels ${roi2} is ${total_voxels2}"

    intersect_voxels=`fslstats ${roi1} -k ${roi2} -V | awk '{printf $1 "\n"}'`
    echo "intersect voxels are ${intersect_voxels}"

    fslmaths ${roi1} -add ${roi2} -bin union
    union_voxels=`fslstats union -V | awk '{printf $1 "\n"}'`
    echo "union voxels are ${union_voxels}"

    jaccard_index=`echo "scale=6; ${intersect_voxels}/${union_voxels}" | bc`
    echo "Jaccard index is ${jaccard_index}"

    jaccard_distance=`echo "scale=6; 1-(${intersect_voxels}/${union_voxels})" | bc`
    echo "Jaccard distance is ${jaccard_distance}"

    touch jaccard.txt
    echo "${roi1} ${roi2} ${jaccard_index} ${jaccard_distance}" >>${subrun}.jaccard.txt
}


#===============================================================================
# This string prints the contents of the file (cat), removes columns 10-73 (colrm 10 73: This makes
# it so only the Volume, Mean, Sem, Max Int, X, Y, and Z are printed) then removes any rows that
# begin with "#" from the output (sed '/^#/d') ((Note:^ represents the start of the line, the 'd'
# means delete)) the "." Following that, it replaces any combination of spaces within the text with
# a single space (tr -s '[:space:]'), which it is itself replaced with a tab (awk -v OFS='\t'
# '$1=$1') before limiting only the first 2 rows of the text (head -2)

function whereami_strip() {
    cat $1.txt | colrm 10 73 | sed '/^#/d' | tr -s '[:space:]' | awk -v OFS='\t' '$1=$1' \
        | head -2 > $1.strip.txt

    whereami -tab -atlas TT_Daemon -coord_file $1.strip.txt'[4,5,6]' | sed -n '/TT_Daemon/p' | \
        awk -v OFS='\t' '$1=$1 {print $2,$4,$5,$6}'| head -4 > $1.whereami.txt
}


#===============================================================================
# This function renames efiles specific to the fse anatomical scan

function rename_fse() {
    efile=$1
    j=1

    echo "rename fse e-files"
    echo "This script assumes files with the form e12345s2i*"
    echo ""

    while [ $j -le 99 ]
    do
        fname="${efile}2i${j}"
        if ! test -f $fname; then
            break
        fi

        echo "renaming image $j"

        if [ $j -le 9 ]; then
            mv $fname "${efile}2i00${j}"
        else
            mv $fname "${efile}2i0${j}"
        fi

        j=`expr $j + 1`
    done
}

#===============================================================================
#
# This function renames efiles specific to the spgr anatomical scan

function rename_spgr() {
    echo "rename spgr e-files"

    efile=e[0-9][0-9][0-9][0-9]s[789]i
    j=1

    while [ $j -le 99 ]
    do
        fname="${efile}${j}"
        if ! test -f $fname; then
            break
        fi

        echo "renaming image $j"

        if [ $j -le 9 ]; then
            mv $fname "${efile}7i00${j}"
        else
            mv $fname "${efile}7i0${j}"
        fi

        j=`expr $j + 1`
    done
}
#===============================================================================
