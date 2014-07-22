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
    """ One line description

    Params:
        filePath -- arg


    Returns:
         Description of returns
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


def makeSubTestIndex(filePath):
    """ Create a dictionary with Subtest #s as the keys
        and a list of the data file as values.

    Params:
        arg -- arg


    Returns:
         Description of returns
    """
    testIndex = dict()

    for _file in glob(os.path.join(filePath,"*.txt")):
        sn = getTestID(_file,'[tT]est')
        # print "data id is: ",sn, _file
        testIndex[sn] = [_file]

    return testIndex


def makeFinaldirectory(subId, filePath):
    """

    Params:
        arg -- arg


    Returns:
         Description of returns
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
    _data = open(dFn, 'U').read().strip().split(os.linesep) #re.split('\t+|\r\n+|\r+|\n+', _data)

    # _data = open(iFn, 'U').read().strip()
    _measures = open(iFn, 'U').read().strip().split()
    _ability = [ el.split() for el in open(aFn, 'U').read().strip().split(os.linesep)]

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
    report = open(outFile,'a')  # Append to the file
    report.write(data)
    report.close()


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
    report = open(outFn, 'w')
    for test, error in data:
        result += "{0}:\t {1}\n".format(test, error)
    report.write(result)
    report.close()



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
    SubTest_Index = makeSubTestIndex(DATA)

    # add measures filenames to SubTest_Index
    for measure in glob(os.path.join(MEASURE,"*.txt")):
        sn = getTestID(measure, '[sS]ub')
        # print "measure id is: ",sn, measure
        SubTest_Index[sn].append(measure)  # append the subtest Item and Person measure to the SubTest_Index

        # SubTest_Index should look something like this:
        # {'sub1': ['SubTest01_SC.txt', 'Sub01_item_meausre.txt', 'Sub01_person_meausre.txt'],
        #  'sub3a': ['SubTest3A_SC.txt', 'Sub3A_item_meausre.txt', 'Sub3A_person_meausre.txt']}
    # print "\n",len(SubTestIndex), "SubTestIndex", SubTestIndex


    # Start main loop
    for subId, file_name_List in SubTest_Index.items():
        spacer="                          "
        has_Error=0  # effectively an "ignore me" flag
        print "\n++++++++++++++++++++++++++++ SubTest:", subId, len(file_name_List)

        if len(file_name_List) < 3:
            has_Error = 1
            SubTest_Error_Index.append((file_name_List, "Files(s) Error"))

            print spacer+"ERROR !! Missing,", 3 - len(file_name_List), "SubTest measure files!!", file_name_List
            pass
        else:
            # make the 'final' directory if it doesnt already exist
            output_Filename = makeFinaldirectory(subId, FINAL)

            # load subtest data, item measure, and person ability scores
            subtest_data, items_measures, persons_ability = loadSubtTestDataFiles(file_name_List)

            # Check that subtest_data is the same size as the persons_ability
            if len(subtest_data) != len(persons_ability):
                has_Error = 1
                SubTest_Error_Index.append((file_name_List[0], "Size Mismatch Error:\tdata: {0}\tability: {1}".format(len(subtest_data), len(persons_ability))))
                print spacer+"ERROR !! Size Mismatch Error:\tdata: {0}\tability: {1}".format(len(subtest_data), len(persons_ability))
                # print "\tThere are currently {0} erroneous SubTests that need to be addressed\n".format(len(SubTest_Error_Index))
                pass

            for i, line in enumerate(subtest_data):

                if has_Error:
                    pass
                else:
                    seg = line.strip().split()  # Each line represents a single subject, strip off any newline characters, the split on whitespace
                    data = "".join(seg[9:])  # some data files have spaces intermixed in the data column, resulting in
                                             # potentially missed values, this line corrects that.subtest_data[i]
                    subtest_data[i] = [seg[0], data]
                    # print "subtest_data[{0}]: \t{1}".format(i, subtest_data[i])
                    # persons_ability[i] = re.split('\t+|\r\n+|\r+|\n+', persons_ability[i])
                    result = "{0}\t".format(subtest_data[i][0])

                    # print "\tSubTest subID:",repr(subtest_data[i][0]), len(subtest_data[i][0])
                    # print "\tperson subID:", repr(persons_ability[i][0]), len(persons_ability[i][0])

                    # Check that if there is a mismatch between subtest_data[i][0] and persons_ability[i][0] subIds
                    if subtest_data[i][0] != persons_ability[i][0]:  # if the subtest participant id does not match the person id, log the error!
                        has_Error = 1
                        SubTest_Error_Index.append((dFn, "Participant ID Mismatch Error: line {0}".format(i)))
                        print spacer+"ERROR !! Participant ID Mismatch Error:{0} participant ID does not match {1} participant ID: line {2}!!".format(dFn, aFn, i)
                        # print "\t",repr(subtest_data[i][0]), repr(persons_ability[i][0])
                        # print "\tThere are currently {0} erroneous SubTests that need to be addressed\n".format(len(SubTest_Error_Index))
                        break

                    # Perform measure corrections and write to file, Or report error and skip subject
                    if len(items_measures) != len(subtest_data[i][1]):
                        has_Error = 1
                        SubTest_Error_Index.append((file_name_List[i], "Item Measure Mismatch:\titem: {0}\tdata: {1}".format(len(items_measures), len(subtest_data[i][1]))))
                        print spacer+"ERROR !! Item Measure Mismatch:\titem: {0}\tdata: {1}".format(len(items_measures), len(subtest_data[i][1]))
                        pass
                    elif persons_ability[i][1] in ["X","x","?"]:  # If the ability file has an X, skip it. Subj never took the test
                        # print "Subject didnt take test"
                        writeResults(output_Filename, result+subtest_data[i][1])
                    else:
                        for j, point in enumerate(subtest_data[i][1]):
                            if point != '.':    # If the value is not a '.' write that value
                                result += point
                            else:
                                if float(persons_ability[i][1]) < float(items_measures[j]):  # if ability is less than measure, assign 0
                                    result += '0'
                                elif float(persons_ability[i][1]) >  float(items_measures[j]): # if ability is greater than measure, assign 1
                                    result += '1'
                                else:  # if ability is equal to measure...
                                    if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
                                        result += "0"  # Failed
                                    else: # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
                                        result += "1"  # Passed
                        writeResults(output_Filename, result)  # write final results to file
        has_Error=0
    if SubTest_Error_Index:
        print "\nThere were errors {0} in the program! Writing error report...".format(len(SubTest_Error_Index))
        errorFN = os.path.join(FINAL,"ErrorReport_")
        writeErrorReport(errorFN, SubTest_Error_Index) # Write
    else:
        print "There were no errors detected! Be sure to look over your results for accuracy!"

if __name__ == '__main__':
    main()
