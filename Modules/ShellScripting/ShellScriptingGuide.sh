#!/bin/bash
#================================================================================
#    Program Name: ShellScriptingGuide.sh
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
#           Notes: I want to be clear that while I have a pretty good idea of 
#                  what I am doing when it comes to scripting and using AFNI
#                  I am by no means an expert. Furthermore, this primer is 
#                  only a GUIDE, not a set of hard and fast rules. At the end
#                  of the day, the onus is on you to make sure you know what
#                  you are doing. When in doubt, use your resources, ASK FOR 
#                  HELP, and read the literature!
#
#                  I STRONGLY recommend you give the "Advanced Bash Scripting- 
#                  Guide" a solid look through. Many of the tips and tricks I 
#                  demonstrate in this guide and in my own code were inspired 
#                  after reading that guide and are explained in greater 
#                  detail and with fantastic examples. To that end I would also
#                  encourage you to really take the time to DO THE EXAMPLES!
#                
#       Last Word: At the time of this writing Bash is up to version 4.3, 
#                  however Apple (Mac OS) only ships Bash version 3.2, which 
#                  is what your shell uses by default. Dont upgrade unless the
#                  whole lab upgrades, otherwise you risk breaking code and 
#                  causing a whole bunch of headache because your program uses
#                  associative arrays and none of the lab computers support 
#                  them.
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
# When writing a program or script there are several things that I find to be 
# absolutely CRITICAL in terms of the speed at which I develop as well as the 
# accuracy of the programs that I write. 
#
# 1) Always have a TERMINAL open. Bash is first and foremost a command-line 
# utility, it was built with the use of the terminal in mind. So USE IT! Cant 
# remember how a particular command works? Test it out in your terminal first. 
#
# 2) Take advantage of a dedicated editor. People that claim you can write code 
# using apple's default text editor are technically correct and technically 
# masochistic. Modern text editors, specifically those geared towards writing 
# code are designed to make writing code easier. Among their most valuable 
# features include Syntax highlighting, code-completion, and a myriad of other 
# features that just make the job easier. I personally recommend Sublime Text 
# http://www.sublimetext.com trust me, you will be glad you did.
#
# 3) echo statements (or print statements), echo statements everywhere! A silent
# program is both a deadly one and a bitch to debug. Do yourself a favor and 
# throw in an echo statement or three
#
# 4) Use your resources! The World Wide Web is a wonderful thing, and I wouldnt
# have learned as much as I have without it. The following sites have proven
# CRITICAL time and again when I have run into a problem or when I am trying to 
# figure something out. Use them, that is what they are there for!
#     http://www.unix.com/
#     http://stackoverflow.com/
#     http://afni.nimh.nih.gov/afni/community/board/index.php
#
# 5) Practice makes perfect! Rome wasn't built in a day, neither will your 
# coding or AFNI skills. Personally I found I enjoyed scripting and coming up 
# with neat little utilities to make boring and repetitive tasks quicker and
# easier. WWhich frees up your time to do more interesting tasks.
#
# 6) Document your code. Document your code. DOCUMENT YOUR CODE!
# Think you will remember why you named that variable 'aa' next week? Why 
# do you create a folder only to remove it later. What the hell does this 
# command do again?!: 
#
#     clust=$(awk 'match($1,'${plvl}'0000 ) {print $11}' ${ETC}/ClustSim.NN1.1D)
#
# You think you will remember, but I promise, you wont. Always document your 
# code. Both as a courtesy to yourself when 5 months down the line you have to 
# revisit your old script and have NO idea what it does, and for the poor fool 
# who has to take over after you're gone. It will happen to you!!
#
# 7) Use MEANINGFUL variable and function names! Trust me, 'input3d' is a much
# better name than 'ip3d', or worse 'v'. As a general rule, unless it is 
# absolutely crystal clear, the context of the code SCREAMS its meaning, DO 
# NOT use single characters as variable names. The only exception to this rule 
# is when you are using a counter in a for-loop, or some kind of indexing 
# variable. Even then, make sure it makes sense in context, when in doubt 
# give it a name! You'll thank yourself later that you did.
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


#---------------------------
#   A real world example...
#---------------------------
subj=sub001        # Notice the various levels of quotations
run='run2'          
cond="learnable"    

# I have assigned three variables: subj, run, and cond (short for condition).
# Each variable contains a string. In bash, everything is technically a 
# string, you dont NEED to include the quotation marks around a term. All 
# three variable assignments are valid statements.


# Let make a file name
fName=${subj}_${run}_${cond}.nii  # again, the brackets here arent necessarily needed, but
                                  # they demonstrate good form, and cleaner code which is
                                  # less likely to contain bugs, just do it.

echo $fname  # see how nice variables are? So much less typing!
             # sub001_run2_learnable.nii

fName2=${subj}_${run}_${cond}  # A slight variation on the previous example
echo ${fname2}.nii             # Can you tell the difference?

#==============================================================================
#                      Arrays: Advanced Variables
#==============================================================================
# Arrays are powerful tools which allow one to store lots of data in a nicely
# wrapped up package. As you look through my old scripts and code you will 
# see frequent use of Arrays. 

# You can declare arrays in a number of ways, the first by using 'declare -a' 
declare -a groceryList  # However this isn't required

# to populate the array you can assign a value to each index
groceryList[0]="oranges"       # remember, wrapping strings in quotes isnt
groceryList[1]=rice            # necessary, but its good practice
groceryList[2]="beans" 
groceryList[3]='steak'         # If you're not using variables, single quotes
groceryList[4]='beer'          # work just fine. 
groceryList[5]=lime
groceryList[6]=$fruit          # There is nothing stopping you from adding 
                               # variables to your array

# You can also declare and initialize an array like this as well (I prefer this)
groceryList=( oranges rice beans steak beer lime $fruit ) # This is fine too

#------------------
# Indexing Arrays 
#------------------
# To access elements in the array, you give it the index of the element you 
# want

echo ${groceryList[0]}  # Gives us "oranges"
echo ${groceryList[1]}  # Gives us "rice"
echo ${groceryList[6]}  # Gives us "apples", It evaluates variables too!

# Arrays in Bash (and most programming languages for that matter) are Zero-based
# That is, the first element in the array is accessed by the value 0, the next
# element is accessed by 1, the third by 2, and so on

echo $groceryList     # Gives us "oranges", if no index is given, defaults to 
                      # 0th element
echo ${groceryList}   # Same thing

echo $groceryList[1]  # What happens?

# To see all the elements in the array at once, try the following
echo ${groceryList[*]} # oranges rice beans steak beer lime apples
echo ${groceryList[@]} # This also works too


# To determine the length of the array,e.g. or how many elements it contains,  
# append the '#' to the front of the name, like so:
echo ${#groceryList[*]}  # 7 elements

# However, dont be fooled into doing something like this
echo ${groceryList[7]}  # "" no element at index 7!! Remember we are Zero-based

# However, this works!
echo ${groceryList[7-1]}

echo ${groceryList[${#groceryList[*]}-1]}  # Even this mess is legal! I 
                                           # would avoid doing this however
#------------------
# Modifying Arrays 
#------------------
# Say we want to add 'mustard' to our grocery list, well thats easy:
groceryList[7]="mustard"
echo ${#groceryList[*]}  # 8 elements
echo ${groceryList[*]} # oranges rice beans steak beer lime apples mustard
echo ${groceryList[7]}  # 'mustard'

# We can just as easily replace an element of the array by doing this:
groceryList[7]='relish'
echo ${groceryList[7]}  # 'relish'

#----------------------
# FYI
#----------------------
# Unfortunately you cannot create multidimensional arrays, that is, arrays 
# within arrays. It is not supported and isnt really necessary anyway. 

#-----------------------------------------------------------------------------
#                 Some gotchas and advanced bash functionality
#-----------------------------------------------------------------------------
# Before I demonstrated how you could get the length of your array, its worth
# mentioning that the syntax for evaluating the length of your array works 
# the same when determining the length of a String! Observe...

echo ${#groceryList}  # Gives us 7?! 

# recall that evaluating the array without an index results in the 0th element
# In this case, our 0th element is 'oranges'
echo ${groceryList}  # oranges

# Guess how many characters are in the word 'oranges'. If you guessed 7, Bingo!
# you guessed right (If you guessed something else, stop reading and go home)


#==============================================================================
#                           STRING MANIPULATION
#==============================================================================
# Bash offers a surprising number of string manipulation operation. However 
# these tools tend to lack a unified focus and the syntax gets muddled between
# different types of manipulations making them confusing and their functions
# inconsistent. That being said I am presenting them here so you know how to 
# do them so you know NOT to do them. 

# Lets start by making a variable containing the string "Happy Birthday!" 
aString="Happy Birthday!"

#----------------------
# String Length
#----------------------
echo ${#aString}

#==============================================================================
#                           BRACE EXPANSIONS
#==============================================================================





#==============================================================================
#                        LOOPS: While, For, and Until
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
#                      LOGIC OPERATORS: If, Test, and Case
#==============================================================================


#==============================================================================
#  Exercise: 
#   
#  
#
#
#==============================================================================



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
#                              Crazy Examples
#==============================================================================

mv ${files[16]} $(echo ${files[16]} | cut -d '.' -f1).tcsh








#==============================================================================
#  Exercise: 
#   
#  
#
#
#==============================================================================
