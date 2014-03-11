# This program assumes the user has already extracted the nifti files from their
# respective zipped folders and are in the current working directory.

cd /Exps/Analysis/WB1/GiftAnalysis/Learnable/Learnable_group_stats_files

FILES=(`ls *nii`)

for file in ${FILES[*]}; do
    fn=(`echo $file | awk -v FS="_" '{print $1" "$4}'`)
    for (( i = 46, j=1; i < 128; i+=2, j++ )); do
        outname="${fn[0]}_${fn[1]}_IC$j.1D"
        case $j in
            2 )
                3dmaskdump -xbox 236:-90 $i -72 -noijk $file > ${outname}
                ;;
            7 )
                3dmaskdump -xbox 236:-90 $i -72 -noijk $file > ${outname}
                ;;
            25 )
                3dmaskdump -xbox 236:-90 $i -72 -noijk $file > ${outname}
                ;;
            31 )
                3dmaskdump -xbox 236:-90 $i -72 -noijk $file > ${outname}
                ;;
            39 )
                3dmaskdump -xbox 236:-90 $i -72 -noijk $file > ${outname}
                ;;
        esac

    done
done