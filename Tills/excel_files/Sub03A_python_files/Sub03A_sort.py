#!/usr/bin/python
short = {}
for line in open('Sub03A_short.txt').read().split("\r"):
	print line
	value = line.split()[0]
	subj = line.split()[1]
	short[subj] = value
# print short
for line in open('Sub03A_long.txt').read().split("\r"):
	# print line2
	subj = line.strip()
	if not short.has_key(subj):
		short[subj] = 'X'

f = open('Sub03A_final.txt', 'a+')
for k,v in short.items():
	# print "{1}\t{0}\n".format(k,v)
	f.write("{1}\t{0}\n".format(k,v))
f.close()