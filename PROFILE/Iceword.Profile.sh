#!/bin/bash
#================================================================================
#    Program Name: Iceword.Profile.sh
#          Author: Kyle Reese Almryde
#            Date: 02/06/2013 @ 10:34:16 AM
#
#     Description: This Profile contains the metadata for the entire Iceword study.
#                  All necessary varaibles are defined within, as well as all
#                  programs and functions.
#
#    Deficiencies: Probably a lot. It still a work in progress...
#
#     Study Notes: One possible ideas is to treat this file as the README file
#                  for the whole study. That way everything needed can be
#                  accessed from one source. When the time comes to publish, all
#                  study related notes are provided, and the production code used
#                  is already available, which can be easily applied to later
#================================================================================
#                              SETUP DEFINITIONS
#================================================================================
source /usr/local/Utilities/PROFILE/BASE.Profile.sh

#---------------------------------#
#       Directory Pointers        #
#---------------------------------#
BASE="/Volumes/Data/Iceword"
RD="${BASE}/${sub}/Func/${SDIR}/RealignDetails"
OLDICE=/Volumes/Data/ETC/ICEWORD

#---------------------------------#
#       Function Variables        #
#---------------------------------#
tr=2400     # repetition time in milliseconds
nfs=218     # number of functional scans
nas=22      # number of functional slices
fov=220     # field of view for functional and FSE
thick=6     # Z-slice thickness for functional and FSE

#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================


function makeImageCorrections() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Make various corrections to problematic images
    #
    #
    #       Input:
    #
    #    Output:
    #
    #------------------------------------------------------------------------

    local DIRNAME=/path/
    local var=param1

} # End of makeImageCorrections


function reviewFunc() {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function calls afni's plugout_drive utility to drive the
    #           GUI in such a way as to review subject data and information.
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local DIRNAME=/path/
    local var=param1

    sub=$1
    scan=$2

    dsets=(`ls ${RD}/${sub}-*.nii`)

    cd $RD
    afni -yesplugouts &
    sleep 5

    plugout_drive                                  \
        -skip_afnirc                               \
        -com "SWITCH_UNDERLAY ${dsets[0]}"         \
        -com "OPEN_WINDOW sagittalimage            \
                          geom=300x300+420+400"    \
        -com "OPEN_WINDOW axialimage               \
                          geom=300x300+720+400"    \
        -com "OPEN_WINDOW sagittalgraph            \
                          geom=400x300+0+400"      \

    sleep 2    # give afni time to open the windows


    # ------------------------------------------------------
    # process each dataset using video mode

    for dset in ${dsets[*]}; do
        plugout_drive                        \
            -com "SWITCH_UNDERLAY $dset"     \
            -com "OPEN_WINDOW sagittalgraph  \
                              keypress=a     \
                              keypress=v"    \
            -quit

        sleep 2    # wait for plugout_drive output

        echo ""
        echo "++ now viewing $dset, hit enter to continue"
        read -s -n 1    # wait for user to hit enter
    done


} # End of reviewFunc



function reviewAnat() {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function calls afni's plugout_drive utility to drive the
    #           GUI in such a way as to review subject data and information.
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local DIRNAME=/path/
    local var=param1

    sub=$1
    scan=$2
    MORPH="${BASE}/${sub}/Morph"
    dsets=(`ls ${MORPH}/${sub}-*.nii`)


    cd $MORPH
    afni -yesplugouts &
    sleep 5

    # ------------------------------------------------------
    # process each dataset using video mode

    for dset in ${dsets[*]}; do
        plugout_drive                                  \
            -skip_afnirc                               \
            -com "SWITCH_UNDERLAY $dset"               \
            -com "OPEN_WINDOW axialimage keypress=v"   \
            -com "OPEN_WINDOW sagittalimage"            \
            -com "OPEN_WINDOW coronalimage"             \
            -quit

        sleep 2    # wait for plugout_drive output

        echo ""
        echo "++ now viewing $dset, hit enter to continue"
        read -s -n 1    # wait for user to hit enter
    done


} # End of reviewAlign




function testIce() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Test to ensure that variables are being passed correctly.
    #
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    echo "${RD}"

} # End of testIce


#================================================================================
#                                START OF MAIN
#================================================================================

