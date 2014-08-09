
BOOT=/Volumes/Data/Exps/Data/BootCamp
RUSSIAN=/Volumes/Data/Exps/Data/Russian

if [[ ! -d $RUSSIAN ]]; then
  BOOT=/Exps/Data/BootCamp
  RUSSIAN=/Exps/Data/Russian
fi


subjList=(
           sub100 sub104 sub105 sub106
           sub109 sub116 sub117 sub145
           sub158 sub159 sub160 sub161
           sub166 sub111 sub120 sub121
           sub124 sub129 sub132 sub133
           sub144 sub156 sub163 sub164
           sub171
         )



for sub in ${subjList[*]}; do


  STRUC=${BOOT}/$sub/Struc
  MORPH=${RUSSIAN}/$sub/Morph

  for r in {1..4}; do
    RUN=Run${r}
    FUNC=${RUSSIAN}/$sub/Func/${RUN}
    PREP=${BOOT}/$sub/${RUN}/Prep

    runsub=run${r}_${sub}

    echo "Checking for ${FUNC}/${runsub}.nii.gz"
    if [[ -e ${FUNC}/${runsub}.nii.gz ]]; then
      echo "${FUNC}/${runsub}.nii.gz Exists!"
      mkdir -p ${BOOT}/$sub/{Struc,Run${r}/{Prep,Glm}}

      if [[ ! -e ${PREP}/${runsub}.nii.gz ]]; then
        3dcopy ${FUNC}/${runsub}.nii.gz ${PREP}/${runsub}.nii.gz
      fi

      if [[ ! -e ${STRUC}/${sub}_mprage.nii.gz ]]; then
        3dcopy ${MORPH}/${sub}_mprage.nii.gz ${STRUC}/${sub}_mprage.nii.gz
      fi

    fi
  done
done
