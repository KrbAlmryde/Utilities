
function anat() {
    dir=$1
    input=$2

    cd ${dir}
    to3d -fse \
        -prefix ${dir}/${input}.nii \
        -xSLAB 12.70L-R \
        -ySLAB 12.70S-I \
        -zSLAB 5.50P-A \
        Orig/MRIm*
}


function epi() {
    dir=$1
    input=$2.$4
    sl=$3
    reps=$4
    tr=$5

    cd ${dir}

    to3d -epan \
        -prefix ${input}.nii \
        -text_outliers \
        -save_outliers ${dir}/${input}.outs.txt \
        -xSLAB 12.70L-R \
        -ySLAB 12.70S-I \
        -zSLAB 5.50A-P \
        -time:zt $sl $reos $tr seq+z \
        Orig/MRIm*
}


B=/Volumes/Data/MouseHunger

for m in m00{1,2}; do
    for r in {base,treat,rare}; do
        case $m.$r in
            m001.base ) sl=15
                       reps=100
                       tr=1200
                    ;;
            m001.treat) sl=15
                       reps=500
                       tr=1200
                    ;;
            m002.base) sl=19
                       reps=200
                       tr=1500
                    ;;
            m001.treat) sl=19
                       reps=700
                       tr=1500
                    ;;
        esac

        echo $sl $reps $tr

        case $r in
            rare ) anat ${B}/${m}/${r} ${m}.${r}
                ;;
            base | treat ) epi ${B}/${m}/${r} ${m}.${r} $sl $reps $tr
                ;;
        esac

    done
done

