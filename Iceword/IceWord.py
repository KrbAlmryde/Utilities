from MRI import fMRI
import os


class Iceword(fMRI):
    """docstring for Iceword"""
    def __init__(self, scan):
        self.scan = scan

    def checkPath(self, path, alt, imgFile):
        """Check that the path to file exists, if it doesnt, test the alternate

        Params:
            path -- is always a path /volumes/data/foo/
            alt -- can be a path or a file
            imgFile -- is always a file

        Returns:
            return the image
        """
        if not os.path.isdir(alt):
            check1 = os.path.join(path, imgFile)
            check2 = os.path.join(path, alt)
        else:
            check1 = os.path.join(path, imgFile)
            check2 = os.path.join(alt, imgFile)

        if os.path.exists(check1 + '.BRIK'):
            print '\tGoing with check1', check1
            return check1
        elif os.path.exists(check2 + '.BRIK'):
            print '\tGoing with check2', check2
            return check2
        else:
            print 'Didnt Find it...uh oh'
            return

    def getImgData(self, inputImg, outputImg):
        """Grab functional and structural images

           This function utilizes 3dCopy to copy the inputImg, to the
           outputImg, effectively copying and renaming the file to the
           new location in the new IceWord directory.

           Params:
               inputImg -- The desired image to be grabbed, path
                           is included in the name.
               outputImg -- The output file name to be placed,
                            path is included in the name.
        """
        if os.path.exists(outputImg):
            print outputImg.split('/')[-1], 'Already exists, skipping... '
            pass
        else:
            os.popen('3dcopy -denote ' + inputImg + ' ' + outputImg)

    def getFuncSpec(self, imgFile, funcDict):
        """Get Subject Image Specifications such as # of Volumes, TRs etc

        Params:
            ImgFile -- The image file in question
            funcDict --

        Returns:
             Modifies the supplied dictionary in place
        """
        print '3dinfo', imgFile, '\n', funcDict

        for line in os.popen('3dinfo ' + imgFile):
            line = line.strip()
            if 'third  ' in line:
                funcDict['Orient'] = line.split()[-1][:-1]
            elif 'R-to-L extent' in line:
                funcDict['Dimensions'] = line.split()[8]
            elif 'A-to-P extent' in line:
                funcDict['Dimensions'] += ' x ' + line.split()[8]
            elif 'Number of time steps' in line:
                funcDict['Reps'] = line.split('=')[1].split()[0]
                funcDict['TR'] = line.split('=')[2].split()[0]
                funcDict['Origin'] = line.split('=')[3].split()[0]
                funcDict['Slices'] = line.split('=')[4].split()[0]
                funcDict['Thickness'] = line.split('=')[5].split()[0]

    def getImgSpec(self, imgFile, subjDict, subj, scan):
        """ Determine which 'Spec' function to call

        Params:
            imgFile -- The imgFile to examine
            subjDict -- The dictionary containing

        Returns:
             Description of returns
        """
        if scan in ('Run1', 'Run2', 'Run3', 'Run4'):
            self.getFuncSpec(imgFile, subjDict[subj][scan])

        elif scan in ('SPGR', 'FSE'):
            self.getAnatSpec(imgFile, subjDict[subj][scan], scan)

        else:
            pass

    def getAnatSpec(self, imgFile, anatDict, scan):
        """ One line description

        Params:
            imgFile --
            anatDict --

        Returns:
             Modifies the supplied dictionary in place
        """
        print '3dinfo', imgFile, '\n', anatDict

        for line in os.popen('3dinfo ' + imgFile):
            line = line.strip()
            if 'third  ' in line:
                anatDict['Orient'] = line.split()[-1][:-1]

            elif 'R-to-L extent' in line:
                anatDict['FOV'] = line.split()[-2][1:]
                anatDict['R-extent'] = line.split()[2] + ' to ' + line.split()[5]
                if scan == 'SPGR':
                    anatDict['Thickness'] = line.split()[8]
                else:
                    anatDict['Dimensions'] = line.split()[8]

            elif 'A-to-P extent' in line:
                anatDict['FOV'] += ' x ' + line.split()[-2][1:]
                anatDict['A-extent'] = line.split()[2] + ' to ' + line.split()[5]
                if scan == 'SPGR':
                    anatDict['Dimensions'] = line.split()[8]
                else:
                    anatDict['Dimensions'] += ' x ' + line.split()[8]

            elif 'I-to-S extent' in line:
                anatDict['I-extent'] = line.split()[2] + ' to ' + line.split()[5]
                if scan == 'SPGR':
                    anatDict['FOV'] += ' x ' + line.split()[-2][1:]
                    anatDict['Dimensions'] += ' x ' + line.split()[8]
                else:
                    anatDict['FOV'] += ' x ' + line.split()[-2]
                    anatDict['Thickness'] = line.split()[8]

            print anatDict, '\n'

    def writeReport(self, subjDict):
        """ One line description

        Params:
            orientDict --
            fout --

        Returns:
             None
        """
        title = "{:<11}{:<8}{:<10}{:<15}{:<17}{:<13}{:<20}{:<21}{:<23}{:<20}\n"
        header = ['Subject', 'Scan', 'MRInum', 'Orientation', 'Dimensions', 'Thickness', 'TR/FOV', 'Reps/R-extent', 'Slices/A-extent', 'Origin/I-extent']

        fout = open('/Volumes/Data/Iceword/README.txt', 'a+')
        fout.write(title.format(*header))

        for subscan in [(sub, scan) for sub in subjDict for scan in subjDict[sub] if scan not in ('MRInum', 'OldID')]:
            subj = subscan[0]
            scan = subscan[1]
            if scan in ('Run1', 'Run2', 'Run3', 'Run4'):
                dataTbl = "{0:<11}{1:<8}{2:<10}{Orient:<15}{Dimensions:<17}{Thickness:<13}{TR:<20}{Reps:<21}{Slices:<23}{Origin:<20}\n"
            elif scan in ('SPGR', 'FSE'):
                dataTbl = "{0:<11}{1:<8}{2:<10}{Orient:<15}{Dimensions:<17}{Thickness:<13}{FOV:<20}{R-extent:<21}{A-extent:<23}{I-extent:<20}\n"
            fout.write(dataTbl.format(subj, scan, subjDict[subj]['MRInum'], **subjDict[subj][scan]))
        fout.close()
