"""
==============================================================================
Program: dataPrep.py
 Author: Kyle Reese Almryde
   Date: 06/06/2014

 Description: This program uses Pandas to prepare the TILLS datasets for uses
              in dataFix.py. It extracts the subject ID and the ability metric
              from the appropriate excel file and writes them to a text (txt)
              file. It also converts the item measure scores to text file. 

==============================================================================
"""

import os
import pandas as pd
from glob import glob

#=============================== START OF MAIN ===============================

def main():
    # Several datafiles, each with a long list of subjects

    # Directory path variable assignment, assumes script is in working directory!!!
    DATA = "data"
    MEASURE = "measure"
    EXCEL = "excel_files"

    # Mainly for testing purposes
    if len(sys.argv) > 1: 
        DATA = os.path.join(sys.argv[1], DATA)
        MEASURE = os.path.join(sys.argv[1], MEASURE)
        FINAL = os.path.join(sys.argv[1], FINAL)


    # Create a dictionary with Subtest #s as the keys and a list of the data
    # file as values. Uses a Dictionary Comprehension
    SubTestIndex = [os.path.split(_file)[1].split('_')[0].split('Test')[1] for _file in glob(os.path.join(DATA,"*.txt"))]

    for sID in SubTestIndex:  # sID => subtest ID,  eg. Sub[03A]
        pXLXS = os.path.join(EXCEL, "Sub{0}_person_measure.xlsx".format(sID))
        pTXT = os.path.join(MEASURE, "Sub{0}_person_measure.txt".format(sID))

        if os.path.exists(pXLXS):
            person_measure = pd.read_excel(pXLXS, header=None, names=['Scores', 'NaN', 'SubID', '_SubID', '_NaN'])
            person_output = person_measure[['SubID', 'Scores']]
            person_output.to_csv(pTXT, sep='\t', index=False, header=False)

            iXLXS = os.path.join(EXCEL, "Sub{0}_item_measure.xlsx".format(sID))
            iTXT = os.path.join(MEASURE, "Sub{0}_item_measure.txt".format(sID))
            pd.read_excel(iXLXS, header=None).to_csv(iTXT, sep='\t', index=False, header=False)



if __name__ == '__main__':
    main()
