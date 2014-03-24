"""
==============================================================================
Program: dataFix.py
 Author: Kyle Reese Almryde
   Date: 03/11/2014

 Description: Replaces missing values in a behavioral score report based on
              scaled difficulty ratings and weighted "ability" metrics for
              subjects who have participated in a behavioral research
              experiment. If a subject has not taken then entire battery of
              tests they will not have scores computed for them.

==============================================================================
"""

import os
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


#=============================== START OF MAIN ===============================
def main():
    # Several datafiles, each with a long list of subjects
    DATA = "/Users/kylealmryde/Dropbox/Shared-Projects/Tills_data/data"
    MEASURE = "/Users/kylealmryde/Dropbox/Shared-Projects/Tills_data/measure"
    FINAL = "/Users/kylealmryde/Dropbox/Shared-Projects/Tills_data/final"


    # Create a dictionary with Subtest #s as the keys and a list of the data
    # file as values. Uses a Dictionary Comprehension
    SubTestIndex = {os.path.split(_file)[1].split('_')[0].split('Test')[1]: [_file] for _file in glob(os.path.join(DATA,"*.txt"))}


    for measure in glob(os.path.join(MEASURE,"*.txt")):
        sn = os.path.split(measure)[1].split('_')[0].split('Sub')[1]
        SubTestIndex[sn].append(measure)  # append the subtest Item and Person
                                          # measure to the SubTestIndex

    for k,v in SubTestIndex.items():
        if len(v) < 2: pass
        else:
            outFn = os.path.join(FINAL,"SubTest{0}_results.txt".format(k))
            dFn, iFn, aFn = v  # {[d]ata,[i]tem,[a]bility} [F]ile[n]ame
            items_measures = open(iFn).read().split()
            persons_ability = open(aFn).read().split()

            if os.path.isfile(outFn):
                os.remove(outFn) # check that the file doenst already exist
                print "{0} already exists! Removing...".format(outFn)

            for i, line in enumerate(open(dFn)):
                seg = line.split()  # Each line represents a single subject
                data = "".join(seg[9:])  # some data files have spaces intermixed in the data column, resulting in
                                         # potentially missed values, this line corrects that.

                result = "{0}\t".format(seg[0])
                # print result

                if persons_ability[i] in ["X","x"]:  # If the ability file has an X, skip it. Subj never took the test
                    print "Subject didnt take test"
                    writeResults(outFn, result+data)
                else:
                    for j, point in enumerate(data):
                        if point != '.':    # If the value is not a '.' write that value
                            result += point
                        else:
                            if persons_ability[i] < items_measures[j]:  # if ability is less than measure, assign 0
                                result += '0'
                            elif persons_ability[i] >  items_measures[j]: # if ability is greater than measure, assign 1
                                result += '1'
                            else:  # if ability is equal to measure...
                                if random() < 0.5:  # assign a 0 if a randomly generated value between 0-1 is less than 0.5
                                    result += "0"  # Failed
                                else: # assign a 1 if a randomly generated value between 0-1 is greater than 0.5
                                    result += "1"  # Passed

                    writeResults(outFn, result)  # write final results to file


if __name__ == '__main__':
    main()
