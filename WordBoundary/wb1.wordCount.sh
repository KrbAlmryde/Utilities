#!/bin/bash

#========================================================================================================
# Unlearnable stimuli



file=etc/Unlearnable_Sentences.txt     # make a variable name linking the file name for readability later on


if [[ ! -f Unlearnable_Count.txt ]]; then    # check to see if the file exists or not, create it if need be
	touch Unlearnable_Count.txt				 # if it doesnt, make it. 
fi

# Initiate a while loop which reads the contents of the unlearnable_list.txt. This file is identical to the 
# Unlearnable_Sentences.txt file save that each word is on its own line. The result of this is enables us
# to process each item individually. Admittedly this is very redudant code, it results in going over a lot 
# of the same words repeatedly, but thats why we have control structures :-)

while read unlearn; do  
	
	# This command searches the formatted output file, specifically looking at the first column which 
	# identifies the word we are interested in. It then counts the number of instances (within in the 
	# first column only), if the count is not 0, then we know that that word has already been counted
	# in the file with the sentences. If the count is 0, then it performs the next steps described below
	cmd=$(cat Unlearnable_Count.txt | awk -F '\:' '{print $1}' | grep -ciw "$unlearn")	  

	if [[ "$cmd" != "0" ]]; then			# Test to see if the word has already been counted or not. 
		echo "$unlearn already counted"
	else
		echo -ne "${unlearn}:\t" >> Unlearnable_Count.txt			# This prints the word and omitts the newline
		grep -ciw "${unlearn}" $file >> Unlearnable_Count.txt		# This counts the number of whole word occurances
																	# 	of our word while ignoring case. It then appends
																	#	the results to the same line  as the previous command
		
		grep -inw "${unlearn}" $file > etc/tmp.txt					# This identifies the sentences containing the word, and prints
																	# the whole sentence as well as its line number to a temporary file


		awk -F '\:' '{print "\t"$1":", $2}' etc/tmp.txt >> Unlearnable_Count.txt	# This formats the previous commands output so it looks
																					# prettier than what grep spits out, and indents it for 
																					# readability
		
		echo >> Unlearnable_Count.txt								# This produces a newline for readability
	fi
	
done <etc/unlearnable_list.txt


sentences=({Unlearnable,Learnable}_Sentences.txt)
list=({Unlearnable,Learnable}_List.txt)
count=({Unlearnable,Learnable}_Count.txt)


for i in {0,1}; do
	if [[ ! -f ${count[i]} ]]; then
		touch ${count[i]}
	fi

	while read cond; do
		cmd=$(cat ${count[i]} | awk -F '\:' '{print $1}' | grep -ciw "$cond")

		if [[ "$cmd" != "0" ]]; then
			echo "$cond already counted"
		else
			echo -ne "${cond}:\t" >> ${count[i]}
			grep -ciw "${cond}" etc/${file[i]} >> ${count[i]}
			grep -inw "${cond}" etc/${file[i]} > etc/tmp.txt
			awk -F '\:' '{print "\t"$1":", $2}' etc/tmp.txt >> ${count[i]}
			echo >> ${count[i]}
		fi

	done <etc/${list[i]}