# example of a very simple Python script
# you can run this from inside TextPad: http://www.atug.com/andypatterns/textpad_and_python.htm
# you first need to install Python for Windows of course: http://www.python.org/
# for Python reference and help: http://safari.oreilly.com/JVXSL.asp




# this imports useful Python libraries
import re,os,sys,string,time

top_dir = 'y:/best_study_ever/analysis/'

subjects_list = [1,2,3,4,5,12,234]
[batch_file_list] = ['prestats','stats','poststats']

for subject in subjects_list:
    # this appends the text 'subjectN' to the top directory, formating the subject number N to have leading 0s
    subject_dir = top_dir+'subject%003d'%subject

    # change to subject directory
    os.chdir(subject_dir)

    # now run all three batch files
    for batch_file in batch_file_list:
        batch_file_name = batch_file+'.bat'
        # run the batch file
        os.system(batch_file_name)