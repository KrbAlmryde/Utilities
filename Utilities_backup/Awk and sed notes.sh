# This function reads an outlier file looking for a pattern of a single digit between 0 and 9
# and prints the NUMBER line - 5 to account for time shifting and AFNI's penchant for starting
# timeseries with 0 (which is annoying), then exits, which causes awk to print only 1 value.
# This allows us to acquire a base value to register our data.
#---------------------------------------------------------------------------------------------------

function base_reg ()
{
awk '/  [0-9] / {print NR-5;exit}' DIR/etc/outliers.txt
}

#---------------------------------------------------------------------------------------------------
# This function reads an outlier file looking for a pattern of a single digit between 0 and 9
# and prints the NUMBER line - 5 to account for time shifting and AFNI's penchant for starting
# timeseries with 0 (which is annoying), then exits, which causes awk to print only 1 value.
# This allows us to acquire a base value to register our data.
# dump the contents of the file to the screen with the line number preceding each line. 
# Pipe the output of cat to sort, the "-k2" tag specifies the position. Pipe that output 
# to head, where we just print the first line. Pipe that to awk, since the output of sort 
# -k2 looks like this 
#	 "65:     11"
# we want just the contents of the first field "65". Then we will subtract one from that 
# value and print it to the screen.
#	   64
#---------------------------------------------------------------------------------------------------
function base_reg ()
{
cat -n run1_sub001.outliers.txt | sort -k2 | head -1 | awk '{print $1-1}'
}



#---------------------------------------------------------------------------------------------------
# Read the 4th column, denoting accuracy, caluclate the mean Accuracy, then create a file listing
# the Subject_Run = Mean score for the entire population name it ${cond}_Summary_%ACC.txt
# Do the same, but count the sum, not the mean.
#---------------------------------------------------------------------------------------------------

<ACC.txt awk '{sum+=$4} END { print sum/NR*100"%"}' >> DIR/Summary_ACC%.txt
<ACC.txt awk '{sum+=$4} END { print sum}' >> DIR/Summary_ACC.txt
#---------------------------------------------------------------------------------------------------
# Read the 3rd column, denoting Reaction Time, caluclate the mean RT for IN/CORRECT response, then
# create a file listing the Subject_Run = Mean score for the entire population
# Just in case we need it.... awk '{sum+=$3} END { print "'${subrun}' = ",sum/NR}'
#---------------------------------------------------------------------------------------------------

<RT.Correct.txt awk '{sum+=$3} END { print sum/NR}' >> DIR/Summary_RT_Correct.txt
<RT.Incorrect.txt awk '{sum+=$3} END { print sum/NR}' >> DIR/Summary_RT_Incorrect.txt
<ACC.txt awk '{sum+=$3} END { print sum/NR}' >> DIR/Summary_RT.txt
#---------------------------------------------------------------------------------------------------
# Print the Accuracy scores for each item to a list, then transpose them
# Do the same for the Reaction Times, this will allows us to look at the Accuracy for individual
# items and their
#---------------------------------------------------------------------------------------------------


<ACC.txt awk 'FNR==1{A[++a]=$4;next}{A[a]=A[a] OFS $4;next}END {while(A[++i]) print A[i]}' >> DIR/Summary_ACC_item.txt
<ACC.txt awk 'FNR==1{A[++a]=$3;next}{A[a]=A[a] OFS $3;next}END {while(A[++i]) print A[i]}' >> DIR/Summary_RT_item.txt
#---------------------------------------------------------------------------------------------------
# Get lines containing RT (or Target.RESP or CRESP) and save the 2nd field
#---------------------------------------------------------------------------------------------------

cat temp | grep RT | awk '{print $2}' >> rt
			##I wonder if i can print multiple fields as in: awk '{print $1,$2,$3}'
#---------------------------------------------------------------------------------------------------
# Extract just the rows of interest. By using the -e the sed commands are all executed together,
# so we retain the line ordering of the file
#---------------------------------------------------------------------------------------------------

cat ${subj}-${run}.txt | sed -n -e '/SoundFile:/p' -e '/WordType:/p' -e '/SpeakerGender:/p' -e \
	'/SlideTarget.RT:/p' -e '/SlideTarget.RESP:/p' -e '/SlideTarget.CRESP:/p' -e \
	'/SlideTarget.OnsetTime:/p' | tr -d '\t' > temp
#---------------------------------------------------------------------------------------------------
# Change the delimiter from spaces to tabs
#---------------------------------------------------------------------------------------------------


cat temp.report | awk -v OFS='\t' '$1=$1' >> Report.txt
#---------------------------------------------------------------------------------------------------
# Compare the contents of field $6 to $7, if they are equal, print a value of 1 in field $8
# if they are different, print a value of 0 in filed $8
#---------------------------------------------------------------------------------------------------


cat Report.txt | awk '{ if( $6==$7){ print $8=1}; if($6 != $6){print $8=0}}' >>awk2.txt

#---------------------------------------------------------------------------------------------------
# Speaking to the marvelous utility of awk, you can read a multicolumn file into awk, and print a
# specific column or columns of interest to a new file
#---------------------------------------------------------------------------------------------------

	cat voice.cresp.fix | awk '{print $1}' >> speakergender.tmp
#---------------------------------------------------------------------------------------------------
# Some really helpful notes about GREP, if you want to look for multiple patterns or words, you
# simply use the -E option and connect the two strings with a "|" see the example below.
# Note: I used grep two different ways, both produce the same output. Also, grep prints the 
# ENTIRE LINE that contains the pattern, in case you forgot ;-)
#---------------------------------------------------------------------------------------------------

grep -E 'Old|New' file.txt > out.txt
cat file.txt | grep -E 'Old|New' > out2.txt
#---------------------------------------------------------------------------------------------------
# This is a pretty handy SED trick, the ^ refers to the start of the line
# specific column or columns of interest to a new file
#---------------------------------------------------------------------------------------------------

sed s/'^/0/g' ACC.Report.TS001.TP2.txt >a.txt
	
#---------------------------------------------------------------------------------------------------
# This pattern matches any lines containing the word Old and the value 1 at the end of the line
# its important to note that in the below example, I specifically wanted any and all lines that 
# had the value 1 at the end. This ensures that I return only lines with the Old condition and a 
# positive accuracy scores (in the case of this example. 
# 
#---------------------------------------------------------------------------------------------------

grep "Old.*[1]$" Report.TS004.TP1.txt

471.8	turnip	Old	1990	3	3	1
478.8	porcupine	Old	846	3	3	1
489.3	poodle	Old	986	3	3	1
492.8	lemming	Old	895	3	3	1
496.3	yam	Old	887	3	3	1
506.8	waffle	Old	1662	3	3	1


#---------------------------------------------------------------------------------------------------
# Count how many lines are "empty" using grep
#---------------------------------------------------------------------------------------------------

grep -c '^$' file.txt

2

#---------------------------------------------------------------------------------------------------
# Print the number of the lines which are "empty" using grep
#---------------------------------------------------------------------------------------------------
grep -n '^$' file.txt

5878
6875

#---------------------------------------------------------------------------------------------------
# Count the number of empty lines in the 8th field of a comma seperated file.
# the awk -F"," is specifying the delimiter in this case
#---------------------------------------------------------------------------------------------------

cat Long.tap.txt | awk -F"," '{print $8}' | grep -c '^$'



#---------------------------------------------------------------------------------------------------
# Identify the lines that have duplicate items in them
#---------------------------------------------------------------------------------------------------
	egrep -n '(^|,)([^,]+).*,\2($|,)' file


#---------------------------------------------------------------------------------------------------
# 
# dump the contents of the file to the screen with the line number preceding each line. 
# Pipe the output of cat to sort, the "-k2" tag specifies the position. Pipe that output 
# to head, where we just print the first line. Pipe that to awk, since the output of sort 
# -k2 looks like this 
#	 "65:     11"
# we want just the contents of the first field "65". Then we will subtract one from that 
# value and print it to the screen.
#	   64
#---------------------------------------------------------------------------------------------------
	cat -n run1_sub001.outliers.txt | sort -k2 | head -1 | awk '{print $1-1}'





