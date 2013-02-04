a=$1

case $a in
	[0-9] | 1[01] )
		echo "the first option worked"
		;;
	1[2-5] )
		echo "the second option worked"
		;;
	* )
		echo "nothin worked"
		;;
esac



<<WORKS
function conditions ()
{
	case ${run[$j]} in
		r1 ) cond=( A B )
			;;
		r2 ) cond=( C D )
		;;
		r3 ) cond=( E F G )
		;;
		r4 ) cond=( H )
		;;
	esac
}


function echo_stuff ()
{
	echo $subj.$run
}



while read subj; do
	echo ===================
	echo This is subject ${subj}
	echo ===================

	while read run; do
		conditions
		echo_stuff
	done <$LST/lst_run_tap.txt
done <$LST/lst_subj_tap.txt




for (( i = 0; i < ${#sub[@]}; i++ )); do
	
	echo ===================
	echo This is subject ${sub[$i]}
	echo ===================
	
	for (( j = 0; j < ${#run[@]}; j++ )); do
		
		conditions
					
		for (( k = 0; k < ${#cond[@]}; k++ )); do		
		
			echo ${sub[$i]}.${run[$j]}.${cond[$k]}
			
		done
	done
done	

W



<<A


case ${run[$j]} in
	r1 ) cond=( A B )
		;;
	r2 ) cond=( C D )
	;;
	r3 ) cond=( E F G )
	;;
	r4 ) cond=( H )
	;;
esac

		echo ${sub[$i]}.${run[$j]}.${cond[$k]}

		if [[ $i = ${#sub[@]} ]]; then 
			((j++)); i=0; 
			echo

		elif [[ $j = ${#run[@]} ]]; then 
			((k++)); j=0; 
			echo

		elif [[ $k = ${#cond[@]} ]]; then 
			((l++)); k=0
			echo

		elif [[ $l = ${#contr[@]} ]]; then
			break

		fi
done
A

<<LOOPS
echo "\
#=================================================================================
# For Loops with Arrays
#=================================================================================
"
sub=( 01 02 03 04 05 06 07 08 09 10 11 12 13 14 )
run=( A B C D )

echo "${sub[$i]}.${run[$j]}, no subrun" 
echo =============================================
for (( i = 0; i < ${#sub[@]}; i++ )); do
	for (( j = 0; j < ${#run[@]}; j++ )); do
		echo ${sub[$i]}.${run[$j]}
	done
done
echo "Loop1 complete"; echo





echo "'${sub[$i]}.${run[$j]}' 'subrun' defined before loop"
subrun=${sub[$i]}.${run[$j]}
echo =============================================
for (( i = 0; i < ${#sub[@]}; i++ )); do
	for (( j = 0; j < ${#run[@]}; j++ )); do
		echo $subrun
	done
done
echo "Loop2 complete"; echo



echo "${sub[$i]}.${run[$j]}, 'subrun' defined inside loop"
echo =============================================
for (( i = 0; i < ${#sub[@]}; i++ )); do
	for (( j = 0; j < ${#run[@]}; j++ )); do
		subrun=${sub[$i]}.${run[$j]}
		echo $subrun
	done
done

echo "\
#=================================================================================
# While Loops with Arrays
#=================================================================================
"
sub=( 01 02 03 04 05 06 07 08 09 10 11 12 13 14 )
run=( A B C D )
i=0; j=0


echo "${sub[$i]}.${run[$j]}, no subrun" 
echo =============================================
while [[ $i < ${#sub[@]} ]]; do
	while [[ $j < ${#run[@]} ]]; do
		echo ${sub[$i]}.${run[$j]}
		((i++)); ((j++))
	done
done

i=0; j=0
echo "${sub[$i]}.${run[$j]}, 'subrun' defined inside loop"
echo =============================================
while [[ $i < ${#sub[@]} ]]; do
	while [[ $j < ${#run[@]} ]]; do
		subrun=${sub[$i]}.${run[$j]}
		echo $subrun
		((i++)); ((j++))
	done
done

i=0; j=0
echo "'${sub[$i]}.${run[$j]}' 'subrun' defined before loop"
subrun=${sub[$i]}.${run[$j]}
echo =============================================
while [[ $i < ${#sub[@]} ]]; do
	while [[ $j < ${#run[@]} ]]; do
		echo $subrun
		((i++)); ((j++))
	done
done

echo "\
#=================================================================================
# UNTIL Loops with Arrays
#=================================================================================
"
sub=( 1 2 3 4 5 6 7 8 9 10 )
run=( r1 r2 r3 r4 )
cond=( A B C D )
contr=( ${cond[0]}.vs.${cond[1]} ${cond[1]}.vs.${cond[0]} ${cond[2]}.vs.${cond[3]} ${cond[3]}.vs.${cond[2]} )
i=0
j=0
k=0
l=0

until [[ $l = ${#contr[@]} ]]; do 
	subcond=${sub[$i]}.${run[$j]}.${cond[$k]}
	subcontr=${sub[$i]}.${run[$j]}.${contr[$l]}
	echo $subcond
	echo $subcontr
	((i++)) 

	if [[ $i = ${#sub[@]} ]]; then 
		((j++)); i=0; 
		echo
	
	elif [[ $j = ${#run[@]} ]]; then 
		((k++)); j=0; 
		echo

	elif [[ $k = ${#cond[@]} ]]; then 
		((l++)); k=0
		echo

	elif [[ $l = ${#contr[@]} ]]; then
		break

	fi

done
LOOPS
