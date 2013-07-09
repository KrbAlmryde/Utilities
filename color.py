import itertools


class ColorPallet(object):
    """docstring for ColorPallet"""
    def __init__(self, maxRange, limit=5):
        super(ColorPallet, self).__init__()
        self.maxRange = maxRange  # The highest overlap value
        self.limit = limit  # The number of components
        self.length = 0
        self.overlap = []  # [2,3,4]
        self.comboValues = set()  # [1.01, 1.02, 1.03, 1.04, 1.05, 2.0300000000000002, 2.04, 2.05, 2.06...]
        self.palletValues = set()  # [2.5495049504950495, 2.0495049504950495, 2.0445544554455446, 2.0396039603960396...]
        self.compValue = [1.01, 1.02, 1.03, 1.04, 1.05]
        self.colorCodes = ['navyblue', '#0069ff', '#00ccff', '#6600cc', '#00ff00', '#ffcc00', '#ccff00', '#ff0000']
        self.colorNames = ['navy', 'dk-blue', 'lt-blue1', 'blue-cyan', 'purple', 'green', 'yell-oran', 'rbgyr20_14', 'red']
        # Set the value lists
        self.setComboValues()
        self.setPalletValues()

    def setComboValues(self):
        for i in range(1, len(self.compValue) + 1):
            for x in itertools.combinations(self.compValue, i):
                self.comboValues.add(sum(x))
        self.comboValues = sorted(list(self.comboValues))

    def setPalletValues(self):
        for v in self.comboValues:
            self.palletValues.add(v/self.maxRange)
        self.palletValues = sorted(list(self.palletValues))
        self.palletValues.reverse()

    def getComboValues(self):
        return self.comboValues

    def getPalletValues(self):
        return self.palletValues

    def trimValueLists(self, index, check):
        if check < 2.0:
            self.comboValues.pop(index)
            self.palletValues.pop(index)
        elif check >= 2.0:
            if int(check) in self.overlap:
                self.comboValues.pop(index)
                self.palletValues.pop(index)
            else:
                self.overlap.append(int(check))
        if self.comboValues[index] == check:
            self.comboValues.pop(index)

    def build_Pallet(self, palletName):
        template = "#--------------------------------------\n#   Component colors\n#      1 - Red     ==> 1.01\n#      2 - Yellow  ==> 1.02\n#      3 - Orange  ==> 1.03\n#      4 - Green   ==> 1.04\n#      5 - Purple  ==> 1.05\n#\n#   Overlapping Component colors\n#      2 - Cyan blue   ==> 2.0[3-9]\n#      3 - Light blue  ==> 3.[06-12]\n#      4 - Dark Blue   ==> 4.1[0-4]\n#      5 - Navy blue   ==> 5.15\n#--------------------------------------\n\n"
        COLORS = "***COLORS\n\tnavy = navyblue\n\tdk-blue = #0000ff\n\tlt-blue1 = #0069ff\n\tblue-cyan = #00ccff\n\tpurple = #6600cc\n\tgreen = #00ff00\n\tyell-oran = #ffcc00\n\trbgyr20_14 = #ccff00\n\tred = #ff0000\n"
        pallet = "{}\n{}\n***PALETTES {} [{}+]".format(template, COLORS, palletName, self.length)

        for i, val in enumerate(self.getPalletValues()):
            if i+1 > self.limit:
                self.trimValueLists(i, val)
            pallet += "\n\t{:0.4f} -> {}".format(val, self.colorNames[i])
            i += 1
        return pallet


def main():
    iceR1 = ColorPallet(2.02, 4)
    print iceR1.getComboValues()
    print iceR1.getPalletValues()
    print iceR1.build_Pallet('iceR1')


if __name__ == '__main__':
    main()

# for i in range(1, len(num) + 1):
#     for x in itertools.combinations(num, i):
#         print sum(x), '\t', sum(x)/target, '\t', x

    """ output of above function
    1.01    0.196116504854  (1.01,)
    1.02    0.198058252427  (1.02,)
    1.03    0.2     (1.03,)
    1.04    0.201941747573  (1.04,)
    1.05    0.203883495146  (1.05,)
    2.03    0.394174757282  (1.01, 1.02)
    2.04    0.396116504854  (1.01, 1.03)
    2.05    0.398058252427  (1.01, 1.04)
    2.06    0.4     (1.01, 1.05)
    2.05    0.398058252427  (1.02, 1.03)
    2.06    0.4     (1.02, 1.04)
    2.07    0.401941747573  (1.02, 1.05)
    2.07    0.401941747573  (1.03, 1.04)
    2.08    0.403883495146  (1.03, 1.05)
    2.09    0.405825242718  (1.04, 1.05)
    3.06    0.594174757282  (1.01, 1.02, 1.03)
    3.07    0.596116504854  (1.01, 1.02, 1.04)
    3.08    0.598058252427  (1.01, 1.02, 1.05)
    3.08    0.598058252427  (1.01, 1.03, 1.04)
    3.09    0.6     (1.01, 1.03, 1.05)
    3.1     0.601941747573  (1.01, 1.04, 1.05)
    3.09    0.6     (1.02, 1.03, 1.04)
    3.1     0.601941747573  (1.02, 1.03, 1.05)
    3.11    0.603883495146  (1.02, 1.04, 1.05)
    3.12    0.605825242718  (1.03, 1.04, 1.05)
    4.1     0.796116504854  (1.01, 1.02, 1.03, 1.04)
    4.11    0.798058252427  (1.01, 1.02, 1.03, 1.05)
    4.12    0.8     (1.01, 1.02, 1.04, 1.05)
    4.13    0.801941747573  (1.01, 1.03, 1.04, 1.05)
    4.14    0.803883495146  (1.02, 1.03, 1.04, 1.05)
    5.15    1.0     (1.01, 1.02, 1.03, 1.04, 1.05)
    """


# for i in range(1, len(color) + 1):
#     for x in itertools.combinations(color, i):
#         print x

# for j in (r, g, b):
# 	print j, '\n'
# 	for i in range(1, len(j) + 1):
# 	    for x in itertools.combinations(j, i):
# 	        print sum(x) / len(x)





# """           r   g  b
# yellow = (255,255,0  )
#    red = (255,0  ,0  )
#   blue = (0  ,0  ,255)
#  green = (0  ,255,0  )
#   pink = (255,0  ,255)
# orange = (255,105,0  )

# (r1, g1, b1) + (r2, g2, b2) = ((r1+r2)/2, (g1+g2)/2, (b1+b2)/2)

# r = ['r1', 'r2', 'r3', 'r4', 'r5', 'r6']
# g = ['g1', 'g2', 'g3', 'g4', 'g5', 'g6']
# b = ['b1', 'b2', 'b3', 'b4', 'b5', 'b6']
# """



# template = """
#--------------------------------------
#   Component colors
#      1 - Red     ==> 1.01
#      2 - Yellow  ==> 1.02
#      3 - Orange  ==> 1.03
#      4 - Green   ==> 1.04
#      5 - Purple  ==> 1.05
#
#   Overlapping Component colors
#      2 - Cyan blue   ==> 2.0[3-9]
#      3 - Light blue  ==> 3.[06-12]
#      4 - Dark Blue   ==> 4.1[0-4]
#      5 - Navy blue   ==> 5.15
#--------------------------------------
# """
