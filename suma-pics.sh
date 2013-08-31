#!/bin/bash

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

# Connect Suma to afni
DriveSuma -com viewer_cont -key t

# Set the size of window
DriveSuma -com viewer_cont -viewer_size 1920 1200

# Turn the background colors and crosshair to OFF
DriveSuma -com viewer_cont -key b -key F3

# Move brain to show right lateral side and start recorder
DriveSuma -com viewer_cont -key 'ctrl+right' -key R
dataLoop R-Lat

# Remove the Right Hemisphere for Left Medial Shot
DriveSuma -com viewer_cont -key ']'
dataLoop L-Med

# Move brain for Left lateral shot
DriveSuma -com viewer_cont -key 'ctrl+left'
dataLoop L-Lat

# Restore Right hemisphere and Remove the Left Hemisphere for Right Medial Shot
DriveSuma -com viewer_cont -key ']' -key '['
dataLoop R-Med
