#================================================================================
#	Program Name: .bash_profile
#		  Author: Kyle Reese Almryde
#			Date: 01/27/12
#
#	 Description: sh initialization file.
#
#================================================================================
#                                START OF MAIN
#================================================================================
echo ".bash_profile has been sourced!!"

# ***** Program Configurations ******
set autolist
set dextract
set history=300
set ignoreeof
set listjobs
set matchbeep=nomatch
set noclobber
set notify
set rmstar
set savehist=200
set symlinks=chase
set time=100
set umask 000

# Teminal Colors
export CLICOLOR=true
export LSCOLORS=dxfxcxdxbxegedabagacad  # For dark backgrounds


export AFNI_HOME=/usr/local/afni
export EDITOR='/opt/local/bin/subl'
# export SUBLIME_PACKAGES='/Users/krbalmryde/Library/Application\ Support/Sublime\ Text\ 2/site-packages'
# export EDITOR=nano
export FSLDIR=/usr/local/fsl
export GIT_HOME=/opt/local/git
export INSIGHT_TK_HOME=/opt/local/itk241_yale/include/InsightToolkit
export LATEXMK=/opt/local/latexmk-439
export LESS='-R -X -e -c -M -PM%f (file\: %i/%m line\: %lb/%L) [%pb\%] '
export PAGER='less'
export ROIS=${REF}/IMAGES/STANDARD_MASKS
export TERM=xterm-color
export U=/opt/local/src
export Ubin=/opt/local/bin

source $FSLDIR/etc/fslconf/fsl.sh


# DYLD Path
export DYLD_LIBRARY_PATH=""
export DYLD_VERSIONED_LIBRARY_PATH= # ${AFNI_HOME} #:/opt/X11/lib:/opt/lib:/opt/local/lib
export DYLD_FALLBACK_LIBRARY_PATH=${AFNI_HOME}:/opt/local/lib:/usr/lib #:/opt/lib:/opt/X11/lib #/opt/local/lib




# Kyle's enviornment variables
export UTL=/opt/local/Utilities         #The directory where I house all my scripts
export SHOP=$UTL/WorkShop               #The direcotry where I house all my work in progress scripts
export ATTM=$UTL/AttnMem
export DIC=$UTL/Dichotic
export ICE=$UTL/Iceword
export NBA=$UTL/NBack
export RAT=$UTL/Rat
export MOUSE=$UTL/Mouse
export RUS=$UTL/Russian
export STP=$UTL/Stroop
export SUA=$UTL/SustainedAttention
export TAP=$UTL/Tap
export WB=$UTL/WordBoundary


# Experiment Specific enviornment variables
export ETC=/Volumes/Data/ETC
export DICHOTIC=/Volumes/Data/DICHOTIC      #The Dichotic listening study
export WORDBOUNDARY=/Volumes/Data/WordBoundary1
export LATERALITY=/Volumes/Data/WB1
export ICEWORD=/Volumes/Data/Iceword
export RATPAIN=/Volumes/Data/RatPain                #The directory which houses the Rat data.
export TAP=/Volumes/Data/TAP                #The Transfer Appropriate Processing study
export MOUSEHUNGER=/Volumes/Data/MouseHunger


# path additions
PATH=$PATH:/opt/local/bin:/opt/local/sbin
PATH=$PATH:/Developer/usr/bin
PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin
PATH=$PATH:/opt/local/Utilities
PATH=$PATH:/opt/local/pin
PATH=$PATH:/opt/local/lib:/usr/lib     # DYLD Library files

# My Tools
PATH=$PATH:$TOOLS:$TOOLS/LIBRARY:$TOOLS/LIBRARY/ATLAS
PATH=$PATH:$PROJECTS/DTIERP:$PROJECTS/DTIERP/DTI:$PROJECTS/DTIERP/MORPH:$PROJECTS/DTIERP/REG
PATH=$PATH:$PROJECTS/ICEWORD:$PROJECTS/ICEWORD/FUNC:$PROJECTS/ICEWORD/REG:$PROJECTS/ICEWORD/TEXT
PATH=$PATH:$PROJECTS/IJN:$PROJECTS/IJN/ICEIJN:$PROJECTS/IJN/PIJN
PATH=$PATH:$PROJECTS/PLANTE:$PROJECTS/PLANTE/DTI:$PROJECTS/PLANTE/FUNC:$PROJECTS/PLANTE/MORPH:$PROJECTS/PLANTE/REG:$PROJECTS/PLANTE/TEXT
PATH=$PATH:$PROJECTS/SZR:$PROJECTS/SZR/DTI:$PROJECTS/SZR/FUNC:$PROJECTS/SZR/MORPH:$PROJECTS/SZR/REG:$PROJECTS/SZR/TEXT
PATH=$PATH:$UTL:${SHOP}:${ATTM}:${CAL}:${DIC}:${DRV}:${ICE}:${NBA}:${RAT}:${MOUSE}:${RUS}:${STP}:${SUA}:${TAP}:${WB}:${ETC1}
PATH=$PATH:/mricron:$MAGICK_HOME/bin
PATH=$PATH:$FMRISTAT:$AFNI_MAT
PATH=$PATH:$LATEXMK

# Imaging Tools
PATH=$PATH:$AFNI_HOME
PATH=$PATH:$INSIGHT_TK_HOME
PATH=$PATH:${FSLDIR}/bin:${FSLDIR}/data/atlases/bin
PATH=$PATH:${GIT_HOME}/bin

# Applications in the Path
PATH="~/Library/Enthought/Canopy_32bit/User/bin:${PATH}"

#Python path
PYTHONPATH="$HOME/Library/Enthought/Canopy_32bit/User/lib/python2.7/site-packages"
MKL_NUM_THREADS=1

# PYTHONPATH="/Library/Frameworks/Python.framework/Versions/7.3/bin"
# PYTHONPATH="$PYTHONPATH:/Library/Frameworks/Python.framework/Versions/7.3/lib/python2.7/site-packages"

# Java Classpath
JUNIT_HOME=/opt/local/junit4.10/
CLASSPATH=.:/opt/local/bin/j3d/lib/ext/j3dcore.jar:/opt/local/bin/j3d/lib/ext/j3dutils.jar:/opt/local/bin/j3d/lib/ext/vecmath.jar
CLASSPATH=$CLASSPATH:/opt/local/bin/jogl/lib/jogl.jar:/opt/local/bin/jogl/lib/gluegen-rt.jar
CLASSPATH=$CLASSPATH:$JUNIT_HOME/junit-4.10.jar

# Haskell path
PATH="${PATH}:${HOME}/Library/Haskell/bin"

# C++ paths
# LIBRARY_PATH=/opt/local/lib:/usr/lib
# LIBRARY_PATH=${LIBRARY_PATH}:${FRAMEWORKS}/OpenGL.framework/Libraries

# CPATH=/opt/X11/include:/opt/local/include:/usr/include
# CPATH=$CPATH:${FRAMEWORKS}/OpenGL.framework/Headers
# CPATH=$CPATH:${FRAMEWORKS}/Carbon.framework/Headers
# CPATH=$CPATH:${FRAMEWORKS}/Cocoa.framework/Headers
# CPATH=$CPATH:${FRAMEWORKS}/AppKit.framework/Headers
# CPATH=$CPATH:${ALUMINUM}/osx:${ALUMINUM}/src:${NIFTI}:${NIFTI}/nifti:${NIFTI}/nifti/niftilib

# $CPLUS_INCLUDE_PATH


# Export Paths
export PATH
export CLASSPATH
export PYTHONPATH
export MATLAB_USE_USERPATH=$UTL
export CDPATH=.:..:~:/Exps/Data:/opt/local:/opt/local/scripts:/opt/local/ref:/opt/local/Utilities:/Users/krbalmryde/Documents

export CC=clang
export CXX=clang
# export LIBRARY_PATH
# export CPLUS_INCLUDE_PATH
# export OBJC_INCLUDE_PATH

export FFLAGS=-ff2c
export MKL_NUM_THREADS      # Has to do with the EPD setup
export NIPYPE_NO_MATLAB=


PS1="[\h:\W:\$(git_branch) \!] \$ "


ahdir=`apsearch -afni_help_dir`
if [ -f "$ahdir/all_progs.COMP.bash" ]
then
   . $ahdir/all_progs.COMP.bash
fi

# This line is in case of the AFNI bash command completions dont work. Presently they do.
# . <(sed -n 's@^set \(ARGS=(.*) ; complete\) \([^ ]*\) "C/-/($ARGS)/" "p/\*/f:/" ; #.*@\1 -W "${ARGS\[\*\]}" -o bashdefault -o default \2@p' ~/.afni/help/all_progs.COMP)

# Added by Canopy installer on 2013-06-12
# VIRTUAL_ENV_DISABLE_PROMPT can be '' to make bashprompt show that Canopy is active, otherwise 1
VIRTUAL_ENV_DISABLE_PROMPT=1 
source /Users/krbalmryde/Library/Enthought/Canopy_32bit/User/bin/activate

# Backup .bash_profile into one big aggregate file
cat ~/.bash_{profile,functions,aliases} > $UTL/bash_profile_back.sh


source ~/.bash_functions
source ~/.bash_aliases
# source /sw/bin/init.sh

#!/usr/bin/env bash
#================================================================================
#    Program Name: .bash_functions
#          Author: Kyle Reese Almryde
#            Date: 7/12/13 @ 10:59am
#
#   Defines frequently used functions that make my life easier
#================================================================================

#================================================================================
#                            FUNCTION DEFINITIONS
#================================================================================
function git_branch () { git rev-parse --abbrev-ref HEAD 2>/dev/null; }
function git+ () { git add $*; git status ; }
function git- () { git reset HEAD $*; git status ; }
function gclone () { git clone $*; }


function loc () { chmod a-w $* ; }
function ffd () { find . -name $* -print ; }
function fedit () { edit `find . -name \!*` ; }
function fps () { ps aux | grep -i $* ; }
function fpw () { ps -a -x -w -w -o user,pid,ppid,stat,command | grep -i $* | grep -v grep ; }
function go () { pushd $* ; }
function to () { pushd $* ; }
function treed () { tree -d $* 2>&1 | less ; }
function treel () { tree $* 2>&1 | less ; }
function unlock () { chmod a+rwx $* ; }
function prt () { pr $* | lpr ; }
function rd () { rcsdiff $* 2>&1 | less ; }
function rl () { rlog $* 2>&1 | less ; }
function l.m  () { ls -dCF .[a-zA-Z0-9]* 2>&1 | less ; }
function lam  () { ls -aCF $* 2>&1 | less ; }
function lalm () { ls -alF $* 2>&1 | less ; }
function lfm  () { ls -CF $* 2>&1 | less ; }
function lflm () { ls -lF $* 2>&1 | less ; }
function lfls () { ls -lSF $* 2>&1 | less ; }
function lflt () { ls -ltF $* 2>&1 | less ; }

# functions for use on Auk:
function gets () { scp -p -P 33333 seth:/Users/dpat/temp/ $* . ; }
function puts () { scp -p -P 33333 $* seth:/Users/dpat/temp/ ; }
function seth () { ssh -p 33333 $* seth ; }

# functions for use on Seth:
function geta () { scp -p auk:/Users/dpat/temp/ $* . ; }
function puta () { scp -p $* auk:/Users/dpat/temp/ ; }


function cutn () { 
    local d=$1
    local f=$2
    case $# in
        0 )
            d=' '
            f=1 
        ;;
        1 )  
            f=1
        ;;
    esac
    cut -d $d -f $f 
}


function maker () {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function executes make on an existing make file for a
    #           c++ program. It will perform the following steps in order:
    #           clean, make, and execute project
    #
    #    Input: compile -- should be the executable name in the targeted 
    #                      makefile.
    #
    #   usage: make homework4
    #
    #------------------------------------------------------------------------

    local compile=$1
    make clean
    make
    ./$compile
}



function cxx () {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function allows me to compile AND run a simple c++
    #            program using g++ compiler
    #
    #    Input: infile should be a C++ source file of the form infile.cpp
    #           or infile.cxx
    #
    #   usage: cxx Arrow.cpp
    #
    #------------------------------------------------------------------------

    local infile=$1
    local compile=$(echo $infile | cut -d . -f 1)
    echo $compile
    if [[ -e $compile.o ]]; then
        rm $compile.o
    fi

    if [[ $(echo $infile | grep '\.') ]]; then
        # cc -framework GLUT -framework OpenGL -framework Cocoa $infile -o $compile.o
        g++ -Wall $infile -o $compile.o
    fi

    ./${compile}.o

} # End of cxx


function pid() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Get the process ID of the supplied process name. If none is
    #           provided, display the entire process log
    #    Input: A process value, ie scala
    #
    #   Output: A number indicating the processes ID number
    #
    #------------------------------------------------------------------------

    local process=$1
    local num=$2
    if [[ -z $process ]]; then
        ps -A
    elif [[ -z $num ]]; then
        ps -A | grep -m1 $process | awk '{print $1}'
    else
        ps -A | grep -m $num $process | awk '{print $1}'
    fi


} # End of pid



function upafni() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Check for updates and if necessary update afni.
    #
    #------------------------------------------------------------------------

    # take note of the AFNI version and compile date
    date=$(echo `afni -ver` | awk '{print $6,$7,$8}' | sed 's/]//g' | awk '{print $2,$1,$3}')

    # check that the current AFNI version is recent enough
    afni_history -check_date ${date}

    # When checking the date, if there was an error
    if [[ $? -ne 0 ]]; then
        echo "** this script requires newer AFNI binaries (than "$(date +"%B %d %Y")
        sudo @update.afni.binaries -defaults
    fi


} # End of upafni


function split() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Simple function to split a word based on delimiter, returning
    #           input to an array (if desired) or the word as a string 
    #           separated by white-space
    #
    #    Input: $1 should be the delimiter eg. '.'
    #           $2 should be the word you wish to split
    #   
    #   Output: If everything works, it should be the word split on the chosen
    #           delimiter. Otherwise an error code will appear
    #
    #------------------------------------------------------------------------

    local delim=$1
    local word=$2
    local STOP=0
    local EXIT=1 # By default set Exit code to 1, presumes bad exit. 
    local f=1 # field index
    local i=0 # array index
    declare -a splitList

    if [[ $# -ne 2 ]]; then
        echo "Requires two arguments, received ${#}! Exiting..."
        return $EXIT
    fi

    while [[ $STOP -ne 1 ]]; do
        
        temp=$(echo $word | cut -d "${delim}" -f$f)

        case $temp in
            $word ) 
                    STOP=1
                    return $EXIT; # "Bad delimiter, exiting..."
                ;;
               "" ) 
                    echo ${splitList[*]} # reached end of splits
                    STOP=1
                ;;
                * )
                    splitList[$i]=$temp
                    ((i++,f++))
                ;;
        esac
    done
}


function hidden() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Shows or Hides hidden files on Mac
    #
    #------------------------------------------------------------------------

    visible=$(defaults read com.apple.finder AppleShowAllFiles)

    if [[ $visible -eq 1 ]]; then
        defaults write com.apple.finder AppleShowAllFiles -boolean false
        killall Finder
    else
        defaults write com.apple.finder AppleShowAllFiles -boolean true
        killall Finder
    fi


} # End of hidden


function pass? () {
    #------------------------------------------------------------------------
    #
    #   Description: pass?
    #
    #       Purpose: This fuction will use egrep to check my account password
    #                stored in a file
    #
    #         Input: Should be either the Username or the account name, regex
    #                can be used to assist in identifying the name
    #
    #        Output: 3 lines of output. Depending on the query it may or may
    #                contain the Account, Username, and password. Unless I am
    #                explicitly looking up a password, the password should
    #                always be outputted
    #
    #------------------------------------------------------------------------
    local query=$1
    local location=~/Dropbox/Code-Projects

    if [[ ${query} == "upd" ]]; then
        subl ${location}/UnPw.txt
    else
        echo
        egrep -A 2 "${query}" ${location}/UnPw.txt
       local password=$(\
                    egrep -A 2 "${query}" ${location}/UnPw.txt \
                    | egrep 'Password: ' \
                    | cut -d " " -f2 \
                )
        echo
        echo $password | pbcopy
    fi
}



function setPass () {
    #------------------------------------------------------------------------
    #
    #  Purpose: This function will set a new password using the Password.py
    #           script I wrote.
    #
    #    Input: Account Name, Username, True/False, Password Length
    #
    #------------------------------------------------------------------------

    python ~/Dropbox/Code-Projects/PGen/Password.py

} # End of setPass




function addpass() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Adds a new Account/Username/Passoword set to the password DB
    #
    #
    #    Input: 3 arguments are required; The account name, The username
    #           and the password
    #
    #------------------------------------------------------------------------
    local location=~/Dropbox/Code-Projects

    local account=$1
    local username=$1
    local password=$1

    if [[ ! $account ]]; then
        echo "Account name: "
        read account
    fi

    if [[ ! $username ]]; then
        echo "Username: "
        read username
    fi

    if [[ ! $password ]]; then
        echo "Password: "
        read password
    fi

    printf "\n Account: %s\nUsername: %s\nPassword: %s\n" $account $username $password

    echo "Ok to add?"
    read answer

    if [[ ! $answer ]]; then
        printf "\n Account: %s\nUsername: %s\nPassword: %s\n" $account $username $password >> ${location}/UnPw.txt
        pass?
    else
        echo "aborting!"
    fi



} # End of addpass


function jcj (){
    #------------------------------------------------------------------------
    #
    #   Description: jcj
    #
    #       Purpose: This function allows me to compile AND run
    #                a java program. Note: Do not include the file extension
    #
    #         Input: jcj Prog1b
    #
    #        Output: Compiled and run java program
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------

    javac $1.java
    java $1
}



function jcjunit () {
    #------------------------------------------------------------------------
    #
    #   Description: jcjunit
    #
    #       Purpose: This function allows me to compile AND run
    #                a java unitest. Note: Do not include the file extension
    #
    #         Input: jcjunit Prog1bTest
    #
    #        Output: Compiled and run java program
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------
    javac $1.java
    java org.junit.runner.JUnitCore $1
}



function tarit () {
    #------------------------------------------------------------------------
    #
    #   Description: tarit
    #
    #       Purpose:  This function compresses a file for me.
    #
    #         Input: Input is the name of the compressed file, and the
    #                directory to be compressed
    #                e.g. tarit data_tap REML
    #
    #        Output: A compressed file and directory
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------
    tar -cvf $1.tar $2 $3 $4
}


function sendit () {
    #------------------------------------------------------------------------
    #
    #   Description: sendit
    #
    #       Purpose: Using scp send a file to Hagar's desktop under my username
    #
    #         Input: File to be copied to the desktop
    #
    #        Output: None
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------

    scp -p $1 128.196.62.133:/Users/krbalmryde/Desktop
}



function getit () {
    #------------------------------------------------------------------------
    #
    #   Description: getit
    #
    #       Purpose: Using scp remotely pull a file from Hagar's desktop
    #
    #         Input: Desired file
    #
    #        Output: None
    #
    #     Variables: None
    #
    #------------------------------------------------------------------------
    scp -p 128.196.62.133:/Users/krbalmryde/Desktop/ $1
}




function ginit() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Setup a new git repository. Initializes in the current working
    #           directory.
    #
    #------------------------------------------------------------------------
    local repo=$1

    echo -e "*.class\n*.nii*\n*.pdf\n*.pyc\n*.o\n*.gz\n*.zip\n*.log" > .gitignore
    touch README.md
    git init
    git add README.md
    git commit -m "first commit"
    git remote add origin https://github.com/KrbAlmryde/${repo}.git
    git push -u origin master

} # End of gitinit



function mkprj() {
    #------------------------------------------------------------------------
    #
    #  Purpose: Creates a new project in the 'Projects' folder. It also setups
    #           a git repository as well.
    #
    #    Input:
    #
    #   Output:
    #
    #------------------------------------------------------------------------

    local project=$1
    local shortcut=$2
    local fnStart=$3  # Start with a newly generated file

    local prjDir=`pwd`
    local srcDir="${prjDir}/src"

    mkdir -p ${prjDir}/{doc,src,"test"}
    echo -e "\tCreated ${project} project sucessfully"
    echo -e "\tpreparing to build git repository now..."

    cd ${prjDir}
    echo -e "*.class\n*.nii*\n*.pdf\n*.pyc\n*.o\n*.gz\n*.zip\n*.log" > .gitignore
    git init
    touch ReadMe.md

    if [[ ${shortcut} = '' ]]; then
        name=${project}
    else
        name=${shortcut}
    fi

    echo -e "\t${project} repository has been created!"
    echo -e "\tProject ${project} is ready to begin development!"
    echo -e "alias ${name}='cd ${srcDir}; ls -Fl; pwd'" >> ~/.bash_aliases

    if [[ ${fnStart} != '' ]]; then
        subl ${srcDir}/$fnStart
    fi

    . ~/.bash_profile

} # End of mkprj



function xnii () {
    #------------------------------------------------------------------------
    #
    #  Purpose: Builds and runs niftiViewer xcode project from the command-
    #           line.
    #
    #     Note: This actually works!!! I can compile and run from the fucking
    #           command-line!!!
    #
    #------------------------------------------------------------------------

    # EXAMPLE_DIR="$( cd "$( dirname "$0" )" && pwd )"
    operation=$1

    case $operation in
        refresh )
            precompile
            makelib
            ;;
        *)
            echo
            ;;
    esac

    APP="niftiViewer"

    EXAMPLE_DIR="/Users/krbalmryde/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/niftiViewer"
    BASE_DIR="$EXAMPLE_DIR/../../../.."
    SRC_DIR="$BASE_DIR/src"
    OSX_DIR="$BASE_DIR/osx"
    LIB_DIR="/opt/local/lib"
    INCLUDE_DIR="/opt/local/include"
    ASSIMP="$LIB_DIR/libassimp.dylib"
    CPP_LIB="/usr/lib/c++/v1"
    NIFTI_LIB="$EXAMPLE_DIR/niftilib"
    FREEIMAGE="$LIB_DIR/libfreeimage.dylib"

    COCOA="-isysroot /Applications/XCode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.7.sdk \
           -mmacosx-version-min=10.7 \
           -framework Cocoa \
           -framework QuartzCore \
           -framework OpenGL \
           -framework AppKit \
           -framework Foundation \
           -framework AVFoundation \
           -framework CoreMedia \
           -framework Carbon"



    OPTIONS="-O3 " \
             # -Wreturn-type \
             # -Wformat \
             # -Wmissing-braces \
             # -Wparentheses \
             # -Wswitch \
             # -Wunused-variable \
             # -Wsign-compare \
             # -Wno-unknown-pragmas  \
             # -Woverloaded-virtual"

    INCLUDE="-I./ -I$OSX_DIR -I$SRC_DIR -I$NIFTI_LIB -I$INCLUDE_DIR -I$CPP_LIB"
    LIBS="$ASSIMP $FREEIMAGE"
    SRC="-x objective-c++ $SRC_DIR/*.cpp $OSX_DIR/*.mm $EXAMPLE_DIR/*.mm"

    cd $BASE_DIR; pwd

    #COMPILE
    # echo -e "\nbuilding... \n\nc++ $COCOA $OPTIONS -std=c++11 $LIBS $INCLUDE $SRC -o $EXAMPLE_DIR/$APP \n\n"

    # time c++ $COCOA $OPTIONS -stdlib=libc++ -std=gnu++0x $BASE_DIR/aluminum.a $LIBS $INCLUDE $SRC -o $EXAMPLE_DIR/$APP
    # real    1m12.248s
    # user    0m36.053s
    # sys    0m4.608s

    time c++ $COCOA $OPTIONS -stdlib=libc++ -std=gnu++0x $BASE_DIR/aluminum.a $LIBS $INCLUDE $EXAMPLE_DIR/*.mm -o $EXAMPLE_DIR/$APP
    # real    0m28.196s
    # user    0m9.562s
    # sys    0m1.815s

    #RUN
    cd $EXAMPLE_DIR && ./$APP && rm ./$APP

} # End of xnii



function messWithYou() {
    #------------------------------------------------------------------------
    #
    #  Purpose: All your bases are belong to us!
    #
    #   Output: messWithYou & disown to detach it from the terminal ;)
    #
    #------------------------------------------------------------------------

    index=0
    incFlag=1
    counter=0
    statements=(
                "All your bases are belong to us"
                "smelly cat, smelly cat, what are they feeding you?"
                "R O C K in the USA, R O C K in the USA"
                "Never gonna give you up, never gonna let you down"
                "Im sorry dave, I cant do that"
                "Destroy all humans, destroy all humans, destroy all...what?"
                "Hello Kyle, lets play a game"
                "Toto, I've got a feeling we're not in Kansas anymore."
                "I love the smell of napalm in the morning."
                "I'm as mad as hell, and I'm not going to take this anymore!"
                )

    while [[ 1 -eq 1 ]]; do
        rand=${RANDOM:0:1}
        osascript -e "set volume ${index}"
        say ${statements[0]}

        if [[ counter -eq 100 ]]; then
            osascript -e "set volume 10"
            say "I'll be back."
            exit
        fi

        if [[ incFlag -eq 1 ]]; then
            ((index++))
        else
            ((index--))
        fi

        if [[ $index -eq 10 ]]; then
            incFlag=0
            sleep ${rand}
        elif [[ $index -eq 0 ]]; then
            incFlag=1
            sleep ${rand}
        fi

        ((counter++))
    done    

} # End of messWithYou

#!/usr/bin/env bash
#================================================================================
#    Program Name: .bash_aliases
#          Author: Kyle Reese Almryde
#            Date: 7/12/13 @ 10:59am
#
#   Defines frequently used aliases that make my life easier
#================================================================================

# Server based
alias grad='ssh grad@128.196.62.60' #password is B@s@l4u
alias get_grad='sftp grad@128.196.62.60' #password is B@s@l4u
alias jump='ssh marija@128.196.62.133' #password is neurolab!   # Navigate to and from Marija's Machine
alias lectura='ssh kalmryde@lectura.cs.arizona.edu' # HighWayToH3||1343  # Access lectura server in CS department
alias paige='ssh cclab@128.196.98.155' # 417guest
alias get_paige='sftp cclab@128.196.98.155' # 417guest
alias pushlec='sftp kalmryde@lectura.cs.arizona.edu' # HighWayToH3||1343
alias take='sftp marija@128.196.62.133' #password is neurolab!
alias ted='sftp kalmryde@128.196.112.121' #password is zeebob15  # Access Trouardo2 server
alias ted2='ssh kalmryde@128.196.112.121' #password is zeebob15


# Afni specific
alias afnir='afni -R -yesplugouts'
alias 3di='3dinfo'
alias 3div='3dinfo -verb'
alias suuma='afnir -niml & suma -spec /usr/local/suma_MNI_N27/MNI_N27_both.spec -sv /usr/local/suma_MNI_N27/MNI_N27_SurfVol.nii &'    #'afni -niml & suma -spec /opt/local/suuma/N27_both_tlrc.spec -sv /opt/local/afni/TT_N27+tlrc &'


# Common Directories
alias db='cd /Users/krbalmryde/Dropbox'
alias dl='cd /Users/krbalmryde/Downloads'
alias home='cd /Users/krbalmryde'
alias eye='cd /Users/krbalmryde/Dropbox/Work-Projects/EyeTracker'
alias nii='cd /Users/krbalmryde/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer; ls -Flt; pwd'
alias opl='cd /opt/local; pwd; ls -Flt'
alias prj='cd /Users/krbalmryde/Dropbox/Code-Projects; pwd; ls -Flt'
alias utl='cd /opt/local/Utilities; pwd; ls -Flt'
alias url='cd /usr/local; pwd; ls -Flt'
alias work='cd /Users/krbalmryde/Dropbox/Work-Projects'
alias xprj='cd /Users/krbalmryde/Dropbox/XCodeProjects/aluminum; pwd; ls -Flt'

# Class specific aliases
alias class='cd /Users/krbalmryde/Dropbox/Class-Projects'
alias ista130='cd /Users/krbalmryde/Dropbox/Class-Projects/ISTA130'
alias ista555='cd /Users/krbalmryde/Dropbox/Class-Projects/ISTA555'
alias ista516='cd /Users/krbalmryde/Dropbox/Class-Projects/ISTA516'
alias cs227='cd /Users/krbalmryde/Dropbox/Class-Projects/cs227'
alias cs335='cd /Users/krbalmryde/Dropbox/Class-Projects/cs335'
alias cs372='cd /Users/krbalmryde/Dropbox/Class-Projects/cs327'
alias cs533='cd /Users/krbalmryde/Dropbox/Class-Projects/cs533'

# Editor specific
alias afn='subl /Users/krbalmryde/.afnirc'
alias upd='subl /Users/krbalmryde/.bash_{profile,functions,aliases}'
alias sb='source /Users/krbalmryde/.bash_profile'
alias updi='subl /Users/krbalmryde/.ipython/profile_default/startup/00-profile.py'

# Project stuff
alias utls='subl --project /opt/local/Utilities/Utilities.sublime-project'
alias niis='subl --project /Users/krbalmryde/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/NiftiViewer.sublime-project'
alias prjs='subl --project /Users/krbalmryde/Dropbox/Code-Projects/Projects.sublime-project'
alias classp='subl --project /Users/krbalmryde/Dropbox/Class-Projects/Class.sublime-project'
# alias xnii='open /Users/krbalmryde/Dropbox/XCodeProjects/aluminum/osx/examples/niftiViewer/niftiViewer.xcodeproj'

# Package Managers
alias ports='sudo port search'
alias portin='sudo port install'
alias portun='sudo port uninstall'
alias portup='sudo port selfupdate; sudo port upgrade outdated'
alias ipip='sudo pip install'
alias upip='sudo pip uninstall'
alias easy='sudo easy_install'

# git stuff
alias gitb='git branch -avv'
alias gitcia='git add . -A; git commit -m'  # 'git commit -a -m'
alias gitd='git diff'  #unstaged vs last commit
alias gitl='git log'
alias gitls='git log --stat'
alias gitr='git remote -v'
alias gits='git status'
alias gith='git help'
alias gpush='git push -u origin master'
alias gpull='git pull'


# Data related
alias exp='cd /Volumes/Data/Exps; pwd; ls -Flt'
alias expd='cd /Volumes/Data/Exps/Data; pwd; ls -Flt'
alias expa='cd /Volumes/Data/Exps/Analysis; pwd; ls -Flt'
alias vol='cd /Volumes; pwd; ls -Flt'
alias data='cd /Volumes/Data; pwd; ls -Flt'
alias mse='cd /Volumes/Data/Exps/Data/MouseHunger; ls -Flt; pwd'
alias rat='cd /Volumes/Data/Exps/Data/RatPain; ls -Flt; pwd'
alias strp='cd /Volumes/Data/Exps/Data/Stroop; ls -Flt; pwd'
alias attm='cd /Volumes/Data/Exps/Data/AttnMem; ls -Flt; pwd'
alias struc='cd /Volumes/Data/GlobalSession; ls -Flt; pwd'
alias ice='cd /Volumes/Data/Exps/Data/Iceword; ls -Flt; pwd'
alias icea='cd /Volumes/Data/Exps/Analysis/Iceword; ls -Flt; pwd'
alias rus='cd /Volumes/Data/Exps/Data/Russian; ls -Flt; pwd'
alias rusa='cd /Volumes/Data/Exps/Analysis/Russian; ls -Flt; pwd'
alias wb1='cd /Volumes/Data/Exps/Data/WordBoundary1; ls -Flt; pwd'
alias wb1a='cd /Volumes/Data/Exps/Analysis/WordBoundary1; ls -Flt; pwd'
alias wb2='cd /Volumes/Data/Exps/Data/WordBoundary2; ls -Flt; pwd'
alias wb2a='cd /Volumes/Data/Exps/Analysis/WordBoundary2; ls -Flt; pwd'


# language Interpreters
alias ghc='ghci -XNoMonomorphismRestriction'
alias lr='lein repl'
alias py='ipython'


# Tools (ones that make my life easier)
alias allow='chmod ugo+x'
alias ownit='sudo chomod a+rwx'  # requires a directory as input
alias call='${CALL}/call.sh'
alias cls='clear'
alias cp='cp -i'
alias cpr='cp -Rnv'
alias cur='dir=`pwd`'
alias prev="cd ${dir}"
alias lah='ls -Fltah'
alias lh='ls -Flth'
alias la='ls -Flta'
alias ll='ls -Flt'
alias l='ls -Ft'
alias pass='cat /Users/krbalmryde/Dropbox/Code-Projects/UnPw.txt'
alias total='ls -Flt . | egrep -c '^-'' # Counts the number of files in a directory
alias up='cd ..; pwd; ls -Flt'
alias unlock='chmod -R a+rwx \!*'
alias mkdir='mkdir -p'
alias h='history'
alias j='jobs -l'
alias which='type -a'
alias ..='cd ..'

# Pretty-print of some PATH variables:
alias path='echo -e ${PATH//:/\\n}'
alias libpath='echo -e ${LD_LIBRARY_PATH//:/\\n}'


# Dianne's Aliases
alias color='export CLICOLOR yes'
alias cut3='cut -d " " -f 3'


alias dir='ls -F'
alias fe_dtierp='fe /Volumes/Data/Exps/Data/dti_erp lst_subj_dtierp.txt '
alias fe_ice='fe /Exps/Data/IceIJN lst_subj_ice.txt '
alias fe_ijn='fe /Exps/Data/ijn lst_subj_ijn.txt '
alias fe_plante='fe /Exps/Data/plante lst_subj_plante.txt '
alias fe_szr='fe /Exps/Data/lst_subj_szr.txt '
alias fprob='time fprob'
alias fprob2='time fprob2'
alias fproc='time fproc'

alias fv='fslview'
alias fvs='fslview $STANDARD/avg152T1.nii.gz'
alias ht='history 35'
alias math='fslmaths'
alias mv='mv -i'
alias nocolor='unexport CLICOLOR'
alias pathdump='echo $PATH | tr ":" "\n"'
alias pd=dirs
alias pe='printenv | sort | less'
alias pp=popd
alias psm='ps aux | less'
alias rdj='rcsdiff *.java 2>&1 | less'

alias ren='mv -i'
alias view=less
alias xod='od -tax1'


