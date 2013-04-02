#!/bin/env python
"""
==============================================================================
Program: NBack.py
 Author: Kyle Reese Almryde
   Date: Thu 03/21/2013 @ 10:33:30 AM
Updated: Thu 03/28/2013 @ 11:42:48 AM

 Description: This program uses the Python Image Library (PIL) to build and
              manipulate images for the N-Back Summer Camp game. It also
              assists in constructing the game script.


==============================================================================
"""
import os
import sys
import glob
import random
import Image


def getRandomValue(aDict, sample=6):
    """ 'pop' a random item from the supplied Dictionary

    This is a generator function! It will only work once,
    in addition, it changes the supplied dictionary in place
    which may not be what you want.

    Params:
        aDict --
        sample --

    Returns:
         Description of returns
    """
    print "\tGetting Random Values!!\n"

    for i in xrange(sample):
        key = random.choice(aDict.keys())
        value = aDict.pop(key)
        yield (key, value)


def iter_sample_fast(iterator, samplesize=6):
    """ extract an random sampling from a  generator object

    This code was originally developed by DzinX as per this
    question on SO
    http://stackoverflow.com/questions/12581437/python-random-sample-with-a-generator

    Params:
        iterable -- An iterable object
        sameplesize -- The desired sample size

    Returns:
         A list containing the randomly generated sample.
    """
    results = []
    # Fill in the first samplesize elements:
    try:
        for _ in xrange(samplesize):
            results.append(iterator.next())
    except StopIteration:
        raise ValueError("Sample larger than population.")
    random.shuffle(results)  # Randomize their positions
    for i, v in enumerate(iterator, samplesize):
        r = random.randint(0, i)
        if r < samplesize:
            results[r] = v  # at a decreasing rate, replace random items
    return results


def getImageFiles(pattern='*.jpg', delim='.'):
    """ Create a dictionary containing all available image thumbnails

    Params:
        pattern -- String: The filename pattern used for glob. Default value
                    is '*.jpg'

    Returns:
        A dictionary composed of the image files, with the subject of the
        file name as the key, and the original image filename as the value
    """
    for filename in glob.iglob(pattern):
        tailName = os.path.split(filename)[1]
        outname = tailName.split(delim)[0].lower()
        yield (outname, filename)


def Resize(infile, outfile, width=156, height=156, format="JPEG"):
    """ Resize the supplied image to the desired specifications

    Params:
        infile -- String: The input image filename
        width -- Int: The desired image width, default is 156
        height -- Int: The desired image height, default is 156
        format -- String: The desired output image format, default is JPEG
    Returns:
        outfile name, indicating file was written to disk, otherwise returns
        None
    """
    # print "\tResizing Image", infile, "\n"

    if os.path.isfile(outfile):
        return outfile
    else:
        size = (width, height)
        try:
            img = Image.open(infile)  # copy
            img.thumbnail(size, Image.ANTIALIAS)
            img.save(outfile, format)
            return outfile
        except IOError:
            print "cannot resize %s" % infile
            return None


def Crop(infile, outfile, upperPos, width=156, height=156, format="JPEG"):
    """ Crop and existing array image in order to extract an image

    Params:
        infile --
        outfile --
        upperPos --
        width=156 --
        height=156 --
        format="JPEG" --

    Returns:
        outfile name, indicating file was written to disk, otherwise returns
        None
    """
    box = (upperPos[0], upperPos[1], upperPos[0] + width, upperPos[1] + height)
    if os.path.isfile(outfile):
        return outfile
    else:
        try:
            img = Image.open(infile)  # copy
            cropped = img.crop(box)
            cropped.save(outfile, format)
            return outfile
        except IOError:
            print "cannot crop %s" % infile
            return None


def getImageOffset(img, pos, box=(156, 156)):
    """ Determine the required image offset

    Params:
        img -- The PIL Image object
        pos -- The (x,y) postion
        box -- The bounding box (x,y) position

    Returns:
         A tuple containg the offset coordinates (j,k)
    """
    x_offset = max((box[0] - img.size[0]) / 2, 0)
    y_offset = max((box[1] - img.size[1]) / 2, 0)
    j = pos[0] + x_offset
    k = pos[1] + y_offset
    return (j, k)


def makeImgArray(Targets, Distractors, posDict, tail=None, size=(3, 3)):
    """ Create a list composed of targets and distractors

    From the list of Targets and Distractors create an image
    array consisting of {size} images.


    Params:
        Targets -- A list containing the target items
        Distractors -- A list containing the distractor items
        size -- (Int,Int) a tuple describing the number of
                target items and distractors to use to create
                the array.
    Returns:
         imgArray -- A list of size[0] + size[1] elements
         arrayName -- string composed of the target items with the starting position
         pos -- The position of the target image, casted as an int
    """
    tmp = []
    imgPool = []
    for _ in xrange(size[0]):
        nm, fl = Targets.pop()
        tmp.append(nm.split('_')[0])
        imgPool.append(fl)

    tar = imgPool[0]  # the first item will be our target
    imgPool.extend([Distractors.pop()[1] for _ in xrange(size[1])])  # add the distractors

    random.shuffle(imgPool)  # shuffle the list
    pos = str(imgPool.index(tar) + 1)  # get the postion of the starting index, add one so were not zero-based, and make it a string

    print posDict[pos]

    while posDict[pos] >= 5:  # if we end up with more than 4 target positions
        print "too many targets in that position!"
        random.shuffle(imgPool)  # shuffle the list
        pos = str(imgPool.index(tar) + 1)  # get the postion of the starting index, add one so were not zero-based, and make it a string

    posDict[pos] += 1
    tmp.append(tail)  # start constructing the file name
    tmp.insert(0, pos)  # insert the targets position at the start of the name list
    arrayName = '_'.join(tmp)  # join the items together to form the list

    return imgPool, arrayName, pos


def Overlay(background, inFile, position, outfile=None, format="JPEG"):
    """ Overlay the resized images onto the frame template

    Params:
        background -- String: The background image
        inFile --
        outfile --

    Returns:
         None
    """
    if os.path.isfile(outfile):
        return outfile

    bg = Image.open(background)
    for i, pos in enumerate(position):
        if type(inFile) == list:
            fg = Image.open(inFile[i])
        else:
            fg = Image.open(inFile)
        pos = getImageOffset(fg, pos)
        bg.paste(fg, pos)
    bg.save(outfile, format)


def AlphaOverlay(baseFile, inFile, position, outname=None, format="PNG"):
    """ Overlay an image with an alpha value onto a background image

    Params:
        baseFile --
        inFile --
        position --
        outname=None --
        format="PNG" --

    Returns:
         None
    """
    bottom = Image.open(baseFile)
    top = Image.open(inFile)
    r, g, b, a = top.split()
    top = Image.merge("RGB", (r, g, b))
    mask = Image.merge("L", (a,))
    bottom.paste(top, position, mask)
    bottom.save(outname, format)


#=============================== START OF MAIN ===============================

def main():
    if sys.platform == 'darwin':
        NBACK = '/Users/kylealmryde/Dropbox/DirectRT/N-Back'
    else:
        NBACK = 'C:\\Users\\Kyle\\Dropbox\\DirectRT\\N-Back'

    #----------------------
    # Setup Path variables
    #----------------------
    THUMBS = os.path.join(NBACK, 'WorkShop', 'Thumbs')
    TEMPLATES = os.path.join(NBACK, 'WorkShop', 'Templates')
    CLIPART = os.path.join(THUMBS, 'ClipArt')

    RESIZED = os.path.join(THUMBS, 'RESIZED')
    FRAMES = os.path.join(THUMBS, 'FRAMES')
    DOGPOS = os.path.join(THUMBS, 'DOGPOS')
    #----------------------------------------
    # Setup some useful parameter variables
    #----------------------------------------
    frame = os.path.join(TEMPLATES, 'frame2.png')  # for Overlay()
    dog = os.path.join(TEMPLATES, 'StandingDog.png')  # for Overlay()

    # Setup the positions for the images to be overlaid
    imgPositions = [(9, 10), (179, 10), (349, 10), (519, 10), (689, 10), (859, 10)]

    # And where the dog should be placed
    dogPositions = [(10, 12), (180, 12), (350, 12), (520, 12), (690, 12), (860, 12)]

    # create a wildcard pattern to supplie to getImageFiles
    objPat = os.path.join(CLIPART, '*.jpg')
    rezPat = os.path.join(RESIZED, '*.jpg')
    # dogPat = os.path.join(FRAMES, '*.jpg')

    # Make a positon counter to make sure our targets are evenly distributed across the arrays
    pos_count = {'1': 0, '2': 0, '3': 0, '4': 0, '5': 0, '6': 0}
    ###########################
    # Build the resized images
    #------------------------
    for k, v in getImageFiles(objPat):
        # Start by resizing the image
        outname = '_'.join([k, 'resized.jpg'])  # Create the output filename
        outResize = os.path.join(RESIZED, outname)  # and append the path to it.
        Resize(v, outResize)  # Resize the images, and save them

    rezImgs = [(n, fn) for n, fn in getImageFiles(rezPat)]
    random.shuffle(rezImgs)  # Shuffle the total images so we can randomly select them
    targets = [rezImgs.pop() for _ in xrange(75)]  # Select the first 6 images
    distractors = [rezImgs.pop() for _ in xrange(75)]  # Select the first 6 images

    for x in xrange(25):
        imgArray, name, pos = makeImgArray(targets, distractors, pos_count, "Overlay.jpg")
        print "our target count is...", pos_count
        outname = os.path.join(FRAMES, name)
        Overlay(frame, imgArray, imgPositions, outname)  # Paste those 6 images onto the array Frame
        # dogPos = (int(pos) - 1)
        # name = name.replace('Overlay.jpg', 'dogPos' + pos)
        # infile = outname
        # outname = os.path.join(DOGPOS, name)
        # AlphaOverlay(infile, dog, dogPositions[dogPos], outname, "BMP")


if __name__ == '__main__':
    main()



# def __main():
#     #-------------------------------------------------
#     # Check which platform we are currently working on
#     #-------------------------------------------------
#     if sys.platform == 'darwin':
#         nback = '/Users/kylealmryde/Dropbox/DirectRT/N-Back'
#     else:
#         nback = 'C:\\Users\\Kyle\\Dropbox\\DirectRT\\N-Back'

#     #----------------------
#     # Setup Path variables
#     #----------------------
#     THUMBS = os.path.join(nback, 'WorkShop', 'Thumbs')
#     TEMPLATES = os.path.join(nback, 'WorkShop', 'Templates')
#     RESIZED = os.path.join(THUMBS, 'RESIZED')
#     FRAMES = os.path.join(THUMBS, 'FRAMES')
#     OBJECTSALL = os.path.join(THUMBS, 'OBJECTSALL')

#     #----------------------------------------
#     # Setup some useful parameter variables
#     #----------------------------------------
#     frame = os.path.join(TEMPLATES, 'frame.png')  # for Overlay()
#     dog = os.path.join(TEMPLATES, 'StandingDog.png')  # for Overlay()

#     # Setup the positions for the images to be overlaid
#     imgPositions = [(9, 10), (179, 10), (349, 10), (519, 10), (689, 10), (859, 10)]

#     # And where the dog should be placed
#     dogPositions = [(10, 12), (180, 12), (350, 12), (520, 12), (690, 12), (860, 12)]

#     # create a wildcard pattern to supplie to getImageFiles
#     objPat = os.path.join(OBJECTSALL, '*.jpg')
#     rezPat = os.path.join(RESIZED, '*.jpg')
#     ###########################
#     # Build the resized images
#     #------------------------
#     for k, v in getImageFiles(objPat):
#         # Start by resizing the image
#         outname = '_'.join([k, 'resized.jpg'])  # Create the output filename
#         outResize = os.path.join(RESIZED, outname)  # and append the path to it.
#         Resize(v, outResize)  # Resize the images, and save them

#     # Now start making randome array images sequences, we want 25 patterns in all
#     for x in xrange(25):
#         sampleDIR = ''.join(['sample', str(x)])
#         os.mkdir(os.path.join(FRAMES, sampleDIR))
#         SAMPLES = os.path.join(FRAMES, sampleDIR)
#         for y in xrange(50):
#             out = ''.join([str(y), 'Overlay.jpg'])
#             outname = os.path.join(SAMPLES, out)
#             rezImg = (v for k, v in getImageFiles(rezPat))
#             imgArray = iter_sample_fast(rezImg, 6)  # Random image array
#             Overlay(frame, imgArray, imgPositions, outname)
