
# ================================================================
#  This is a call script which sources various functions and allows
#  for making calls to specific pipelines
#
#
#  call <Study Profile> <processing piple>
#  call tap preprocessing [function-name]
#
#  available options for <Study Profile>: [tap, attnmen, stroop, wb1, ice, rat, test]
#  		specific variable names, and functions if defined provided by the profile
#
#  available options for <proccessing pipelines>:
#		two potential options, the first is the class of Pipeline, ie Preprocessing, Analysi, etc
#		Classes are capitalized in order to distinguish them from specifc function calls.
# 		Calling the Reconstruction class will execute the predefined list of operations for that
#			pipeline. If the Study Profile specified has a Class of the same name defined under its
#			namespace, then that Pipeline will be utilized instead of the default one already defined.
# 		Specify a 'Class' (ie Preprocessing) or a specifc function name. In both cases, calling the
#			'Class'
# 													[reconstruct
#													 	--build_functional
#													 	--build_anat
#													 	--_renameAnat
#													 preprocessing
#													 	--timeShift
#													 	--sliceTiming
#													 	--deSpiking
#													 	--volTrim
#													 	--volReg
#													 analysis,
#													 	--anova
#													 	--ttest
#													 	--ica
#													 registration,
#													 	--warpToMNI
#													 	--warpToTLRC
#													 	--somethingelse
#													 regression,
# 														--deconvolve
#														--something else
# 												   ]




source reconstruct_functions
source registration_functions
source regression_functions
source utility_functions

if [[ -e ${study}_functions.sh]]; then
	# This would be calling overide functions that will overide
	# a method name I have in one of the sourced fuctions above.
	source ${study}_functions
fi


call tap Preprocessing  # this would run the preprocessing pipeline as defined by the tap profile
						 # if such a pipeline exists under that study profile. Otherwise it will
						 # use the default pipeline. Regardless of case, the tap profile will supply
						 # all required variables for the Preprocessing pipline functions.

call tap sliceTiming  # this would run the sliceTiming function as defined by the tap profile,
					  # if it exists under that study profile. Otherwise, it will the default
					  # method supplied with varibles defined under the tap profile.

# In both examples, these calls would iterate over every subject and every run, because the default
# behavior is to do so, unless a specifc set of subjects and or scans is specified.

call tap sliceTiming {1,3,7} 1 # This example is calling the sliceTiming function under
									   # the tap namespace, but only for subjects 1,3,7
									   # at scan 1

call tap Preprocessing 1, {1,4} # This is a similar example showing the various inputs. THis would
								# only perform Preprocessing operations on subject 1, for runs 1 and 4

#--------------Start of Main--------------
context=${1}  # This is the study profile (can also be test). It is called context becase it represents
			  # the context of with which the pipelines and function will execute. Or something...

operation=${2}  # Can be either a <Pipeline>, or it can be a <function> (both <<case-sensitive>>)
				# Both must exist, whether as a default Pipleine/Function, or a context specific
				# Pipeline/Function

source ${PROFILE}/Profile.${context}.sh

if [ $# -lt 4 ]; then
	for subj in ${subjArray[*]}; do
		${PROG}/${context}_${operation}
	done
fi



