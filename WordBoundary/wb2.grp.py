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
import subprocess as sp


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
        +        [NL]                   For the typical subjects       +
        +        [LD]                   For the LD subjects            +
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
    +                     python wb2.grp.py NL pre                         +
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
    sp.call(['3dMean', '-prefix', outImage]+imgList)
    return outImage


def subj_NoNeg(imgFile, outImage):
    """ One line description

    Params:
        imgFile -- The input 4d image
        outImage -- The desired prefix for the newly created image file

    Returns:
         None
    """
    sp.call(['3dmerge', '-1noneg', '-prefix', outImage, imgFile])


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
    fittCMD = 'fitt_p2t({0}000,128)'.format(plvl)

    thresh = sp.check_output(['ccalc', '-expr', fittCMD]).strip()

    sp.call(['3dmerge', '-1noneg', '-1tindex', '1', '-dxyz=1',
             '-1clust_order', '1.01', cluster, '-1thresh', thresh,
             '-prefix', outMaskImg, imgFile])


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
        imgFile = ' '.join([_ + brik for _ in inputImg])
    else:
        imgFile = inputImg + brik
    sp.call(['3dttest++', '-setA', imgFile,'-mask', maskFile,'-prefix', outImage])


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
    # roiStats = sp.check_output(['3dmaskave', '-sigma', '-mask', maskImg, imgFile])
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

    clusterTbl = sp.check_output(['3dclust', '-orient', 'RPI',
                                  '-1noneg', '-1dindex', '0',
                                  '-1tindex', '1', '-1thresh',
                                  '2.040', '2', '0', imgFile])

    # Strip newline and get last line with the stats output table from 3dclust; split
    # on white-space, and turn it into a list.
    clusterTbl = clusterTbl.strip().split('\n')[-1].split()

    mean = clusterTbl[-6]  # get the mean of the image file
    volume = clusterTbl[0]
    return '\t'.join([imgInfo[0], imgInfo[1], imgInfo[2], imgInfo[-1][:-7], imgInfo[3], imgInfo[4], volume, mean, 'NA', imgFile])


#=============================== START OF MAIN ===============================


def main():
    """Generate unedited statistical masks from group averaged single subject data"""

    cond = sys.argv[1]
    operation = sys.argv[2]

    # You will need to change the values here to the actual subject numbers,
    # no need to add the zeros in front Python will do it for you.
    subjDict = {'NL': [13, 16, 19, 21, 23, 27, 28, 33, 35, 39, 46, 50, 57, 67, 69, 73, 'learnable'],
                'LD': [9, 11, 12, 18, 22, 30, 31, 32, 38, 45, 47, 48, 49, 51, 59, 60, 'unlearnable']}

    condition = subjDict[cond][-1]   # learnable or unlearnable depending on value of cond

    for scan in ('Run1', 'Run2', 'Run3'):

        #---------------------------------#
        # Define pointers for GRP results #
        #---------------------------------#
        #---------------------------------#
        WB = 'WordBoundary2' # Or whatever the folder is called...
        BASE = os.path.join('/','Volumes','Data',WB)
        GLM = os.path.join(BASE,'GLM')
        ANOVA = os.path.join(BASE,'ANOVA')
        COMBO = os.path.join(ANOVA,'Combo',scan)
        MASK = os.path.join(ANOVA,'Mask', scan)
        MEAN = os.path.join(ANOVA,'Mean', scan)
        MERG = os.path.join(ANOVA,'Merge', scan)
        TTEST = os.path.join(ANOVA,'tTest', scan)
        REPORT = os.path.join(ANOVA,'Report', scan)

        subStatsImgList = []
        #--------------------#
        # Initiate functions #
        #--------------------#
        if operation == 'pre':

            #---------------------------#
            # Begin pre-Mask operations #
            #---------------------------#
            for subj in subjDict[cond][0:-1]:
                subj = 'sub{:03}'.format(subj)

                # STATS is the directory containing the individual subject images output from the glm
                STATS = os.path.join(GLM, subj,'Glm',scan,'Stats')

                #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                # Executing groupImageStats():
                #  ++ Strip coef and tstat briks for the sent condition from subject files, bucket them into their own
                #  file.
                #       sub4dImg -- input file
                #       subStatsImg -- output file name
                #       brik -- subbrik index for the coef and tstat of the sent condition
                #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                imageFile = '_'.join([scan.lower(), subj, 'tshift_volreg_despike_mni_7mm_164tr_0sec', condition]) + '.stats.nii.gz'
                statsImage = '_'.join([scan.lower(), subj, condition, 'sent', 'Stats']) + '.nii.gz'
                sub4dImg = os.path.join(STATS, imageFile)
                subStatsImg = os.path.join(COMBO,statsImage)
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
            imageCoef = '_'.join([scan.lower(), condition, 'sent', 'Group', 'Mean', 'Coef']) + '.nii.gz'
            imageTstat = '_'.join([scan.lower(), condition, 'sent', 'Group', 'Mean', 'Tstat']) + '.nii.gz'
            grpMeanCoef = os.path.join(MEAN, imageCoef)
            grpMeanTstat = os.path.join(MEAN, imageTstat)

            computeImageMean(subStatsImgList, grpMeanCoef, '[0]')
            computeImageMean(subStatsImgList, grpMeanTstat, '[1]')

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing groupImageStats():
            # ++ Combine the mean coef and tstat images
            #       grpMeanList -- input file; List containing of the mean coef and tstat images
            #       grpStatsMean -- output file; Combined file containing the mean coef and tstat images
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            grpMeanList = [grpMeanCoef, grpMeanTstat]
            grpStatsImage = '_'.join([scan.lower(), condition, 'sent', 'Group', 'StatsMean']) + '.nii.gz'
            grpStatsMean = os.path.join(MEAN, grpStatsImage)

            groupImageStats(grpMeanList, grpStatsMean)
            sp.call(['3drefit', '-substatpar', '1', 'fitt', '128', grpStatsMean])

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing subj_NoNeg():
            # ++ Compute Positive activation only images
            #       subjImg -- input file;
            #       outImgNoNoeg -- output file;
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            for subjImg in subStatsImgList:
                inputImage = subjImg
                subjImg = subjImg.split('/')[-1].split('_')
                noNegImage = '_'.join([x for x in subjImg[:-1]] + ['NoNeg', subjImg[-1]])
                outImgNoNeg = os.path.join(MERG,noNegImage)

                subj_NoNeg(inputImage, outImgNoNeg)

            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            # Executing statMask():
            # ++ Combine the mean coef and tstat images
            #       grpStatsMean -- input file; Combined file containing the mean coef and tstat images
            #       clusterMask -- output file; A statistical mask containing statistically significant clusters
            #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            cluster01 = '_'.join([scan.lower(), condition, '01', 'cm', 'sent', 'statMask']) + '.nii.gz'
            cluster05 = '_'.join([scan.lower(), condition, '05', 'cm', 'sent', 'statMask']) + '.nii.gz'
            clusterMask01 = os.path.join(MASK,cluster01)
            clusterMask05 = os.path.join(MASK,cluster05)

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
            maskImgList = sp.check_output('ls', os.path.join(MASK, '*_', condition, '*')).split('\n')[:-1]
            ttestInputList = sp.check_output('ls', os.path.join(COMBO, '*sub0*_', condition, '*')).split('\n')[:-1]
            subjNoNegList = sp.check_output('ls', os.path.join(MERG,'*sub0*_', condition, '*')).split('\n')[:-1]
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
                imageFile = '_'.join(['tTest', inputMask.split('/')[-1][:-4], 'sent']) + '.nii.gz'
                ttestOutImage = os.path.join(TTEST,imageFile)

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

