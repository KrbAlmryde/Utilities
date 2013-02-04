format for this project
$study $step		$input1 [$input2]
 TAP	prep_tstat  TS018	SP1

#==========================================
# All function calls need to be defined BEFORE the study functions so that the study functions can access 
# those functions calls.


function prep_despike ()
{
	3dDespike \
		-prefix ${PREP}/${subj}.${run}.despike+orig \
		${PREP}/${subj}.${run}.tshift+orig 
	
	etc ..
	etc...
}

function prep_tcat ()
{
	some code about tcat
	.....
	....
	...
}

build_epan ()
{
	stuff about building epan files
	.....
	....
	...
	..
}


#============
# Study variable calls
# put them at the bottom of the script so the other functions can be declared into the shell
#============

function TAP ()
{
	step=${1}
	input1=${2}
	input2=${3}
			
	TAP=/Volumes/Data/TAP
		
	case $step in
		prep_* )

			if [[ $input1 = "loop" ]]; then
				subj_list=( $( basename  $( ls ${TAP}/TS* ) ) ) # will create an Array of all subjects
				run_list=( SP1 SP2 TP1 TP2 )
				
				for (( s=0, r=0; s<${#subj[*]}; s++, r(iterate once every ${#subj[*]} subjects) ))
					subj=${subj_list}
					run=${run_list}
					
					${step} ${subj} ${run}
					
				done
			
			elif [[ $input2 = TS[::num::] ]]; then
				subj=$input1
				run=$input2
				
				${step} ${subj} ${run}

			else
				echo "something is wrong"
			fi
		;;
		
		regress_* )
				if [[ $input1 = "loop" ]]; then
					subj_list=( $( basename  $( ls ${TAP}/TS* ) ) ) # will create an Array of all subjects
					run_list=( SP1 SP2 TP1 TP2 )
				
					for (( s=0, r=0; s<${#subj[*]}; s++, r(iterate once every ${#subj[*]} subjects) ))
						subj=${subj_list}
						run=${run_list}
						regress_step=${step}
						
						${regress_step} ${subj} ${run}
						
					done
					
				elif [[]] 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	 	   mjknb mj mmbnnnnn 