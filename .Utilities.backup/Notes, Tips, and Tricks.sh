####################################################################################################
# The eprime on the new scanner PC produces text files in UTF16.  This breaks everything. iconv can 
# do the conversion back to a standard text format that sed likes.
####################################################################################################

iconv -f UTF-16 -t ISO-8859-1 ${subj}-${run}.txt > iconv.iso.${subrun}.txt
####################################################################################################
# The dos2unix tool is the next step in the conversion from UTF16 to UNIX compatible text files. 
# You'll first need to used iconv above to convert to UTF-8 bit, then this tool to convert the
# Windows-CRLF encoding type to UNIX(LF). This is crucial, as the windows line-returns breaks paste
# in horrible ways that makes text editing via sed and awk a goddamn nightmare. The dos2unix tool 
# is part of the fink distribution, but you have to go get it. Special Thanks to Tom Hicks and
# Dianne Patterson for this. NOTE: This command affects the actual file, it does not print any sort
# of output to the screen, it simply converts the file. Try to remember that before you start hating
# this marvelous tool. 
####################################################################################################

dos2unix iconv.iso.${subrun}.txt

####################################################################################################
## Here are some pieces of bash code that underpants gnomes have found useful:
####################################################################################################
#How many lines in a file? 
####################################################################################################
wc file.txt

####################################################################################################
#List directories (not their contents)
ls -d
#List files
ls -f

#These last two commands are useful for if-then statements. For example the following code says if 
#the file /clare/image.nii.gz exists, then print "Clare is great" to the screen, otherwise print 
# "Image is missing"
if [ -f /clare/image.nii.gz ]
then
echo "Clare is great"
else echo "Image is missing"
fi

#This first one says if the directory /clare/sub001 exists, then print "Clare is great" to the screen,
# otherwise print "sub001 directory is missing"
if [ -d /clare/sub001 ]
then
echo "Clare is great"
else echo "sub001 directory is missing"
fi


##Get a line containing a particular piece of text from a file
grep "DTI_field_map" temp.txt> FMdirs_coc.txt

#Read in a textfile, and get characters 37-38 from each line, Then write those characters into a 
# new file

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

####################################################################################################
#Create a BRIK & HEADER from a manual TLRC

adwarp -apar anat+tlrc -dpar anat+orig -prefix anat -overwrite


First I ran the align_epi_anat.py script on the ${spgr}+orig in order to align it to the
${fse}+orig. This is a standard procedure for all of my subjects, as it not only aligns the spgr to the fse,
but it also skull-strips. Here is the code I used....

	`align_epi_anat.py -dset1to2 -dset1 ${spgr}+orig -dset2 ${fse}+orig -cost lpa`

For whatever reason, likely something to do with the align_epi_anat.py script, there are no markers
to allow you to manually talairach, so I used the 3drefit command to add some for me at AFNI`s		'
suggestion. This will become a standard procedure soon. Here is the code I used

	`3drefit -markers ${spgr}_al+orig`

From that point I was able to manually talairach the ${spgr}_al+orig images. The manual talaiarch
doesnt always do a very good job however, so its often necessary to nudge the images a bit so that
they fit the standard a little better. Unfortunately, you need to have both a .BRIK & .HEADER +tlrc
file. The output of the manual talairach leaves you with only a .HEADER file, appending the changes
to the BRIK of the +orig dataset. In order to make both a .BRIK & .HEADER +tlrc file you will need
to run the following code...

	`adwarp -apar ${spgr}_al+tlrc -dpar ${spgr}_al+orig -prefix ${spgr}_al -overwrite`

At this point I was about to manually nudge the subjects BRIK/HEADER spgr image to try and match my
standard model brain, in this case TT_N27+tlrc, when tt occured to me that I could use the
align_epi_anat.py script to do that for me. I wasnt sure how well this was going to work since it
is going to attempt to skull-strip the already skull-stripped ${spgr}_al image. However that turned
out to not be an issue, and the result was a very beautifully aligned, talairached spgr image, that
fits to the best of its ability, our standard template. Here is the code I used...

	`align_epi_anat.py -dset1to2 -dset1 ${spgr}_al+tlrc -dset2 TT_N27+tlrc -suffix igned -cost lpa`

The final output look something like this....${spgr}_aligned+tlrc

Woot! Woot! SS out!

SS
