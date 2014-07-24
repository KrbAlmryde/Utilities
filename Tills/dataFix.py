"""
==============================================================================
Program: dataFix.py
 Author: Kyle Reese Almryde
   Date: 03/11/2014
Updated: 06/06/2014

 Description: Replaces missing values in a behavioral score report based on
              scaled difficulty ratings and weighted "ability" metrics for
              subjects who have participated in a behavioral research
              experiment. If a subject has not taken then entire battery of
              tests they will not have scores computed for them.

              Program will check that datasets match in both length and via
              subject IDs. In the event that an error is encountered, the
              program will do 1 of the following:
                1) If the Dataset does not match the person_measure in terms
                   of the number of entries, an error will be reported, and
                   no corrections will be made to that dataset.
                2) If there is a mismatch in terms of subject IDs in the
                   dataset against the person_measure, the program will log
                   an error, but WILL report corrections made up to the point
                   of mismatch in the file.
              In all cases, the program will indicate which Subtest it
              encountered the error and in the case of subject ID mismatch,
              will also identify the entry number.

          NB: If you encounter a strange error, bug, or problem that you cant
              (or wont) resolve, feel free to contact me via email at:

               kyle.almryde@gmail.com

==============================================================================
"""

import os, sys, re
from glob import glob
from random import random


def loadSubtTestDataFiles(fileList):
    """ One line description

    Params:
     arg -- arg

    Returns:
      Description of returns
    """
    dFn, iFn, aFn = fileList

    # _data = open(dFn, 'U').read().strip()
    with open(dFn, 'U') as dataStream:
        _data = dataStream.read().strip().split(os.linesep)  # re.split('\t+|\r\n+|\r+|\n+', _data)

    # _data = open(iFn, 'U').read().strip()
    with open(iFn, 'U') as measureStream:
        _measures = measureStream.read().strip().split()

    with open(aFn, 'U') as abilityStream:
        _ability = [el.split() for el in abilityStream.read().strip().split(os.linesep)]

    # print "\ndata loaded", _data, "\n\n"
    # print "\nmeasure loaded", _measures, "\n\n"
    # print "\nability loaded", _ability, "\n\n"
    return _data, _measures, _ability


def writeResults(outFile, data):
    """ Writes data to a file

    Params:
        outFile -- String: The output file name
        data -- String: 1s and 0s (and optionally all '.')
                denoting subjects performance.
    Returns:
        None
    """
    data += "\n"  # Add a newline just in case
    with open(outFile, 'a') as report:  # Append to the file
        report.write(data)


def writeErrorReport(data):
    """ Writes error report with associated problem

    Params:
        data -- List: Contains tuple of offending Subtest and type of
                    error, ie size mismatch, order mismatch, etc
    Returns:
        None
    """
    from datetime import datetime
    result = ""
    outFile = "ErrorReport_{}.txt".format(datetime.now().time().isoformat())
    with open(outFile, 'w') as report:
        for test, error in data:
            result += "{0}:\t {1}\n".format(test, error)
        report.write(result)


class Subject(object):
    """docstring for Subject"""
    def __init__(self, ID):
        super(Subject, self).__init__()
        self.ID = ID
        self.ability = None
        self.performance = None

    def __call__(self, _ability, _perfomance):
        self.ability = _ability
        self.performance = _perfomance

    def hasMatchingSubjects(self):
        if self.ability is None:
            return False


class ErrorLogger(object):
    """Tracks errors and creates log detailing problems that occurred"""
    def __init__(self):
        super(ErrorLogger, self).__init__()
        from datetime import datetime

        self.log = []
        self.numErrors = 0
        self.outFile = "ErrorReport_{}.txt".format(datetime.now().time().isoformat())
        self.ErrorIndex = {
            "001": "Missing SubTest Files",
            "002": "Size Mismatch! Data has {0}, Person has {0} entries",
            "003": "Participant ID Mismatch Error! Data {0} != Person {0}",
            "004": "Item/Data Size Mismatch!"
        }

    def __call__(self, errorCode, sub_test):
        """ errorCode will act as key to ErrorIndex, which will report Error
            type and call appropriate message function. *arguments will be
            supplied to respective function
        """
        self.numErrors += 1
        error = self.ErrorIndex[errorCode]
        print "{:>10} !! {} !!".format('ERROR', error)

        if error is '001':
            self.error001(sub_test)
        elif error is '002':
            self.error002(sub_test)
        elif error is '003':
            self.error003(sub_test)
        elif error is '004':
            self.error004(sub_test)

    def error001(self, sub_test):
        missing = []
        if sub_test.itemFile is None:
            missing.append("item_measure.txt")
        if sub_test.personFile is None:
            missing.append("person_measure.txt")

        error = "Files missing From SubTest{}:".format('ERROR', len(missing), sub_test.ID)
        for el in missing:
            error += " {}".format(el)
        self.log.append(error)

    def error002(self, fileList):
        print self.spacer+"ERROR !! Size Mismatch:\tdata: {0}\tability: {1}".format(len(fileList[0]), len(fileList[1]))

    def error003(self, fileList):
        pass

    def error004(self, fileList):
        pass

    def error005(self, fileList):
        pass

    def generateReport(self):
        """ Writes error report with associated problem

        Params:
            data -- List: Contains tuple of offending Subtest and type of
                        error, ie size mismatch, order mismatch, etc
        Returns:
            None
        """
        pass
        # from datetime import datetime
        # result = ""
        # outFile = "ErrorReport_{}.txt".format(datetime.now().time().isoformat())
        # with open(outFile, 'w') as report:
        #     # for test, error in data:
        #         result += "{0}:\t {1}\n".format(test, error)
            # report.write(result)


class SubTestManager(object):
    """Class used to keep track of everything related to subtest"""
    def __init__(self, _dFile, _mDIR):
        super(SubTestManager, self).__init__()

        self.MEASURE = _mDIR
        self.dataFile = _dFile

        self.ID = self.getTestID(_dFile)
        self.DATA = os.path.split(_dFile)[0]

        self.pattern = self.makePattern()
        self.dataScores = self.loadDataScores()

        self.itemFile = None
        self.itemMeasure = None

        self.personFile = None
        self.abilityMeasure = None

        self.result = ""
        self.outFile = "final/SubTest{0}_results.txt".format(self.ID)

    def getTestID(self, filePath):
        """ Extracts the Test ID from the provided file path using a
            regexp pattern provided by the user

        Params:
            filePath -- A string of the for /path/to/the/file_name.txt

        Returns:
             A string representing the subtest ID
        """
        fpl = filePath.lower()
        _fn = os.path.split(fpl)[1].split('_')[0]
        sn = re.split('[tT]est', _fn)[1]  # sn => subtest number
        numMatch = re.search('[0-9]+', sn)
        alphaMatch = re.search('[a-z]+', sn)

        if numMatch and alphaMatch:
            num, alpha = numMatch.group(), alphaMatch.group()
            num = str(int(num))  # convert the string to an int to strip the leading 0 (if there is one)
            return num+alpha
        elif numMatch and not alphaMatch:
            num = numMatch.group()
            return str(int(num))
        else:
            alpha = alphaMatch.group()
            return alpha

    def makePattern(self):
        pat = r'0?'
        for l in self.ID:
            if re.search('[a-zA-Z]', l):
                pat += "[{}{}]".format(l.upper(), l.lower())
            elif re.search('[0-9]', l):
                pat += l
        return pat

    def hasFiles(self):
        fileList = []
        path = os.path.join(self.MEASURE, "*.txt")
        fileList = [f for f in glob(path) if re.search(self.pattern, f)]

        for fn in fileList:
            if re.search('[iI]tem', fn):
                self.itemFile = fn
            elif re.search('[pP]erson', fn):
                self.personFile = fn

        if len(fileList) < 2:
            return False
        else:
            return True

    def loadDataScores(self):
        _data = []
        with open(self.dataFile, 'U') as d:
            for line in d:
                rline = line.rstrip('\r\n')
                sline = rline.split()
                scores = ''.join(sline[9:])
                _data.append([sline[0], scores])
        return _data

    def loadItemMeasure(self):
        if self.itemFile is None:
            return None
        else:
            with open(self.itemFile, 'U') as i:
                _item = i.read().rstrip('\r\n').split()
            return _item

    def loadAbilityMeasure(self):
        if self.personFile is None:
            return None
        else:
            _ability = []
            with open(self.personFile, 'U') as p:
                for line in p:
                    rline = line.rstrip('\r\n')
                    sline = rline.split()
                    if len(sline) < 2 and len(sline) > 1:
                        sline.append('x')
                    _ability.append(sline)
            return _ability

    def hasMatchingLengths(self):
        # Check that subtest_data is the same size as the persons_ability
        if self.abilityMeasure is None:
            return False
        elif len(self.dataScores) is not len(self.abilityMeasure):
            return False
        else:  # They do!
            return True

    def hasMatchingSubjects(self):
        index = 1
        for dataSub, abilSub in zip(self.dataScores, self.abilityMeasure):
            if dataSub[0] != abilSub[0]:
                return (False, index)
            index += 1
        return (True, index)

    def hasMatchingItemLengths(self):
        for index, scores in enumerate(self.dataScores):
            if len(self.itemMeasure) != len(zip(scores[1], self.itemMeasure)):
                self.ErrorLog('A2', index, len(self.itemMeasure), len(scores[1]))
                return False
        return True

    def FixData(self):
        for i, subjScores in enumerate(self.dataScores):
            subj = subjScores[0]
            scores = subjScores[1]
            self.result = "{0}\t".format(subj)
            ability = self.abilityMeasure[i][1]
            if ability in ["X", "x", "?"]:  # If the ability file has an X, skip it. Subj never took the test
                self.result += "{0}\n".format(scores)
            else:
                for j, value in enumerate(scores):
                    if value != '.':
                        self.result += value
                    else:
                        item = self.itemMeasure[j]
                        self.result += self.getPerformanceScore(item, ability)

    def getPerformanceScore(self, item, ability):
        if item in ["X", "x", "?"]:
            return " "
        elif float(ability) < float(item):  # if ability is less than measure, assign 0
            return '0'
        elif float(ability) > float(item):  # if ability is greater than measure, assign 1
            return '1'
        else:  # if ability is equal to measure...
            if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
                return '0'  # Failed
            else:  # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
                return '1'  # Passed

    def generateReport(self):
        """ Writes data to a file

        Returns:
            None
        """
        if os.path.isfile(self.outFile):
            print self.ErrorLog.spacer+"WARNING !! {0} already exists! Removing...".format(self.outFile)
            os.remove(self.outFile)  # check that the file doenst already exist
        self.result += "\n"  # Add a newline just in case
        with open(self.outFile, 'a') as report:  # Append to the file
            report.write(self.result)

    def hasErrors(self):
        if self.ErrorLog.has_Error:
            return True
        else:
            return False

#=============================== START OF MAIN ===============================


def main():
    # Several datafiles, each with a long list of subjects

    # Directory path variable assignment, assumes script is in working directory!!!
    DATA = "data"
    MEASURE = "measure"
    FINAL = "final"
    errorLog = ErrorLogger()

    # Mainly for testing purposes
    if len(sys.argv) > 1:
        DATA = os.path.join(sys.argv[1], DATA)
        MEASURE = os.path.join(sys.argv[1], MEASURE)
        FINAL = os.path.join(sys.argv[1], FINAL)

    # checks to see if the 'final' directory exists, creating it if necessary
    if not os.path.exists(FINAL):
        os.mkdir(FINAL)

    # Start main loop
    for st in glob(os.path.join(DATA, '[Ss]ub[Tt]est*.txt')):
        subTest = SubTestManager(st, MEASURE)
        print "\n{:*>30}".format(" Now Processing SubTest{} ".format(subTest.ID))

        if not subTest.hasFiles():
            errorLog('001', subTest)
        elif not subTest.hasMatchingLengths():
            errorLog('002', subTest)
        elif not subTest.hasMatchingSubjects()[0]:

    print "There was {} Error(s)! See {} for more details".format(errorLog.numErrors, errorLog.outFile)

if __name__ == '__main__':
    main()
