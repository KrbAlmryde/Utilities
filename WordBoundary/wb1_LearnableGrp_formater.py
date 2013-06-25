"""
==============================================================================

Program name: wb1_learnable_format.py
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
    comps = '\t\t' + '2\t2\t7\t7\t25\t25\t31\t31\t39\t39\t\t' * 2
    header = 'Hemisphere\t' + 'Mean\tSD\t' * 5
    fout.write(comps + '\n' + 'Scan\t' + header * 2 + '\n')


def organizeBlock(block, fout):
    """
    Purpose: This function extracts information from a list and
             writes it to a file. It computes the standard
             deviation from the provided variance and writes that
             value in place of the variance provided by the infile

     Params: block -> A list of lenght 10, containing lines composed
                      of the current scan, hemisphere, and stats

                    eg: ['s1  L  IC2  1.2345  0.01234',
                         's1  R  IC2  1.2345  0.01234',
                         's1  L  IC7  1.2345  0.01234',
                         's1  R  IC7  1.2345  0.01234']

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
    path = '/Exps/Analysis/WB1/GiftAnalysis/Learnable/Learnable_figure/Report'
    fin = open(path + '/temp_Learnable_grp_rpt.txt')                    # The AFNI generated RAW report file
    fout = open(path + '/Learnable_Group_unformatted_Report.txt', 'w')  # The python unformated filed, pre-excel

    i, j = 1, 11
    lines = fin.readlines()
    writeHeader(fout)
    while j <= len(lines):
        blockLR = lines[i:j]
        organizeBlock(blockLR, fout)
        i += 10
        j = 10 + i

    fin.close()
    fout.close()


if __name__ == '__main__':
    main()
