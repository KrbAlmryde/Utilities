"""==============================================================================
 Program: wb1.grp.py
  Author: Kyle Reese Almryde
    Date: 11/21/2012 @ 16:00:46 PM

 Description: The purpose of this program is to perform a Group 1 sample ttest
              on the imaging data for the Word Boundary Laterality project. In
              addition to preforming the ttest analysis, this program extracts
              and reports regions of interest from the resultant neural
              activation maps that are deemed significant from the ttest.

==============================================================================
"""
import sys
import os
import roiAnalysis as ra


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


def statMask(imgFile, outMaskImg, cluster='273', plvl='0.01'):
    """ Create a statistical mask image

    Params:
        imgFile -- The input 4d image
        outMaskImg -- The desired output name
        cluster -- The number of clusters, default is 273
        plvl -- The corrected alpha level, default is 0.01

    Returns:
         None    """
    # See if you cant use a proper stats function via python instead of the afni one here
    thresh = os.popen("ccalc -expr 'fitt_p2t(" + plvl + "000,128)'").readlines()

    os.system('3dmerge -1noneg -1tindex 1 -dxyz=1'
              + ' -1clust_order 1.01 ' + cluster
              + ' -1thresh ' + thresh
              + ' -prefix ' + outMaskImg + ' ' + imgFile)


def oneSample_tTest(imgList, maskFile, outImage, brik=''):
    """ perform a one sample tTest

    Params:
        imgList -- a list of image file names
        maskFile -- the mask image file
        brik -- the desired subbrick number
        outImage -- the output file name

    Returns:
         None
    """
    if type(imgList) == list:
        imgFile = ' '.join([x + brik for x in imgList])
    else:
        imgFile = imgList + brik

    os.system('3dttest++ -setA ' + imgFile + ' -mask ' + maskFile + ' -prefix ' + outImage)


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
        stats -- a string containing the values for mean, peak, xyz, and roi
    """
    clusterTbl = os.popen('3dclust -orient RPI -1noneg -1dindex 0 -1tindex 1 -1thresh 2.131 ' + imgFile).readlines()[-1].strip()  # Strip newline and get last line with the stats output table from 3dclust

    tempXyz = ' '.join(clusterTbl.split()[-3:]).replace('.0', '')  # Strip the '.0' from the coordinate numbers.

    mean = clusterTbl.split()[-6]  # get the mean of the image file
    peak = clusterTbl.split()[-4]   # a list object containing the [peak intensity, Xcoord, Ycoord, Zcoord]
    xyz = ra.flipXYZ(tempXyz)  # Use the flipXYZ function to flip the x and y coordinates (name is a bit misleading)
    roi = ra.whereAmI(xyz)  # Extract the Region of Interest based on the supplied xyz coordinates

    return ' '.join([mean, peak, xyz, roi])

#=============================== START OF MAIN ===============================


def main():
    cond = sys.argv[1]

    subjDict = {'learn': [13, 16, 19, 21, 23, 27, 28, 33, 35, 39, 46, 50, 57, 67, 69, 73, 'learnable'],
                'unlearn': [9, 11, 12, 18, 22, 30, 31, 32, 38, 45, 47, 48, 49, 51, 59, 60, 'unlearnable']}

    condition = subjDict[cond][-1]   # learnable or unlearnable depending on cond

    for scan in ('Run1', 'Run2', 'Run3'):
        scanDir = scan + '/'

        #---------------------------------#
        # Define pointers for GRP results #
        #---------------------------------#
        ANOVA = '/Volumes/Data/WB1/ANOVA/'
        COMBO = ANOVA + 'Combo/' + scanDir
        MASK = ANOVA + 'Mask/' + scanDir
        MEAN = ANOVA + 'Mean/' + scanDir

        subStatsImgList = []
        #--------------------#
        # Initiate functions #
        #--------------------#
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
            print subStatsImgList
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
        # Executing statMask():
        # ++ Combine the mean coef and tstat images
        #       grpStatsMean -- input file; Combined file containing the mean coef and tstat images
        #       clusterMask -- output file; A statistical mask containing statistically significant clusters
        #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        clusterMask = MASK + '_'.join([scan.lower(), condition, '01', 'cm', 'sent', 'statMask']) + '.nii.gz'

        statMask(grpStatsMean, clusterMask)

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
