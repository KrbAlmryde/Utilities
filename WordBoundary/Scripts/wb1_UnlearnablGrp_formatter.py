"""
==============================================================================

Program name: wb1_Unlearnable_format.py
      Author: Kyle Reese Almryde
        Date: 11/02/12 @ 11:39 AM

 Description:



==============================================================================
"""
from math import sqrt


def writeHeader(fout):
    """
    Purpose: This function writes the header to the output file.

     Params: fout -> output filehandler
    Returns: None
    """
    comps = '\t\t' + '14\t14\t29\t29\t\t' * 2
    header = 'Hemisphere\t' + 'Mean\tSD\t' * 2
    fout.write(comps + '\n' + 'Scan\t' + header * 2 + '\n')


def organizeBlock(block, fout):
    """
    Purpose: This function extracts information from a list and
             writes it to a file. It computes the standard
             deviation from the provided variance and writes that
             value in place of the variance provided by the infile

     Params: block -> A list of lenght 4, containing lines composed
                      of the current scan, hemisphere, and stats

                    eg: ['s1  L  IC14  1.2345  0.01234',
                         's1  R  IC14  1.2345  0.01234',
                         's1  L  IC29  1.2345  0.01234',
                         's1  R  IC29  1.2345  0.01234']

              fout -> The output filehandle
    Returns: None
    """
    size = len(block)
    scan = block[0].split()[0] + '\t'  # The scan number #

    leftList = [block[0].split()[1] + '\t']
    rightList = [block[1].split()[1] + '\t']

    for i in range(0, size, 2):
        lSqrt = str(sqrt(float(block[i].split()[4]))) + '\t'
        lMean = block[i].split()[3] + '\t'
        leftList.append(lMean + lSqrt)

        rMean = block[i + 1].split()[3] + '\t'
        rSqrt = str(sqrt(float(block[i + 1].split()[4]))) + '\t'
        rightList.append(rMean + rSqrt)

    data = "".join(leftList) + "".join(rightList)
    fout.write(scan + data + '\n')


#=============================== START OF MAIN ===============================

def main():
    path = '/Exps/Analysis/WB1/GiftAnalysis/Unlearnable/Unlearnable_figure/Report'
    fin = open(path + '/temp_Unlearnable_grp_rpt.txt')                     # The AFNI generated RAW report file
    fout = open(path + '/Unlearnable_Group_unformatted_Report.txt', 'w')   # The python unformated filed, pre-excel

    i, j = 1, 5
    lines = fin.readlines()
    writeHeader(fout)
    while j <= len(lines):
        blockLR = lines[i:j]
        organizeBlock(blockLR, fout)
        i += 4
        j = 4 + i

    fin.close()
    fout.close()


if __name__ == '__main__':
    main()
