chmod ugo+x `cat input.txt`


Input from file
awk 'pattern' filename
awk '{action}' filename
awk 'pattern {action}' filename

Input from command
command | awk 'pattern' filename
command | awk '{action}' filename
command | awk 'pattern {action}' filename




# script setup
cat ${c}_FvM.txt ${c}_FvM.txt ${c}_MvF.txt ${c}_MvN.txt ${c}_NvF.txt ${c}_NvM.txt > temp1_${c}.txt
# --------------------------------------------------
# script setup
tr -s '\012\015' ' ' <temp1_${c}.txt > tr_temp2_${c}.txt
awk '$1=$1' RS= temp1_${c}.txt > awk_temp3_${c}.txt
cat tr_temp2_${c}.txt tr_temp2_${c}.txt tr_temp2_${c}.txt > foo.txt
# --------------------------------------------------



echo "cat files 1 A 2 B 3 C together"
cat 1.txt 2.txt 3.txt > N1.txt
cat A.txt B.txt C.txt > L1.txt
echo "convert single column to a single row"
tr -s '\012\015' ' ' <N1.txt > N2.txt
tr -s '\012\015' ' ' <L1.txt > L2.txt
echo "This awk command does the same this as the tr command above"
awk '$1=$1' RS= N2.txt > N3.txt
awk '$1=$1' RS= L2.txt > L3.txt
echo "step 3"
cat N2.txt L2.txt > NL1.txt



cat ${c}_FvM.txt ${c}_FvN.txt ${c}_MvF.txt ${c}_MvN.txt ${c}_NvF.txt ${c}_NvM.txt > temp1_${c}.txt
# --------------------------------------------------
# script setup
tr -s '\012\015' ' ' <temp1_${c}.txt > tr_temp2_${c}.txt
awk '$1=$1' RS= temp1_${c}.txt > awk_temp3_${c}.txt
cat tr_temp2_${c}.txt tr_temp2_${c}.txt tr_temp2_${c}.txt > foo.txt
# --------------------------------------------------

awk '$1=$1' RS= 1.txt > N1.txt
awk '$1=$1' RS= A.txt > L1.txt
cat N1.txt L1.txt > Combined?.txt


awk '{print $1,$11,$12,$13,$14,$15,$16}' NL2.txt

awk -v OFS='\t' '$1=$1 {print 1,$2,$3,$4,$5,$6 "\n" $7,$8,$9,$10,$11,$12 "\n" $13,$14,$15,$16,$17,$18 "\n" $19,$20,$21,$22,$23,$24 }' NL2.txt
awk -v OFS='\t' '$1=$1'


awk '{print $4"\t"}' 100_visual_Congruent_ACC.txt > test3
awk '{print $4"\t"}' 100_visual_Congruent_ACC.txt > test4
awk -v OFS='\n''$1=$1' RS= test1 > test3
awk -v OFS='\n''$1=$1' RS= test1 >> test3

<test1 awk '$1=$1' RS=  >> test2

awk '$1=$1' RS= test.1 >> test1.1