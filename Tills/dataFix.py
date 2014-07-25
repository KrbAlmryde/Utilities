"""
==============================================================================
Program: dataFix.py
 Author: Kyle Reese Almryde
   Date: 03/11/2014
Updated: 06/06/2014
         07/12/2014
         07/25/2014

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
from datetime import datetime


class ErrorLogger(object):
    """Tracks errors and creates log detailing problems that occurred"""
    def __init__(self):
        super(ErrorLogger, self).__init__()

        self.log = []
        self.numErrors = 0
        self.result = ""
        tm = datetime.now().timetuple()
        self.outFile = "ErrorReport_{}-{}-{}_{}:{}:{}.txt".format(tm.tm_mon, tm.tm_mday, tm.tm_year, tm.tm_hour-12, tm.tm_min, tm.tm_sec)
        self.ErrorIndex = {
            "001": "Missing SubTest Files",
            "002": "Size Mismatch! Data and Person file do not have equal entries",
            "003": "Item/Data Size Mismatch!",
            "004": "Participant ID Mismatch Error!",
            "005": "Size of Corrected Results vector does not match supplied Data vector"
        }

    def __call__(self, errorCode, sub_test):
        """ errorCode will act as key to ErrorIndex, which will report Error
            type and call appropriate message function. *arguments will be
            supplied to respective function
        """
        self.numErrors += 1
        error = self.ErrorIndex[errorCode]
        print "{:>15} {}".format('!! ERROR !!', error)

        if errorCode is '001':
            self.error001(sub_test)
        elif errorCode is '002':
            self.error002(sub_test)
        elif errorCode is '003':
            self.error003(sub_test)
        elif errorCode is '004':
            self.error004(sub_test)
        elif errorCode is '005':
            self.error005(sub_test)

    def error001(self, sub_test):
        missing = []
        if sub_test.itemFile is None:
            missing.append("item_measure")
        if sub_test.personFile is None:
            missing.append("person_measure")

        error = "SubTest{}: {} File(s) missing: ".format(sub_test.ID, len(missing))
        for el in missing:
            error += " {}".format(el)
        self.log.append(error)

    def error002(self, sub_test):
        dataSize = len(sub_test.dataScores)
        personSize = len(sub_test.abilityScores)
        error = "SubTest{}: Number of entries do not match: Data has {}, Person has {} entries".format(sub_test.ID, dataSize, personSize)
        self.log.append(error)

    def error003(self, sub_test):
        dataLen = len(sub_test.dataScores[sub_test.stopIndex][1])
        itemLen = len(sub_test.itemScores)
        error = "SubTest{}: Number of Data points does match number of items: Data has {} points, Items has {}".format(sub_test.ID, dataLen, itemLen)
        self.log.append(error)

    def error004(self, sub_test):
        index = sub_test.stopIndex - 1
        dataSub = sub_test.dataScores[index][0]
        personSub = sub_test.abilityScores[index][0]
        error = "SubTest{}: Subjects do not match: Data {} != Person {}, on line {}".format(sub_test.ID, dataSub, personSub, sub_test.stopIndex)
        self.log.append(error)

    def error005(self, sub_test):
        index = sub_test.error005[0] + 1
        subj = sub_test.error005[1]
        lenResult = sub_test.error005[2]
        lenData = sub_test.error005[3]
        error = "SubTest{}: Size of Corrected Results vector({}) != Supplied Data vector({}) for Subject {} on line {}".format(sub_test.ID, lenResult, lenData, subj, index)
        self.log.appen(error)

    def generateReport(self, outDIR):
        """ Writes error report with associated problem

        Params:
            data -- List: Contains tuple of offending Subtest and type of
                        error, ie size mismatch, order mismatch, etc
        Returns:
            None
        """
        self.outFile = os.path.join(outDIR, self.outFile)
        with open(self.outFile, 'w') as report:
            for error in self.log:
                self.result += "{}\n".format(error)
            report.write(self.result)


class SubTestManager(object):
    """Class used to keep track of everything related to subtest"""
    def __init__(self, _dFile, _mDIR):
        super(SubTestManager, self).__init__()

        self.ID = self.getTestID(_dFile)

        self.MEASURE = _mDIR
        self.DATA = os.path.split(_dFile)[0]

        self.dataFile = _dFile
        self.dataScores = self.loadDataScores()

        self.itemFile = None
        self.itemScores = None

        self.personFile = None
        self.abilityScores = None

        self.stopIndex = None  # This is used exclusively in the event that a mismatch occurs with subjects
        self.pattern = self.makePattern()

        self.result = ""
        self.outFile = "SubTest{0}_results.txt".format(self.ID)
        self.error005 = None

    def hasFiles(self):
        fileList = []
        path = os.path.join(self.MEASURE, "*.txt")
        fileList = [f for f in glob(path) if re.search(self.pattern, f)]

        if len(fileList) < 2:
            return False
        elif len(fileList) >= 2:
            for fn in fileList:
                _fn = os.path.split(fn)[1].split('_')[0]
                rawID = re.split('[sS]ub', _fn)[1]
                pat = '^{}$'.format(self.pattern)
                if re.search(pat, rawID):
                    if re.search('[iI]tem', fn):
                        # print "\tItem {}".format(fn)
                        self.itemFile = fn
                    elif re.search('[pP]erson', fn):
                        # print "\tPerson {}".format(fn)
                        self.personFile = fn
            return True

    def hasMatchingLengths(self):
        # Check that subtest_data is the same size as the persons_ability
        if self.abilityScores is None:
            try:
                self.abilityScores = self.loadAbilityScores()
            except IOError:
                return False

        if len(self.dataScores) != len(self.abilityScores):
            return False
        else:  # They do!
            return True

    def hasMatchingItemLengths(self):
        if self.itemScores is None:
            try:
                self.itemScores = self.loadItemScores()
            except IOError:
                return False
        _index = 0
        for _, scores in self.dataScores:
            if len(self.itemScores) != len(scores):
                self.stopIndex = _index
                return False
            _index += 1
        return True

    def hasMatchingSubjects(self):
        _index = 1
        for dataSub, abilSub in zip(self.dataScores, self.abilityScores):
            if dataSub[0] != abilSub[0]:
                self.stopIndex = _index
                return False
            _index += 1
        return True

    def FixData(self, errorLog):
        if not self.hasMatchingSubjects():
            errorLog('004', self)
        for i, subjScores in enumerate(self.dataScores):
            subj = subjScores[0]
            scores = subjScores[1]
            result = ""
            try:
                ability = self.abilityScores[i][1]
            except IndexError:
                ability = 'x'
            if i is self.stopIndex:
                return True
            for j, point in enumerate(scores):
                item = self.itemScores[j]
                if re.search('[xX? ]', item):
                    result += "*"
                elif re.search('[xX? ]', ability):  # If the ability file has an X, a ?, or is simply blank, skip it. Subj never took the test
                    if point != '.':
                        result += point
                    else:
                        result += "."  # "{0}".format(scores)
                elif point != '.':
                    result += point
                else:
                    result += self.calculatePerformance(item, ability)
            if len(result) != len(scores):
                print "\tProblems!!", len(result), len(scores)
                self.error005 = (i, subj, len(result), len(scores))
                errorLog('005', self)
            self.result += "{0}\t{1}\n".format(subj, result)
        return True

    def generateReport(self, outDIR):
        """ Writes data to a file

        Returns:
            None
        """
        self.outFile = os.path.join(outDIR, self.outFile)
        if os.path.isfile(self.outFile):  # check that the file doenst already exist
            print "{:>17} {} already exists! Removing...".format("!! WARNING !!", self.outFile)
            os.remove(self.outFile)
        with open(self.outFile, 'a') as report:  # Append to the file
            report.write(self.result)

    # ================== Private Methods ==================

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
            # num = str(int(num))  # convert the string to an int to strip the leading 0 (if there is one)
            return num+alpha
        elif numMatch and not alphaMatch:
            return numMatch.group()
            # num = numMatch.group()
            # return str(int(num))
        else:
            alpha = alphaMatch.group()
            return alpha

    def makePattern(self):
        pat = r''
        for i, l in enumerate(self.ID):
            if i is 0 and l is '0':
                pat = r'0?'
            elif re.search('[a-zA-Z]', l):
                pat += "[{}{}]".format(l.upper(), l.lower())
            elif re.search('[0-9]', l):
                pat += l
        return pat

    def loadDataScores(self):
        if self.dataFile is None:
            return None
        else:
            _data = []
            with open(self.dataFile, 'U') as d:
                for line in d:
                    rline = line.rstrip('\r\n')
                    sline = rline.split()
                    scores = ''.join(sline[9:])
                    _data.append([sline[0], scores])
            return _data

    def loadItemScores(self):
        if self.itemFile is None:
            return None
        else:
            with open(self.itemFile, 'U') as i:
                _item = i.read().rstrip('\r\n').split()
            return _item

    def loadAbilityScores(self):
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

    def calculatePerformance(self, item, ability):
        if float(ability) < float(item):  # if ability is less than item, assign 0
            return '0'
        elif float(ability) > float(item):  # if ability is greater than item, assign 1
            return '1'
        else:  # if ability is equal to item...
            if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
                return '0'  # Failed
            else:  # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
                return '1'  # Passed

#=============================== START OF MAIN ===============================


def main():
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
        elif not subTest.hasMatchingItemLengths():
            errorLog('003', subTest)
        elif subTest.FixData(errorLog):
            subTest.generateReport(FINAL)

    print "\nThere was {} Error(s)! See {} for more details".format(errorLog.numErrors, errorLog.outFile)
    errorLog.generateReport(FINAL)

if __name__ == '__main__':
    main()
