#!/bin/python
#==============================================================================
#   Program Name: wb1_unlearn_format.py
#         Author: Kyle Reese Almryde
#           Date: Today
#    Description: This script formats the text file:
#                 'tbl_clusters_unlearnable_manual+5p.txt' Elena gave me. Its
#                 mainly used as an exercise in python for my own sake, but in
#                 case Elena is reading this... it reads the text file provided
#                 and line by line, pulls out the requested information from the
#                 first field and places it in its own field, thereby allowing
#                 us to independently identify the component#, Scan#, and
#                 hemisphere. This will result in much easier sorting and
#                 organization of our data later on.
#
#         Notes:  Regarding this as an exercise in using Python for text
#                 processing: Ive been struggling to use other open source tools
#                 in various mixed computing enviornments for a few years now
#                 and its never been that effective or efficient. Particularly
#                 when I had to look at the code days, weeks, or months later.
#                 I wanted to give Python a try for a few reasons:
#                 1) Im taking a class and I might as well get some bang for
#                    my buck
#                 2) Python is easy to read, easy to write, and easy to learn,
#                    so I can be fairly confident in others or myself being
#                    able to understand the code at a later time.
#                 3) Python has some pretty powerful text processing capablities
#                    on a level much greater than that of awk or sed, with the
#                    added benefit of it all being in one language rather than
#                    two (plus bash). So instead of trying to wrap my head around
#                    multiple langauge's syntax, Im only doing it with one. Not
#                    to mention, Python is quite popular both in industry and
#                    within the scientific and academic community, so its worth
#                    jumping on the bandwagon as its in high demand.
#                 4) Last but not least, Python is considered a scripting language
#                    and at least in my opinion act much like bash, so I could
#                    fairly easily ditch bash all together and just use Python
#                    for daily tasks.
#
#==============================================================================
#                            FUNCTION DEFINITIONS
#==============================================================================

fin = open('tbl_clusters_unlearnable_manual+5p.txt')  # Input file, read in data
fout = open('Wb1_unlearnable_clusters.txt', 'w')      # Output file, write out


#-----------------------------------------
# This function writes the header of the
# output file. In addition to the supplied
# information, it also adds the following
# fields: component, scan, and hemisphere
# to the header
#-----------------------------------------

def writeHeader(row):
    size = len(row)
    for col in range(size):
        if col == 0:
            fout.write(row[0] + '\tcomponent\tscan\themisphere\t')
        elif col == size - 1:
            fout.write(row[col])
        else:
            fout.write(row[col] + '\t')


#-----------------------------------------
# This function organizes the contents of
# the supplied row and prints them to the
# desired output file. Additionally it
# pulls the desired information from the
# first 'field' and prints them in their
# own field.
#-----------------------------------------

def organizeRow(row):
    size = len(row)
    img = row[0].split('_')   # This is a list composed of the img field, split based on the '_' separator
    scan = img[7][1:] + '\t'  # This is the scan #, with a tab character concatenated for easy printing
    comp = img[8][2:] + '\t'  # This is the component #
    hemi = img[11] + '\t'     # This is the hemisphere

    for col in range(size):
        if col == 0:
            fout.write(row[0] + '\t' + comp + scan + hemi)
        elif col == size - 1:
            fout.write(row[col])
        else:
            fout.write(row[col] + '\t')


#==============================================================================
#                                START OF MAIN
#==============================================================================

i = 0  # This will act as a counter so we know when to call the writeHeader function
for line in fin:             # Read each line one by one
    row = line.split(' ')    # Create a list object containing the individual fields
    if i == 0:               # If this is the first row, call writeHeader
        writeHeader(row)
    else:                    # Otherwise, call organizeRow
        organizeRow(row)
    i += 1                   # Increase the counter by one so we know which row we
                             # are on.

fin.close()   # Close the input file to free up memory
fout.close()  # Do the same to the output file
