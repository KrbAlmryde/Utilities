"""
==============================================================================
Program: SpellingCorrector.py
 Author: Kyle Reese Almryde
   Date: Wed 03/27/2013 @ 3:52:30 PM

 Description: This program tries to correct the spelling of a word using a
              supplied dictionary and a criteria.



==============================================================================
"""
import os
import sys
import difflib
import wave
import contextlib


def getWAVduration(fname):
    """ Determine the duration of a .WAV file

    Params:
        fname -- String: The WAV filename

    Returns:
         A 3 tuple Float representing the duration in minutes, seconds,
         and milliseconds of the supplied wav file
    """
    f = wave.open(fname, 'r')
    frames = f.getnframes()
    rate = f.getframerate()
    duration = frames/float(rate) * 1000
    return duration


def FuzzyMatches(wordList, lexicon, cutoff=0.6):
    corrected = {}
    for word in wordList:
        corrected[word] = difflib.get_close_matches(word, lexicon, 3, cutoff)

    return corrected


def WriteToFile(outDir, outName, aDict):
    outfile = os.path.join(outDir, outName)
    fout = open(outfile, 'w')

    template = "{0}\t{1}\t{2}\t{3}\t{4}\t{5}\n"
    header = ["Marking", "Path", "Old Word", "Best Fit", "Candidate1", "Candidate2"]

    fout.write(template.format(*header))
    for key in aDict.keys():
        p = os.path.split(key)[0]
        k = os.path.split(key)[-1].lower()
        v = [os.path.split(i)[-1].lower() for i in aDict[key] if len(i) > 0]

        if len(v) < 1:
            fout.write(template.format(p, k, '', '', ''))
        elif len(v) == 1:
            fout.write(template.format(p, k, v[0], '', ''))
        elif len(v) == 2:
            fout.write(template.format(p, k, v[0], v[1], ''))
        else:
            fout.write(template.format(p, k, *v))

    fout.close()


#=============================== START OF MAIN ===============================

def main():

    SOUNDS = '/usr/local/Utilities/PROJECTS/Russian/sounds'
    inc = os.path.join(SOUNDS, 'IncorrectList.txt')
    corr = os.path.join(SOUNDS, 'CorrectList.txt')

    incorrect = {x.strip() for x in open(inc).readlines()}
    lexicon = {y.strip() for y in open(corr).readlines()}

    fixedDict = FuzzyMatches(incorrect, lexicon, 0.8)

    WriteToFile(SOUNDS, 'FixedList.txt', fixedDict)


if __name__ == '__main__':
    main()

adict = {'a':"Old Word", 'b':"Best", 'c':"Candidate1", 'd':"Candidate2"}