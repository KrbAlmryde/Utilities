#!/bin/sh
####################################################################################################
. $UTL/${1}_profile
cd ${func_dir}
####################################################################################################
echo ""; echo "drt_behav.sh is under way"
####################################################################################################
# Strip all columns save those of interest, remove header, and pull specific condition items"
echo ""; echo "${runnm}.csv"
<${runnm}.csv cut -d , -f 1,8-10 | sed '1d' | awk '/,"'"${cond}"'/' > rm.${condnm}.txt
####################################################################################################
# Copy rm.${condnm}.txt to the condition directory and remove the old

echo ""; echo "moving rm.${condnm}.txt to ${con_dir} directory"
mv rm.${condnm}.txt ${cond}
####################################################################################################
# Change to the Condition Directory

echo ""; echo "changing to ${cond_dir} directory"
cd ${cond_dir}
####################################################################################################
# Format file to prepare it for Excel, change TRUE -> 1, FALSE -> 0, convert spaces to tabs
# This file will our Accuracy file
#

echo ""; echo "creating ${condnm}.ACC.txt"
<rm.${condnm}.txt sed -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g' | awk -v \
	OFS='\t' '$1=$1' | sort > ${condnm}.ACC.txt
####################################################################################################
# Print only the correct responses so we can analyze the  Reaction Times for correct responses
# Print only the incorrect responses so we can analyze the Reaction Times for incorrect responses
#
echo ""; echo "creating ${condnm}.RT.Correct.txt and ${condnm}.RT.Incorrect.txt"
<rm.${condnm}.txt awk '/,True/' > rm.${condnm}.RT.Correct.txt
<rm.${condnm}.txt awk '/,False/' > rm.${condnm}.RT.Incorrect.txt
####################################################################################################
# Format file to prepare it for Excel, convert spaces to tabs
# This file will our Accuracy file
#

echo ""; echo "creating ${condnm}.ACC.txt"
<rm.${condnm}.RT.Correct.txt sed -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g' | awk \
	-v OFS='\t' '$1=$1' | sort > ${condnm}.RT.Correct.txt
<rm.${condnm}.RT.Incorrect.txt sed -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g' | awk \
	-v OFS='\t' '$1=$1' | sort > ${condnm}.RT.Incorrect.txt
####################################################################################################
####################################################################################################
# Read the 4th column, denoting accuracy, caluclate the mean Accuracy, then create a file listing
# the Subject_Run = Mean score for the entire population name it ${cond}_Summary_%ACC.txt
# Do the same, but count the sum, not the mean.
#
echo ""; echo "creating ACC Summary files"
<${condnm}.ACC.txt awk '{sum+=$4} END { print "'${runnm}' = ",sum/NR}' >> ${cond}_Summary_ACC%.txt
<${condnm}.ACC.txt awk '{sum+=$4} END { print "'${runnm}' = ",sum}' >> ${cond}_Summary_ACC.txt
####################################################################################################
# Read the 3rd column, denoting Reaction Time, caluclate the mean RT for IN/CORRECT response, then
# create a file listing the Subject_Run = Mean score for the entire population
#
echo ""; echo "creating ${cond}_Summary_RT_In/Correct.txt files"
<${condnm}.RT.Correct.txt awk '{sum+=$3} END { print "'${runnm}' = ",sum/NR}' >> \
	${cond}_Summary_RT_Correct.txt
<${condnm}.RT.Incorrect.txt awk '{sum+=$3} END { print "'${runnm}' = ",sum/NR}' >> \
	${cond}_Summary_RT_Incorrect.txt
####################################################################################################
# Copy Summary files to the results Directory then remove the originals in the CONDITION directory
#
echo ""; echo "moving Summary Files to the results directory"
mv ${cond}_Summary_RT_Correct.txt ../../Results
mv ${cond}_Summary_RT_Incorrect.txt ../../Results
mv ${cond}_Summary_ACC%.txt ../../Results
mv ${cond}_Summary_ACC.txt ../../Results
####################################################################################################
# Remove Summary files from the CONDITION directory

#rm ${cond}_Summary_RT_Correct.txt
#rm ${cond}_Summary_RT_Incorrect.txt
#rm ${cond}_Summary_ACC%.txt
#rm ${cond}_Summary_ACC%.txt
####################################################################################################
# Print the Accuracy scores for each item to a list, then transpose them
# Do the same for the Reaction Times, this will allows us to look at the Accuracy for individual
# items and their
#
echo ""; echo "Creating Item Summary files"
<${condnm}.ACC.txt awk 'FNR==1{A[++a]=$4;next}{A[a]=A[a] OFS $4;next}END \
	{while(A[++i]) print A[i]}' >> ${condnm}_summary_acc_item.txt
<${condnm}.ACC.txt awk 'FNR==1{A[++a]=$3;next}{A[a]=A[a] OFS $3;next}END \
	{while(A[++i]) print A[i]}' >> ${condnm}_summary_rt_item.txt
####################################################################################################
#The first line establishes a while loop which reads from the file ls.txt, and executes for every
#item in the list.
#The second line removes all but the columns of interest, the first line of the file, and any items
#not in block 3 or 4
#The third line uses sed to change all ::spaces:: to "_", all "," to "::space::", True to 1, False
#to 0, changes the delimiter to a tab, and finally sorts the contents
#The fourth line calculates the accuracy for each subject, then prints the "subject# = AVG" in a
#seperate file runnmd Summary
#The fifth line removes the temporary file subject#_A.txt
#The final line closes the loop, and provides the input for the program to run.
