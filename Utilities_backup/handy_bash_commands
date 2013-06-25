## Here are some pieces of bash code that underpants gnomes have found useful:


#How many lines in a file? 
wc file.txt

#List directories (not their contents)
ls -d
#List files
ls -f

#These last two commands are useful for if-then statements. For example the following code says if the file /clare/image.nii.gz exists, 
#then print "Clare is great" to the screen, otherwise print "Image is missing"
if [ -f /clare/image.nii.gz ]
then
echo "Clare is great"
else echo "Image is missing"
fi

#This first one says if the directory /clare/sub001 exists, then print "Clare is great" to the screen, otherwise print "sub001 directory is missing"
if [ -d /clare/sub001 ]
then
echo "Clare is great"
else echo "sub001 directory is missing"
fi


##Get a line containing a particular piece of text from a file
grep "DTI_field_map" temp.txt> FMdirs_coc.txt

##Read in a textfile, and get characters 37-38 from each line
##Then write those characters into a new file
while read line
do
	DTI_dir=$( echo $variable | cut -c 37-38 )
	printf " \t ${DTI_dir}" >>DTI_cocaine_MAR2010.txt
	printf " \n" >>DTI_cocaine_MAR2010.txt
done < FMdirs_coc.txt
	
##Take 6th field (here, column) from line, where the separator is /
sub=$( echo $line | cut -d '/' -f 6 )

##Write variable into file, with tab separating
printf " \t ${i}" >>DTI_cocaine_MAR2010.txt
printf " \t ${DTI_dir}" >>DTI_cocaine_MAR2010.txt

##Go to next line in output file
printf " \n" >>DTI_cocaine_MAR2010.txt

###Take a variable variable and use sed to replace something in a file with something else
## note that the indices start at 0, like an image file!
TRs=( 265 195 195 127 119 )

x=0

for site in Bangor Berlin Berlin-Margulies Cleveland Harvard

do
	echo ${x}
	numTRs=${TRs[${x}]}
	
	echo ${numTRs}
	
	sed -e s/265/"${numTRs}"/g <ofc_l.fsf > ${site}_TR_ofc_l.fsf
	sed -e s/Bangor/"${site}"/g <${site}_TR_ofc_l.fsf > ${site}_ofc_l.fsf
	
	x=$(( $x + 1 ))
done


##Count to variable number within for loop

for dir in {1..10}
do

	for number in `seq 1 ${dir}`
	do
	
	3dcalc -a ${dir}/corr${number}.nii.gz \
	-expr 'log((1+a)/(1-a))/2' -prefix ${dir}/zstat${number}.nii.gz
	
	done
done
