#================================================================================
#    Program Name: review_subj.py
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
from subprocess import call
from os import popen

"""This is kind of a bust, as the command 'plugout_drive' itself takes string
inputs. So trying to compound non-strings to with strings is tricky and not
really worht the effort.
"""
def view_anatomy(infiles, anat):
    for dset in infiles:
        'plugout_drive -skip_afnirc'

        coms = ["{0}", "{1}", "{2}", "{3}", "{4}", "{5}","{6}"]

        driver = [
            "SWITCH_UNDERLAY {anat}",
            "SWITCH_OVERLAY {dset}",
            "SET_DICOM_XYZ A 0 20 40",
            "OPEN_WINDOW A.axialimage geom=492x585+1944+66 ifrac=0.8 opacity=8",
            "OPEN_WINDOW A.sagittalimage geom=605x479+2551+66 ifrac=0.8 opacity=8",
            "OPEN_WINDOW A.coronalimage geom=554x520+3231+44 ifrac=0.8 opacity=8",
            "OPEN_WINDOW A.axialimage keypress=v"]

        anatDriver = " -com ".join(driver) + " -quit"
        cmd = anatDriver.format(**{'anat': anat, 'dset': dset})
        popen(cmd)
        # print "\n", anatDriver.format(**{'anat': anat, 'dset': dset}), "\n"

        raw_input("Press <Return> to continue: ")

