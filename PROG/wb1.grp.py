#!/usr/bin/env python
"""
==============================================================================
 Program: wb1.grp.py
  Author: Kyle Reese Almryde
    Date: 11/19/2012 @ 04:00:46 PM

 Description: The purpose of this program is to perform a Group 1 sample ttest
              on the imaging data for the Word Boundary Laterality project. In
              addition to preforming the ttest analysis, this program extracts
              and reports regions of interest from the resultant neural
              activation maps that hare deemed significant from the ttest.

==============================================================================
"""
import sys
import os


def usage_message():
    print """
    ------------------------------------------------------------------------
    +                    +++ No arguments provided! +++                    +
    +                                                                      +
    +              This program requires at least 2 arguments.             +
    +                                                                      +
    +      NOTE: [words] in square brackets represent possible input.      +
    +                   See below for available options.                   +
    +                                                                      +
    ------------------------------------------------------------------------
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        +             Argument 1:   Experimental condition             +
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        +                                                              +
        +        [learn]                For the Learnable Condtion     +
        +        [unlearn]              For the Unlearnable Condtion   +
        +                                                              +
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        +               Argument 2:  Analysis  Operation               +
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        +                                                              +
        +      [pre]      Construct an un-edited statistical mask      +
        +      [post]     Compute stats on editied Statistical Mask    +
        +                                                              +
        ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    ------------------------------------------------------------------------
    +                   Example command-line execution:                    +
    +                                                                      +
    +                     python wb1.grp.py learn pre                      +
    +                                                                      +
    +                       +++ Please try again +++                       +
    ------------------------------------------------------------------------
    """


def groupImageStats(imgFile, outImage, brik=''):
    """ Strip the desired image statistics from the image file

    Specifically, remove those subbricks from specified from the
    supplied image, and store them in their own file that can be
    manipulated more easily later on.

    Params:
        imgFile -- The input 4d file. It can be a subject image
                   file or a group image file, so long as at
                   least 2 subbricks reside within the image.
                   The image should contain the desired path.
                   '/path/to/image/file/4dImage.nii.gz'
                   Optionally, a list of 4d images can be supplied
                   in which case a string will be constructed
                   using a list comprehension.

        brik -- The desired subbrik(s) to be extracted. AFNI
                conventions for specifying subbriks apply.

        outImage -- The desired prefix for the newly created
                  image file. The path name should be included
                  in the image prefix

    Returns:
         A string composed of the output image's path and name,
         in case it is needed.
    """
    if type(imgFile) == list:
        imgFile = ' '.join([x + brik for x in imgFile])
    else:
        imgFile = imgFile + brik

    os.system('3dbucket -prefix ' + outImage + ' ' + imgFile)
    return outImage


def computeImageMean(imgList, outImage, brik=''):
    """ using 3dmean, average datasets

    Params:
        imgList -- A list of 4d images to be averaged. It is assumed
                   the list has already been stripped.

        brik -- an optional parameter which can specify a subbrik.

        outImage -- The desired prefix for the newly created
                  image file. The path name should be included
                  in the image prefix

    Returns:
         A string composed of the output image's path and name,
         in case it is needed.
    """
    imgFiles = ' '.join([x + brik for x in imgList])

    os.system('3dMean -prefix ' + outImage + ' ' + imgFiles)
    return outImage


def subj_NoNeg(imgFile, outImage):
    """ One line description

    Params:
        imgFile -- The input 4d image
        outImage -- The desired prefix for the newly created image file

    Returns:
         None
    """
    os.system('3dmerge -1noneg -prefix ' + outImage + ' ' + imgFile)


def statMask(imgFile, outMaskImg, cluster='273', plvl='0.01'):
    """ Create a statistical mask image

    Params:
        imgFile -- The input 4d image
        outMaskImg -- The desired output name
        cluster -- The number of clusters, default is 273
        plvl -- The corrected alpha level, default is 0.01

    Returns:
         None
    """
    # See if you cant use a proper stats function via python instead of the afni one here
    thresh = os.popen("ccalc -expr 'fitt_p2t(" + plvl + "000,128)'").read().strip()

    os.system('3dmerge -1noneg -1tindex 1 -dxyz=1'
              + ' -1clust_order 1.01 ' + cluster
              + ' -1thresh ' + thresh
              + ' -prefix ' + outMaskImg + ' ' + imgFile)


def oneSample_tTest(inputImg, maskFile, outImage, brik=''):
    """ perform a one sample tTest

    Params:
        inputImg --
        maskFile --
        brik --
        outImage --

    Returns:
         Description of returns
    """
    if type(inputImg) == list:
        imgFile = ' '.join([x + brik for x in inputImg])
    else:
        imgFile = inputImg + brik

    os.system('3dttest++ -setA ' + imgFile
               + ' -mask ' + maskFile
               + ' -prefix ' + outImage)


def getSubjStats_ROI(imgFile, maskImg):
    """Get ROI statistics per subject per ROI

    Params:
        imgFile -- The subject image file
        maskImg -- The ROI mask image

    Returns:
         A tuple containing the subject#, Scan, Condition, event, Side, ROI, volume, mean, and stdev
    """
    imgInfo = imgFile.split('/')[-1].split('_')
    maskInfo = maskImg.split('/')[-1].split('_')
    roiStats = os.popen('3dmaskave -sigma -mask ' + maskImg + ' ' + imgFile).readlines()[-1].strip().split()
    mean = roiStats[0]
    stdev = roiStats[1]
    volume = roiStats[2][1:]
    return '\t'.join([imgInfo[1], imgInfo[0], imgInfo[2], 'sent', maskInfo[2], maskInfo[3][:-4], volume, mean, stdev, imgFile, maskImg])


def getClusterStats_tTest(imgFile):   # This has potential to be very Modular, I just need to decide if I like it enough
    """Extract cluster stats from tTest image file

    This function uses the os mondule popen to capture output from
    afni's 3dclust command. Presently it assumes the image is in
    2x2x2 resolution. Output is the mean and peak voxel intensity
    followed by the peak xyz coordinates

    Params:
        imgFile -- a 4D Image, path included eg,
                   '/path/to/image/file/4dImage.nii.gz'

    Returns:
        stats -- a string containing the values for Scan, Condition, event, Side, ROI, volume, mean
    """
    imgInfo = imgFile.split('/')[-1].split('_')
    clusterTbl = os.popen('3dclust -orient RPI -1noneg -1dindex 0 -1tindex 1 -1thresh 2.040 2 0 ' + imgFile).readlines()[-1].strip()  # Strip newline and get last line with the stats output table from 3dclust

    mean = clusterTbl.split()[-6]  # get the mean of the image file
    volume = clusterTbl.split()[0]
    return '\t'.join([imgInfo[0], imgInfo[1], imgInfo[2], imgInfo[-1][:-7], imgInfo[3], imgInfo[4], volume, mean, 'NA', imgFile])


#=============================== START OF MAIN ===============================


def main():
    """Generate unedited statistical masks from group averaged single subject data"""

    cond = sys.argv[1]
    operation = sys.argv[2]

    subjDict = {'learn': [13, 16, 19, 21, 23, 27, 28, 33, 35, 39, 46, 50, 57, 67, 69, 73, 'learnable'],
                'unlearn': [9, 11, 12, 18, 22, 30, 31, 32, 38, 45, 47, 48, 49, 51, 59, 60, 'unlearnable']}

    condition = subjDict[cond][-1]   # learnable or unlearnable depending on value of cond

    for scan in ('Run1', 'Run2', 'Run3'):
        scanDir = scan + '/'

        #---------------------------------#
        # Define pointers for GRP results #
        #---------------------------------#
        ANOVA = '/Volumes/Data/WB1/ANOVA/'
        COMBO = ANOVA + 'Combo/' + scanDir
        MASK = ANOVA + 'Mask/' + scanDir
        MEAN = ANOVA + 'Mean/' + scanDir
        MERG = ANOVA + 'Merge/' + scanDir
        TTEST = ANOVA + 'tTest/' + scanDir
        REPORT = ANOVA + 'Report/' + scanDir

        subStatsImgList = []
        #--------------------#
        # Initiate functions #
        #--------------------#
        if operation == 'pre':

            #---------------------------#
            # Begin pre-Mask operations #
            #---------------------------#
            for subj in subjDict[cond][0:-1]:
                subj = 'sub%003d' % subj
                subjDir = subj + '/'

                # STATS is the directory containing the individual subject images output from the glm
                STATS = '/Volumes/Data/WB1/GLM/' + subjDir + 'Glm/' + scanDir + 'Stats/'

                #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                # Executing groupImageStats():
                #  ++ Strip coef and tstat briks for the sent condition from subject files, bucket them into their own file.
                #       sub4dImg -- input file
                #       brik -- subbrik index for the coef and tstat of the sent condition
                #       subStatsImg -- output file name
                #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                sub4dImg = STATS + '_'.join([scan.lower(), subj, 'tshift_volreg_despike_mni_7mm_164tr_0sec', condition]) + '.stats.nii.gz'
                subStatsImg = COMBO + '_'.join([scan.lower(), subj, condition, 'sent', 'Stats']) + '.nii.gz'
                brik = '[12,13]'

                # Store new files in a list which will be used as input to the next function
                subStatsImgList.append(groupImageStats(sub4dImg, subStatsImg, brik))

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing computeImageMean():
            #  ++ Compute group mean image of all subjects for the coef and tstat subbriks
            #       subStatsImgList -- input file; List containing the subjects computed stat image
            #       grpMeanCoef -- output file; The group mean of the coef statistic
            #       grpMeanTstat -- output file; The group mean of the tstat statistic
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            grpMeanCoef = MEAN + '_'.join([scan.lower(), condition, 'sent', 'Group', 'Mean', 'Coef']) + '.nii.gz'
            grpMeanTstat = MEAN + '_'.join([scan.lower(), condition, 'sent', 'Group', 'Mean', 'Tstat']) + '.nii.gz'

            computeImageMean(subStatsImgList, grpMeanCoef, '[0]')
            computeImageMean(subStatsImgList, grpMeanTstat, '[1]')

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing groupImageStats():
            # ++ Combine the mean coef and tstat images
            #       grpMeanList -- input file; List containing of the mean coef and tstat images
            #       grpStatsMean -- output file; Combined file containing the mean coef and tstat images
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            grpMeanList = [grpMeanCoef, grpMeanTstat]
            grpStatsMean = MEAN + '_'.join([scan.lower(), condition, 'sent', 'Group', 'StatsMean']) + '.nii.gz'

            groupImageStats(grpMeanList, grpStatsMean)
            os.system('3drefit -substatpar 1 fitt 128 ' + grpStatsMean)

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing subj_NoNeg():
            # ++ Compute Positive activation only images
            #       subjImg -- input file;
            #       outImgNoNoeg -- output file;
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            for subjImg in subStatsImgList:
                inputImage = subjImg
                subjImg = subjImg.split('/')[-1].split('_')
                outImgNoNeg = MERG + '_'.join([x for x in subjImg[:-1]] + ['NoNeg', subjImg[-1]])

                subj_NoNeg(inputImage, outImgNoNeg)

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing statMask():
            # ++ Combine the mean coef and tstat images
            #       grpStatsMean -- input file; Combined file containing the mean coef and tstat images
            #       clusterMask -- output file; A statistical mask containing statistically significant clusters
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            clusterMask01 = MASK + '_'.join([scan.lower(), condition, '01', 'cm', 'sent', 'statMask']) + '.nii.gz'
            clusterMask05 = MASK + '_'.join([scan.lower(), condition, '05', 'cm', 'sent', 'statMask']) + '.nii.gz'

            statMask(grpStatsMean, clusterMask01)
            statMask(grpStatsMean, clusterMask05, '1402', '05')
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            #++++++++++++++++++++++++++++++++++++++++++++++End pre-Mask operations++++++++++++++++++++++++++++++++++
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        elif operation == 'post':
            #----------------------------#
            # Begin post-Mask operations #
            #----------------------------#
            fout = open(REPORT + '_'.join([scan, condition, 'Report']) + '.txt', 'a+')
            fout.write('ID\tRun\tCondition\tEvent\tSide\tROI\tVolume\tT-Mean\tT-Stdev\n')

            # A list containing statistical masks for the given condition
            maskImgList = os.popen('ls ' + MASK + '*_' + condition + '*').read().split('\n')[:-1]
            ttestInputList = os.popen('ls ' + COMBO + '*sub0*_' + condition + '*').read().split('\n')[:-1]
            subjNoNegList = os.popen('ls ' + MERG + '*sub0*_' + condition + '*').read().split('\n')[:-1]
            print '\n Mask Image List \n', maskImgList
            print '\n Ttest Image List \n', ttestInputList
            print '\n Subject Image List \n', subjNoNegList
            tTestReportList = []
            subjReportList = []

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing oneSample_tTest():
            # ++ Combine the mean coef and tstat images
            #       ttestInputList -- input file; A list containing the subject Stat images
            #       inputMask -- input file; Individual element from maskImgList used as the actual input mask file.
            #       outImage -- output file; A one sample Ttest stat image
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            for inputMask in maskImgList:
                ttestOutImage = TTEST + '_'.join(['tTest', inputMask.split('/')[-1][:-4], 'sent']) + '.nii.gz'

                oneSample_tTest(ttestInputList, inputMask, ttestOutImage)
                tTestReportList.append(getClusterStats_tTest(ttestOutImage))

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing getSubjStats_ROI():
            # ++ Combine the mean coef and tstat images
            #       ttestInputList -- input file; A list containing the subject Stat images
            #       inputMask -- input file; Individual element from maskImgList used as the actual input mask file.
            #       outImage -- output file; A one sample Ttest stat image
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            for image in [(mask, noNeg) for mask in maskImgList for noNeg in subjNoNegList]:
                maskImg = image[0]
                imgFile = image[1]

                subjReportList.append(getSubjStats_ROI(imgFile, maskImg))

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Write Report
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            fout.write('\n'.join(tTestReportList) + '\n')
            fout.write('\n'.join(subjReportList))
            fout.close()

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            #++++++++++++++++++++++++++++++++++++++++++++End Post-Mask operations+++++++++++++++++++++++++++++++++++
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

        #--------------------#
        #    End functions   #
        #--------------------#
        print """
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
        \tMAIN has completed for %s
        ========================================================
        """ % scan


if __name__ == '__main__':
    main()

'''
#------------------------------------------------------------------------
#  Description: ClusterSim_Output
#
#  Purpose: This is an unused function provided here for documention
#           purposes. It contains the 3dClustSim command used to
#           generate the Cluster Size Threshold Report provided below
#------------------------------------------------------------------------

# 3dClustSim -nxyz 91 109 91 -dxyz 2 2 2 -fwhm 7 -pthr 0.05 0.01
# Grid: 91x109x91 2.00x2.00x2.00 mm^3 (902629 voxels)
#
# CLUSTER SIZE THRESHOLD(pthr,alpha) in Voxels
# -NN 1  | alpha = Prob(Cluster >= given size)
#  pthr  |  0.100  0.050  0.020  0.010
# ------ | ------ ------ ------ ------
 0.050000  1018.3 1135.0 1289.0 1402.0
 0.010000   205.1  226.1  252.0  273.0
'''

