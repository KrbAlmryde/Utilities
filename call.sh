#!/bin/bash
#================================================================================
#    Program Name: call.sh
#          Author: Kyle Reese Almryde
#            Date: 02/03/2013 @ 19:41:53 PM
#
#     Description: The purpose of this script is to drive various processing and
#                  analysis steps for fMRI data under study specific conditions.
#                  It acts in some ways to that of an operator hub which
#                  coordinates the interactions of variables coming into scope
#                  with different functions and programs.
#
#    Deficiencies: Presently this project is incomplete. Code functionality is
#                  presently unstable at the moment. Primary construction is
#                  still incomplete.
#
#================================================================================
#                              FUNCTION DEFINITIONS
#================================================================================

context=${1}    # This is the study profile (can also be test). It is called
                # context because it represents the context of with which the
                # pipelines and function will execute. Or something...

operation=${2}  # Can be either a <Pipeline>, or it can be a <function> both
                # <<case-sensitive>> Both must exist, whether as a default
                # Pipleine/Function, or a context specific Pipeline/Function

CONTEXT="/Volumes/Data/${context}"
PROFILE="/usr/local/Utilities/PROFILE"
PROG="/usr/local/Utilities/PROG"
BLOCK="/usr/local/Utilities/BLK"

#================================================================================
#                                 START OF MAIN
#================================================================================

# Source the context dependent variables and pathnames. A study specific
source ${PROFILE}/${context}.profile.sh


context=${1}
operation=${2}
shift
shift

while getopts ":s:" Option; do
    case $Option in
        s | S )
                scan=run${OPTARG#*-}
                subj=`printf "sub%02d" ${OPTARG%-*}`
                ;;
            * )
                usageMessage() ;;
    esac


    # First check to see if there is a context specific operation, do this for a specific program
    if [[ -e ${PROG}/${context}.${operation}.sh ]]; then
        cmd="${PROG}/${context}.${operation}.sh ${subj} ${scan}"

    # Next check to see if there is a context specific operation, do this for a specific Pipeline
    elif [[ -e ${BLOCK}/${context}.${operation}.sh ]]; then
        cmd="${BLOCK}/${context}.${operation}.sh ${subj} ${scan}"

    # If both of those options fail, check for a default program by that identifier
    elif [[ -e ${PROG}/${operation}.sh ]]; then
        cmd="${PROG}/${operation}.sh ${subj} ${scan}"

    # Then check for a default Pipeline under that name.
    elif [[ -e ${BLOCK}/${operation}.sh ]]; then
        cmd="${BLOCK}/${operation}.sh ${subj} ${scan}"

    # Otherwise, display this usage message and exit the program.
    else
        usageMessage()
    fi


    . ${cmd} 2>&1 | tee -a ${CONTEXT}/log.${context}.${operation}.txt
done

#================================================================================
#                                  END OF MAIN
#================================================================================

echo "Our Motto"
echo "We've suffered so you wont have to!"
echo "Because we put the RE in RESEARCH"
echo "afterall"
echo "Its not Rocket science, its BRAIN science!"
echo ""
exit 0