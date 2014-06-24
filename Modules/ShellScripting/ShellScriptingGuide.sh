# Variables

aNumber=10  # A number!
fruit="apples"  # a Word

echo "I have $aNumber ${fruit}!"  # evaluate the expression!
echo I have $aNumber $fruit!     # You dont NEED quotes, but they are helpful
echo 'I have $aNumber ${fruit}!'  # What do you notice?

# File paths and variables
aDIR=BootCamp/Examples

# Lets make a directory
makdir $aDIR

#=====================================================================================

# NB: You'll notice I am not terribly consistent with the the 'curly brackets' around
# variable names. This is because they arent `technically` necessary...They just "protect"
# the variable name. This is especially relevant when you incorporate the variables name
# in another variable, as Ill demonstrate below...

# A real world example...

subj=sub001
run='run2'
cond="learnable"

# I have assigned three variables: subj, run, and cond (short for condition). Each variable
# contains a string. In bash, everything is technically a string, you dont NEED to include
# the quotation marks around a term. All three variable assignments are valid statements.

# Let make a file name
fName=${subj}_${run}_${cond}.nii  # again, the brackets here arent necessarily needed, but
                                  # they demonstrate good form, and cleaner code which is
                                  # less likely to contain bugs, just do it.

echo $fname  # see how nice variables are? So much less typing!
             # sub001_run2_learnable.nii



