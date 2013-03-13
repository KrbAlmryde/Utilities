# -- call system notes --

# This is IT!!!
while (($#)); do
    sub=`printf "sub%03d" ${1%-*}`
    run=run${1#*-}
    rdir=Run${1#*-}
    sunbrun=${sub}_${run}

    echo $# $sub $run $subrun $cond $rdir/
    shift
done

<<idea
-- A note about Profiles...
   This ->
         foo=(`echo sub0{1..9}` `echo sub{10..20}`)
   is acceptable syntax to create a list of subjects such as the following:
        sub01 sub02 sub03 sub04 sub05 sub06 sub07 sub08 sub09 sub10
        sub11 sub12 sub13 sub14 sub15 sub16 sub17 sub18 sub19 sub20

    Alternatively, This ->
            foo=(`echo sub0{1..9}_run{1..4}`)
    also works to produce a combined list of subject/run combinations:
        sub01_run1 sub01_run2 sub01_run3 sub01_run4
        sub02_run1 sub02_run2 sub02_run3 sub02_run4
        sub03_run1 sub03_run2 sub03_run3 sub03_run4
        sub04_run1 sub04_run2 sub04_run3 sub04_run4
        sub05_run1 sub05_run2 sub05_run3 sub05_run4
        sub06_run1 sub06_run2 sub06_run3 sub06_run4
        sub07_run1 sub07_run2 sub07_run3 sub07_run4
        sub08_run1 sub08_run2 sub08_run3 sub08_run4
        sub09_run1 sub09_run2 sub09_run3 sub09_run4

    Or even This ->
            subID=(`echo sub01_run{1..4}_cond{A..D}`)
    can be used to create subj_run_cond combinations....excellent
    sub01_run1_condA sub01_run1_condB sub01_run1_condC sub01_run1_condD
    sub01_run2_condA sub01_run2_condB sub01_run2_condC sub01_run2_condD
    sub01_run3_condA sub01_run3_condB sub01_run3_condC sub01_run3_condD
    sub01_run4_condA sub01_run4_condB sub01_run4_condC sub01_run4_condD



-- Some more notes about arrays in bash

    stuff[0]=A
    stuff[1]=B
    stuff[2]=C
    stuff[3]=D
    stuff[4]=E

    echo ${stuff[*]} # A B C D E

    stuff=(`echo {A..E} {1..5}`)
    echo ${stuff[*]}  # A B C D E 1 2 3 4 5

    # Access subsets of the array, This says start at the 3[4th] element to the end
    echo ${stuff[*]:3}  # D E 1 2 3 4 5

    # Further subseting of the array, This says start at the 3[4th] element to the next 4
    echo ${stuff[*]:3:4}  # D E 1 2


-- Ideas about parsing the command-line format
case 1: call -c ice -p Regression -s {1..19} -r 1

case 2: call ice Regression {1..4} {2..4}
        call ice Regression {1..4}

case 3: call ice Regression -s {1..19} -r {2..4}
        call ice Regression -r {2..4}
        call ice Regression -s 1
        call ice Regression -r 2

getopts s:xh:x

idea


<<possible1
# For a commandline that follows
# The the pattern below will parse variables to look like --> sub1 run1
#
# [hagar]$ bash call tap Preprocess -ssub{1..20}run{1..4}

while getopts ":s:r:" Option; do
    case $Option in
        s | S )
                subj=${OPTARG%run[1-4]}  # This is saying anything with 'run*$' in the parameter gets
                                         # sliced off, leaving only the prefix portion --> sub1
                scan=run${OPTARG#sub*[0-9]run}  # This is saying anything with the pattern 'sub*run'
                                                # in the name, slice off everything save the very tail and
                                                # prefix it with a 'run' --> run1
            * ) shift ;;
    esac
done
shift $(($OPTIND - 1))
possible1




<<this
# For a command-line that looks like the following:
# bash call_system_build_notes.sh ice GLM -s{1..10}-{A..D}
#
# The way to handle the non-options is to assign them away, then shift them off the Parameter Line!


context=${1}
operation=${2}
shift
shift


echo -e "\t<In While LOOP>"
while getopts ":s:" Option; do
    case $Option in
        s | S )
                scan=run${OPTARG#*-}
                subj=`printf "sub%02d" ${OPTARG%-*}`
                ;;
            * ) shift ;;
    esac
    echo -en "Subj: ${subj}    Scan: ${scan}\n"

    # echo -e "Orig: $orig    Subj: ${subj}    Scan: ${scan}"
done

# shift $(($OPTIND - 1))
# echo "<Out of While LOOP> ${subj}_${scan}"
this

<<wrap
Wrap the program if statment into a couple seperate functions that check which scripts
should be run based on the type of option the user reqested.

ie if the user supplies -R argument
    >> bash call ice ANOVA -r{1..3}

    The -R flag will call the scanDirectedPrograms() function, which searches only those
    scripts and programs which take just the scan as a parameter.

    This way, we never run into the problem of calling a script without the correct arguments




function check_execute_A() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Will check those programs and scripts which take a subject
    #           and scan id as parameters for execution.
    #
    #    Input: subj, scan -- The subject and scan Ids respectively
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    sub=$3
    scan=$4

    # First check to see that there are the correct number of arguments,
    # if not display this usage message and exit the program.
    if [[ $# -lt 2 ]]; then
        usageMessage2()

    # Otherwise check to see if there is a context specific operation, do this for a specific program
    elif [[ -e ${PROG}/${context}.${operation}.sh ]]; then
        cmd="${PROG}/${context}.${operation}.sh ${sub} ${scan}"

    # Next check to see if there is a context specific operation, do this for a specific Pipeline
    elif [[ -e ${BLOCK}/${context}.${operation}.sh ]]; then
        cmd="${BLOCK}/${context}.${operation}.sh ${sub} ${scan}"

    # If both of those options fail, check for a default program by that identifier
    elif [[ -e ${PROG}/${operation}.sh ]]; then
        cmd="${PROG}/${operation}.sh ${sub} ${scan}"

    # Then check for a default Pipeline under that name.
    elif [[ -e ${BLOCK}/${operation}.sh ]]; then
        cmd="${BLOCK}/${operation}.sh ${sub} ${scan}"

    fi

    . ${cmd} 2>&1 | tee -a ${CONTEXT}/log.${context}.${operation}.txt

} # End of check_execute_A()



function check_execute_B() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Will check those programs and scripts which take a subject
    #           and scan id as parameters for execution.
    #
    #    Input: scan -- The scan Ids respectively
    #
    #   Output:
    #
    #------------------------------------------------------------------------
    scan=$3

    # First check to see that there are the correct number of arguments,
    # if not display this usage message and exit the program.
    if [[ $# -lt 2 ]]; then
        usageMessage2()

    # Otherwise check to see if there is a context specific operation, do this for a specific program
    elif [[ -e ${PROG}/${context}.${operation}.sh ]]; then
        cmd="${PROG}/${context}.${operation}.sh ${scan}"

    # Next check to see if there is a context specific operation, do this for a specific Pipeline
    elif [[ -e ${BLOCK}/${context}.${operation}.sh ]]; then
        cmd="${BLOCK}/${context}.${operation}.sh ${scan}"

    # If both of those options fail, check for a default program by that identifier
    elif [[ -e ${PROG}/${operation}.sh ]]; then
        cmd="${PROG}/${operation}.sh ${scan}"

    # Then check for a default Pipeline under that name.
    elif [[ -e ${BLOCK}/${operation}.sh ]]; then
        cmd="${BLOCK}/${operation}.sh ${scan}"

    fi

    . ${cmd} 2>&1 | tee -a ${CONTEXT}/log.${context}.${operation}.txt

} # End of check_execute_A()
wrap



call ice volReg 18-4

    Base.profile.sh:
        BASE="/Volumes/Data/Iceword"
        UTL="/usr/local/Utilities"      #
        DVR="${UTL}/DRIVR"              #
        PFL="${UTL}/PROFILE"            #
        LST="${UTL}/LST"                #
        BLK="${UTL}/BLK"                #
        PRG="${UTL}/PROG"               #
        STM="${UTL}/STIM"               #

        HelpMessage() {
            echo 'Your doing it wrong'
        }

        check_status() {
            echo 'Its up to date!'
        }

        check_execute() {
            # check the input, source the profile
        }
    ------------------------------------
    sub=sub0{18}
    scan=run{4}
    SDIR=Run{4}

    ${PFL}/{ice}.profile:
        runsub=${run}_${sub}
        FUNC="/Volumes/Data/Iceword/${sub}/Func"
        RD="/Volumes/Data/Iceword/${sub}/Func/${SDI}/RealignDetails"


        volReg():
            3dVolReg ... ${RD}/$runsub.nii.gz

