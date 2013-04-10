#!/bin/bash
#================================================================================
#	Program Name: nback.bash
#		  Author: Kyle Reese Almryde
#			Date: June 18 2012
#
#	 Description: 
#				  
#				  
#
#	Deficiencies: 
#				  
#				  
#				  
#				  
#
#================================================================================
#				START OF MAIN
#================================================================================


	#------------------------------------------------------------------------
	#
	#	Description: a
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
	#------------------------------------------------------------------------

words=( $(cat nback.lst) )

for (( i=0, j=0; i < ${#words[*]}; i++, j=i%6 )) ;do 

	if [[ $i -le 19 ]]; then 
		group="1-back.Target"
	elif [[ $i -ge 20 ]]; then 
		if [[ $j -eq 0 ]]; then
			group="2-back.Distractor"
		else
			group="2-back.Target"
		fi
	fi 

	#mv ${words[i]} ${group}.$i.${words[i]}
	echo i$i j$j ${group}.${words[i]}
done


