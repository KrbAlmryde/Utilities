"""
==============================================================================
Program: color.py
 Author: Kyle Reese Almryde
   Date:

 Description:



==============================================================================
"""
import itertools


COLORS_COMPONENT = ['red', 'rbgyr20_14', 'yell-oran', 'green', 'purple']*2
COLORS_OVERLAP = ['blue-cyan', 'lt-blue1', 'dk-blue', 'navy']*2
# VALUES_COMPONENT = [1.01, 1.02, 1.03, 1.04, 1.05]
VALUES_COMPONENT = [1.10000, 1.01000, 1.00100, 1.00010, 1.00001]
VALUES_OVERLAP = [2.03, 3.06, 4.1, 5.15]

class ColorPallet(object):
    """docstring for ColorPallet"""

    def __init__(self, _maxRange, _limit=5):
        super(ColorPallet, self).__init__()
        self.maxRange = _maxRange  # The highest overlap value
        self.limit = _limit  # The number of components
        self.pallet = ''
        self.overlap = [2.03, 3.06, 4.1, 5.15]  # These are the basal values for each overlap
        self.compValue = []  # [1.01, 1.02, 1.03, 1.04, 1.05]
        self.comboValues = set()  # [1.01, 1.02, 1.03, 1.04, 1.05, 2.0300000000000002, 2.04, 2.05, 2.06...]
        self.palletValues = set()  # [2.5495049504950495, 2.0495049504950495, 2.0445544554455446, 2.0396039603960396...]
        self.colorNames = []
        self.colorOverlap = []

        # Set the value lists
        self.setCompValues()
        self.setComboValues()
        self.setPalletValues()
        self.trimValueLists()

    def setCompValues(self):
        """Sets the total number of possible component
           values to that of limit, so that we dont
           produce extra computations
        """
        print "in setCompValues"
        for i, x in enumerate(VALUES_COMPONENT):
            if len(self.compValue) is self.limit:
                print "\tBREAK!!"
                break
            else:
                print "\t",i ,x,COLORS_COMPONENT[i]
                self.compValue.append(x)
                self.colorNames.append(COLORS_COMPONENT[i])

    def setComboValues(self):
        """Populates the comboValues attribute with the
           total combinations
        """
        print "\n\tIn setComboValues"
        for i in range(1, len(self.compValue) + 1):
            for x in itertools.combinations(self.compValue, i):
                val = round(sum(x), 4)  # compute the sum of values, then round up to decimals
                # print x, val
                if val > self.maxRange:
                    break
                else:
                    print "\t",i, x, val
                    self.comboValues.add(val)
        self.comboValues = sorted(list(self.comboValues))
        # print self.comboValues

    def setPalletValues(self):
        """Sets the Pallet values for each of the individual
           colors by dividing the maxRange by the value in
           comboValues
        """
        print "\n\tIn setPalletValues"
        for v in self.comboValues:
            if len(self.palletValues) == len(self.comboValues):
                break
            else:
                palletValue = v/self.maxRange
                # print v, palletValue, self.maxRange
                self.palletValues.add(palletValue)
        self.palletValues = sorted(list(self.palletValues))
        self.palletValues.reverse()
        print "\t",self.palletValues


    def getComboValues(self):
        return self.comboValues

    def getPalletValues(self):
        return self.palletValues

    def getColorNames(self):
        return self.colorNames

    def trimValueLists(self):
        i, el = 0, 0
        # print len(self.comboValues), self.comboValues
        # print len(self.palletValues), self.palletValues
        self.palletValues.reverse()
        while len(self.getComboValues()) != 0:
            if el >= len(self.getComboValues()):
                break
            check = self.comboValues[el]
            if check > 1.05:
                if check not in VALUES_OVERLAP:
                    self.comboValues.pop(el),
                    self.palletValues.pop(el)
                else:
                    self.colorNames.append(COLORS_OVERLAP[i])
                    el += 1
                    i += 1
            else:
                el += 1
        self.palletValues.reverse()

    def buildPallet(self, palletName):
        template = "#--------------------------------------\n#   Component colors\n#      1 - Red     ==> {0}\n#      2 - Yellow  ==> {1}\n#      3 - Orange  ==> {2}\n#      4 - Green   ==> {4}\n#      5 - Purple  ==> {4}\n#\n#   Overlapping Component colors\n#      2 - Cyan blue   ==> 2.0[3-9]\n#      3 - Light blue  ==> 3.[06-12]\n#      4 - Dark Blue   ==> 4.1[0-4]\n#      5 - Navy blue   ==> 5.15\n#--------------------------------------\n\n".format(*VALUES_COMPONENT)
        COLORS = "***COLORS\n\tnavy = navyblue\n\tdk-blue = #0000ff\n\tlt-blue1 = #0069ff\n\tblue-cyan = #00ccff\n\tpurple = #6600cc\n\tgreen = #00ff00\n\tyell-oran = #ffcc00\n\trbgyr20_14 = #ccff00\n\tred = #ff0000\n"
        # self.trimValueLists()
        self.pallet = "{}\n{}\n***PALETTES {} [{}+]".format(template, COLORS, palletName, len(self.palletValues))
        self.colorNames.reverse()
        for i, val in enumerate(self.getPalletValues()):
            self.pallet += "\n\t{:0.8f} -> {}".format(val, self.colorNames[i])
            print val

        fout = open(palletName + '.pal', 'a+')
        fout.write(self.pallet)
        # return self.pallet

#=============================== START OF MAIN ===============================


def main():
    # print ColorPallet(2.06, 4).buildPallet('iceR1')
    # print ColorPallet(3.09, 4).buildPallet('iceR2')
    # print ColorPallet(3.08, 4).buildPallet('iceR3')
    # print ColorPallet(4.1, 4).buildPallet('iceR4')
    # print
    ColorPallet(4.1111, 4).buildPallet('IC4')
    # print
    ColorPallet(4.1111, 4).buildPallet('IC11')
    # print
    ColorPallet(4.1111, 4).buildPallet('IC12')
    # print
    ColorPallet(4.1111, 4).buildPallet('IC18')


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
