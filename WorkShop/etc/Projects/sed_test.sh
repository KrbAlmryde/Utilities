#!/bin/sh
# Okay, I can delete lines starting with #
# A few other bits that might be useful (not sure yet) are listed below...
# Mostly helping me make sense of sed
# =============

if [ $# -lt 1 ]
then
    echo "Usage: $0 <input file>"
    echo "Example: $0 test.txt"
    echo "This makes all delimiters in a file into single spaces"
    echo ""  
    exit 1
fi

file=$1

# Only keep lines that do not begin with #

# Find lines that begin with #
comments=`grep ^# ${file}`
echo "${comments}"

# remove first line from file
sed '1d' ${file} > temp.txt

# remove lines starting with #
sed '/^#/d' ${file} > temp.txt

# 2 spaces->1 space
sed 's/  / /g' ${file} > temp.txt