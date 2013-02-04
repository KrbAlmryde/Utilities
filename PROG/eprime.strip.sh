################################################################################
. $PROFILE/${1}_profile.sh
################################################################################
cd ${BEHAV_dir}
################################################################################
echo "------------------------ eprime.strip -----------------------------"
echo "-------------------------- ${subrun} -----------------------------"
echo "The objective of this program is to construct the LONG file "
echo ""
#set -n
################################################################################
# Extract just the rows of interest. By using the -e the sed commands are all executed together,
# so we retain the line ordering of the file
################################################################################
cat etc/${subj}-${run}.txt | sed -n -e '/Target:/p' -e '/WordType:/p' \
	-e '/SpeakerGender:/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP:/p' \
	-e '/CorrectAnswer:/p' | tr -d '\t' 	> tmp.${subrun}

################################################################################
# Long file header and echo the column titles into it. Because we are creating
# a group code, we do not need to distinguish between speaker and word
################################################################################
echo "Subject Run SoundFile Timing Group RT RESP ACC" > header
echo "Subject,Run,SoundFile,Timing,Group,RT,RESP,ACC" > header.long
################################################################################
# Extract the relevant information from the eprime file. In this case we want
# The Target, Wordtype, SpeakerGender, RT, CorrectAnswer, and SlideTarget.Resp
# information. These will become their own individual files, which we will work
# with throughout the construction of the long file. 
################################################################################
cat tmp.${subrun} | sed -n 's/Target: //p' | awk '{print $1}' \
														>> soundfile.${subrun}
cat tmp.${subrun} | grep WordType | awk '{print $2}' >> tmp.wordtype.${subrun}
cat tmp.${subrun} | grep SpeakerGender | awk '{print $2}' \
												>> tmp.speakergender.${subrun}
# this is to act as a place holder for the timing files, since we already have
# that information, I dont need to rebuild that file here. 
cat tmp.${subrun} | grep RT | awk '{print $2}' >> rt.${subrun}
cat tmp.${subrun} | grep CorrectAnswer | awk '{print $2}' >> tmp.cresp.${subrun}
cat tmp.${subrun} | grep SlideTarget.RESP | awk '{print $2}' \
														>> tmp.resp.${subrun}

################################################################################
# make a file called subjects.file that contains a list of the subject's number
# repeated down a colum 150 times, then 
################################################################################
for (( i = 1; i < 151; i++ )); do
	echo "${subj}" >> subject.${subrun}
	echo "${run}" >> run.${subrun}
done

################################################################################
# Need to replace any blanks with a 0 in the tmp.resp.file, then rename it, and 
#get rid of the tmp.resp.file
# Also, for subjects TS003 and TS006, we need to replace the 1 with a 2, and the
# 4 with a 3
################################################################################

if [ "${subj}" = "TS003" ]; then
	cat tmp.resp.${subrun} | sed -e 's/$/ 0/' -e 's/1/2/g' -e 's/4/3/g' | \
											awk '{print $1}' >> resp.${subrun}
elif [ "${subj}" = "TS006" ]; then
	cat tmp.resp.${subrun} | sed -e 's/$/ 0/' -e 's/1/2/g' -e 's/4/3/g' | \
	awk '{print $1}' >> resp.${subrun}

else
	cat tmp.resp.${subrun} | sed 's/$/ 0/' | awk '{print $1}' >> resp.${subrun}
fi

#rm tmp.resp.${subrun}

################################################################################
# Need to combine the wordtype and speakergender to form the group code Am, Fa
# etc for the corresponding runs. This will be used later when I start running
# the stats and buiding the response files. Then we will remove the wordtype and
# speakergender files
################################################################################
if [ "${run}" = "TP1" ]; then
	cat tmp.wordtype.${subrun} >> grp.${subrun}

elif [ "${run}" = "SP1" ]; then
	paste -d" " tmp.wordtype.${subrun} tmp.speakergender.${subrun} \
															>> tmp.grp.${subrun} 

	cat tmp.grp.${subrun} | sed -e 's/A male/Am/g' -e 's/A female/Af/g' \
					-e 's/F male/Fm/g' -e 's/F female/Ff/g' >> grp.${subrun}
else
	paste -d" " tmp.wordtype.${subrun} tmp.speakergender.${subrun} \
															>> tmp.grp.${subrun} 
	
	cat tmp.grp.${subrun} | sed -e 's/A male/aM/g' -e 's/A female/aF/g' \
					-e 's/F male/fM/g' -e 's/F female/fF/g' >> grp.${subrun}
fi

#rm tmp.wordtype.${subrun} tmp.speakergender.${subrun} tmp.grp.${subrun}

################################################################################
# Some of the subject files had the target-response switched between the 
# targets, resulting in a higher than normal rate of errors at no fault of the 
# subjects (or is it...). This block of code corrects that problem. Here is a 
# step by step explainaition of what the code is doing
#
#  First: Using paste, combine the speakergender.file and the cresp.file,
#         creating the voice.cresp.file
# Second: Using SED change the correct response for Male from 2 to 3, and the
#         correct response for Female from 3 to 2, print those changes to a file 
#         named voice.cresp.fix.file
# Third:  Using CAT and AWK, print $1 (Speakergender) to speakergender.tmp.file
#		  then print $2 (CRESP) to cresp.tmp.file
#Fourth: Move speakergender.tmp.file to speakergender.file, overwriting the 
#        original. The same is done for the cresp.tmp.file ==> cresp.file
################################################################################
if [ "${run}" = "SP2" ]; then 
	
	if [ "$subj" = "TS001" -o  "$subj" = "TS002" -o  "$subj" = "TS014" ];then
		mv tmp.cresp.${subrun} cresp.${subrun}
		
	else
		cat tmp.cresp.${subrun} |  sed -e 's/3/5/g' -e 's/2/6/g' | \
							sed -e 's/5/2/g' -e 's/6/3/g' > cresp.${subrun}
	fi
	
elif [ "${run}" = "TP2" ]; then
	
	if [ "$subj" = "TS001" -o "$subj" = "TS002" -o "$subj" = "TS005" -o\
		"$subj" = "TS006" -o "$subj" = "TS007" -o "$subj" = "TS014" ];then
		mv tmp.cresp.${subrun} cresp.${subrun}
	else
		cat tmp.cresp.${subrun} |  sed -e 's/3/5/g' -e 's/2/6/g' | \
								sed -e 's/5/2/g' -e 's/6/3/g' > cresp.${subrun}
	fi
	
else
	mv tmp.cresp.${subrun} cresp.${subrun}

fi

#rm tmp.cresp.${subrun}

################################################################################
# Compare the contents of field $1 to $3, if they are equal, print a 
# value of 1 in field $3 if they are different, print a value of 0 in 
# filed $3, name the file acc.file, then remove the tmp.resp.cresp and cresp 
# files. 
################################################################################
paste -d" " resp.${subrun} cresp.${subrun} >> tmp.resp.cresp.${subrun}

cat tmp.resp.cresp.${subrun} | awk '{ if( $1==$2){ print $3=1}; if($1 != $2){print $3=0}}' >> acc.${subrun}

#rm tmp.resp.cresp.${subrun} cresp.${subrun}

################################################################################
# Paste the fields I want in contiguous space separated columns, Then utilize 
#grep to remove the null conditions from the report.
################################################################################
if [ "${run}" = "TP1" ]; then

	paste -d" " subject.${subrun} run.${subrun} soundfile.${subrun} \
		etc/timing.txt grp.${subrun} rt.${subrun} resp.${subrun} acc.${subrun} \
		| grep -E '[ON]' >>tmp.report.${subrun}
else
	
	paste -d" " subject.${subrun} run.${subrun} soundfile.${subrun} \
		etc/timing.txt grp.${subrun} rt.${subrun} resp.${subrun} acc.${subrun} \
		| grep -E '[aAfF][mMfF]' >>tmp.report.${subrun}
fi	

################################################################################
# print the contents of the tmp.report.file to the header.file, then change the 
# delimiter from spaces to tabs to produce the Report.file
################################################################################
cat header tmp.report.${subrun} | awk -v OFS='\t' '$1=$1' \
														>> Report.${subrun}.txt
cat header.long > tmp.long

cat tmp.report.${subrun} >> tmp.long
cat tmp.long | awk -v OFS=',' '$1=$1' >> Long.Report.txt

################################################################################
#rm subject.${subrun} run.${subrun} soundfile.${subrun} grp.${subrun} rt.${subrun} resp.${subrun} acc.${subrun} header header.long tmp.${subrun} tmp.${subrun}
