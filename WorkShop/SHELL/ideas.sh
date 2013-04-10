[hagar:TAP]$ study_functions.bash
[hagar:TAP]$ tap 'prep 'tcat ts1 sp1''
[hagar:TAP]$ tap 'prepl sp1'
 
		function tap($1) ()
		{
			echo 'tap functions'
			
			local declare -f prep
			local declare -f regress
			local declare -f anova
			local declare -f analysis
			
			function prep ()
			{
				echo 'prep function'
				
				local declare -f tcat
				local declare -f despike
				
				function tcat ()
				{ 
					echo 'tcat function!'
				}
				
				function despike ()
				{
					echo 'despike function'
				}
			}
			
			
			function regress
			{
				echo 'regress function'
				
				local declare -f censor
				local declare -f basic
				local declare -f dprime
				
				function censor ()
				{
					echo 'censor function'
				}
				
				function basic ()
				{
					echo 'basic function'
				}
			}
				
			function anova ()
			{
				echo 'anova functions'
			}
			
		}
		
IDEA_2 (){
#===========================================================================================================
#===========================================================================================================
#===========================================================================================================
<<idea_2

format for this project
[]$ <$study> <$step> <$input1> <[$input2]>
[hagar:~/]$  TAP prep_tstat [TS018] [SP1]
[hagar:~/]$  TAP prep_tstat [loop] [loop]

idea_2
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



# Study variable call should be put them at the bottom of the script so the other functions can be called from within


function TAP ()
{
	step=${1}
	input1=${2}
	input2=${3}
	
	# will create an Array of all subjects
	subj_list=( $( basename  $( ls ${TAP}/TS* ) ) ) 
	# will create an Array of all runs
	run_list=( SP1 SP2 TP1 TP2 )

			
	if [[ $input1 = loop && -z $input2 ]]; then

		subj=${subj_list[$]}
		run=${run_list[$]}



	TAP=/Volumes/Data/TAP
		   nbhh 	 	 	 	 	 	 	 	 	 	   
	case $step in
		prep_* )

			if [[ $input1 = "loop" ]]; then
				
				for (( s=0, r=0; s<${#subj[*]}; s++, r(xxxx))	# iterate once every ${#subj[*]} subjects) 
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
					
				elif [[ $input2 = TS[::num::] ]]; then
						subj=$input1
						run=$input2
						
						${step} ${subj} ${run}
				
					else
						echo "something is wrong"
					fi
				;;
					
					