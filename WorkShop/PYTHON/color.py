import itertools

# num = [1, 2, 4, 8, 16]
num = [1.01, 1.02, 1.03, 1.04, 1.05]
color = ['yellow', 'red', 'blue', 'green', 'pink']
r = [255, 255, 0, 0, 255]
g = [255, 0, 0, 255, 0]
b = [0, 0, 255, 0, 255]

# for i in range(1, len(num) + 1):
#     for x in itertools.combinations(num, i):
#         print sum(x), "\t", sum(x) / 12.4, '\t', sum(x) / 15.5, '\t', x

for i in range(1, len(num) + 1):
    for x in itertools.combinations(num, i):
        print sum(x), '\t', sum(x)/5.15, '\t', x

# for i in range(1, len(color) + 1):
#     for x in itertools.combinations(color, i):
#         print x

# for j in (r, g, b):
# 	print j, '\n'
# 	for i in range(1, len(j) + 1):
# 	    for x in itertools.combinations(j, i):
# 	        print sum(x) / len(x)


"""           r   g  b
yellow = (255,255,0  )
   red = (255,0  ,0  )
  blue = (0  ,0  ,255)
 green = (0  ,255,0  )
  pink = (255,0  ,255)
orange = (255,105,0  )

(r1, g1, b1) + (r2, g2, b2) = ((r1+r2)/2, (g1+g2)/2, (b1+b2)/2)

r = ['r1', 'r2', 'r3', 'r4', 'r5', 'r6']
g = ['g1', 'g2', 'g3', 'g4', 'g5', 'g6']
b = ['b1', 'b2', 'b3', 'b4', 'b5', 'b6']
"""





