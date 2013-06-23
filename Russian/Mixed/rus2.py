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

Deficiencies
==============================================================================
"""
import os
import random
from glob import glob


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


def padBlock(block, dur):
    """Adjusts the block for the proper timing interval"""
    nBlock = []
    for i, b in enumerate(block):
        if i == 0:
            nBlock.append(b)
        else:
            j = i - 1
            prev = block[j]
            ev = b + dur + prev
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
    tblock = padBlock(iblock, dur)   # tblock composed of time influenced iblocks

    while sum(tblock) > blockLen:  # If the duration of tblock is longer than blockLen, generate a new one.
        print "\nOptimal length not Found :-("
        print sum(iblock), sum(tblock)
        iblock = randOnset(limit, stop)
        tblock = padBlock(iblock, dur)

    print "\nFound optimal length!"
    print sum(iblock), sum(tblock)
    return iblock, tblock


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

    return stimOrder, sf1, sf2, sm1, sm2

#=============================== START OF MAIN ===============================


def main_BlockDesign():
    isiModel = []
    tModel = []
    designModel = []
    stimOrder, sf1, sf2, sm1, sm2 = timingFiles()

    # 1) generate 96 ISIs
    for _ in range(8):
        isi, tisi = buildBlock()
        isiModel.append(isi)
        tModel.append(tisi)
    print "\nISI model is"
    print len(isiModel), isiModel
    print "\nTime model is"
    print tModel

    # 2) Create Random Ordering of Stim blocks
    stimOrd = ["f1", "f2", "m1", "m2"] * 2
    random.shuffle(stimOrd)

    # 3) Flatten the tModel
    design = [ev for block in tModel for ev in block]
    print '\n Flatten Design Matrix'
    print design

    # 4) Adjust the model for time.
    for i, ev in enumerate(design):
        ev += i * 2
        designModel.append(ev)

    # 5) Apply stim labels and write to file
    tempModel = designModel[:]
    for stim in stimOrd:
        for _ in range(12):
            if "f1" in stim:
                sf1.write(str(tempModel.pop(0)) + " ")
            elif "f2" in stim:
                sf2.write(str(tempModel.pop(0)) + " ")
            elif "m1" in stim:
                sm1.write(str(tempModel.pop(0)) + " ")
            elif "m2" in stim:
                sm2.write(str(tempModel.pop(0)) + " ")
            stimOrder.write(stim + '\n')
            print len(tempModel), tempModel

    sf1.close()
    sf2.close()
    sm1.close()
    sm2.close()
    stimOrder.close()

    # 6) Run that shit!
    os.system('bash rus2_3dd.sh')


if __name__ == '__main__':
    main_BlockDesign()

