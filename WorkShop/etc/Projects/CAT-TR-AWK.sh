#!/usr/bin/env tcsh
# script setup
#echo "cat files 1 2 3 and A B C together"
				cat 1.txt 2.txt 3.txt > N1.txt
				cat A.txt B.txt C.txt > L1.txt
#echo "convert single column to a single row"
				tr -s '\012\015' ' ' <N1.txt > N2.txt
				tr -s '\012\015' ' ' <L1.txt > L2.txt				
#echo "This awk command does the same this as the tr command above"
				awk '$1=$1' RS= N1.txt > N3.txt
				awk '$1=$1' RS= L1.txt > L3.txt
#cat txt files 1 2 3 4 5 together
				cat N2.txt L2.txt > NL1.txt
				cat 1.txt 2.txt 3.txt A.txt B.txt C.txt > NL1-5.txt
# --------------------------------------------------
 awk -v OFS='\t' '$1=$1 {print 1,$2,$3,$4,$5,$6 "\n" $7,$8,$9,$10,$11,$12 "\n" $13,$14,$15,$16,$17,$18 "\n" $19,$20,$21,$22,$23,$24 }' RS= NL1.txt > NL2.txt
 awk -v OFS='\t' '$1=$1 {print 1,$2,$3,$4,$5,$6 "\n" $7,$8,$9,$10,$11,$12 "\n" $13,$14,$15,$16,$17,$18 "\n" $19,$20,$21,$22,$23,$24 }' RS= NL1-5.txt > NL2-5.txt
