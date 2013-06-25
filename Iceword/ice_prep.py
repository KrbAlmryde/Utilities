"""
==============================================================================
 Program: ice_prep.py
  Author: Kyle Reese Almryde
    Date: 12/20/2012 @ 12:38:47 PM
Modified: 01/09/2013 @ 15:48:13 PM

 Purpose: This program performs standard pre-processing operations on 4D image
          data collected for the Iceword project. Operations to be performed
          are as follows:  ('x' denote function completed)

         Correct Image Inconsistencies: x
         Volume-Trim: truncate volumes to 213: x
         Slice Timing Correction: Temporally align slices: x
         Motion Correction: Realign 4d image to 'best volume': x
         Despike: Reduce image signal noise: x
         Smoothing: Blur image to 7mm gaussian filter: x


==============================================================================
"""
import os
from ice_examine import getOutName, getImgData, getFuncSpec

ICEWORD = '/Volumes/Data/IcewordNEW'


def getOutName(inputImg, addName=None, addDir='', altPath=''):
    """Make output file name based on inputImg

    Params:
        inputImg --
        extension -- The added extension, can be None
        addDir -- The path extention to be added. If not
                  provided, then no extention is added.
    Returns:
         return a tuple containing the subj ID, scan, and outName
    """
    path, image = os.path.split(inputImg)
    body, tail = '', ''

    if len(image.split('-')) < 3:
        subj = image.split('-')[0]
        scan = image.split('-')[1].split('.')[0]
    elif len(image.split('-')) > 3:
        subj, scan = image.split('-')[:2]
        body = image.split('-')[2:-1]
        tail = image.split('-')[-1].split('.')[0]
    else:
        subj, scan = image.split('-')[:2]
        tail = image.split('-')[-1].split('.')[0]

    outName = [subj, scan]

    if body:
        outName.extend(body)

    if tail and 'RAW' not in tail:
        outName.append(tail)
    else:
        pass

    if addName:
        outName.append(addName)

    outName = '-'.join(outName) + '.nii.gz'

    if altPath:
        outImg = os.path.join(altPath, addDir, outName)
    else:
        outImg = os.path.join(path, addDir, outName)
    return subj, scan, outImg


def logImageStats(inputImg, baseVol=''):
    """Log robust_min robust_max mean sd statistics to log file
       for each input dataset

    Params:
        inputImg -- Image file to log computed statistics for.
        baseVol -- The image volume determined to be the most stable

    Returns:
        If a log does not exist already, a new one with appended image
        stats will be created. Otherwise, append image statistics.
    """
    subj, scan = getOutName(inputImg)[0:2]
    image = os.path.split(inputImg)[-1]
    stats = [image]

    path = os.path.join(ICEWORD, subj, 'Func')
    logFile = os.path.join(path, 'log_preproc.txt')

    template = '{0}\t{1}\t{2}\t{3}\t{4}\n'
    header = ['image', 'robust_min', 'robust_max', 'mean', 'sd']

    fslstats = 'fslstats ' + inputImg + ' -r -m -s'
    imgStats = os.popen(fslstats).read().split()
    stats.extend(imgStats)

    if os.path.exists(logFile):
        fout = open(logFile, 'a')
        fout.write(template.format(*stats))
    else:
        fout = open(logFile, 'w')
        fout.write(template.format(*header))
        fout.write(template.format(*stats))
    fout.close()


def plotImageStats(inputImg, dfile=None):
    """Plot input image using afni's 1dplot

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz
        dfile -- a File containing the shifting information from the ouput of
                 volumeReg()
    """
    outCount = ' '.join(['3dToutcount', inputImg])
    plot = '1D:' + ','.join([count.strip() for count in os.popen(outCount).readlines()])
    imgName = inputImg.split('.')[0]

    if dfile:
        plot1d = ' '.join(['1dplot -jpeg', imgName, '-volreg -xlabel TIME', dfile])
    else:
        imgName += '-outs'
        plot1d = ' '.join(['1dplot -jpeg', imgName, plot])

    os.system(plot1d)


def makeImageCorrections(inputImg):
    """Make various corrections to problematic images

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    masterFunc = '/Volumes/Data/IcewordNEW/sub005/Func/Run1/sub005-run1-RAW.nii.gz'
    masterFSE = '/Volumes/Data/IcewordNEW/sub005/Morph/sub005-fse-RAW.nii.gz'
    masterSPGR = '/Volumes/Data/IcewordNEW/sub005/Morph/sub005-spgr-RAW.nii.gz'
    subj, scan, outImg = getOutName(inputImg)

    if scan in 'fse' and inputImg not in masterFSE:
        return __MakeImageCorrections(masterFSE, inputImg)

    elif scan in 'spgr' and inputImg not in masterSPGR:
        return __MakeImageCorrections(masterSPGR, inputImg)

    elif inputImg not in masterFunc:
        return __MakeImageCorrections(masterFunc, inputImg)

    else:
        getImgData(inputImg, outImg)
        logImageStats(outImg)
        return outImg


def __MakeImageCorrections(masterImg, inputImg):
    """Modify inputImg to match masterImg

    This function uses 3dResample to make major structural changes
    either to the voxel sizes, the image orientation, or both. If the
    input image is of a Functional type, then perform 3drefit first to
    ensure that the TR time is correct, then proceed to resampling.
    When resampling has completed, remove the original inputFile,
    and rename the outputFile to that of the old inputFile.

    Params:
        masterImg -- The master image file which the inputImg should
                     be matched to.
        inputImg -- The image file to be adjusted.

    Returns:
         Description of returns
    """
    subj, scan, outImg = getOutName(inputImg)
    resample = ' '.join(['3dresample -master', masterImg, '-prefix', outImg, '-inset', inputImg])
    refit = ' '.join(['3drefit -TR', masterImg, inputImg])

    os.system(refit)
    os.system(resample)
    logImageStats(outImg)
    plotImageStats(outImg)
    return outImg


def volumeTrim(inputImg, trim):
    """Remove first n volumes from image

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    print '\n\tTrimming Volumes: ', trim

    outImg = getOutName(inputImg, '213tr', 'RealignDetails')
    trunc = '[' + trim + '..$]'
    tcat = ' '.join(['3dTcat -verb -prefix', outImg[-1], inputImg]) + trunc
    os.system(tcat)
    logImageStats(outImg[-1])
    plotImageStats(outImg[-1])

    return outImg[-1]


def sliceTiming(inputImg):
    """ Run 3dTshift to temporally align the slices in each volume to the
        middle slice using sepminus. Uses Fourier interpolation by default,
        which is slowest but the most accurate

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    outImg = getOutName(inputImg, 'tshift')
    tshift = ' '.join(['3dTshift -tpattern seqminus -prefix', outImg[-1], inputImg])
    os.system(tshift)
    logImageStats(outImg[-1])
    plotImageStats(outImg[-1])

    return outImg[-1]


def baseVolume(inputImg):
    """Find best volume (smallest outlier value) for base realignment
       volume. By default, this uses the whole image (brain and nonbrain)
       when it looks for outliers.

    Params:
        inputImg -- 4d functional of the form runX_subXXX.nii.gz

    Returns:
        An integer value representing the the base realignment volume.
    """
    subj, scan = getOutName(inputImg)[:2]
    outcount = ' '.join(['3dToutcount', inputImg])
    result = [int(count.strip()) for count in os.popen(outcount).readlines()]
    base = str(result.index(min(result)))

    baseLog = os.path.join(ICEWORD, subj, 'Func', scan, 'base_Volume.txt')
    fout = open(baseLog, 'w')
    fout.write('{0}\t{1}\n'.format('base Volume', base))
    fout.close()

    return base


def volumeReg(inputImg, baseVol='0'):
    """ One line description

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    outImg = getOutName(inputImg, 'volreg')
    baseImg = inputImg + '[' + baseVol + ']'
    dfile = '_'.join([outImg[-1].split('.')[0], 'dfile.1D'])
    maxdisp = '_'.join([outImg[-1].split('.')[0], 'mm.1D'])
    volreg = ' '.join(['3dvolreg -zpad 4 -base', baseImg,
                       '-1Dfile', dfile, '-maxdisp1D', maxdisp,
                       '-prefix', outImg[-1], '-Fourier', inputImg])
    os.system(volreg)
    logImageStats(outImg[-1], baseVol)
    plotImageStats(outImg[-1])  # Produce a plot of the image stats
    plotImageStats(outImg[-1], dfile)

    return outImg[-1]


def despikeVolume(inputImg):
    """Remove spikes from the data by fitting a smoothish curve to the data.
        -nomask prevents automasking during despiking. We will use a different
        mask later on (generated from the skull stripped T1), so we don't
        want to automask now. Despiking may negatively affect volreg, and so
        should be done after volreg.

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    outImg = getOutName(inputImg, 'despike')
    spikes = getOutName(inputImg, 'spikes')
    despike = ' '.join(['3dDespike -nomask -prefix', outImg[-1],
                                '-ssave', spikes[-1], inputImg])
    os.system(despike)
    logImageStats(outImg[-1])
    plotImageStats(outImg[-1])  # Produce a plot of the image stats
    return outImg[-1]


def smoothVolume(inputImg, kernel='7.0'):
    """ Smooth image at fwhm using 7.0mm kernel.

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii.gz
        kernel -- The size of the gaussian kernel deisred. Default is 7mm

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii.gz
    """
    outImg = getOutName(inputImg, '7mm')
    smooth = ' '.join(['3dmerge -1blur_fwhm', kernel, '-doall -prefix',
                                                 outImg[-1], inputImg])
    os.system(smooth)
    logImageStats(outImg[-1])
    plotImageStats(outImg[-1])
    return outImg[-1]


def writeReport(subjDict):
    """ One line description

    Params:
        orientDict --
        fout --

    Returns:
         None
    """
    title = "{:<11}{:<8}{:<15}{:<17}{:<13}{:<20}{:<21}{:<23}{:<20}\n"
    header = ['Subject', 'Scan', 'Orientation', 'Dimensions', 'Thickness', 'TR/FOV', 'Reps/R-extent', 'Slices/A-extent', 'Origin/I-extent']

    fout = open('/Volumes/Data/IcewordNEW/README.txt', 'a+')
    fout.write(title.format(*header))

    for subscan in [(sub, scan) for sub in sorted(subjDict) for scan in sorted(subjDict[sub]) if scan not in ('MRInum', 'OldID')]:
        subj = subscan[0]
        scan = subscan[1]
        if scan in ('Run1', 'Run2', 'Run3', 'Run4'):
            dataTbl = "{0:<11}{1:<8}{Orient:<15}{Dimensions:<17}{Thickness:<13}{TR:<20}{Reps:<21}{Slices:<23}{Origin:<20}\n"
        elif scan in ('SPGR', 'FSE'):
            dataTbl = "{0:<11}{1:<8}{Orient:<15}{Dimensions:<17}{Thickness:<13}{FOV:<20}{R-extent:<21}{A-extent:<23}{I-extent:<20}\n"
        fout.write(dataTbl.format(subj, scan, **subjDict[subj][scan]))
    fout.close()

#=============================== START OF MAIN ===============================


def main():
    funcSpecs = {'Orient': '', 'Dimensions': '', 'Thickness': 0, 'Reps': 0, 'TR': 0, 'Origin': 0, 'Slices': 0}
    subjDict = {'sub{:003d}'.format(s): {'Run{:d}'.format(i): dict(funcSpecs) for i in [1, 2, 3, 4]} for s in range(1, 20)}
    #-------------------#
    #    Ready, Begin   #
    #-------------------#
    for subscan in [(sub, scan) for sub in subjDict.keys() for scan in subjDict[sub].keys()]:
        subj, scan = subscan
        print '\n', subj, scan

        #---------------------------------#
        #       Directory Pointers        #
        #---------------------------------#
        ICEWORD = '/Volumes/Data/IcewordNEW'
        FUNC = os.path.join(ICEWORD, subj, 'Func')
        RD = os.path.join(FUNC, scan, 'RealignDetails')

        #---------------------------------#
        #       Functional Images         #
        #---------------------------------#
        img = '_'.join([subj, scan.lower(), 'RAW.nii'])
        imgFile = os.path.join(FUNC, scan, img)

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing getFuncSpec():
        #  ++
        #       This will extract the specs of the imageFIle and update
        #       the subjDict to reflect the information extracted.
        #       Supplied variables are the image file in question, the
        #       subject Dictionary, and the reference to subj and scan,
        #       this is done as a control check to make sure the program is
        #       outputting the correct information.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        print '\n\tpopulating header'
        getFuncSpec(imgFile, subjDict[subj][scan])

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing makeImageCorrections():
        #  ++
        #       This will make corrections to each of the images via resample.
        #       It returns a pointer to the new image file created.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        print '\n\tmaking Image corrections'
        imgFile = makeImageCorrections(imgFile)
        getFuncSpec(imgFile, subjDict[subj][scan])

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing volumeTrim():
        #  ++
        #       This will trim the first X volumes from the image. If the
        #       image has 214 TRs, then only 1 volume is removed, otherwise
        #       5 volumes will be removed.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        if subjDict[subj][scan]['Reps'] == '214':
            trim = '1'
        else:
            trim = '5'

        imgFile = volumeTrim(imgFile, trim)
        getFuncSpec(imgFile, subjDict[subj][scan])

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing sliceTiming():
        #  ++
        #       This will trim the first X volumes from the image. If the
        #       image has 214 TRs, then only 1 volume is removed, otherwise
        #       5 volumes will be removed.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        imgFile = sliceTiming(imgFile)

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing volumeReg():
        #  ++
        #       After a base volume is identified, volumeReg is performed.
        #       It will correct for motion related errors.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        base = baseVolume(imgFile)
        imgFile = volumeReg(imgFile, base)

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing despikeVolume():
        #  ++
        #       After a base volume is identified, volumeReg is performed.
        #       It will correct for motion related errors.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        imgFile = despikeVolume(imgFile)

        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        # Executing smoothVolume():
        #  ++
        #       After a base volume is identified, volumeReg is performed.
        #       It will correct for motion related errors.
        #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
        imgFile = smoothVolume(imgFile)
        getFuncSpec(imgFile, subjDict[subj][scan])

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Executing writeReport():
    #  ++
    #       sub4dImg -- input file
    #       subStatsImg -- output file name
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    writeReport(subjDict)


def main2():
    funcSpecs = {'Orient': '', 'Dimensions': '', 'Thickness': 0, 'Reps': 0, 'TR': 0, 'Origin': 0, 'Slices': 0}
    subjDict = {'sub{:003d}'.format(s): {'Run{:d}'.format(i): dict(funcSpecs) for i in [4]} for s in [15]}
    #-------------------#
    #    Ready, Begin   #
    #-------------------#
    subj = 'sub015'
    scan = 'Run4'
    print '\n', subj, scan

    #---------------------------------#
    #       Directory Pointers        #
    #---------------------------------#
    ICEWORD = '/Volumes/Data/IcewordNEW'
    FUNC = os.path.join(ICEWORD, subj, 'Func')
    RD = os.path.join(FUNC, scan, 'RealignDetails')

    #---------------------------------#
    #       Functional Images         #
    #---------------------------------#
    img = '-'.join([subj, scan.lower() + '.nii.gz'])
    imgFile = os.path.join(FUNC, scan, img)

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Executing getFuncSpec():
    #  ++
    #       This will extract the specs of the imageFIle and update
    #       the subjDict to reflect the information extracted.
    #       Supplied variables are the image file in question, the
    #       subject Dictionary, and the reference to subj and scan,
    #       this is done as a control check to make sure the program is
    #       outputting the correct information.
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    print '\n\tpopulating header'
    getFuncSpec(imgFile, subjDict[subj][scan])

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Executing volumeTrim():
    #  ++
    #       This will trim the first X volumes from the image. If the
    #       image has 214 TRs, then only 1 volume is removed, otherwise
    #       5 volumes will be removed.
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if subjDict[subj][scan]['Reps'] == '214':
        trim = '1'
    else:
        trim = '5'

    imgFile = volumeTrim(imgFile, trim)
    getFuncSpec(imgFile, subjDict[subj][scan])

    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    # Executing writeReport():
    #  ++
    #       sub4dImg -- input file
    #       subStatsImg -- output file name
    #++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    writeReport(subjDict)

if __name__ == '__main__':
    # main()
    main2()
