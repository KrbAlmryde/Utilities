#================================================================================
# Directory Name: Tills_Data
#         Author: Kyle Reese Almryde
#           Host: Hagar@128.196.62.95
#           Date: 03/13/2014
#
#        Project: Tills
#             PI: Dr. Elena Plante
#          Grant: ??
#
#    Description: Contains corrected Tills Subtest data. Presently all Subtests
#                 have been corrected except Subtests 11-13, which is awaiting
#                 the final measure files completion.
#
#
#       Contents: data/
#                      contains the raw data for all subtests
#                 measure/
#                       contains item & person measures for all subtests
#                 final/
#                       contains corrected datafiles for each subtest
#                 excel_files/
#                       construction files to arrange the measure files.
#                 Tests/
#                       Mirrored version of the parent directory. Contains
#                       test cases to ensure program is working satisfactorily.
#                       There is an intentionally problematic dataset to 
#                       demonstrate the error logging capabilities of this
#                       program
#
#          Tools: dataFix.py
#                    Python script used to apply corrections to the datasets.
#                    If you want to run the script yourself, open a terminal,
#                    navigate to this directory and type the following:
#                       python dataFix.py
#                   
#                   Optionally to test the program first against a dataset or
#                   two without running the entire analysis, do the following:
#                       python dataFix.py Tests
#
#                 dataPrep.py
#                   Python script used to extract data from excel files and
#                   convert them to text files for dataFix.py. This program 
#                   requires the external module Pandas in order to work. It 
#                   is not mission critical to this project and was included 
#                   primarily for posterity. To run it, type:
#                       python dataPrep.py               
#
#  Current State: complete
#
#================================================================================