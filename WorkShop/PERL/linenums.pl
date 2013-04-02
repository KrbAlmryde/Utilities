#!/bin/perl
#================================================================================
#   Program Name: linenums.pl
#         Author: Kyle Reese Almryde
#           Date: 
#
#    Description: Demostrate perl's text processing abilities. This program reads
#                 a text file line by line and prints the line number and the 
#                 corresponding line. It uses a while loop to do this. 
#
#   Deficiencies: 
#                 
#================================================================================
#                               START OF MAIN
#================================================================================

use feature ':5.10';



while (<>) {      # The <> reads a single line from a file supplied via the command-line. 
				  # The while loop condition states that as long as there is a line to read, keep looping. 
	$size=length($_);
	tr/A-Z/a-z/;		 # tr replaces the first /SET/ with the second /set/, in this capital letters to lowercase.
						 # The reverse could be applied simply by doing the following tr/a-z/A-Z/
	print "$. >> $_";    # The $. is a perl variable which stands for the current line number of the supplied file. 
					     # The $_ is a perl veriable which represents the default input, which is the line itself
}


print "\n\nThere are $. lines in total\n\n";

