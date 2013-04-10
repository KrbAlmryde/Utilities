#!/bin/bash
#================================================================================
#    Program Name: backGITup.sh
#          Author: Kyle Reese Almryde
#            Date: today
#
#     Description:
#
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

#================================================================================
#                                START OF MAIN
#================================================================================

UTL='/usr/local/Utilities'
CLASS='/Users/kylealmryde/Dropbox/CLASS'

# cd ${UTL}

# cd ${CLASS}
# git add . -A
# git commit -m "Routine commit and backup"
# git push


for dir in $UTL $CLASS; do
    cd $dir
    git add . -A
    git commit -m "Routine commit and backup"
    git push
done