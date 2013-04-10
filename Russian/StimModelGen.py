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
import wave
import glob
import random
import pprint
# from subprocess import Popen


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


def buildEvents(stimOrd, isiLst, tr=2.0, dur=0.8, delayDur=0.0):
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
        offset = i * tr  # Offset is the total time between the start of stim1 and stim2
        if ev not in 'null':
            tm = isiLst.pop(0) + offset
            eventModel.append(tm)
        else:
            print i, "null"
            eventModel.append(offset)

    return eventModel


def builtDirectRT(stimOrd, stimDict, isiModel):
    """ One line description

    Params:
        stimOrd, stimDict, isiModel --

    Returns:
         Description of returns
    """
    drtCMD = []
    nullTemplate = '-1,{0},{1},0,0,9,~{2},"0,0,0",rt:5,*'
    stimTemplate = '-1,{0},{1},0,0,9,~{2},"0,0,0",{3},!{4},"0,0,0",rt:5,*'
    drtCMD.append("block,trial,!item,bgr,wgr,style,stim,loc,time,stim,loc,time,*")
    drtCMD.append('-1,1,Trigger,0,0,9,~Waiting for Scanner to Trigger experiment,"0,0,1",rt:5,*')
    drtFile = open("RussianEvent.csv", "w")

    for i, stim in enumerate(stimOrd):
        j = str(i + 1)
        if stim in 'null':
            drtCMD.append(nullTemplate.format(j, stim, 'Null'))
        else:
            jitter = int((isiModel[i] * 1000) + 2000)    # for the individual stim files jitter
            soundFile = stimDict[stim].pop()
            word = os.path.split(soundFile)[-1]
            notice = 'Acquisition...' + word
            drtCMD.append(stimTemplate.format(j, stim, notice, jitter, soundFile))
    drtFile.write('\n'.join(drtCMD))
    drtFile.close()


def build3Deconvolve(stimOrd, designModel, ntp=150, tr=2.00, model='WAV'):
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
    stimDict = {i: open(''.join(['russ_', i, '.1D']), 'w') for i in stimOrd}
    stimOrderFile = open('StimOrder.txt', 'w')
    for stim in stimOrd:
        stimOrderFile.write(stim + '\n')
        stimDict[stim].write(str(designModel.pop(0)) + " ")

    # close the files
    stimOrderFile.close()
    {f.close() for f in stimDict.values()}

    cmd = ['3dDeconvolve',
           ' '.join(["-nodata", str(ntp), str(tr)]),
           '-polort A',
           ' '.join(['-num_stimts', str(len(stimDict) - 1)])]

    for i, stim in enumerate(stimDict.keys()):
        i += 1
        if 'null' in stim:
            pass
        else:
            cmd.append(' '.join(['-stim_times', str(i), ''.join(['russ_', stim, '.1D']), model]))
            cmd.append(' '.join(['-stim_label', str(i), stim]))

    cmd.append('-x1D russ.xmat.1D')
    oneDplot = "\n1dplot -thick -sepscl -xlabel Time russ.xmat.1D'[4..$]'"
    return "  \\\n".join(cmd) + oneDplot


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


def timingFiles(stimList):
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


def directRTwordList():
    SOUNDS = '/usr/local/Utilities/Russian/sounds'
    os.chdir(SOUNDS)
    wordList = glob.glob('*ale/*/*2.wav')
    # pprint.pprint(wordList)
    random.shuffle(wordList)
    stimList = {"Ff1": [], "Ff2": [], "Fm1": [], "Fm2": [], "Mm1": [], "Mm2": [], "Mf1": [], "Mf2": []}
    os.chdir('../')

    for word in wordList:
        if word.startswith("Female/"):
            # Masculine Double marking
            if word.endswith('telya2.wav') or word.endswith('telyem2.wav'):
                stimList["Fm2"].append(word)
            # Masculine Single marking
            elif word.endswith('ya2.wav') or word.endswith('yem2.wav'):
                stimList["Fm1"].append(word)
            # Feminine Double markings
            elif word.endswith('kaoj2.wav') or word.endswith('koj2.wav'):
                stimList["Ff2"].append(word)
            elif word.endswith('kaoy2.wav') or word.endswith('koy2.wav'):
                stimList["Ff2"].append(word)
            elif word.endswith('kau2.wav') or word.endswith('ku2.wav'):
                stimList["Ff2"].append(word)
            # Feminine Single markings
            elif word.endswith('aoj2.wav') or word.endswith('oj2.wav'):
                stimList["Ff1"].append(word)
            elif word.endswith('aoy2.wav') or word.endswith('oy2.wav'):
                stimList["Ff1"].append(word)
            elif word.endswith('au2.wav') or word.endswith('u2.wav'):
                stimList["Ff1"].append(word)
        else:
            if word.endswith('telya2.wav') or word.endswith('telyem2.wav'):
                stimList["Mm2"].append(word)
            # Masculine Single marking
            elif word.endswith('ya2.wav') or word.endswith('yem2.wav'):
                stimList["Mm1"].append(word)
            # Feminine Double markings
            elif word.endswith('kaoj2.wav') or word.endswith('koj2.wav'):
                stimList["Mf2"].append(word)
            elif word.endswith('kaoy2.wav') or word.endswith('koy2.wav'):
                stimList["Mf2"].append(word)
            elif word.endswith('kau2.wav') or word.endswith('ku2.wav'):
                stimList["Mf2"].append(word)
            # Feminine Single markings
            elif word.endswith('aoj2.wav') or word.endswith('oj2.wav'):
                stimList["Mf1"].append(word)
            elif word.endswith('aoy2.wav') or word.endswith('oy2.wav'):
                stimList["Mf1"].append(word)
            elif word.endswith('au2.wav') or word.endswith('u2.wav'):
                stimList["Mf1"].append(word)
    return stimList


#=============================== START OF MAIN ===============================


def main():
    ntp, tr, dur, delay = 140, 3.0, 0.8, 1.0
    isiModel = []
    designModel = []
    drtWordDict = directRTwordList()
    # stimOrderFile, sf1, sf2, sm1, sm2, null = timingFiles()

    #1) Generate 135 ISIs
    isiModel = randOnset(0.2, 135)

    #2) Create Random Ordering of Stim events, including nulls
    stimList = ["Ff1", "Ff2", "Fm1", "Fm2", "Mm1", "Mm2", "Mf1", "Mf2"]
    stimOrd = eventOrdering(stimList, 15, 15)

    # 3) Build DirectRT File
    # builtDirectRT(stimOrd, drtWordDict, isiModel)

    #4) Flatten tModel
    designModel = buildEvents(stimOrd, isiModel, tr, dur, delay)
    print designModel
    print len(designModel)

    #5) Build 3dDeconvolve file and test it.
    deconvolveCMD = build3Deconvolve(stimOrd, designModel, ntp, tr)
    print deconvolveCMD

    # 6) Run that shit!
    os.system(deconvolveCMD)

# Apply stim labels and write to file
    # tempModel = designModel[:]
    # for stim in stimOrd:
    #     stimOrderFile.write(stim + '\n')

    #     if "f1" in stim:
    #         sf1.write(str(tempModel.pop(0)) + " ")
    #     elif "f2" in stim:
    #         sf2.write(str(tempModel.pop(0)) + " ")
    #     elif "m1" in stim:
    #         sm1.write(str(tempModel.pop(0)) + " ")
    #     elif "m2" in stim:
    #         sm2.write(str(tempModel.pop(0)) + " ")
    #     elif "null" in stim:
    #         null.write(str(tempModel.pop(0)) + " ")
        # print len(tempModel), tempModel

    # sf1.close()
    # sf2.close()
    # sm1.close()
    # sm2.close()
    # null.close()
    # stimOrderFile.close()



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

    # b = open("Stim_order.txt").readlines()
    # for i, v in enumerate(b):
    #     if 'null' in v:
    #         print "-censor_RGB purple -CENSORTR", str(i * 3) + "-" + str((i*3)+1), "\\"
    #     elif 'f1' in v:
    #         print "-censor_RGB \#000 -CENSORTR", str(i * 3) + "-" + str((i*3)+1), "\\"
    #     elif 'f2' in v:
    #         print "-censor_RGB red -CENSORTR", str(i * 3) + "-" + str((i*3)+1), "\\"
    #     elif 'm1' in v:
    #         print "-censor_RGB green -CENSORTR", str(i * 3) + "-" + str((i*3)+1), "\\"
    #     elif 'm2' in v:
    #         print "-censor_RGB blue -CENSORTR", str(i * 3) + "-" + str((i*3)+1), "\\"
