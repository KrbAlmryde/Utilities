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

UTL=/usr/local/Utilities/*
SCRIPTS=/Users/kylealmryde/Dropbox/Scripts/*
CLASS=/Users/kylealmryde/Dropbox/CLASS/*

git add ${UTL} -A
git add ${SCRIPTS} -A
git add ${CLASS} -A
git commit -m "Routine commit and backup"
git push origin master
