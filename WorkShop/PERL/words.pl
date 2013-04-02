#!/bin/perl
#================================================================================
#   Program Name: words.pl
#         Author: Kyle Reese Almryde
#           Date: 
#
#    Description: Execute this program via the command-line like so:
#                 perl words.pl <file.txt>
#                 This program counts the number of words in a file.
#
#   Deficiencies: 
#                 
#================================================================================
#                               START OF MAIN
#================================================================================

use feature ':5.10';

while (<>) {
	chop; 				 # Removes the final character from the file, always does this regardless of char type; chomp is often better
						 # because it removes just the final newline char
	foreach $w (split) { # $w represents an orthographic word, its a reserved perl variable. Neat! Split splits strings to words, nothing new there.
		$words++;	     # This is a counter that stores the number of words it encounters. Since its being used as an integer, its typed that way.
					 	 # apparently it doesnt need to be declared before hand either, and automatically starts at 0. Neat!
		$charsnums=length($w);
		$chars += $charsnums;

	}
}
$mean=$words/$.;         # Divide the number of words by the number of lines in the file. A note about variables, you must append the $ to the name
$meanChars=$chars/$words;						 # during assignment, this tells perl what type of variable your using right off the bat. Think spanish. Neat!
print "\n$words words in this file\n"; # Prints how many words were in the file. 
print "The mean words per line is $mean\n\n";
print "The mean chars per word is $meanChars\n\n";