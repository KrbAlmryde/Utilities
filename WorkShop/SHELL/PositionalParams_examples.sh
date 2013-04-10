#!/bin/bash

function commandline_test ()
{
	pos1=$1
	pos2=$2

	if [[ -z $pos1 && -z $pos2 ]]; then
		echo -n "No argurment, what is pos1?: "
		read pos1
		
		echo -n "No argurment, what is pos2?: "
		read pos2
		
	elif [[ -z $pos1 ]]; then
		echo -n "No argurment, what is pos1?: "
		read pos1
	elif [[ -z $pos2 ]]; then
		echo -n "No argurment, what is pos2?: "
		read pos2
	fi
	
	echo "pos1 = $pos1 "
	echo "pos2 = $pos2 "
}


function arg_checker ()
{
	echo "======================================================================"
	echo "Your now inside the arg_checker function..., we are goig to test"
	echo "If we can get the commandline_test functions to work right. ";
	commandline_test $1 $2
	
	
}


#======================================================================
#======================================================================

echo "Now we are testing the arg_checker function, lets try to get inside it"
echo "Round 1: No parameters...."
arg_checker


echo; echo "Round 2: Parameters supplied arg_checker... (Hello, World)"
arg_checker Hello World

echo; echo "Round 3: Commandline Parameters supplied to `basename $0` (Funky Monkey) "
arg_checker $1 $2


exit


The execution of this script is interesting, I can supply commandline
arguments via the script itself, OR I can supply function-line arguments
within the script. Either one will be passed to the function and treated
the same. Very cool....very cool indeed.




bash PositionalParams_examples.bash Funky Monkey
$1=Funky
$2=Monkey


