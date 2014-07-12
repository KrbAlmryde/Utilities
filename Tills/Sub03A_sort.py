#!/usr/bin/python
short = {}
for line in open('Sub03A_short.txt').readlines():
	print line
# 	value = line.split()[0]
# 	subj = line.split()[1]
# 	short[subj] = value
# print short
for line2 in open('Sub03A_long.txt').readlines():
	print line2
	# subj = line.strip()
	# if not short.has_key(subj):
	# 	short[subj] = 'X'

# f = open('Sub03A_final.txt', 'a+')
# for k,v in short.items():
# 	print "{0}\t{1}\n".format(k,v)
	# f.write("{0}\t{1}\n".format(k,v))
# f.close()