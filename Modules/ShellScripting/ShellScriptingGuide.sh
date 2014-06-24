# Variables

aNumber=10  # A number!
fruit="apples"  # a Word

echo "I have $aNumber ${fruit}!"  # evaluate the expression!
echo I have $aNumber $fruit!     # You dont NEED quotes, but they are helpful
echo 'I have $aNumber ${fruit}!'  # What do you notice?

# File paths and variables
aDIR=BootCamp/Examples
bDIR="BootCamp/Examples/scripts"  # Recall, everything is a string
cDIR=${aDIR}/data              # What does this evaluate to?

# Lets make a directory!
mkdir $aDIR

# Now we are going to jump ahead for a moment and introduce some wild concepts
# We will start by making a directory, and introducing a useful flag

mkdir -p $aDIR/{data, docs, utils}   # Oh snap! What did I just do?!

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



