# -- call system notes --

# while (($#)); do
#     echo $# sub$1
#     shift
# done

<<doc
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

doc

echo "<In While LOOP>"
while getopts ":hs:r:" Option; do
    case $Option in
        s | S )
                subj=`printf "sub%03d" ${OPTARG%-*}`
                scan=run${OPTARG#*-}
                orig=${OPTARG} ;;
        r | R ) scan=run$OPTARG ;;
        h | H ) echo "This is a help message!" ;;
            * ) shift ;;
    esac
    echo -e "Orig: $orig    Subj: ${subj}    Scan: ${scan}"
done
shift $(($OPTIND - 1))
echo "<Out of While LOOP> ${subj}_${scan}"


# subj=`printf "sub%02d" $var`



# For a commandline that follows
# The the pattern below will parse variables to look like --> sub1 run1
#
# [hagar]$ bash call tap Preprocess -ssub{1..20}run{1..4}

# while getopts ":s:r:" Option; do
#     case $Option in
#         s | S )
#                 subj=${OPTARG%run[1-4]}  # This is saying anything with 'run*$' in the parameter gets
#                                          # sliced off, leaving only the prefix portion --> sub1
#                 scan=run${OPTARG#sub*[0-9]run}  # This is saying anything with the pattern 'sub*run'
#                                                 # in the name, slice off everything save the very tail and
#                                                 # prefix it with a 'run' --> run1
#             * ) shift ;;
#     esac
# done
# shift $(($OPTIND - 1))


