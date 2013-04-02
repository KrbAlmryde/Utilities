"""
==============================================================================
Program: renamePy.py
 Author: Kyle Reese Almryde
   Date: 02/12/2013 @ 15:07:46 PM

 Description: This short program renames a supplied list of pfiles such that
              the file names contain the correct number of 0 padding.


==============================================================================
"""
import os
import glob


def pad(pfile):
    """pad a file name with zeros

    Params:
        pfile -- 'P06144.7.754'

    Returns:
        A string with zeros padding the name.
        'P06144.7.0754'
    """
    h, b, t = pfile.split('.')  # ["P06144", "7", "4754"]

    if len(t) == 3:
        t = '0' + t
    elif len(t) == 2:
        t = '00' + t
    elif len(t) == 1:
        t = '000' + t
    else:
        pass

    return '.'.join([h, b, t])


def main():
    os.chdir('/Volumes/Data/IcewordOLD/S18/run4')
    pfiles = glob.glob('P06144.7.*')

    p2 = [pad(p) for p in pfiles]

    for i in range(len(pfiles)):
        os.rename(pfiles[i], p2[i])

#=============================== START OF MAIN ===============================

if __name__ == '__main__':
    main()
