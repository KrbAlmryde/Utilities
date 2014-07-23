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


def getTestID(filePath, pat):
    """ Extracts the Test ID from the provided file path using a 
        regexp pattern provided by the user

    Params:
        filePath -- A string of the for /path/to/the/file_name.txt
        pat -- A regexp pattern string, eg '[tT]est'

    Returns:
         A string representing the subtest ID
    """
    fpl = filePath.lower()
    _fn = os.path.split(fpl)[1].split('_')[0]
    sn = re.split(pat, _fn)[1] # sn => subtest number
    numMatch = re.search('[0-9]+', sn)
    alphaMatch = re.search('[a-z]+', sn)

    if numMatch and alphaMatch:
        num, alpha = numMatch.group(), alphaMatch.group()
        num = str( int(num) ) # convert the string to an int to strip the leading 0 (if there is one)
        return num+alpha

    elif numMatch and not alphaMatch:
        num = numMatch.group()
        return str( int(num) )

    else:
        alpha = alphaMatch.group()
        return alpha


def makeSubTestIndex(dataPath, measurePath):
    """ Create a dictionary with Subtest #s as the keys
        and a list of the data file as values.

    Params:
        dataPath -- A string of the for /path/to/the/file_name.txt
        measurePath -- A string of the for /path/to/the/file_name_measure.txt

    Returns:
         A dictionary containing the subtest ID as the index, and a list
         of filenames as values
    """
    testIndex = dict()

    for _dFile in glob(os.path.join(dataPath,"*.txt")):
        sn = getTestID(_dFile,'[tT]est')
        # print "data id is: ",sn, _dFile
        testIndex[sn] = [_dFile]

    # add measures filenames to SubTest_Index
    for _measure in glob(os.path.join(measurePath,"*.txt")):
        sn = getTestID(_measure, '[sS]ub')
        # print "_measure id is: ",sn, _measure
        testIndex[sn].append(_measure)  # append the subtest Item and Person measure to the SubTest_Index

    return testIndex


def makeFinaldirectory(subId, filePath):
    """ Creates a 'Final' results directory

    Params:
        subId -- A string representing the subtest ID
        filePath -- A string of the for /path/to/the/file_name.txt

    Returns:
         A string 
    """
    outFn = os.path.join(filePath,"SubTest{0}_results.txt".format(subId))
    if os.path.isfile(outFn):
        spacer="                          "
        print spacer+"WARNING !! {0} already exists! Removing...".format(outFn)
        os.remove(outFn) # check that the file doenst already exist
    return outFn


def loadSubtTestDataFiles(fileList):
    """ One line description

    Params:
     arg -- arg

    Returns:
      Description of returns
    """
    dFn, iFn, aFn = fileList  # [d]ata,[i]tem,[a]bility [F]ile[n]ame   '\t+|\r\n+|\r+|\n+'

    # _data = open(dFn, 'U').read().strip()
    with open(dFn, 'U') as dataStream:
        _data = dataStream.read().strip().split(os.linesep) #re.split('\t+|\r\n+|\r+|\n+', _data)

    # _data = open(iFn, 'U').read().strip()
    with open(iFn, 'U') as measureStream:
        _measures = measureStream.read().strip().split()
    
    with open(aFn, 'U') as abilityStream:
        _ability = [ el.split() for el in abilityStream.read().strip().split(os.linesep)]

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
    data+="\n" # Add a newline just in case
    with open(outFile,'a') as report: # Append to the file
        report.write(data)
    

def writeErrorReport(outFile, data):
    """ Writes error report with associated problem

    Params:
        data -- List: Contains tuple of offending Subtest and type of
                    error, ie size mismatch, order mismatch, etc
    Returns:
        None
    """
    from datetime import datetime
    result = ""
    outFn = outFile+datetime.now().time().isoformat() + ".txt"
    with open(outFn, 'w') as report:
        for test, error in data:
            result += "{0}:\t {1}\n".format(test, error)
        report.write(result)


class ErrorLogger(object):
    """Tracks errors and creates log detailing problems that occurred"""
    def __init__(self, subID):
        super(ErrorLogger, self).__init__()
        self.ID = subID
        self.has_Error = 0
        self.spacer = " "*26
        self.ErrorIndex = {
            "A0": ["Missing SubTest Files!", self.A0],
            "A1": ["Size Mismatch! SubTest Data and Person measure files are different lengths!", self.A1],
            "A2": ["Item/Data Size Mismatch!", "A function should go here"],
            "B0": ["Participant ID Mismatch Error! Data Subject != Person Subject", "A function should go here"],
            "B1": ["", "A function should go here"],
            "C0": ["", "A function should go here"],
            "C1": ["", "A function should go here"]
        }
        self.log = []

    def __call__(self, errorCode, *arguments):
        """ errorCode will act as key to ErrorIndex, which will report Error
            type and call appropriate message function. *arguments will be 
            supplied to respective function
        """
        self.has_Error = 1
        error = self.ErrorIndex[errorCode][0]
        func = self.ErrorIndex[errorCode][1]       
        print error
        self.log.append(error)
        func(arguments)

    def A0(self, fileList):
        print self.spacer+"ERROR !! Missing,", 3 - len(fileList), "SubTest measure files!!", fileList
        
    def A1(self, fileList):
        print self.spacer+"ERROR !! Size Mismatch:\tdata: {0}\tability: {1}".format(len(fileList[0]), len(fileList[1]))
    
    def generateReport(self):
        """ Writes error report with associated problem

        Params:
            data -- List: Contains tuple of offending Subtest and type of
                        error, ie size mismatch, order mismatch, etc
        Returns:
            None
        """
        from datetime import datetime
        result = ""
        outFn = outFile+datetime.now().time().isoformat() + ".txt"
        with open(outFn, 'w') as report:
            for test, error in data:
                result += "{0}:\t {1}\n".format(test, error)
            report.write(result)


class SubTestManager(object):
    """Class used to keep track of everything related to subtest"""
    def __init__(self, subID, file_name_List):
        super(SubTestManager, self).__init__()
        self.ID = subID
        self.outFile = "final/SubTest{0}_results.txt".format(self.ID)
        self.ErrorLog = ErrorLogger(subID)
        self.dataFile = ""
        self.itemFile = ""
        self.personFile = ""

        if len(file_name_List) < 3:
            self.ErrorLog("A0", file_name_List)
        else:
            self.dataFile = file_name_List[0]
            self.itemFile = file_name_List[1]
            self.personFile = file_name_List[2]

        self.dataScores = self.getDataScores()
        self.itemMeasure = self.getItemMeasure()
        self.abilityMeasure = self.getAbilityMeasure()
        self.result = ""

    def getDataScores(self):
        _data = []
        if self.ErrorLog.has_Error:
            return ""
        else:
            with open(self.dataFile, 'U') as d:
                for line in d:
                    rline = line.rstrip('\r\n')
                    sline = rline.split()
                    scores = ''.join(sline[9:])
                    _data.append([sline[0], scores])
            return _data

    def getItemMeasure(self):
        if self.ErrorLog.has_Error:
            return ""
        else:
            with open(self.itemFile, 'U') as i:
                _item = i.read().rstrip('\r\n').split()
            return _item

    def getAbilityMeasure(self):
        _ability = []
        if self.ErrorLog.has_Error:
            return ""
        else:    
            with open(self.personFile, 'U') as p:
                for line in p:
                    rline = line.rstrip('\r\n')
                    sline = rline.split()
                    if len(sline) < 2 and len(sline) > 1:
                        sline.append('x')
                    _ability.append(sline)
            return _ability

    def checkDataAbilityLength(self):
        # Check that subtest_data is the same size as the persons_ability
        if len(self.dataScores) != len(self.abilityMeasure):
            self.ErrorLog('A1', self.dataFile, self.personFile)
            return False
        else:
            return True
    
    def checkSubjectsMatch(self):
        index = 0
        for dSub, aSub in zip(self.dataScores, self.abilityMeasure):
            if dSub[0] != aSub[0]:
                self.ErrorLog('B0', index, dSub[0], aSub[0])
                return False
            index+=1
        return True

    def checkDataItemLength(self):
        for index, scores in enumerate(self.dataScores):
            if len(self.itemMeasure) != len(zip(scores[1], self.itemMeasure)):
                self.ErrorLog('A2', index, len(self.itemMeasure), len(scores[1]))
                return False
        return True

    def fixData(self):
        for i, subjScores in enumerate(self.dataScores):
            subj = subjScores[0]
            scores = subjScores[1]
            self.result = "{0}\t".format(subj)
            ability = self.abilityMeasure[i][1]
            if ability in ["X","x","?"]:  # If the ability file has an X, skip it. Subj never took the test
                self.result += "{0}\n".format(scores)
            else:
                for j, value in enumerate(scores):
                    if value != '.':
                        self.result += value
                    else:
                        item = self.itemMeasure[j]
                        self.result += self.getPerformanceScore(item, ability)

    def getPerformanceScore(self, item, ability):
        if item in ["X","x","?"]: 
            return " "
        elif float(ability) < float(item):  # if ability is less than measure, assign 0
            return '0'
        elif float(ability) >  float(item): # if ability is greater than measure, assign 1
            return '1'
        else:  # if ability is equal to measure...
            if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
                return '0'  # Failed
            else: # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
                return '1'  # Passed

    def generateReport(self):
        """ Writes data to a file

        Returns:
            None
        """
        if os.path.isfile(self.outFile):
            print self.ErrorLog.spacer+"WARNING !! {0} already exists! Removing...".format(self.outFile)
            os.remove(self.outFile) # check that the file doenst already exist
        self.result+="\n" # Add a newline just in case
        with open(self.outFile,'a') as report: # Append to the file
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
    SubTest_Error_Index = [] # List to keep track of the number of erroneous files that need addressing

    # Mainly for testing purposes
    if len(sys.argv) > 1:
        DATA = os.path.join(sys.argv[1], DATA)
        MEASURE = os.path.join(sys.argv[1], MEASURE)
        FINAL = os.path.join(sys.argv[1], FINAL)

    # checks to see if the 'final' directory exists, creating it if necessary
    if not os.path.exists(FINAL): os.mkdir(FINAL)

    # create { SubTest: [File names] dictionary }
    # SubTest_Index = makeSubTestIndex(DATA, MEASURE)

    # SubTest_Index should look something like this:
    # {'sub1': ['SubTest01_SC.txt', 'Sub01_item_meausre.txt', 'Sub01_person_meausre.txt'],
    #  'sub3a': ['SubTest3A_SC.txt', 'Sub3A_item_meausre.txt', 'Sub3A_person_meausre.txt']}
    # print "\n",len(SubTestIndex), "SubTestIndex", SubTestIndex

    # Start main loop
    for subId, file_name_List in makeSubTestIndex(DATA, MEASURE).items():
        subtest = SubTestManager(subId, file_name_List)

        if subtest.hasErrors():
            print "There were errors: {0}".format(subtest.ID)
        elif subtest.checkDataAbilityLength() and subtest.checkSubjectsMatch() and subtest.checkDataItemLength():
            subtest.fixData()
            subtest.generateReport()
        else:
            print "There were errors: {0}".format(subtest.ID)
            # subtest.ErrorLog.generateReport()



    #     spacer="                          "
    #     has_Error=0  # effectively an "ignore me" flag
    #     print "\n++++++++++++++++++++++++++++ SubTest:", subtest.ID, len(file_name_List)

    #     if len(file_name_List) < 3:
    #         has_Error = 1
    #         SubTest_Error_Index.append((file_name_List, "Files(s) Error"))

    #         print spacer+"ERROR !! Missing,", 3 - len(file_name_List), "SubTest measure files!!", file_name_List
    #         pass
    #     else:
    #         # make the 'final' directory if it doesnt already exist
    #         output_Filename = makeFinaldirectory(subId, FINAL)

    #         # load subtest data, item measure, and person ability scores
    #         subtest_data, items_measures, persons_ability = loadSubtTestDataFiles(file_name_List)

    #         # Check that subtest_data is the same size as the persons_ability
    #         if len(subtest_data) != len(persons_ability):
    #             has_Error = 1
    #             SubTest_Error_Index.append((file_name_List[0], "Size Mismatch Error:\tdata: {0}\tability: {1}".format(len(subtest_data), len(persons_ability))))
    #             print spacer+"ERROR !! Size Mismatch Error:\tdata: {0}\tability: {1}".format(len(subtest_data), len(persons_ability))
    #             # print "\tThere are currently {0} erroneous SubTests that need to be addressed\n".format(len(SubTest_Error_Index))
    #             pass

    #         for i, line in enumerate(subtest_data):
    #             if has_Error:
    #                 pass
    #             else:
    #                 seg = line.strip().split()  # Each line represents a single subject, strip off any newline characters, the split on whitespace
    #                 data = "".join(seg[9:])     #+ some data files have spaces intermixed in the data column, resulting in
    #                                             #+ potentially missed values, this line corrects that.subtest_data[i]
    #                 subtest_data[i] = [seg[0], data]
    #                 # print "subtest_data[{0}]: \t{1}".format(i, subtest_data[i])
    #                 # persons_ability[i] = re.split('\t+|\r\n+|\r+|\n+', persons_ability[i])
    #                 result = "{0}\t".format(subtest_data[i][0])

    #                 # print "\tSubTest subID:",repr(subtest_data[i][0]), len(subtest_data[i][0])
    #                 # print "\tperson subID:", repr(persons_ability[i][0]), len(persons_ability[i][0])

    #                 # Check that if there is a mismatch between subtest_data[i][0] and persons_ability[i][0] subIds
    #                 if subtest_data[i][0] != persons_ability[i][0]:  # if the subtest participant id does not match the person id, log the error!
    #                     has_Error = 1
    #                     SubTest_Error_Index.append((file_name_List[0], "Participant ID Mismatch Error: line {0}".format(i)))
    #                     # print spacer+"ERROR !! Participant ID Mismatch Error:{0} participant ID does not match {1} participant ID: line {2}!!".format(dFn, aFn, i)
    #                     # print "\t",repr(subtest_data[i][0]), repr(persons_ability[i][0])
    #                     # print "\tThere are currently {0} erroneous SubTests that need to be addressed\n".format(len(SubTest_Error_Index))
    #                     break

    #                 # Perform measure corrections and write to file, Or report error and skip subject
    #                 if len(items_measures) != len(subtest_data[i][1]):
    #                     has_Error = 1
    #                     SubTest_Error_Index.append((file_name_List[i], "Item Measure Mismatch:\titem: {0}\tdata: {1}".format(len(items_measures), len(subtest_data[i][1]))))
    #                     print spacer+"ERROR !! Item Measure Mismatch:\titem: {0}\tdata: {1}".format(len(items_measures), len(subtest_data[i][1]))
    #                     pass
    #                 elif persons_ability[i][1] in ["X","x","?"]:  # If the ability file has an X, skip it. Subj never took the test
    #                     # print "Subject didnt take test"
    #                     writeResults(output_Filename, result+subtest_data[i][1])
    #                 else:
    #                     for j, point in enumerate(subtest_data[i][1]):
    #                         if point != '.':    # If the value is not a '.' write that value
    #                             result += point
    #                         else:
    #                             if items_measures[j] in ["X","x","?"]: 
    #                                 pass
    #                             elif float(persons_ability[i][1]) < float(items_measures[j]):  # if ability is less than measure, assign 0
    #                                 result += '0'
    #                             elif float(persons_ability[i][1]) >  float(items_measures[j]): # if ability is greater than measure, assign 1
    #                                 result += '1'
    #                             else:  # if ability is equal to measure...
    #                                 if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
    #                                     result += "0"  # Failed
    #                                 else: # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
    #                                     result += "1"  # Passed
    #                     writeResults(output_Filename, result)  # write final results to file
    #     has_Error=0
    # if SubTest_Error_Index:
    #     print "\nThere were errors {0} in the program! Writing error report...".format(len(SubTest_Error_Index))
    #     errorFN = os.path.join(FINAL,"ErrorReport_")
    #     writeErrorReport(errorFN, SubTest_Error_Index) # Write
    # else:
    #     print "There were no errors detected! Be sure to look over your results for accuracy!"

if __name__ == '__main__':
    main()
