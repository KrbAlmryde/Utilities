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
#                  unstable at the point. Primary construction is still
#                  incomplete.
#
#================================================================================
#                              SETUP DEFINITIONS
#================================================================================
# Source the context dependent variables and pathnames.
source /usr/local/Utilities/PROFILE/Base.funcs.sh ${1}

if [[ $# -lt 3 ]]; then
    HelpMessage
else
    context=${1}    # This is the study profile (can also be test). It is called
    shift           # context because it represents the context with which the
                    # pipelines and functions will execute. Or something...

    operation=${1}  # Can be either a <Pipeline>, or it can be a <function> both
    shift           # must exist, whether as a default Pipleine/Function, or a
fi                  # context specific Pipeline/Function

#================================================================================
#                                 START OF MAIN
#================================================================================
# check_status  # Check the status of afni's version, update if necessary

echo "Context: ${context}    Operation: ${operation}"


while (($#)); do
    sub=`printf "sub%03d" ${1%-*}`
    scan=run${1#*-}
    sunbrun=${sub}_${scan}
    RDIR=Run${1#*-}

    source ${PFL}/${context}.profile.sh ${operation}

    echo $sub
    echo $scan
    echo $sunbrun
    echo $RDIR


    shift
done




# while getopts ":a:A:s:S:r:R:hH" Option; do

#     case $Option in
#         a | A )
#                 scan=run${OPTARG#*-}
#                 subj=`printf "sub%02d" ${OPTARG%-*}`
#                 echo "Subject: ${subj}    Scan: ${scan}"
#                 # check_execute_A() ${subj} ${scan}
#                 ;;
#         r | R )
#                 scan=run${OPTARG#*-}
#                 echo "    Scan: ${scan}"
#                 # check_execute_B() ${scan}
#                 ;;
#         s | S )
#                 subj=`printf "sub%02d" ${OPTARG%-*}`
#                 echo "    Subject: ${subj}"
#                 ;;
#         h | H )
#                 HelpMessage
#                 ;;
#     esac

# done

#================================================================================
#                                  END OF MAIN
#================================================================================
echo "         Our Motto:
    We've suffered so you wont have to!
  Putting the RE in REsearch to good use!
 Its not Rocket science, its BRAIN science!
"

exit 0
