awk '/ >=0/ {print NR-5;exit}' Test1_outliers.txt #No 0 so it wont work
awk '/ 0/ {print NR-5;exit}' Test2_outliers.txt #This works because there is a 0 somewhere
awk '/  [0-10] / {print NR;exit}' Test1_outliers.txt
awk '/  [0-9] / {print NR;exit}' Test2_outliers.txt
awk '/  [0-9] / {print NR;exit}' Test3_outliers.txt
#This works because there is a 0 somewhere

awk '/ >= 10/ ||/ >= 0/ {print NR;exit}' Test1_outliers.txt
#This finds a value of 10, but I dont know that its evaluating the other expressions...the syntax is
#good though...




awk '/ 0/ {print NR-5}' Test2_outliers.txt # This works, but lists EVERY line with a 0
awk '/ >=0/ {print NR-5}' Test2_outliers.txt



awk '/  [0-9] / {print NR-5;exit}' Test1_outliers.txt
# I think this does the trick!! It searches for the first instance of a single digit between 0 and 9
# and prints the NUMBER line - 5 to account for time shifting and AFNI's penchant for starting
# timeseries with 0 (which is annoying)
