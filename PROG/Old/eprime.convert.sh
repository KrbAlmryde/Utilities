####################################################################################################
. $PROFILE/${1}_profile
####################################################################################################
cd ${BEHAV_dir}/etc
###################################################################################################
# Written by Kyle Almryde 1/21/2012
# Thanks to Tom Hicks and Dianne Patterson for suggestions and troubleshooting.
# Buttons 1 and 2 are equivalent (and what the subject should press if s/he thinks the test is a 
# nonword). Buttons 3 and 4 are equivalent (and what the subject should press if s/he thinks the 
# test is a true word)
####################################################################################################
echo "-------------------------------- eprime.convert.sh ----------------------------------"
echo "-------------------------------- ${subrun} --------------------------------"
echo ""

####################################################################################################
# The eprime on the new scanner PC produces text files in UTF16.  This breaks everything. iconv can 
# do the conversion back to a standard text format that sed likes.
####################################################################################################
echo "iconv -f UTF-16 -t ISO-8859-1 ${subj}-${run}.txt > iconv.iso.${subrun}.txt"
#iconv -f UTF-16 -t ISO-8859-1 ${subj}-${run}.txt > iconv.iso.${subrun}.txt
####################################################################################################
# This is crucial, as the windows line returns broke paste in horrible ways
# The dos2unix tool is part of the fink distribution, but you have to go get it.
# Thanks Tom ; )
####################################################################################################
echo "dos2unix iconv.iso.${subrun}.txt"
#dos2unix iconv.iso.${subrun}.txt
####################################################################################################
# To make sure we never encounter this horrible problem ever again, we are going to replace the
# Original file all together, and mv the iconv.iso.file-name to the original name (so none are the
# wiser ;-)
####################################################################################################
echo "rm ${subj}-${run}.txt; mv iconv.iso.${subrun}.txt ${subj}-${run}.txt"
#rm ${subj}-${run}.txt; mv iconv.iso.${subrun}.txt ${subj}-${run}.txt
####################################################################################################


	


	


echo "striping file"
cat ${subj}-${run}.txt | sed -n -e '/Target:/p' -e '/WordType:/p' -e '/SpeakerGender:/p' -e '/SlideTarget.RT:/p' -e '/SlideTarget.RESP:/p' -e '/CorrectAnswer:/p' | tr -d '\t' > tmp.${subj}.${run}
echo "Timing SoundFile WordType SpeakerGender RT CRESP RESP ACC" > header.${subj}.${run}


echo "making pieces"
cat tmp.${subj}.${run} | grep RT | awk '{print $2}' >> rt.${subj}.${run}
cat tmp.${subj}.${run} | grep SpeakerGender | awk '{print $2}' >> speakergender.${subj}.${run}
cat tmp.${subj}.${run} | sed -n 's/Target: //p' | awk '{print $1}' >> soundfile.${subj}.${run}
cat tmp.${subj}.${run} | grep CorrectAnswer | awk '{print $2}' >> cresp.${subj}.${run}
cat tmp.${subj}.${run} | grep WordType | awk '{print $2}' >> tmp.wordtype.${subj}.${run}
cat tmp.${subj}.${run} | grep SlideTarget.RESP | awk '{print $2}' >> tmp.resp.${subj}.${run}
cat tmp.resp.${subj}.${run} | sed 's/$/ 0/' | awk '{print $1}' >> resp.${subj}.${run}



#rm tmp.resp.${subj}.${run}
cat tmp.wordtype.${subj}.${run} | sed -e "s/A/Animal/g" -e "s/F/Food/g" >> wordtype.${subj}.${run}
echo "pasting pieces"
paste -d" " speakergender.${subj}.${run} cresp.${subj}.${run} >> tmp.voice.cresp.${subj}.${run}
echo "fixing mistakes"
cat tmp.voice.cresp.${subj}.${run} | sed -e 's/male 2/male 3/g' -e 's/female 3/female 2/g' >> voice.cresp.fix.${subj}.${run}
cat voice.cresp.fix.${subj}.${run} | awk '{print $1}' >> tmp.speakergender.${subj}.${run}
cat voice.cresp.fix.${subj}.${run} | awk '{print $2}' >> tmp.cresp.${subj}.${run}





mv tmp.speakergender.${subj}.${run} speakergender.${subj}.${run}
mv tmp.cresp.${subj}.${run} cresp.${subj}.${run}


rm tmp.speakergender.${subj}.${run} tmp.cresp.${subj}.${run}
paste -d" " resp.${subj}.${run} cresp.${subj}.${run} >> tmp.resp.cresp.${subj}.${run}
cat tmp.resp.cresp.${subj}.${run} | awk '{ if( $1==$2){ print $3=1}; if($1 != $2){print $3=0}}' >> acc.${subj}.${run}
echo "SpeakerGender RESP CRESP ACC" >> acc.header.${subj}.${run}

paste -d" " speakergender.${subj}.${run} resp.${subj}.${run} cresp.${subj}.${run} acc.${subj}.${run} >> tmp.acc.header.${subj}.${run}
grep male tmp.acc.header.${subj}.${run} >> acc.header.${subj}.${run}
cat acc.header.${subj}.${run} | awk -v OFS='\t' '$1=$1' >> ACC.Report.${subj}.${run}.txt
paste -d" " etc/timing.txt soundfile.${subj}.${run} wordtype.${subj}.${run} speakergender.${subj}.${run} rt.${subj}.${run} cresp.${subj}.${run} resp.${subj}.${run} acc.${subj}.${run} >> tmp.report.${subj}.${run}
grep male tmp.report.${subj}.${run} >> tmp.report2.${subj}.${run}
cat tmp.report2.${subj}.${run} >> header.${subj}.${run}
cat header.${subj}.${run} | awk -v OFS='\t' '$1=$1' >> Report.${subj}.${run}.txt


