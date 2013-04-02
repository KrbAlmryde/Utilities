"""
==============================================================================
Program: SpellingCorrector.py
 Author: Kyle Reese Almryde
   Date: Thu 03/28/2013 @ 12:03:42 PM

 Description: This program tries to correct the spelling of a word using a
              supplied dictionary and a criteria.



==============================================================================
"""
import os
import sys
import difflib
import wave
from pprint import pprint


def getWAVduration(fname):
    """ Determine the duration of a .WAV file

    Params:
        fname -- String: The WAV filename

    Returns:
         A Float representing the duration in milliseconds
    """
    f = wave.open(fname, 'r')
    frames = f.getnframes()
    rate = f.getframerate()
    duration = frames/float(rate) * 1000
    return duration


#=============================== START OF MAIN ===============================

def main():

    SOUNDS = '/usr/local/Utilities/PROJECTS/Russian/sounds'
    inc = os.path.join(SOUNDS, 'IncorrectList.txt')
    corr = os.path.join(SOUNDS, 'CorrectList.txt')

    lexicon = {os.path.split(y)[1].strip().lower() for y in open(corr).readlines()}

    outFile = os.path.join(SOUNDS, 'FixedList.txt')
    fout = open(outFile, 'w')

    template = "{0}\t{1}\t{2}\t{3}\t{4}\n"
    header = ["Speaker", "Gender", "Marking", "Word", "Fix"]
    fout.write(template.format(*header))

    for line in open(inc).readlines():
        mark, l = line.split(':')
        p, l = os.path.split(l)
        speaker, g = os.path.split(p)
        gender = g[2:]
        word = l.strip().lower()
        fix = difflib.get_close_matches(word, lexicon, 1)
        fix = ''.join(fix) if len(fix) > 0 else None
        fout.write(template.format(speaker, gender, mark, word, fix))

    fout.close()

if __name__ == '__main__':
    main()