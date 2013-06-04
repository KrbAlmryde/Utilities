"""
==============================================================================
Program: MRI.py
 Author: Kyle Reese Almryde
   Date: 01/09/2013 @ 15:51:46 PM

 Description: This class defines a basic FMRI image. It is intended to be interfaced

    Modified: 01/22/2013 @ 10:33:21 AM
                         Reconfigured class layout, added subclasses, renamed
                         package to be called MRI

==============================================================================
"""

import os
import subprocess
from glob import glob
# import shutil


class fmri(object):
    """A basic template for FMRI images.
    This class behaves as a SuperClass or interface for """

    def __init__(self, subj='sub001', scan='Run1', baseDir='/Volumes/Data/Etc/',
                       mriNum='E00001', orient='RAS',  thickness=5.0, TR=2600, 
                       nfs=220, nas=26, FOV=240, model='WAV(18.2,0,4,6,0.2,2)'):

        self.baseDir = os.path.join(baseDir, subj, scan)
        self.subj = subj
        self.scan = scan
        self.mriNum = mriNum
        self.orient = orient
        self.thickness = thickness
        self.TR = TR                # The repetion time in mm, defaults to 2600
        self.nfs = nfs              # The number of functional Scans
        self.nas = nas              # The number of anatomical Scans
        self.FOV = FOV              # The image Field of View
        self.trim = 0
        self.baseVol = 0
        self.model = "WAV(18.2,0,4,6,0.2,2)"  # WAV(duration, delay, rise-time, fall-time, undershoot, recovery)
        self.epan = Reconstruct()
        self.tcat = VolumeTrunc()
        self.despike = Despike()
        self.tshift = TimeShift()
        self.smooth = Smoothing()
        self.volreg = VolumeRegistration()
        self.scale = Normalization()
        self.glm = Regression()


class Reconstruct(fmri):
    """Reconstruct fMRI images. Default params include infile, prefix, """
    def __init__(self, infile=glob('b0*'), prefix='epan.nii', dirName=fmri.baseDir, tool='to3d', args=None):
        self.infile = infile
        self.prefix = prefix
        self.dirName = dirName
        self.args = args
        if tool in ('to3d', 'afni):
            self.command = to3d()

    def to3d(self, args=self.args):
        """Construct the to3d command using class attributes
           @return string composed of to3d command
        """
        inputImg = '-'.join([self.subj, self.scan, 'epan']) + '.nii'
        outliers = '-'.join([self.subj, self.scan, 'outliers']) + '.txt'
        z = float((self.nas - 1) * (self.thickness / 2))
        halfFov = float(FOV / 2)
        xFOV = str(halfFov) + 'R-L'
        yFOV = str(halfFov) + 'A-P'
        zSLAB = str(z) + 'I-' + str(z) + 'S'
        to3d = ' '.join(['to3d -epan',
                         '-prefix', inputImg,
                         '-session', path,
                         '-2swap -text_outliers',
                         '-save_outliers', os.path.join(path, outliers),
                         '-xFOV', xFOV,
                         '-yFOV', yFOV,
                         '-zSLAB', zSLAB,
                         '-time:tz', self.nfs, self.nas, self.TR,
                         '@${STIM}/offsets.1D',
                         '${ORIG}/${run}.*'])
        epan = os.path.join(path, inputImg)
        return epan

    def run(self, command=self.command):
        """Execute to3d command"""
        p = subprocess.Popen(cmd=command, SHELL=True)
        p.call()



class VolumeTrim(fMRI):
    """Remove first n volumes from image

    Params:
        inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii

    Returns:
         String of output image name -> /PATH/TO/sub001-run1-213tr.nii
    """
    def _init_(self, infile, outfile, outdir=None, trim=fmri.trim):
        self.infile = infile
        self.prefix = outfile
        self.outDir = outDir
        self.trim = trim
        self.args = args
        if tool in ('tcat', 'afni):
            self.command = tcat()
    
    def tcat(self, args=self.args):
        """Construct tcat command
        @return string of command to be run
        """
        # outImg = getOutName(inputImg, '213tr', 'RealignDetails')
        trunc = '[{0}..$]'.format(self.trim)
        tcat = ' '.join(['3dTcat -verb -prefix', prefix, infile + trunc])
        os.system(tcat)
        return tcat
    
    def run(self, command=self.command):
        """Execute tcat command"""
        p = subprocess.Popen(cmd=command, SHELL=True)
        p.call()


    def sliceTiming(self):
        """ Run 3dTshift to temporally align the slices in each volume to the
            middle slice using sepminus. Uses Fourier interpolation by default,
            which is slowest but the most accurate

        Params:
            inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii

        Returns:
             String of output image name -> /PATH/TO/sub001-run1-213tr.nii
        """
        outImg = getOutName(inputImg, 'tshift')
        tshift = ' '.join(['3dTshift -tpattern seqminus -prefix', outImg[-1], inputImg])
        os.system(tshift)
        logImageStats(outImg[-1])
        plotImageStats(outImg[-1])

        return outImg[-1]


    def baseVolume(self):
        """Find best volume (smallest outlier value) for base realignment
           volume. By default, this uses the whole image (brain and nonbrain)
           when it looks for outliers.

        Params:
            inputImg -- 4d functional of the form runX_subXXX.nii.gz

        Returns:
            An integer value representing the the base realignment volume.
        """
        outcount = ' '.join(['3dToutcount', inputImg])
        result = [int(count.strip()) for count in os.popen(outcount).readlines()]
        base = str(result.index(min(result)))

        return base


    def volumeReg(self, baseVol='0'):
        """ One line description

        Params:
            inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii

        Returns:
             String of output image name -> /PATH/TO/sub001-run1-213tr.nii
        """
        outImg = getOutName(inputImg, 'volreg')
        baseImg = inputImg + '[' + baseVol + ']'
        dfile = '-'.join([outImg[-1].split('.')[0], 'dfile.1D'])
        maxdisp = '-'.join([outImg[-1].split('.')[0], 'mm.1D'])
        volreg = ' '.join(['3dvolreg -zpad 4 -base', baseImg,
                           '-1Dfile', dfile, '-maxdisp1D', maxdisp,
                           '-prefix', outImg[-1], '-Fourier', inputImg])
        os.system(volreg)
        logImageStats(outImg[-1])
        plotImageStats(outImg[-1])  # Produce a plot of the image stats
        plotImageStats(outImg[-1], dfile)

        return outImg[-1]


    def despikeVolume(self):
        """Remove spikes from the data by fitting a smoothish curve to the data.
            -nomask prevents automasking during despiking. We will use a different
            mask later on (generated from the skull stripped T1), so we don't
            want to automask now. Despiking may negatively affect volreg, and so
            should be done after volreg.

        Params:
            inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii

        Returns:
             String of output image name -> /PATH/TO/sub001-run1-213tr.nii
        """
        outImg = getOutName(self, 'despike')
        spikes = getOutName(self, 'spikes')
        despike = ' '.join(['3dDespike -nomask -prefix', outImg[-1],
                                    '-ssave', spikes[-1], inputImg])
        os.system(despike)
        logImageStats(outImg[-1])
        plotImageStats(outImg[-1])  # Produce a plot of the image stats
        return outImg[-1]


    def smoothVolume(self, kernel='7.0'):
        """ Smooth image at fwhm using 7.0mm kernel.

        Params:
            inputImg -- The image to be trimmed -> /PATH/TO/sub001-run1.nii
            kernel -- The size of the gaussian kernel deisred. Default is 7mm

        Returns:
             String of output image name -> /PATH/TO/sub001-run1-213tr.nii
        """
        outImg = getOutName(inputImg, '7mm')
        smooth = ' '.join(['3dmerge -1blur_fwhm', kernel, '-doall -prefix',
                                                     outImg[-1], inputImg])
        os.system(smooth)
        logImageStats(outImg[-1])
        plotImageStats(outImg[-1])
        return outImg[-1]


def main():
    subjDict = {scan1: None, scan2: None, scan3: None}
    MRIDIR = '/usr/exp/WB1/'
    for (subj, scan) in map(subj, scans):
        subjDict[subj][scan] = fmri(SUBID=subj, SESSION=scan, TR=2600, nas=25, nfs=218, baseDir=MRIDIR)
        
        subjDict[subj][scan].glm = Regression(model='GAM') 
        

#=============================== START OF MAIN ===============================

def main():
    pass


if __name__ == '__main__':
    main()
