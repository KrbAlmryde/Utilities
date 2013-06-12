
condition=$1            # This is a command-line supplied variable which determines
                        # which experimental condition should be run. This value is
                        # important in that it determines which group of subjects should
                        # be run. If this variable is not supplied the program will
                        # exit with an error and provide the user with instructions
                        # for proper input and execution.

case $condition in
    "learn"|"learnable"     )
                              condition="learnable"
                              subj_list=( sub013 sub016 sub019 sub021 \
                                          sub023 sub027 sub028 sub033 \
                                          sub035 sub039 sub046 sub050 \
                                          sub057 sub067 sub069 sub073 )
                              ;;

    "unlearn"|"unlearnable" )
                              condition="unlearnable"
                              subj_list=( sub009 sub011 sub012 sub018 \
                                          sub022 sub030 sub031 sub032 \
                                          sub038 sub045 sub047 sub048 \
                                          sub049 sub051 sub059 sub060 )
                              ;;

    "debug"|"test"          )
                              condition="debugging"
                              subj_list=( sub009 sub013 )
                              ;;

    *                       )
                              HelpMessage
                              ;;
esac


for (( s = 0; s < ${#subj_list[*]}; s++ )); do

    Main ${subj_list[s]}

done

#================================================================================
#                              END OF MAIN
#================================================================================
<<NOTE
This data is linked and as such has different path names, below are the differences
between machines.

On Hagar the path names are:
    FUNC=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}
    RD=/Volumes/Data/WordBoundary1/${subj}/Func/${RUN[r]}/RealignDetails

    STIM=/Volumes/Data/WB1/GLM/STIM
    GLM=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}
    ID=/Volumes/Data/WB1/GLM/${subj}/Glm/${RUN[r]}/Ideal

On Auk the path names are:
    FUNC=/Exps/Data/WordBoundary1/${subj}/Func/${RUN[r]}
    RD=/Exps/Data/WordBoundary1/${subj}/Func/${RUN[r]}/RealignDetails

    STIM=/Exps/Analysis/WordBoundary1/STIM
    GLM=/Exps/Analysis/WordBoundary1/${subj}/Glm/${RUN[r]}
    ID=/Exps/Analysis/WordBoundary1/${subj}/Glm/${RUN[r]}/Ideal
NOTE
