Code:
#!/usr/bin/ksh
#
# SCRIPT: 12_ways_to_parse.ksh.ksh
#
#
# REV: 1.2.A
#
# PURPOSE:	This script shows the different ways of reading
#			 a file line by line.	Again there is not just one way
#			 to read a file line by line and some are faster than
#			 others and some are more intuitive than others.
#
# REV LIST:
#
#			 03/15/2002 - Randy Michael
#			 Set each of the while loops up as functions and the timing
#			 of each function to see which one is the fastest.
#
#######################################################################
#
#			 NOTE: To output the timing to a file use the following syntax:
#
#					12_ways_to_parse.ksh file_to_process	> output_file_name 2>&1
#
#			 The actaul timing data is sent to standard error, file
#			 descriptor (2), and the function name header is sent
#			 to standard output, file descriptor (1).
#
#######################################################################
#
# set -n	# Uncomment to check command syntax without any execution
# set -x	# Uncomment to debug this script
#

FILENAME="$1"
TIMEFILE="/usr/local/utilities/loopfile.out"
>$TIMEFILE
THIS_SCRIPT=$(basename $0)

######################################
function usage
{
echo "\nUSAGE: $THIS_SCRIPT	file_to_process\n"
echo "OR - To send the output to a file use: "
echo "\n$THIS_SCRIPT	file_to_process	> output_file_name 2>&1 \n"
exit 1
}
######################################
function while_read_LINE
{
cat $FILENAME | while read LINE
do
				echo "$LINE"
				:
done
}
######################################
function while_read_LINE_bottom
{
while read LINE
do
				echo "$LINE"
				:

done < $FILENAME
}
######################################
function while_line_LINE_bottom
{
while line LINE
do
				echo $LINE
				:
done < $FILENAME
}
######################################
function cat_while_LINE_line
{
cat $FILENAME | while LINE=`line`
do
				echo "$LINE"
				:
done
}
######################################
function while_line_LINE
{
cat $FILENAME | while line LINE
do
				echo "$LINE"
				:
done
}
######################################
function while_LINE_line_bottom
{
while LINE=`line`
do
				echo "$LINE"
				:

done < $FILENAME
}
######################################
function while_LINE_line_cmdsub2
{
cat $FILENAME | while LINE=$(line)
do
				echo "$LINE"
				:
done
}
######################################
function while_LINE_line_bottom_cmdsub2
{
while LINE=$(line)
do
				echo "$LINE"
				:

done < $FILENAME
}
######################################
function while_read_LINE_FD
{
exec 3<&0
exec 0< $FILENAME
while read LINE
do
				echo "$LINE"
				:
done
exec 0<&3
}
######################################
function while_LINE_line_FD
{
exec 3<&0
exec 0< $FILENAME
while LINE=`line`
do
				echo "$LINE"
				:
done
exec 0<&3
}
######################################
function while_LINE_line_cmdsub2_FD
{
exec 3<&0
exec 0< $FILENAME
while LINE=$(line)
do
				print "$LINE"
				:
done
exec 0<&3
}
######################################
function while_line_LINE_FD
{
exec 3<&0
exec 0< $FILENAME

while line LINE
do
				echo "$LINE"
				:
done

exec 0<&3
}
######################################
########### START OF MAIN ############
######################################

# Test the Input

# Looking for exactly one parameter
(( $# == 1 )) || usage

# Does the file exist as a regular file?
[[ -f $1 ]] || usage

echo "\nStarting File Processing of each Method\n"

echo "Method 1:"
echo "\nfunction while_read_LINE\n" >> $TIMEFILE
echo "function while_read_LINE"
time while_read_LINE >> $TIMEFILE
echo "\nMethod 2:"
echo "\nfunction while_read_LINE_bottom\n" >> $TIMEFILE
echo "function while_read_LINE_bottom"
time while_read_LINE_bottom >> $TIMEFILE
echo "\nMethod 3:"
echo "\nfunction while_line_LINE_bottom\n" >> $TIMEFILE
echo "function while_line_LINE_bottom"
time while_line_LINE_bottom >> $TIMEFILE
echo "\nMethod 4:"
echo "\nfunction cat_while_LINE_line\n" >> $TIMEFILE
echo "function cat_while_LINE_line"
time cat_while_LINE_line >> $TIMEFILE
echo "\nMethod 5:"
echo "\nfunction while_line_LINE\n" >> $TIMEFILE
echo "function while_line_LINE"
time while_line_LINE >> $TIMEFILE
echo "\nMethod 6:"
echo "\nfunction while_LINE_line_bottom\n" >> $TIMEFILE
echo "function while_LINE_line_bottom"
time while_LINE_line_bottom >> $TIMEFILE
echo "\nMethod 7:"
echo "\nfunction while_LINE_line_cmdsub2\n" >> $TIMEFILE
echo "function while_LINE_line_cmdsub2"
time while_LINE_line_cmdsub2 >> $TIMEFILE
echo "\nMethod 8:"
echo "\nfunction while_LINE_line_bottom_cmdsub2\n" >> $TIMEFILE
echo "function while_LINE_line_bottom_cmdsub2"
time while_LINE_line_bottom_cmdsub2 >> $TIMEFILE
echo "\nMethod 9:"
echo "\nfunction while_read_LINE_FD\n" >> $TIMEFILE
echo "function while_read_LINE_FD"
time while_read_LINE_FD >> $TIMEFILE
echo "\nMethod 10:"
echo "\nfunction while_LINE_line_FD\n" >> $TIMEFILE
echo "function while_LINE_line_FD"
time while_LINE_line_FD >> $TIMEFILE
echo "\nMethod 11:"
echo "\nfunction while_LINE_line_cmdsub2_FD\n" >> $TIMEFILE
echo "function while_LINE_line_cmdsub2_FD"
time while_LINE_line_cmdsub2_FD >> $TIMEFILE
echo "\nMethod 12:"
echo "\nfunction while_line_LINE_FD\n" >> $TIMEFILE
echo "function while_line_LINE_FD"
time while_line_LINE_FD >> $TIMEFILE