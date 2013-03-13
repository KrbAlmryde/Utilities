"""
==============================================================================
Program: StimModelGen
 Author: Kyle Reese Almryde
   Date: 02/25/2013 @ 15:14:16 PM

 Description: This program constructs a randomized stimulus timing model for
              a fMRI study. Any design type (Event, Block, Mixed) is possible.
              Presently this program produces a collection of 1D files for use
              with AFNI's 3dDeconvole program, which should be used to check
              the efficiency of the design matrix generated.

Deficiencies: Presently, this program does NOT check for design efficiency,
              that task is left up to the study designer in question. Use AFNI
              for that.
==============================================================================
"""
import os
import random
from glob import glob
from subprocess import Popen

def randOnset(limit, stop):
    """
    This will generate a list of values <= 'limit', up to the
    'stop' range

    random.random() <= 0.5, 160
    """
    series = []
    while True:
        n = random.random()
        if n <= limit:
            series.append(n)

        if len(series) == stop:
            return series


def pack(join, alist):
    """Interleave a list with a value

    This function interleaves a list of values with the joining
    element.

    Params:
        join -- The value to be interleaved within the list
        alist -- The supplied list

    Returns:
         A new list
         pack("a",[1,2,3,4]) ==> ["a",1,"a",2,"a",3,"a",4]
    """
    newList = []
    for el in alist:
        blk = [el, join]
        newList.extend(blk)
    return newList


def timeBlock(block, dur):
    """Adjusts the block for the proper timing interval"""
    nBlock = []
    for i, b in enumerate(block):  # i is the index, b is the isi element within block
        if i == 0:
            nBlock.append(b)
        else:
            j = i - 1
            prev = block[j]      # prev is the previous item in the block list.
            ev = b + dur + prev   # isi + duration + previous isi
            nBlock.append(ev)
    return nBlock


def buildBlock(limit=1, stop=12, dur=0.5, blockLen=16.00):
    """Construct a stimulus timing block

    Builds one stimulus timing 'block'. This can mean a single event,
    or it can refer to a collection of events as per a traditional 'block'
    model.

    Params:
        limit -- Refers to the max range for the ISI
        stop -- The number of ISI's to generate
        dur -- The duration of the stimulus event
        blockLen -- The length of the individual block
    Returns:
         iblock -- a list consisting of unmodified ISIs
         tblock -- a list consisting of time influenced iblocks
    """
    iblock = randOnset(limit, stop)  # iblock consists of ISIs
    tblock = timeBlock(iblock, dur)   # tblock composed of time influenced iblocks

    while sum(tblock) > blockLen:  # If the duration of tblock is longer than blockLen, generate a new one.
        print "\nOptimal length not Found :-("
        print sum(iblock), sum(tblock)
        iblock = randOnset(limit, stop)
        tblock = timeBlock(iblock, dur)

    print "\nFound optimal length!"
    print sum(iblock), sum(tblock)
    return iblock, tblock


def eventOrdering(stimList, nEvs=25, nNulls=5):
    """ Create the stimulus ordering for an event related design

    Params:
        stimList -- A list containing the identifying names of each
                    condition. Should just be the class names!!
        nEvs -- Is the number of items per class, default is 25
        nNulls -- The number of nulls to include, default is 5

    Returns:
         Description of returns
    """
    stimList *= nEvs
    nulls = ["null"] * nNulls
    stimOrd = stimList + nulls
    random.shuffle(stimOrd)

    return stimOrd


def buildEvents(stimOrd, isiLst, tr=2.0, dur=0.8, sparseDur=0.0):
    """Construct an Event related Model

    Takes a list of stimulus events, nulls included, and a list
    of ISIs.

    Params:
        stimOrd -- The list composed of each stimulus event condition
                   Nulls included. Should be randomized.
    Returns:
         Description of returns
    """
    print "\n\n\n\n\nBUILDEVENT!!!"
    eventModel = []
    for i, ev in enumerate(stimOrd):
        offset = i * 3
        if ev not in 'null':
            tm = isiLst.pop(0) + offset
            eventModel.append(tm)
        else:
            print i, "null"
            eventModel.append(offset)

    return eventModel


def dDeconvolve(stimList, prefix='3dd', ntp=150, tr=2.00, model='WAV'):
    """Construct an AFNI 3dDeconvolve command

    This function creates a 3dDeconvolve command to test the design
    of the

    Params:
        stimList -- A list containing the identifying names of each
                    condition. Should just be the class names!!
        prefix -- The output name of those files 3dDeconvolve does produce.
                  Defaults to 3dd
        ntp -- The number of timepoints in the scan. Defaults to 150

        tr -- The tr for the scan, default is 2.00 secons
        model -- The hemodynamic response model, default is the
                 'Cox special' WAV function

    Returns:
        A string representation of the 3dDeconvolve command, which can
        then be run via Popen, or saved to a file.
    """
    cmd = []
    # 3dDeconvolve                \
    # -nodata 420 1.000                   \
    # -polort A                           \
    # -num_stimts 5                       \
    # -stim_times 1 rus2_sF1.1D WAV    \
    # -stim_label 1 sF1                   \
    # -stim_times 2 rus2_sF2.1D WAV    \
    # -stim_label 2 sF2                   \
    # -stim_times 3 rus2_sM1.1D WAV    \
    # -stim_label 3 sM1                   \
    # -stim_times 4 rus2_sM2.1D WAV    \
    # -stim_label 4 sM2                   \
    # -stim_times 5 rus2_NULL.1D WAV    \
    # -stim_label 5 null                   \
    # -x1D rus2.xmat.1D




def timingFiles():
    for file in glob('rus2_*.1D'):
        if os.path.isfile(file):
            os.remove(file)

    if os.path.isfile("Stim_order.txt"):
        os.remove("Stim_order.txt")

    stimOrder = open("Stim_order.txt", "a")
    sf1 = open("rus2_sF1.1D", "a")
    sf2 = open("rus2_sF2.1D", "a")
    sm1 = open("rus2_sM1.1D", "a")
    sm2 = open("rus2_sM2.1D", "a")
    null = open("rus2_NULL.1D", "a")

    return stimOrder, sf1, sf2, sm1, sm2, null

#=============================== START OF MAIN ===============================


def main():
    tr, dur, sparse = 2.0, 0.8, 1.0
    isiModel = []
    designModel = []
    stimOrder, sf1, sf2, sm1, sm2, null = timingFiles()

    #1) Generate 120 ISIs
    isiModel = randOnset(0.2, 120)

    #2) Create Random Ordering of Stim events, including nulls
    stimList = ["f1", "f2", "m1", "m2"]
    stimOrd = eventOrdering(stimList, 30, 15)

    #3) Flatten tModel
    designModel = buildEvents(stimOrd, isiModel, tr, dur, sparse)

    # 5) Apply stim labels and write to file
    tempModel = designModel[:]
    for stim in stimOrd:
        stimOrder.write(stim + '\n')

        if "f1" in stim:
            sf1.write(str(tempModel.pop(0)) + " ")
        elif "f2" in stim:
            sf2.write(str(tempModel.pop(0)) + " ")
        elif "m1" in stim:
            sm1.write(str(tempModel.pop(0)) + " ")
        elif "m2" in stim:
            sm2.write(str(tempModel.pop(0)) + " ")
        elif "null" in stim:
            null.write(str(tempModel.pop(0)) + " ")
        # print len(tempModel), tempModel

    sf1.close()
    sf2.close()
    sm1.close()
    sm2.close()
    null.close()
    stimOrder.close()

    # 6) Run that shit!
    # os.system('bash rus2_3dd.sh')


# def main_BlockDesign():
#     isiModel = []
#     tModel = []
#     designModel = []
#     stimOrder, sf1, sf2, sm1, sm2 = timingFiles()

#     # 1) generate 96 ISIs
#     for _ in range(8):
#         isi, tisi = buildBlock()
#         isiModel.append(isi)
#         tModel.append(tisi)
#     print "\nISI model is"
#     print len(isiModel), isiModel
#     print "\nTime model is"
#     print tModel

#     # 2) Create Random Ordering of Stim blocks
#     stimOrd = ["f1", "f2", "m1", "m2"] * 2
#     random.shuffle(stimOrd)

#     # 3) Flatten the tModel
#     design = [ev for block in tModel for ev in block]
#     print '\n Flatten Design Matrix'
#     print design

#     # 4) Adjust the model for time.
#     for i, ev in enumerate(design):
#         ev += i * 2
#         designModel.append(ev)

#     # 5) Apply stim labels and write to file
#     tempModel = designModel[:]
#     for stim in stimOrd:
#         for _ in range(12):
#             if "f1" in stim:
#                 sf1.write(str(tempModel.pop(0)) + " ")
#             elif "f2" in stim:
#                 sf2.write(str(tempModel.pop(0)) + " ")
#             elif "m1" in stim:
#                 sm1.write(str(tempModel.pop(0)) + " ")
#             elif "m2" in stim:
#                 sm2.write(str(tempModel.pop(0)) + " ")
#             stimOrder.write(stim + '\n')
#             print len(tempModel), tempModel

#     sf1.close()
#     sf2.close()
#     sm1.close()
#     sm2.close()
#     stimOrder.close()

#     # 6) Run that shit!
#     os.system('bash rus2_3dd.sh')


if __name__ == '__main__':
    main()

    b = open("Stim_order.txt").readlines()
    for i, v in enumerate(b):
        if 'null' in v:
            print "-censor_RGB purple -CENSORTR", str(i * 3) + "-" + str((i*3)+1),"\\"
        elif 'f1' in v:
            print "-censor_RGB \#000 -CENSORTR", str(i * 3) + "-" + str((i*3)+1),"\\"
        elif 'f2' in v:
            print "-censor_RGB red -CENSORTR", str(i * 3) + "-" + str((i*3)+1),"\\"
        elif 'm1' in v:
            print "-censor_RGB green -CENSORTR", str(i * 3) + "-" + str((i*3)+1),"\\"
        elif 'm2' in v:
            print "-censor_RGB blue -CENSORTR", str(i * 3) + "-" + str((i*3)+1),"\\"
