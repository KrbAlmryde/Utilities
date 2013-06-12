import os

rtTemplate = "rt: {0}<1{1:02d},{2}<2{1:02d},{3}<2{1:02d},{4}<2{1:02d},{5}<2{1:02d},{6}<2{1:02d}\t"
dopTemplate = "_Animations\Dog_position{}.gif(1024x600)\t"

def item_formatter(list, pos):
    nums = [1,2,3,4,5,6]
    key = int(list[pos][0])
    nums.remove(key)
    return key, nums, list[-1]


j = 1

for files in open('notes.txt'):
    line = files.splitlines()[0]
    _dogs = line.split('framed')
    dogPos = _dogs[0] + "dogposition" + _dogs[1] + "dogPos" + _dogs[2]
    stringpath = os.path.split(line)
    string = stringpath[-1].split('-')

    if "Train" in string[0]:
        key, nums, fname = item_formatter(string, 1)
    else:
        key, nums, fname = item_formatter(string, 0)

    print dopTemplate.format(key), dogPos, '\n', rtTemplate.format(key, j, *nums)

    j += 1
