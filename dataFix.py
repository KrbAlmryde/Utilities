"""
==============================================================================
Program: dataFix.py
 Author: Kyle Reese Almryde
   Date: 02/28/2014

 Description: Replaces missing values in a behavioral score report based on
              scaled difficulting ratings and weighted "ability" metrics for
              subjects who have participated in a behavioral research
              experiment. If a subject has not taken then entire battery of
              tests they will not have scores computed for them.

==============================================================================
"""

import sys
import os
from glob import glob
import subprocess as sp



#=============================== START OF MAIN ===============================

def main():
    # Several datafiles, each with a long list of subjects
    SubTestFiles = []
    ItemDiffFiles = []
    SubjAbilityFiles = []


    for i, s in enumerate(range(1,13)):
        subj = "sub{:03d}".format(s)
        subjData = "{0}_data_stuff".format(subj)
        subjDiff = "{0}_difficulty_ratings".format(subj)
        subjAblt = ""
        subjDict[subj] = []

    subjList = ["sub{:03d}".format(x) for x in range(1,11)];







if __name__ == '__main__':
    main()


    # This is just a useful command
    # [line.split() for line in open("Subject_Data_File.txt")]
