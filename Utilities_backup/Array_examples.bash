#!/bin/bash

stimfile=(`cat emptystimfiles.txt`)	#This is for the stimfile names
sub=(`cat subrunlist.txt`)	#Subject.Run, will contain 10 elements in array, from 0-9
len=${#sub[@]}				# the length of the array



for (( i=0; i < ${len}; i++)); do
	line=(`awk '/0/ {print NR}' motion.${sub[i]}_censor.1D`)

	for (( j = 0; j < ${#line[@]}; j++ )); do
		echo "sed -n '${line[j]}p' timing.txt >> ${stimfile[${i}]}.txt" >> executelist.sh

	done
done


chmod ugo+x executelist.sh
./executelist.sh
for (( i=0; i < ${len}; i++)); do
	cat ${stimfile[${i}]}.txt | tr '\n' ' ' >> ${stimfile[${i}]}
done


exit

time=(`sed -n ''${line[j]}'p' timing.txt`)	#	this also works, for the most part
echo "${time[j]} > ${stimfile[${j}]}.txt" >> executelist.sh

echo " `grep -c '0' motion.${sub[i]}_censor.1D`  ==>  motion.${sub[i]}_censor.1D ">> codetest.txt 
	This is good for counting the number of patterns and printing the source file. 
