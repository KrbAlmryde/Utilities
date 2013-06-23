cut -d , -f 1,8-10 Input.csv > Input.txt
#This will extract the columns of interest, (Subj, Resp, Stim, Rt, Correct).
#The -d option specifices the type of column deliminter, in this case ','
#The -f option lists the columns fields I want to cut, based on my delimiter. It also specifices a
#range, the result is as follows (1=Subj, 8=Stim 9=RT 10=Correct)
sed -e '1d' -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g'
#First it will remove the first row /1d/ replace all instances a space with a '_', then it will #replace all commas (',') with a space (' '), any instance of 'True' will be replaced with '1', and #'False' with '0'. The g flag at the end of the replacement string tells sed	to perform a global #replacement. By using the -e the sed commands are all executed together
awk -v OFS='\t' '$1=$1' > 430vis.txt
#This will turn spaces into tabs, to make it easier to enter into excel
sort
#This last option sorts the entire file alphabetically while maintaining the intergrity of the rest
#of the data


#Now lets put it all together and we have.....
cat 430.csv | cut -d , -f 1,8-10 | sed -e '1d' -e 's/ /_/g' -e 's/,/ /g' -e 's/True/1/g' -e 's/False/0/g' | awk -v OFS='\t' '$1=$1' | sort > 430vis.txt






#cutting room floor as it were. It would be a good idea to start listing my code work throughs on a blog
#I will start doing that from now on
#This will remove remove every instance of the ',' punctuation from the vis.txt
tr -d '\,' > vis3.txt

#This will remove any and all punctuation marks from the file vis.txt, however we dont want that,
#we want to remove every instance of the ',' punctuation from the vis.txt
tr -d '[:punct:]' > vis3.txt



cat vis.txt | cut -d , -f 1,8-10 | sed 's/,/ /g' > vis3.txt
cat vis.txt | cut -d , -f 1,8-10 | tr -d '\,' > vis3.txt
cat vis.txt | cut -d , -f 1,8-10 | tr -d '[:punct:]' > vis3.txt
awk -v "," OFS='\t' '$1=$1' vis2.txt> vis3.txt
