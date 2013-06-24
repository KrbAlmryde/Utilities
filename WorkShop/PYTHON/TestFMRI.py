import os

class MRI(object):
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
        self.epan = Reconstruct(self)
        # self.tcat = VolumeTrim(self)
        # self.despike = Despike()
        # self.tshift = TimeShift()
        # self.smooth = Smoothing()
        # self.volreg = VolumeRegistration()
        # self.scale = Normalization()
        # self.glm = Regression()


class IceWord(MRI):
    """docstring for IceWord"""
    def __init__(self, baseDir='/Volumes/Data/Iceword'):
        self.baseDir = baseDir
        self.epan = Reconstruct(self)

    def __str__(self):
        return 'TR: %.2d,\nMRINUM: %s,\nSUBJ: %s\nRUN: %s' % (self.tr, self.mrinum, self.subj, self.scan)


class Reconstruct(object):
    def __init__(self, outDir='Func'):
        self.outDir = os.path.join(self.baseDir, self.subj, self.scan, outDir)
        # self.infile = infile
        self.outfile = '-'.join([self.subj, self.scan, 'epan']) + '.nii'
        self.command = self.to3d()

    def __str__(self):
        return 'to3d Command:\n %s'.format(self.command)

    def to3d(self):
        """Construct the to3d command using class attributes
           @return string composed of to3d command
        """
        to3d = ' '.join(['to3d -epan',
                         '-prefix', self.outfile,
                         '-time:tz', self.nfs, self.nas, self.tr,
                         '@${STIM}/offsets.1D',
                         '${ORIG}/${run}.*'])
        epan = os.path.join(self.outDir, to3d)
        return epan
