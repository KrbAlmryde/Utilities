#!/bin/sh
# Compcheck.txt
# Written by Kyle Almryde 6/15/2011
# Thanks to Dianne Patterson, Tom Hicks, and Era Eriksson for troubleshooting and suggestions!
# This script massages text generated from a DirectRT .csv file
#
#The first line establishes a while loop which reads from the file ls.txt, and executes for every item in the list.
#The second line removes all but the columns of interest, the first line of the file, and any items not in block 3 or 4
#The third line uses sed to change all ::spaces:: to "_", all "," to "::space::", True to 1, False to 0, changes the
#delimiter to a tab, and finally sorts the contents
#The fourth line calculates the accuracy for each subject, then prints the "subject# = AVG" in a seperate file named Summary
#The fifth line removes the temporary file subject#_A.txt
#The final line closes the loop, and provides the input for the program to run.


	<${func}/${name}.csv cut -d , -f 1,3,8-10 | sed '1d' | awk '/,3,/; /,4,/' >> ${func}/${name}_A.txt
	<${func}/${name}_A.txt sed -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g' | awk -v OFS='\t' '$1=$1' | sort > ${func}/${name}.txt
	<${func}/${name}.txt awk '{sum+=$5} END { print "'${func}/${name}' = ",sum/NR}' >> Summary.txt
	rm ${func}/${name}_A.txt

