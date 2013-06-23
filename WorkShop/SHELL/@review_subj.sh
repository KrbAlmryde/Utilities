#================================================================================
#    Program Name: review_subj.sh
#          Author: Kyle Reese Almryde
#            Date: 01/29/2013 @ 14:29:38 PM
#
#     Description: This program will call afni's driver program to open and review
#                  all files within a single subjects directory. The ideal
#                  application for this would be to make this script resuable
#                  across all studies and modes. There are two types of driver
#                  functions, the first is simply an image slice review, intended
#                  for use with anatomical images, though functional data is also
#                  applicable under this mode. The next function will be for those
#                  data files used as timeseries. The driver will open an image,
#                  then cycle through each volume. Each function will take a list
#                  of one or more file names, for which it will then iterate over
#                  asking the user to 'hit enter to view next image'
#
#
#    Deficiencies: There is some prototype shell code at the beginning, the actual
#                  function definition is legit python code.
#
#
#
#
#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================

sub=$1
RD="/Volumes/Data/Iceword/${sub}/Func/Run1/RealignDetails"
MORPH="/Volumes/Data/Iceword/${sub}/Morph"
subj=${RD}/${sub}

dsets=(`ls ${subj}-*.nii`)

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
    -quit

sleep 2    # give afni time to open the windows


# ------------------------------------------------------
# process each dataset using video mode


for dset in ${dsets[*]}; do
    plugout_drive                        \
        -skip_afnirc                               \
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
