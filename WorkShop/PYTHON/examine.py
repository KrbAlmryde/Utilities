"""
==============================================================================
     Program: Program Name.py
      Author: Kyle Reese Almryde
        Date: 12/10/2012 @ 11:06:32 AM

 Description: This simple program examines the data in Word Boundary ICA paper
              to ensure that what is documented in the table data, is
              corroborated in the manuscript itself. It utilizes data from
              a seperate file called "ROIdata.py" which contains a
              multi-dimensional array with each ROI data point. This program
              only examines the data in terms of internal relationships, it
              does not conduct any mathmatical or statistical analysis.
==============================================================================
"""
from pandas import DataFrame
from ROIdata import data
from HighPredictability import dset
# import pandas as pd
# import numpy as np


def buildDataFrame(frame, rightDict, leftDict):
    for i in range(len(frame.ROI)):
        for roi in frame.ROI.unique():
            if frame.Hemi[i] == 'L':
                checkScan(frame, leftDict, i, roi)
            else:
                checkScan(frame, rightDict, i, roi)


def checkScan(frame, roiDict, index, roi):
    if frame.ROI[index] == roi:
        if roi not in roiDict:
            roiDict[roi] = {'Count': 0, 'Scan1': 0, 'Scan2': 0, 'Scan3': 0}
        elif frame.Scan1[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan1'] = frame.Comp[index]
        elif frame.Scan2[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan2'] = frame.Comp[index]
        elif frame.Scan3[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan3'] = frame.Comp[index]


def buildDataFrame2(frame, rightDict, leftDict):
    for i in range(len(frame.ROI)):
        for roi in frame.ROI.unique():
            if frame.Hemi[i] == 'L':
                scanList(frame, leftDict, i, roi)
            else:
                scanList(frame, rightDict, i, roi)


def scanList(frame, roiDict, index, roi):
    if frame.ROI[index] == roi:
        if roi not in roiDict:
            roiDict[roi] = {'Count': 0, 'Scan1': [], 'Scan2': [], 'Scan3': []}

        if frame.Scan1[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan1'].append(frame.Comp[index])
        else:
            roiDict[roi]['Scan1'].append(0)

        if frame.Scan2[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan2'].append(frame.Comp[index])
        else:
            roiDict[roi]['Scan2'].append(0)

        if frame.Scan3[index]:
            roiDict[roi]['Count'] += 1
            roiDict[roi]['Scan3'].append(frame.Comp[index])
        else:
            roiDict[roi]['Scan3'].append(0)


#=============================== START OF MAIN ===============================

def main():
    roiRight = {}
    roiLeft = {}
    frame = DataFrame(dset, columns=['Comp', 'Hemi', 'ROI', 'Scan1', 'Scan2', 'Scan3'])

    buildDataFrame(frame, roiRight, roiLeft)
    rf = DataFrame(roiRight).T  # columns=['Region', 'Count', 'Scan1', 'Scan2', 'Scan3'], index=['Left', 'Right']).T
    lf = DataFrame(roiLeft).T    # columns=['Region', 'Count', 'Scan1', 'Scan2', 'Scan3'], index=['Left', 'Right']).T

    print 'RIGHT\n--------------------\n', rf
    print '\nLEFT\n--------------------\n', lf


def main2():
    roiRight = {}
    roiLeft = {}
    frame = DataFrame(data, columns=['Comp', 'Hemi', 'ROI', 'Scan1', 'Scan2', 'Scan3'])

    buildDataFrame2(frame, roiRight, roiLeft)
    rf = DataFrame(roiRight).T
    lf = DataFrame(roiLeft).T

    print 'RIGHT\n--------------------\n', rf
    print '\nLEFT\n--------------------\n', lf


if __name__ == '__main__':
    main2()

    # print 'ROI\n'
    # df = pd.merge(rightFrame.T, leftFrame.T)
    # print df
    # for key in roiInfo:
    #     print key
    #     # print '\tHemisphere, Count, Comp, Scan1, Comp, Scan2, Comp, Scan3'
    #     print '\tRight: ', roiInfo[key]['R']
    #     print '\t Left: ', roiInfo[key]['L'], '\n'




    # leftFrame = frame.sort_index(by='Hemi')[:70].sort_index(by='Comp').reset_index(1)  # Data frame with just the right hemisphere
    # lScan1 = leftFrame[leftFrame['Scan1'] > None]
    # lScan100 = lScan1[lScan1['Scan2'] != True]
    # lScan100 = lScan100[lScan100['Scan3'] != True]

    # lScan2 = leftFrame[leftFrame['Scan2'] > None]
    # lScan200 = lScan2[lScan2['Scan1'] != True]
    # lScan200 = lScan200[lScan200['Scan3'] != True]

    # lScan3 = leftFrame[leftFrame['Scan3'] > None]
    # lScan300 = lScan3[lScan3['Scan1'] != True]
    # lScan300 = lScan300[lScan300['Scan2'] != True]

    # lScan12 = lScan1[lScan1['Scan2'] > None]
    # lScan123 = lScan12[lScan12['Scan3'] > None]

    # rightFrame = frame.sort_index(by='Hemi')[70:].sort_index(by='Comp').reset_index(1)  # Data frame with just the right hemisphere
    # rScan1 = rightFrame[rightFrame['Scan1'] > None]
    # rScan100 = rScan1[rScan1['Scan2'] != True]
    # rScan100 = rScan100[rScan100['Scan3'] != True]

    # rScan2 = rightFrame[rightFrame['Scan2'] > None]
    # rScan200 = rScan2[rScan2['Scan1'] != True]
    # rScan200 = rScan200[rScan200['Scan3'] != True]

    # rScan3 = rightFrame[rightFrame['Scan3'] > None]
    # rScan300 = rScan3[rScan3['Scan1'] != True]
    # rScan300 = rScan300[rScan300['Scan2'] != True]

    # rScan12 = rScan1[rScan1['Scan2'] > None]
    # rScan123 = rScan12[rScan12['Scan3'] > None]

    # # Combined Right and Left regions present in all scans, irrespective of IC component
    # allScans = rScan123.append(lScan123, ignore_index=True).sort_index(by=['Comp', 'Hemi'])  # 16 regions (8R,8L)

    # for name, group in rightFrame.groupby('ROI'):
    #     print name, "\n", group[['Comp', 'Scan1', 'Scan2', 'Scan3']], "\n"



# for i in range(1,6):
#     for x in combinations([1,2,3,4,5], i):
#         print x

# [1, 2]
# [1, 3]
# [1, 4]
# [1, 5]
# [2, 3]
# [2, 4]
# [2, 5]
# [3, 4]
# [3, 5]
# [4, 5]
# [1, 2, 3]
# [1, 2, 4]
# [1, 2, 5]
# [1, 3, 4]
# [1, 3, 5]
# [1, 4, 5]
# [2, 3, 4]
# [2, 3, 5]
# [2, 4, 5]
# [3, 4, 5]
# [1, 2, 3, 4]
# [1, 2, 3, 5]
# [1, 2, 4, 5]
# [1, 3, 4, 5]
# [2, 3, 4, 5]
# [1, 2, 3, 4, 5]
