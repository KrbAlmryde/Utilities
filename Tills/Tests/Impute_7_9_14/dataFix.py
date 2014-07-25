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

import os, sys
from glob import glob
from random import random


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

    # Mainly for testing purposes
    if len(sys.argv) > 1: 
        DATA = os.path.join(sys.argv[1], DATA)
        MEASURE = os.path.join(sys.argv[1], MEASURE)
        FINAL = os.path.join(sys.argv[1], FINAL)



    if not os.path.exists(FINAL): os.mkdir(FINAL)  # checks to see if the 'final' directory exists, creating it if necessary

    # Create a dictionary with Subtest #s as the keys and a list of the data
    # file as values. Uses a Dictionary Comprehension
    SubTestIndex = {os.path.split(_file)[1].split('_')[0].split('Test')[1]: [_file] for _file in glob(os.path.join(DATA,"*.txt"))}       

    for measure in glob(os.path.join(MEASURE,"*.txt")):
        sn = os.path.split(measure)[1].split('_')[0].split('Sub')[1] # sn => subtest number
        SubTestIndex[sn].append(measure)  # append the subtest Item and Person
                                          # measure to the SubTestIndex

        # SubTestIndex should look something like this:
        # {'Sub01': ['SubTest01_SC.txt', 'Sub01_item_meausre.txt', 'Sub01_person_meausre.txt']}

    SubTestErrorIndex = [] # List to keep track of the number of erroneous files that need addressing


    # k is the key, ie Sub01, v is a 3 element list containing the filenames associated with each subtest
    for k,v in SubTestIndex.items():
        if len(v) < 2: pass
        else:
            outFn = os.path.join(FINAL,"SubTest{0}_results.txt".format(k))
            if os.path.isfile(outFn):
                print "{0} already exists! Removing...".format(outFn)
                os.remove(outFn) # check that the file doenst already exist
            
            dFn, iFn, aFn = v  # [d]ata,[i]tem,[a]bility [F]ile[n]ame
            subtest_data = open(dFn, 'U').read().strip().split('\n')
            items_measures = open(iFn, 'U').read().strip().split()
            persons_ability = open(aFn, 'U').read().strip().split('\n')

            if len(subtest_data) != len(persons_ability):
                SubTestErrorIndex.append((dFn, "Size Mismatch Error"))
                print "!! Number of entries in SubTest data does not match number of entries in person ability data for: {0}!!".format(k)
                print "\tThere are currently {0} erroneous SubTests that need to be addressed".format(len(SubTestErrorIndex))
                break

            for i, line in enumerate(subtest_data):
                # print "line is", line
                seg = line.strip().split()  # Each line represents a single subject, strip off any newline characters, the split on whitespace
                data = "".join(seg[9:])  # some data files have spaces intermixed in the data column, resulting in
                                         # potentially missed values, this line corrects that.subtest_data[i]
                subtest_data[i] = [seg[0], data]
                persons_ability[i] = persons_ability[i].split()

                result = "{0}\t".format(subtest_data[i][0])
                
                # print result
                if subtest_data[i][0] != persons_ability[i][0]:  # if the subtest participant id does not match the person id, log the error!
                    SubTestErrorIndex.append((dFn, "Participant ID Mismatch Error: line {0}".format(i)))
                    print "!! {0} participant ID does not match {1} participant ID: line {2}!!".format(dFn, aFn, i)
                    print "\t",repr(subtest_data[i][0]), repr(persons_ability[i][0])
                    print "\tThere are currently {0} erroneous SubTests that need to be addressed".format(len(SubTestErrorIndex))
                    break

                if persons_ability[i][1] in ["X","x","?"]:  # If the ability file has an X, skip it. Subj never took the test
                    # print "Subject didnt take test"
                    writeResults(outFn, result+data)
                else:
                    for j, point in enumerate(data):
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

                    writeResults(outFn, result)  # write final results to file
            
    if SubTestErrorIndex:
        print "There were errors in the program! Writing error report..."
        errorFN = os.path.join(FINAL,"ErrorReport_")
        writeErrorReport(errorFN, SubTestErrorIndex) # Write 
    else:
        print "There were no errors detected! Be sure to look over your results for accuracy!"

if __name__ == '__main__':
    main()
