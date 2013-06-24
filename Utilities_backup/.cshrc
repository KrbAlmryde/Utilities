# .cshrc - csh initialization file.
#
#    Written by: Tom Hicks. 12/11/95.
#    Last Modified: Replace redundant env vars. Remove redundant us alias.
#
set autolist
set dextract
#set fignore=(CVS RCS .svn)
set history=300
set ignoreeof
set listjobs
set matchbeep=nomatch
set noclobber
set notify
set prompt="[%m:%c3 \!] % "
set rmstar
set savehist=200
set symlinks=chase
set time=100
unset autologout

setenv AFNI_NOREALPATH YES   # don't convert filenames to 'real' names
setenv AFNI_HOME /usr/local/afni
setenv CLICOLOR yes
#setenv CVSROOT ':ext:dpat@seth:/usr/local/CVSrepos'
#setenv CVS_RSH ssh
setenv DEBABELER_HOME /usr/local/Debabeler/debabeler_2_9
#setenv DISPLAY localhost:0.0
setenv DTIERP /Exps/Data/dti_erp
#setenv SZR /Exps/Data/szr
setenv DTITK_ROOT /usr/local/dtitk
setenv FREESURFER_HOME /Applications/freesurfer
setenv FSLDIR /usr/local/fsl
setenv STANDARD ${FSLDIR}/data/standard/
setenv GROOVY_HOME /usr/local/groovy
setenv INSIGHT_TK_HOME /usr/local/itk241_yale/include/InsightToolkit
setenv ITK_DIR /usr/local/Insight
setenv LESS '-X -e -c -M -PM%f (file\: %i/%m line\: %lb/%L) [%pb\%]'
setenv LESSOPEN "|/usr/local/bin/lesspipe.sh %s"
setenv REF /usr/local/ref
setenv ROIS ${REF}/rois_useful
setenv SCRIPTS /usr/local/scripts
setenv SLICER_HOME /usr/local/Slicer
setenv TERM xterm-color
setenv U /usr/local/src
setenv Ubin /usr/local/bin
setenv Pin /usr/local/pin



# AFNI settings
setenv AFNI_SHELL_GLOB YES

# path additions
set path = (/usr/local/bin /usr/local/sbin /usr/local/pin /Developer/usr/bin /sw/bin)
set path = ($path $SCRIPTS $SCRIPTS/DTI $SCRIPTS/MORPH $SCRIPTS/DEV $SCRIPTS/REG $SCRIPTS/ATLAS $SCRIPTS/FUNC)
set path = ($path $AFNI_HOME $SLICER_HOME/bin /usr/local/bioimagesuite26)
set path = ($path $INSIGHT_TK_HOME)
set path = ($path $FREESURFER_HOME/bin)
set path = ($path $DEBABELER_HOME)
set path = ($path $DTITK_ROOT/bin $DTITK_ROOT/utilities $DTITK_ROOT/scripts)
set path = ($path ${FSLDIR}/bin ${FSLDIR}/data/atlases/bin)
set path = ($path ${GROOVY_HOME}/bin)
set path = ($path /usr/X11R6/bin)
set path = ($path /bin /sbin /usr/bin /usr/sbin)
set path = ($path /opt/local/bin /opt/local/sbin)
set path = ($path /usr/local/ANTS /usr/local/c3d/bin)
set path = ($path /Applications/ITK-SNAP.app/Contents/MacOS/)
set path = ($path /Developer/usr/bin)
set path = ($path /Applications/MATLAB_R2011a.app/bin)
set path = ($path /usr/local/utilities)


set cdpath = (. .. ~ /Exps/Data /usr/local /usr/local/scripts /usr/local/ref /usr/local/utilities /Users/kylealmryde/Documents)

# Java Classpath
setenv CLASSPATH .:/usr/local/bin/j3d/lib/ext/j3dcore.jar:/usr/local/bin/j3d/lib/ext/j3dutils.jar:/usr/local/bin/j3d/lib/ext/vecmath.jar
setenv CLASSPATH ${CLASSPATH}:/usr/local/bin/jogl/lib/jogl.jar:/usr/local/bin/jogl/lib/gluegen-rt.jar

# FSL Configuration
source ${FSLDIR}/etc/fslconf/fsl.csh

# Freesurfer settings
# Annoying...commented out for the time being
#source $FREESURFER_HOME/SetUpFreeSurfer.csh
#setenv NO_FS_FAST
#setenv SUBJECTS_DIR /Applications/freesurfer/subjects

# test -r /sw/bin/init.csh && source /sw/bin/init.csh
alias dti 'cd $DTIERP; pwd'
alias plante 'cd /Exps/Data/plante; pwd'
alias ice 'cd /Exps/Data/IceWord; pwd'
alias us 'cd $SCRIPTS; pwd; ls -l'
alias ref 'cd $REF; pwd; ls -l'
#alias emacs 'aquamacs'
alias fb 'cd /usr/local/fsl/bin; pwd; ls -l'
#alias fe_dtierp 'dti; fe . list_subject_dtierp.txt '
alias fs 'cd /usr/local/fsl/data/standard; pwd; ls -l'
alias sc 'source ~/.cshrc'
alias fv 'fslview'
alias fvs 'fslview $STANDARD/avg152T1.nii.gz'
alias math 'fslmaths'
# Tried this for the new slicer, but it seems unstable, backing out
alias Slicer3D   '/usr/local/Slicer/Slicer3'
alias stats 'fslstats'
alias fprob 'time fprob'
alias fprob2 'time fprob2'
alias fproc 'time fproc'
alias cut3 'cut -d " " -f 3'
alias bio 'start_bioimagesuite'
alias debabel '/Applications/Debabeler/debabeler_2_9/run.sh'
alias snap 'InsightSNAP'
#alias snapit 'snap -g spgr -s Snap_constrained/pretty -l /Data/snap_labels.txt'

# set up colors for ls (use man ls to learn details)
setenv LSCOLORS exfxcxdxbxaxaxaxaxexex

# Kyle's enviornment variables
setenv UTL /usr/local/utilities
setenv TAP /Volumes/Data/TAP
setenv STROOP /Volumes/Data/Stroop
setenv BEHAV /Volumes/Data/Behav-Stroop
setenv ATTNMEM /Volumes/Data/ATTNMEM


# Kyle's Alias
alias upd 'edit ~/.cshrc'
alias utl 'cd /usr/local/utilities; pwd; ls -l'
alias data 'cd /Volumes/Data; pwd; ls -l'
alias attnmem 'cd /Volumes/Data/AttnMem; pwd; ls -l'
alias tap 'cd $TAP; pwd; ls -l'
alias stroop 'cd $STROOP; pwd; ls -l'
alias behav 'cd /Volumes/Data/Behav-Stroop; pwd; ls -l'
alias shop 'cd /Volumes/Data/Workshop; pwd; ls -l'
alias jump 'ssh kylealmryde@128.196.62.133'
alias take 'sftp kylealmryde@128.196.62.133'
alias mjump 'ssh marija@128.196.62.133' #password is neurolab!
alias mtake 'sftp marija@128.196.62.133' #password is neurolab!
alias jjump 'ssh jessie@128.196.62.133' #password is Tremors3
alias jtake 'sftp jessie@128.196.62.133' #password is Tremors3
alias suuma 'afni -niml & suma -spec /suma/N27_both_tlrc.spec -sv /suma/TT_N27+tlrc &'
alias call '${UTL}/call.sh'
alias check 'ci -l'
alias cpr 'cp -Rnv'
alias cpsli 'cp -Rnv /Volumes/PLANTE\ 4/* /Volumes/SLI_DATA/Camp\ 2011/'
alias allow 'chmod ugo+x'

# Tom's aliases
alias cls       clear
alias cp        'cp -i'
alias color	'setenv CLICOLOR yes'
#alias cvd       'cvs -d $CVSROOT diff \!* |& less'
#alias cvl       'cvs -d $CVSROOT log \!* |& less'
#alias cvln      'cvs -d $CVSROOT log -N \!* |& less'
#alias cvt       'cvs -d $CVSROOT status -v \!* |& grep Tag:'
#alias cvup      'cvs -d $CVSROOT update -R -A -d \!*'
#alias cvx       'cvs -d $CVSROOT status \!*'
alias debabel   'cd ${DEBABELER_HOME}; debabeler'
alias ff        'find . -name \!* -print'
alias fps       'ps aux | grep -i \!* | grep -v grep'
alias fpw       'ps -a -x -w -w -o user,pid,ppid,stat,command | grep -i \!* | grep -v grep'
alias go        pushd
alias ht        'history 35'
alias lf        'ls -FH'
alias lfl       'ls -lFH'
alias lflm      'ls -lFH \!* |& less'
alias lflt      'ls -lFHt \!* |& less'
alias lock      'chmod a-w \!*'
alias mv        'mv -i'
alias nocolor	'unsetenv CLICOLOR'
alias pathdump  'echo $PATH | tr ":" "\n"'
alias pp        popd
alias pd        dirs
alias pe        'printenv | sort | less'
alias rd        'rcsdiff \!* |& less'
alias rl        'rlog \!* |& less'
alias treed     'tree -d \!* |& less'
alias treel     'tree \!* |& less'
alias unlock    'chmod u+w \!*'
alias up        'cd ..'
alias xod       'od -tax1'
alias view      less
