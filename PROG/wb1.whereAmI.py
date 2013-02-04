"""
==============================================================================
Program: wb1.whereAmI.py
 Author: Kyle Reese Almryde
   Date: 11/09/12 @ 06:23 PM

Description:



==============================================================================
"""

import os

fin = open('/usr/local/utilities/xyzCoords.txt')
fout = open('/usr/local/utilities/wb1_SS_Cluster_ROIs.txt', 'w')

lines = fin.readlines()

for ln in lines:
    xyz = ' '.join(ln.split())
    atlas = os.popen('whereami ' + xyz
                   + ' -atlas CA_ML_18_MNIA -lpi').readlines()
    index = atlas.index('Atlas CA_ML_18_MNIA: Macro Labels (N27)\n')
    roi = atlas[index + 1].split(':')[1].strip().split()
    fout.write(roi[0] + '\t' + ' '.join(roi[1:]) + '\n')
fin.close()
fout.close()
