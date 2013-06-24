#!/bin/bash
#================================================================================
#	Program Name: nback.bash
#		  Author: Kyle Reese Almryde
#			Date: June 18 2012
#
<<<<<<< HEAD
#	 Description: 
#				  
#				  
#
#	Deficiencies: 
#				  
#				  
#				  
#				  
=======
#	 Description:
#
#
#
#	Deficiencies:
#
#
#
#
>>>>>>> c388accc3877fb367f9b3b3512fef5b71ebe8b61
#
#================================================================================
#				START OF MAIN
#================================================================================


	#------------------------------------------------------------------------
	#
	#	Description: a
<<<<<<< HEAD
	#				  
	#		Purpose: a
	#				  
	#		  Input: a
	#				  
	#		 Output: a  
	#				  
	#	  Variables: a
	#				  
=======
	#
	#		Purpose: a
	#
	#		  Input: a
	#
	#		 Output: a
	#
	#	  Variables: a
	#
>>>>>>> c388accc3877fb367f9b3b3512fef5b71ebe8b61
	#------------------------------------------------------------------------

words=( $(cat nback.lst) )

<<<<<<< HEAD
for (( i=0, j=0; i < ${#words[*]}; i++, j=i%6 )) ;do 

	if [[ $i -le 19 ]]; then 
		group="1-back.Target"
	elif [[ $i -ge 20 ]]; then 
=======
for (( i=0, j=0; i < ${#words[*]}; i++, j=i%6 )) ;do

	if [[ $i -le 19 ]]; then
		group="1-back.Target"
	elif [[ $i -ge 20 ]]; then
>>>>>>> c388accc3877fb367f9b3b3512fef5b71ebe8b61
		if [[ $j -eq 0 ]]; then
			group="2-back.Distractor"
		else
			group="2-back.Target"
		fi
<<<<<<< HEAD
	fi 
=======
	fi
>>>>>>> c388accc3877fb367f9b3b3512fef5b71ebe8b61

	#mv ${words[i]} ${group}.$i.${words[i]}
	echo i$i j$j ${group}.${words[i]}
done


