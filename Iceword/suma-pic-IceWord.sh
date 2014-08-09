#!/bin/bash

#The following text file contains the location of the the functional images you wish to overlay


function dataLoop() {
    fname=$1
    while read image; do
        map=`echo $image | cut -d '.' -f 1 | cut -d '/' -f2`
        case $image in
          IC18-all-2.6503.nii ) colorBar="1.000000=green1 0.962264=green2 0.720755=green3 0.267568=darkolivegreen2 0.245676=darkolivegreen3 0.243487=darkolivegreen4 0.243268=darkolivegreen"
            ;;  # colorBar="1.000000=darkslateblue 0.962264=darkorchid4 0.720755=blueviolet 0.267568=dk-blue 0.245676=deepskyblue3 0.243487=blue-cyan 0.243268=dodgerblue1"
          IC12-all-2.6503.nii ) colorBar="1.000000=firebrick1 0.962264=orange 0.720755=rbgyr20_17 0.267568=lightsalmon 0.245676=lightsalmon1 0.243487=lightsalmon2 0.243268=lightsalmon3"
            ;; # colorBar="1.000000=rbgyr20_15 0.962264=rbgyr20_17 0.720755=rbgyr20_19 0.267568=lightsalmon 0.245676=lightsalmon1 0.243487=lightsalmon2 0.243268=lightsalmon3"
          IC11-all-2.6503.nii ) colorBar="1.000000=rbgyr20_15 0.962264=darkgoldenrod1 0.720755=darkorange 0.267568=khaki1 0.245676=khaki2 0.243487=darkkhaki 0.243268=khaki4"
               # colorBar="1.000000=green1 0.962264=green2 0.720755=green3 0.267568=khaki1 0.245676=gold 0.243487=darkgoldenrod1 0.243268=yellow"
            ;; # colorBar="1.000000=green1 0.962264=green2 0.720755=green3 0.267568=khaki1 0.245676=khaki2 0.243487=darkkhaki 0.243268=khaki4"
          IC4-all-2.6503.nii ) colorBar="1.000000=dk-blue 0.962264=blue-cyan 0.720755=cyan 0.267568=darkslategray1 0.245676=darkslategray2 0.243487=darkslategray3 0.243268=darkslategray4"
        esac
        plugout_drive \
          -com "SWITCH_FUNCTION ${image}" \
          -com "SET_THRESHNEW A. 0.05 *p" \
          -com "SET_FUNC_RANGE A. 4.112" \
          -com "SET_PBAR_ALL A.+7 ${colorBar}" \
        -quit

        sleep 2
        DriveSuma \
            -com recorder_cont -save_as ${fname}_${map}.jpg

    done <ic_image_list.txt

} # End of dataLoop


# IC4 aka 1
# plugout_drive -com "SWITCH_FUNCTION IC4-all-2.6503.nii" -com "SET_FUNC_RANGE A. 4.112" -com "SET_PBAR_ALL A.+7 1.000000=cyan 0.962264=blue-cyan 0.720755=dk-blue 0.267568=darkslategray1 0.245676=darkslategray2 0.243487=darkslategray3 0.243268=darkslategray4" -quit

# IC12 aka 2
# plugout_drive -com "SWITCH_FUNCTION IC12-all-2.6503.nii" -com "SET_FUNC_RANGE A. 4.112" -com "SET_PBAR_ALL A.+7 1.000000=rbgyr20_17 0.962264=orange 0.720755=firebrick1 0.267568=lightsalmon 0.245676=lightsalmon1 0.243487=lightsalmon2 0.243268=lightsalmon3" -quit

# IC11 aka 3
# plugout_drive -com "SWITCH_FUNCTION IC11-all-2.6503.nii" -com "SET_FUNC_RANGE A. 4.112" -com "SET_PBAR_ALL A.+7 1.000000=rbgyr20_15 0.962264=darkgoldenrod1 0.720755=darkorange 0.267568=khaki1 0.245676=khaki2 0.243487=darkkhaki 0.243268=khaki4" -quit

# IC18 aka 4
# plugout_drive -com "SWITCH_FUNCTION IC18-all-2.6503.nii" -com "SET_FUNC_RANGE A. 4.112" -com "SET_PBAR_ALL A.+7 1.000000=green1 0.962264=green2 0.720755=green3 0.267568=darkolivegreen2 0.245676=darkolivegreen3 0.243487=darkolivegreen4 0.243268=darkolivegreen" -quit

# Open afni and suma, wait 8 seconds or so because it takes SUMA a while to open
afni -yesplugouts -niml & suma -spec /usr/local/suma_MNI_N27/MNI_N27_both.spec -sv /usr/local/suma_MNI_N27/MNI_N27_SurfVol.nii -niml & sleep 8
plugout_drive -com "SWITCH_UNDERLAY MNI_N27_SurfVol.nii" \
              -com "SEE_OVERLAY +" \
              -com "SET_PBAR_SIGN +" \
              -com "SET_PBAR_NUMBER 7" \
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
