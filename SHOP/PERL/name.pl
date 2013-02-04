#!/bin/perl
#================================================================================
#   Program Name: name.pl
#         Author: Kyle Reese Almryde
#           Date: September 12th, 2012
#
#    Description: A simple perl script to demostrate its functionality. It will
#                 ask the user for their name, and output the results to the 
#                 terminal
#
#   Deficiencies: 
#                 
#================================================================================
#                               START OF MAIN
#================================================================================

use feature ':5.10';


print "Type your name and press return: ";
$name = <STDIN>;

chomp($name);
$size=length($name);


say "Hello, $name!";
say "Your name contains $size letters.";

print "\nWhich Country you are from: ";
$country = <STDIN>;
chomp($country);

say "Good, I like people from $country";