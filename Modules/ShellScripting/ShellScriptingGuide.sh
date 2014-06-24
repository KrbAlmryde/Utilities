#!/bin/bash
#================================================================================
#    Program Name: .sh
#          Author: Kyle Reese Almryde
#            Date: 
#
#     Description: The goal of this guide is to act as a primer for both your
#                  shell scripting AND your AFNI scripting. I will do my best
#                  to demonstrate for you what I consider best practices when
#                  you are writing your own programs, as well as how to perform
#                  common tasks using AFNI that you will likely be performing
#                  again and again. 
#                
#    Deficiencies: I want to be clear that while I have a pretty good idea of 
#                  what I am doing when it comes to scripting and using AFNI
#                  I am by no means an expert. Furthermore, this primer is 
#                  only a GUIDE, not a set of hard and fast rules. At the end
#                  of the day, the onus is on you to make sure you know what
#                  you are doing. When in doubt, use your resources, ASK FOR 
#                  HELP, and read the literature!
#
#================================================================================
#                            TABLE OF CONTENTS
#================================================================================

0) General Tips and Tricks
1) Variables
2) Common Commands
3) 

Loops and Iterations
Logic operations
Functions
Gotchas



#==============================================================================
#                         GENERAL TIPS AND TRICKS
#==============================================================================
# When writing a program or script there are two things that I find to be 
# absolutely CRITICAL in terms of the speed at which I develop as well as the 
# accuracy of the programs that I write. 
#
# 1) Always have a TERMINAL open. Bash is a first and foremost a command-line 
# utility, it was built with the use of the terminal in mind. So USE IT! Cant 
# remember how a particular command works? Test it out in your terminal first. 
#
# 2) Take advantage of a dedicated editor. People that claim you can write code 
# using apple's default text editor are technically correct and technically 
# masochistic. Modern text editors, specifically those geared towards writing 
# code are designed to make writing code easier. Among their most valuable 
# features include Syntax highlighting, code-completion, and a myriad of other 
# features that just make the job easier. I personally recommend Sublime Text 
# http://www.sublimetext.com/ trust me, you will be glad you did.
#
# 3) echo statements (or print statements), echo statements everywhere! A silent
# program is both a deadly one and a bitch to debug. Do yourself a favor and 
# throw in an echo statement 
#
# 4) Use your resources! The World Wide Web is a wonderful thing, and I wouldnt
# have learned as much as I have without it. The following sites have proven
# CRITICAL time and again when I have run into a problem or when I am trying to 
# figure something out. Use them, that is what they are there for!
#     http://www.unix.com/
#     http://stackoverflow.com/
#     http://afni.nimh.nih.gov/afni/community/board/index.php
#
# 5) Practice makes perfect! Rome wasnt built in a day, neither will your 
# coding or AFNI skills. Personally I found I enjoyed scripting and coming up 
# with neat little utilities to make boring and repetitive tasks quicker
#
# 6) Document your code. Document your code. DOCUMENT YOUR CODE!
# Think you will remember what why you named that variable aa next week? Why 
# do you create a folder only to remove it later. What the hell does this 
# command do again?!: 
#
#     clust=$(awk 'match($1,'${plvl}'0000 ) {print $11}' ${ETC}/ClustSim.NN1.1D)
#
# You think you will remember, but I promise, you wont. Always document your 
# code. Both as a courtesy to yourself when 5 months down the line you have to 
# revist your old script and have NO idea what it does, and for the poor fool 
# has to take over after your gone. It will happen to you!!
#
# 7) Use MEANINGFUL variable and function names! Trust me, input3d is a much
# better name than ip3d, or worse v. As a general rule, unless it is absolutely
# crystal clear, the context of the code SCREAMS its meaning, DO NOT use single
# characters as variable names. The only exception to this rule is when you are
# using a counter in a for-loop, or some kind of indexing variable. Even then, 
# make sure it makes sense in context, when in doubt give it a name! You'll 
# thank yourself later that you did.
#
#==============================================================================
#                             VARIABLES
#==============================================================================

aNumber=10  # A number!
fruit="apples"  # a Word

echo "I have $aNumber ${fruit}!"  # evaluate the expression!
echo I have $aNumber $fruit!      # You dont NEED quotes, but they are helpful
echo 'I have $aNumber ${fruit}!'  # What do you notice?

# File paths and variables
aDIR=BootCamp/Examples
bDIR="BootCamp/Examples/scripts"  # Recall, everything is a string
cDIR="${aDIR}/data"              # What does this evaluate to?


#-----------------------------------------------------------------------------
#                           A real world example...
#-----------------------------------------------------------------------------
subj=sub001        # Notice the various levels of quotations
run='run2'          
cond="learnable"    

# I have assigned three variables: subj, run, and cond (short for condition).
# Each variable contains a string. In bash, everything is technically a 
# string, you dont NEED to include the quotation marks around a term. All 
# three variable assignments are valid statements.

#----------------------
# Let make a file name
#----------------------
fName=${subj}_${run}_${cond}.nii  # again, the brackets here arent necessarily needed, but
                                  # they demonstrate good form, and cleaner code which is
                                  # less likely to contain bugs, just do it.

echo $fname  # see how nice variables are? So much less typing!
             # sub001_run2_learnable.nii

fName2=${subj}_${run}_${cond}  # A slight variation on the previous example
echo ${fname2}.nii             # Can you tell the difference?





#==============================================================================
#  Exercise: 
#   
#  
#
#
#==============================================================================


#==============================================================================
#                             VARIABLES
#==============================================================================

for (( number = 0; number < 10; number++ )); do
    echo $i
done

for letter in {a..k}; do   # You can use brace expansions in for loops!
    echo $letter
done

for word in This is a 'for' loop son; do   # why did I put 'for' in quotes?
    echo $word
done



#==============================================================================
#                              Common Commands
#==============================================================================

# Lets make a directory!
mkdir $aDIR

# Now we are going to jump ahead for a moment and introduce some wild concepts
# We will start by making a directory, and introducing a useful flag

mkdir -p $aDIR/{data,docs,utils}   # Oh snap! What did I just do?!

# The '-p' is a "flag" (think option) for mkdir which will, in addition to creating the
# desired directory, will also create any intermediate dirctories as needed.

# The {data, docs, utils}, is what is known as a brace expansion. On its own
# {data, docs, utils} isnt particularly useful, but when you combine it to make
# mkdir -p $aDIR/{data, docs, utils}, suddenly you have a Proejct directory structure!
# The best part is, you can nest brace expansions to get REALLY crazy. For example

mkdir -p $aDIR/{data/{sub00{1..9}/{PREP,GLM},Group/{ANOVA,TTEST,STATS}},docs,utils}

# And just like that, you have an ENTIRE project directory structure, loaded with
# subject folders and all! Your program should create something that looks like this:
# |-- BootCamp
# |   `-- Examples
# |       |-- data
# |       |   |-- Group
# |       |   |   |-- ANOVA
# |       |   |   |-- STATS
# |       |   |   `-- TTEST
# |       |   |-- sub001
# |       |   |   |-- GLM
# |       |   |   `-- PREP
# |       |   |-- sub002
# |       |   |   |-- GLM
# |       |   |   `-- PREP
# |       |   |-- sub003
# |       |   |   |-- GLM
# |       |   |   `-- PREP
#=====================================================================================

# NB: You'll notice I am not terribly consistent with the the '{curly brackets}' around
# variable names. This is because they arent `technically` necessary...They just "protect"
# the variable name. This is especially relevant when you incorporate the variables name
# in another variable, as Ill demonstrate below...










#==============================================================================
#  Exercise: 
#   
#  
#
#
#==============================================================================
