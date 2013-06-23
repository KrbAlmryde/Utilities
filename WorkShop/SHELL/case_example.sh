#! /bin/bash
case "$1" in
"") echo "Usage: ${0##*/} <filename>"; exit $E_PARAM;;
# No command-line parameters,
# or first parameter empty.
# Note that ${0##*/} is ${var##pattern} param substitution.
# Net result is $0.
-*) FILENAME=./$1;; # If filename passed as argument ($1)
#+ starts with a dash,
#+ replace it with ./$1
#+ so further commands don't interpret it
#+ as an option.
* ) FILENAME=$1;; # Otherwise, $1.
esac
