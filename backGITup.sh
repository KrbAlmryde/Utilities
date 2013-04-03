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

UTL=/usr/local/Utilities

git add ${UTL} -A
git commit -m "Routine commit and backup"
git push origin master
