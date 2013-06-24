"""
This is a quick and dirty script used to build sections of the
N-back game
"""

import os
import glob
import Image


def item_formatter(list, pos):
    nums = [1, 2, 3, 4, 5, 6]
    key = int(list[pos][0])
    nums.remove(key)
    return key, nums, list[-1]


def fixbmp(pattern):
    for f in glob.glob(pattern):
        img = Image.open(f).convert("RGB")
        img.save(f)


def main():
    j = 1
    files = open('notes.txt')
    rtTemplate = "rt: {0}<1{1:02d},{2}<2{1:02d},{3}<2{1:02d},{4}<2{1:02d},{5}<2{1:02d},{6}<2{1:02d}\t"
    dopTemplate = "_Animations\Dog_position{0}.gif(1024x600)\t{1}\t"

    for ln in files:
        line = ln.strip()
        _dogs = line.split('framed')
        dogPos = _dogs[0] + "dogposition" + _dogs[1] + "dogPos" + _dogs[2]
        stringpath = os.path.split(line)
        string = stringpath[-1].split('-')

        if "Train" in string[0]:
            key, nums, fname = item_formatter(string, 1)
        else:
            key, nums, fname = item_formatter(string, 0)

        print dopTemplate.format(key, dogPos), rtTemplate.format(key, j, *nums)
        j += 1

    # for f in glob.glob('*dogPos*'):
    #     token = f.split('.')
    #     fn = '.'.join([token[0][:-1], token[1]])
    #     os.rename(f, fn)

    # s = 'somepath'
    # im = Image.open('{}'.format(os.path.join(os.getcwd(), s + '.png'))).convert("RGB")

if __name__ == '__main__':
    main()
