# fin = open('Block2.txt')
# fout = open('listBlock2.txt', 'a')
# fset = open('setBlock2.txt', 'a')

# joinedBlock = []
# blockSet = set()

# for line in fin:
#     splitLine = line.split()
#     splitLine[-1] = splitLine[-1].capitalize()
#     splitLine[0] = splitLine[0].capitalize()
#     newLine = '_'.join(splitLine)
#     joinedBlock.append(newLine)
#     blockSet.add(newLine)

# for ln in blockSet:
#     print ln
#     fset.write(ln + '\n')


# for ln2 in joinedBlock:
#     fout.write(ln2 + '\n')


# fset.close()
# fout.close()

fset = open('setBlock2.txt')
Masc_Single = []
Masc_Double = []
Fem_Single = []
Fem_Double = []
wordDict = {'Male': [Masc_Single[:],
                     Masc_Double[:],
                     Fem_Single[:],
                     Fem_Double[:]],
            'Female': [Masc_Single[:],
                       Masc_Double[:],
                       Fem_Single[:],
                       Fem_Double[:]]}

for line in fset:
    word, gender, marking, speaker = line.split('_')
    if 'Fem' in gender and 'single' in marking:
        Fem_Single.append(word)
