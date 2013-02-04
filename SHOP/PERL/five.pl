#!/bin/perl
#================================================================================
#   Program Name: five.pl
#         Author: Kyle Reese Almryde
#           Date: 
#
#    Description: Count the number of 5 letter words in a file
#                 
#                 
#
#   Deficiencies: 
#                 
#================================================================================
#                               START OF MAIN
#================================================================================

use feature ':5.10';


while (<>) {
	chop;
	tr/;:,.!?-//d;    # This deletes punctuation marks - we dont want them to count towards determining word length
					  # its basically stating anything of the following ";:,.!?-" should be removed, the /d means delete (I think)
	foreach $w (split) {
		if (length($w)==5) {   # if statement that says if the length of the word is equal to 5, print it, and count the sum in $score
			print "$w\n";
			$score++;
		}
	}
}

print "\n$score 5-letter words in this file\n\n";