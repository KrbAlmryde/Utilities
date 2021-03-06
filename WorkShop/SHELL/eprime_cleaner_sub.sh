#!/bin/sh
# Written by Dianne Patterson 5/11/2011
# Thanks to Tom Hicks and Kyle Almryde for suggestions and troubleshooting
# Buttons 1 and 2 are equivalent (and what the subject should press if s/he thinks the test is a nonword)
# Buttons 3 and 4 are equivalent (and what the subject should press if s/he thinks the test is a true word)

source /usr/local/tools/REF/PROFILES/plante_profile.sh

if [ $# -lt 2 ]
then
    echo "Usage: $0 <input file> <run>"
    echo "Example: $0 test.txt 1"
    echo "This massages text from an eprime file generated by the plante imaging experiment"
    echo ""  
    exit 1
fi

file=${1}
echo "$file"
echo "$MR_NUM"
RUN=$2

# get the base name of the file without the txt extension
name=`basename ${file} .txt`
# The eprime on the new scanner PC produces text files in UTF16.  This breaks everything. iconv can do the conversion
# back to a standard text format that sed likes.
iconv -f UTF-16 -t ISO-8859-1 ${EPRIME}/${file} >${EPRIME}/${file}.conv
# This is crucial, as the windows line returns broke paste in horrible ways
# The dos2unix tool is part of the fink distribution, but you have to go get it.
# Thanks Tom ; )
dos2unix ${EPRIME}/${file}.conv
# Extract just the rows of interest.  By using the -e the sed commands are all executed together, so we retain the line ordering of the file
cat ${EPRIME}/${file}.conv | sed -n -e '/SoundFile/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP/p' | tr -d '\t' >> temp
# Create access file and echo the column title into it.
touch ${STATS}/access_${name}.txt
echo "SubjectNum RunNum TestItem RT Resp" > ${STATS}/access_${name}.txt
# Add a clean list of the sound files, swap _ for spaces in wav file names.  Remove .wav from the filename.
cat temp | sed -n -e 's/SoundFile: test items//p' | colrm 1 3 | sed 's/ /_/g' | sed 's/.wav//g' >> soundfile
awk '{print "sb " "rn " $1}' soundfile  >>soundfile2
rm soundfile
cat soundfile2 | sed -e "s/sb/${SUBJECT}/g" -e "s/rn/${RUN}/g" >> soundfile
# Get lines containing RT (or Target.RESP) and save the 2nd field
cat temp | grep RT | awk '{print $2}' >> rt
cat temp | grep Target.RESP | awk '{print $2}' >> resp
# Paste the fields I want in contiguous space separated columns
paste -d" " soundfile rt resp >> ${STATS}/access_${name}.txt
rm soundfile soundfile2 resp rt temp   
$mylog
