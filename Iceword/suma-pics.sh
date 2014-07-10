#!/bin/bash


# # Open afni and suma, wait 8 seconds or so because it takes SUMA a while to open
# afni -niml & suma -spec /usr/local/suma_MNI_N27/MNI_N27_both.spec -sv /usr/local/suma_MNI_N27/MNI_N27_SurfVol.nii -niml & sleep 8


# ## CHANGE SUMA OPTIONS

# #size of window

# DriveSuma -com viewer_cont -viewer_size 1920 1200

# #Change the backgroud to white and get rid of the crosshairs

# DriveSuma -com viewer_cont -key F3 -key F1

# #talk to AFNI *NB Must have pressed NIML button on AFNI

# DriveSuma -com viewer_cont -key t

# #start recorder

# DriveSuma -com viewer_cont -key R

# # MAP RESULTS

# plugout_drive -com "SET_ANATOMY /Volumes/Data/StructuralImage/MNI_N27_SurfVol.nii" -quit

# #the following text file contains the location of the the functional images you wish to overlay

# maps=$( cat ttest_image_list.txt )


# while read image; do
#     map=`echo ${i} | cut -d '.' -f 1`
#     plugout_drive -com "SWITCH_FUNCTION A.${i}" \
#     -quit

#     sleep 2
#     DriveSuma \
#     -com re corder_cont -save_as ./righthem_${map}_m.jpg \
#     -com sleep 1
# done <ttest_image_list.txt

#==========================================================================================

#The following text file contains the location of the the functional images you wish to overlay
maps=$( cat ttest_image_list.txt )


function dataLoop() {
    fname=$1
    while read image; do
        map=`echo $image | cut -d '.' -f 1 | cut -d '/' -f2`

        plugout_drive \
              -com "SWITCH_FUNCTION ${image}" \
              -com "SET_PBAR_SIGN +" \
              -com "SET_THRESHNEW A 0.05 *p" -quit

        sleep 2
        DriveSuma \
            -com recorder_cont -save_as ${fname}_${map}.jpg

    done <ttest_image_list.txt

} # End of dataLoop



# Open afni and suma, wait 8 seconds or so because it takes SUMA a while to open
afni -yesplugouts -niml & suma -spec /usr/local/suma_MNI_N27/MNI_N27_both.spec -sv /usr/local/suma_MNI_N27/MNI_N27_SurfVol.nii -niml & sleep 8
plugout_drive -com "SWITCH_UNDERLAY MNI_N27_SurfVol.nii" \
              -com "SEE_OVERLAY +" \
              -com "SET_PBAR_SIGN +" \
              -quit


## CHANGE SUMA OPTIONS
DriveSuma -com viewer_cont -key t

# Sleep to let me set the cluster correction level
sleep 2

#size of window
DriveSuma -com viewer_cont -viewer_size 1920 1200

#Turn the background colors and crosshair to OFF
DriveSuma -com viewer_cont -key b -key F3


# Remove the Right Hemisphere for Left Medial Shot
DriveSuma -com viewer_cont -key 'ctrl+right' -key R
dataLoop R-Lat

# # Remove the Left Hemisphere for Right Medial Shot
DriveSuma -com viewer_cont -key ']'
dataLoop L-Med

DriveSuma -com viewer_cont -key 'ctrl+left'
dataLoop L-Lat


DriveSuma -com viewer_cont -key ']' -key '['
dataLoop R-Med

# #start recorder
# # DriveSuma -com viewer_cont -key R

# # MAP RESULTS

# #talk to AFNI *NB Must have pressed NIML button on AFNI
